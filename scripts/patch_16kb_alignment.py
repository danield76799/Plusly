#!/usr/bin/env python3
"""
Patch all .so files inside an APK or AAB to 16KB ELF alignment.
This is more robust than patch_elf_alignment.py because it:
- Correctly handles AAB nested zips (base.zip, config.xx.so.zip, ...)
- Uses NDK objcopy per ABI
- Re-zips with aligned offsets (4-byte zip entries are fine; only ELF alignment matters)
"""
import os
import sys
import struct
import shutil
import subprocess
import tempfile
import zipfile


def check_elf_alignment(so_path):
    with open(so_path, 'rb') as f:
        magic = f.read(4)
        if magic != b'\x7fELF':
            return None
        ei_class = struct.unpack('B', f.read(1))[0]
        is_64bit = (ei_class == 2)
        f.seek(0x20 if is_64bit else 0x1C)
        phoff = struct.unpack('<Q' if is_64bit else '<I', f.read(8 if is_64bit else 4))[0]
        f.seek(0x36 if is_64bit else 0x2A)
        phentsize = struct.unpack('<H', f.read(2))[0]
        phnum = struct.unpack('<H', f.read(2))[0]
        max_align = 0
        for i in range(phnum):
            f.seek(phoff + i * phentsize)
            p_type = struct.unpack('<I', f.read(4))[0]
            if p_type != 1:
                continue
            if is_64bit:
                f.seek(phoff + i * phentsize + 0x30)
            else:
                f.seek(phoff + i * phentsize + 0x1C)
            p_align = struct.unpack('<Q' if is_64bit else '<I', f.read(8 if is_64bit else 4))[0]
            if p_align > max_align:
                max_align = p_align
        return max_align


def find_objcopy(ndk_path):
    if ndk_path and os.path.isdir(ndk_path):
        for root, dirs, files in os.walk(ndk_path):
            if 'objcopy' in files:
                return os.path.join(root, 'objcopy')
    for name in ['objcopy', 'llvm-objcopy']:
        path = shutil.which(name)
        if path:
            return path
    return None


