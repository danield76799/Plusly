#!/usr/bin/env python3
"""
Patch ELF .so alignment to 16KB inside APK or AAB archives.

For APKs:
  .so files live at lib/<abi>/lib*.so

For AABs:
  .so files live inside module directories, e.g.
  base/lib/arm64-v8a/lib*.so
  config.arm64_v8a/lib/arm64-v8a/lib*.so

Usage:
  python3 scripts/patch_elf_16kb.py <apk-or-aab>

Requires ANDROID_NDK_HOME to point at an NDK r27+ checkout.
"""

import os
import shutil
import struct
import subprocess
import sys
import tempfile
import zipfile


def check_elf_alignment(path):
    """Return max PT_LOAD alignment of an ELF file, or None if not ELF."""
    with open(path, 'rb') as f:
        magic = f.read(4)
        if magic != b'\x7fELF':
            return None
        ei_class = struct.unpack('B', f.read(1))[0]
        is_64bit = ei_class == 2
        f.seek(0x20 if is_64bit else 0x1C)
        phoff_fmt = '<Q' if is_64bit else '<I'
        phoff_size = 8 if is_64bit else 4
        phoff = struct.unpack(phoff_fmt, f.read(phoff_size))[0]
        f.seek(0x36 if is_64bit else 0x2A)
        phentsize = struct.unpack('<H', f.read(2))[0]
        phnum = struct.unpack('<H', f.read(2))[0]
        max_align = 0
        for i in range(phnum):
            f.seek(phoff + i * phentsize)
            p_type = struct.unpack('<I', f.read(4))[0]
            if p_type != 1:  # PT_LOAD
                continue
            align_off = 0x30 if is_64bit else 0x1C
            f.seek(phoff + i * phentsize + align_off)
            p_align = struct.unpack(phoff_fmt, f.read(phoff_size))[0]
            if p_align > max_align:
                max_align = p_align
        return max_align


def find_objcopy():
    ndk = os.environ.get('ANDROID_NDK_HOME') or os.environ.get('ANDROID_NDK_ROOT')
    if ndk and os.path.isdir(ndk):
        candidates = []
        for root, dirs, files in os.walk(ndk):
            for f in files:
                if f == 'llvm-objcopy' or f == 'objcopy':
                    candidates.append(os.path.join(root, f))
        # Prefer llvm-objcopy from NDK toolchain
        for c in candidates:
            if 'llvm-objcopy' in c:
                return c
        if candidates:
            return candidates[0]
    # fallback
    return shutil.which('llvm-objcopy') or shutil.which('objcopy')


def patch_so(objcopy, path):
    tmp = path + '.tmp'
    # Method 1: align PT_LOAD segments using --set-section-alignment on .text.
    # This doesn't always update program headers, so we also try a direct hack.
    result = subprocess.run(
        [objcopy, '--set-section-alignment', '.text=16384', path, tmp],
        capture_output=True, text=True,
    )
    if result.returncode != 0 or check_elf_alignment(tmp) < 16384:
        # Method 2: use the NDK's llvm-objcopy to set alignment globally.
        result2 = subprocess.run(
            [objcopy, '--set-section-alignment', '*=16384', path, tmp],
            capture_output=True, text=True,
        )
        if result2.returncode != 0 or check_elf_alignment(tmp) < 16384:
            # Method 3: direct ELF program header modification.
            if not direct_patch_elf(path, tmp):
                if os.path.exists(tmp):
                    os.unlink(tmp)
                return False
    shutil.move(tmp, path)
    return True


def direct_patch_elf(src, dst):
    """Directly set all PT_LOAD p_align to 16384."""
    try:
        with open(src, 'rb') as f:
            data = bytearray(f.read())
        ei_class = data[4]
        is_64bit = ei_class == 2
        phoff_off = 0x20 if is_64bit else 0x1C
        phoff_size = 8 if is_64bit else 4
        phoff = int.from_bytes(data[phoff_off:phoff_off + phoff_size], 'little')
        phentsize_off = 0x36 if is_64bit else 0x2A
        phentsize = int.from_bytes(data[phentsize_off:phentsize_off + 2], 'little')
        phnum = int.from_bytes(data[phentsize_off + 2:phentsize_off + 4], 'little')
        align_off_in_phdr = 0x30 if is_64bit else 0x1C
        for i in range(phnum):
            p_type_off = phoff + i * phentsize
            p_type = int.from_bytes(data[p_type_off:p_type_off + 4], 'little')
            if p_type != 1:  # PT_LOAD
                continue
            p_align_off = p_type_off + align_off_in_phdr
            data[p_align_off:p_align_off + phoff_size] = (16384).to_bytes(phoff_size, 'little')
        with open(dst, 'wb') as f:
            f.write(data)
        return check_elf_alignment(dst) >= 16384
    except Exception as e:
        print(f"  direct_patch failed: {e}")
        return False


def repack_archive(src_path, dst_path, so_patches):
    """Repack zip archive replacing patched .so files and stripping signatures."""
    with zipfile.ZipFile(src_path, 'r') as zin:
        with zipfile.ZipFile(dst_path, 'w', zipfile.ZIP_DEFLATED) as zout:
            for item in zin.namelist():
                # Strip old signatures — invalid after modifying contents
                if item.startswith('META-INF/') and item.split('.')[-1] in ('SF', 'RSA', 'DSA', 'EC'):
                    continue
                if item in so_patches:
                    zout.write(so_patches[item], item)
                else:
                    zout.writestr(item, zin.read(item))


def process_archive(path):
    objcopy = find_objcopy()
    if not objcopy:
        print("ERROR: no objcopy/ANDROID_NDK_HOME found")
        return 1
    print(f"Using objcopy: {objcopy}")

    tmpdir = tempfile.mkdtemp(prefix='elf16kb_')
    try:
        so_files = []
        needs_fix = []
        with zipfile.ZipFile(path, 'r') as zf:
            for name in zf.namelist():
                if name.endswith('.so'):
                    dest = os.path.join(tmpdir, name)
                    os.makedirs(os.path.dirname(dest), exist_ok=True)
                    with open(dest, 'wb') as f:
                        f.write(zf.read(name))
                    align = check_elf_alignment(dest)
                    status = 'OK' if (align and align >= 16384) else 'NEEDS FIX'
                    kb = (align // 1024) if align else '?'
                    print(f"  {name}: {kb}KB - {status}")
                    so_files.append(name)
                    if align and align < 16384:
                        needs_fix.append(name)

        if not needs_fix:
            print("No .so files need fixing.")
            return 0

        fixed = 0
        so_patches = {}
        for name in needs_fix:
            full = os.path.join(tmpdir, name)
            if patch_so(objcopy, full):
                new_align = check_elf_alignment(full)
                print(f"  Fixed {name} -> {new_align // 1024}KB")
                so_patches[name] = full
                fixed += 1
            else:
                print(f"  FAILED to fix {name}")

        if fixed == 0:
            print("ERROR: could not fix any .so file")
            return 1

        backup = path + '.bak'
        shutil.copy2(path, backup)
        repack_archive(backup, path, so_patches)
        print(f"Repacked {path}: {fixed}/{len(needs_fix)} .so files patched")
        return 0
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: patch_elf_16kb.py <apk-or-aab>")
        sys.exit(1)
    sys.exit(process_archive(sys.argv[1]))