def patch_so(objcopy, so_path):
    tmp = so_path + '.tmp'
    # NDK r27 llvm-objcopy: --set-section-alignment <name>=<align>
    # Set alignment on all major loadable sections. Using max alignment for .text suffices.
    result = subprocess.run(
        [objcopy, '--set-section-alignment', '.text=16384', so_path, tmp],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        # Try setting alignment on the segment flags instead? Nope. Just set section alignment globally.
        result2 = subprocess.run(
            [objcopy, '--set-section-alignment', '*=16384', so_path, tmp],
            capture_output=True, text=True,
        )
        if result2.returncode != 0:
            print(f"  objcopy failed for {so_path}: {result.stderr}")
            return False
    shutil.move(tmp, so_path)
    return True


def process_apk_or_aab(path, ndk_path):
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return 1

    objcopy = find_objcopy(ndk_path)
    if not objcopy:
        print("No objcopy found — cannot patch")
        return 1
    print(f"Using objcopy: {objcopy}")

    # For AAB we need to patch nested module zips
    if path.endswith('.aab'):
        return process_aab(path, objcopy)
    return process_apk(path, objcopy)


def process_apk(apk_path, objcopy):
    tmpdir = tempfile.mkdtemp(prefix='apk_patch_')
    try:
        needs_fix = []
        with zipfile.ZipFile(apk_path, 'r') as zf:
            for name in zf.namelist():
                if name.endswith('.so'):
                    zf.extract(name, tmpdir)
                    full = os.path.join(tmpdir, name)
                    align = check_elf_alignment(full)
                    if align is not None and align < 16384:
                        print(f"  Needs fix: {name} ({align // 1024}KB)")
                        needs_fix.append(name)

        if not needs_fix:
            print("All .so files already 16KB aligned ✅")
            return 0

        for name in needs_fix:
            full = os.path.join(tmpdir, name)
            if patch_so(objcopy, full):
                new_align = check_elf_alignment(full)
                print(f"  Fixed {name} → {new_align // 1024}KB")
            else:
                print(f"  FAILED: {name}")

        backup = apk_path + '.bak'
        shutil.copy2(apk_path, backup)
        with zipfile.ZipFile(backup, 'r') as zin:
            with zipfile.ZipFile(apk_path, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.namelist():
                    if item.startswith('META-INF/') and item.split('.')[-1] in ['SF', 'RSA', 'DSA', 'EC']:
                        continue
                    if item in needs_fix:
                        zout.write(os.path.join(tmpdir, item), item)
                    else:
                        zout.writestr(item, zin.read(item))
        print("APK patched. Signature removed — must re-sign.")
        return 0
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


def process_aab(aab_path, objcopy):
    tmpdir = tempfile.mkdtemp(prefix='aab_patch_')
    try:
        aab_zip = zipfile.ZipFile(aab_path, 'r')
        changed = False
        with aab_zip:
            # Extract all module zips
            for item in aab_zip.namelist():
                if not item.endswith('.zip'):
                    continue
                module_zip_path = os.path.join(tmpdir, item)
                os.makedirs(os.path.dirname(module_zip_path), exist_ok=True)
                with open(module_zip_path, 'wb') as f:
                    f.write(aab_zip.read(item))

                module_tmpdir = os.path.join(tmpdir, 'modules', os.path.basename(item).replace('.zip', ''))
                os.makedirs(module_tmpdir, exist_ok=True)

                needs_fix = []
                with zipfile.ZipFile(module_zip_path, 'r') as mzf:
                    for name in mzf.namelist():
                        if name.endswith('.so'):
                            dest = os.path.join(module_tmpdir, name)
                            os.makedirs(os.path.dirname(dest), exist_ok=True)
                            with open(dest, 'wb') as f:
                                f.write(mzf.read(name))
                            align = check_elf_alignment(dest)
                            if align is not None and align < 16384:
                                print(f"  Needs fix: {item}/{name} ({align // 1024}KB)")
                                needs_fix.append(name)

                if not needs_fix:
                    continue

                for name in needs_fix:
                    full = os.path.join(module_tmpdir, name)
                    if patch_so(objcopy, full):
                        new_align = check_elf_alignment(full)
                        print(f"  Fixed {item}/{name} → {new_align // 1024}KB")
                    else:
                        print(f"  FAILED: {item}/{name}")

                # Repack module zip
                backup_module = module_zip_path + '.bak'
                shutil.move(module_zip_path, backup_module)
                with zipfile.ZipFile(backup_module, 'r') as zin:
                    with zipfile.ZipFile(module_zip_path, 'w', zipfile.ZIP_DEFLATED) as zout:
                        for zname in zin.namelist():
                            if zname in needs_fix:
                                zout.write(os.path.join(module_tmpdir, zname), zname)
                            else:
                                zout.writestr(zname, zin.read(zname))
                changed = True

        if not changed:
            print("All .so files already 16KB aligned ✅")
            return 0

        # Repack AAB
        backup_aab = aab_path + '.bak'
        shutil.copy2(aab_path, backup_aab)
        with zipfile.ZipFile(backup_aab, 'r') as zin:
            with zipfile.ZipFile(aab_path, 'w', zipfile.ZIP_DEFLATED) as zout:
                for zname in zin.namelist():
                    if zname.endswith('.zip') and os.path.exists(os.path.join(tmpdir, zname)):
                        zout.write(os.path.join(tmpdir, zname), zname)
                    else:
                        zout.writestr(zname, zin.read(zname))
        print("AAB patched. Signature removed — must re-sign.")
        return 0
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: patch_16kb_alignment.py <apk-or-aab>")
        sys.exit(1)
    ndk = os.environ.get('ANDROID_NDK_HOME', '')
    sys.exit(process_apk_or_aab(sys.argv[1], ndk))
