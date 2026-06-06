#!/usr/bin/env python3
"""
Patch ELF LOAD segment alignment to 16KB (0x4000) for Android 15+/17 compatibility.

This fixes third-party .so files that were compiled with 4KB page size alignment
but are loaded on devices using 16KB page size (Pixel 9 Pro, etc.).

Usage:
    python3 patch_elf_alignment.py <path-to-apk-or-aab>
    python3 patch_elf_alignment.py <directory-with-so-files>
"""

import os
import struct
import sys
import zipfile
import tempfile
import shutil
import subprocess
from pathlib import Path


NEW_ALIGN = 0x4000  # 16KB


def parse_elf_header(data: bytes):
    """Parse ELF64 LE header. Returns (e_phoff, e_phentsize, e_phnum) or None."""
    if len(data) < 64:
        return None
    if data[:4] != b'\x7fELF':
        return None
    if data[4] != 2:  # Not 64-bit
        return None
    if data[5] != 1:  # Not little-endian
        return None

    e_phoff = struct.unpack_from('<Q', data, 32)[0]
    e_phentsize = struct.unpack_from('<H', data, 54)[0]
    e_phnum = struct.unpack_from('<H', data, 56)[0]

    return e_phoff, e_phentsize, e_phentsize and e_phnum or 0, e_phnum


def patch_elf_file(so_path: Path) -> tuple[bool, int]:
    """Patch ELF LOAD segment alignment to NEW_ALIGN. Returns (changed, num_patched)."""
    try:
        with open(so_path, 'rb') as f:
            data = bytearray(f.read())
    except Exception as e:
        return False, 0

    if len(data) < 64 or data[:4] != b'\x7fELF':
        return False, 0
    if data[4] != 2 or data[5] != 1:  # Not 64-bit LE
        return False, 0

    e_phoff = struct.unpack_from('<Q', data, 32)[0]
    e_phentsize = struct.unpack_from('<H', data, 54)[0]
    e_phnum = struct.unpack_from('<H', data, 56)[0]

    if e_phentsize != 56:
        return False, 0

    patches = []
    for i in range(e_phnum):
        ph_offset = e_phoff + i * e_phentsize
        if ph_offset + 56 > len(data):
            break
        p_type = struct.unpack_from('<I', data, ph_offset)[0]
        if p_type != 1:  # PT_LOAD
            continue

        p_align_offset = ph_offset + 48
        p_align = struct.unpack_from('<Q', data, p_align_offset)[0]

        if 0 < p_align < NEW_ALIGN:
            patches.append((p_align_offset, p_align))

    if not patches:
        return False, 0

    for offset, old_align in patches:
        struct.pack_into('<Q', data, offset, NEW_ALIGN)

    with open(so_path, 'wb') as f:
        f.write(data)

    return True, len(patches)


def check_elf_file(so_path: Path) -> tuple[bool, int]:
    """Check if ELF has any 4KB-aligned LOAD segments. Returns (has_4kb, count)."""
    try:
        with open(so_path, 'rb') as f:
            data = f.read()
    except Exception:
        return False, 0

    if len(data) < 64 or data[:4] != b'\x7fELF':
        return False, 0
    if data[4] != 2 or data[5] != 1:
        return False, 0

    e_phoff = struct.unpack_from('<Q', data, 32)[0]
    e_phentsize = struct.unpack_from('<H', data, 54)[0]
    e_phnum = struct.unpack_from('<H', data, 56)[0]

    if e_phentsize != 56:
        return False, 0

    count = 0
    for i in range(e_phnum):
        ph_offset = e_phoff + i * e_phentsize
        if ph_offset + 56 > len(data):
            break
        p_type = struct.unpack_from('<I', data, ph_offset)[0]
        if p_type != 1:
            continue
        p_align = struct.unpack_from('<Q', data, ph_offset + 48)[0]
        if 0 < p_align < NEW_ALIGN:
            count += 1

    return count > 0, count


def patch_apk(apk_path: Path) -> bool:
    """Patch all .so files in an APK."""
    print(f"Patching APK: {apk_path}")

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)
        extract_dir = tmpdir / "extract"
        extract_dir.mkdir()

        # Extract
        with zipfile.ZipFile(apk_path, 'r') as z:
            so_files = [n for n in z.namelist() if n.startswith('lib/') and n.endswith('.so')]
            z.extractall(extract_dir, members=so_files)

        # Patch
        patched_count = 0
        for so_path in extract_dir.rglob('*.so'):
            relative = so_path.relative_to(extract_dir)
            changed, num = patch_elf_file(so_path)
            if changed:
                print(f"  ✅ {relative}: patched {num} segment(s)")
                patched_count += 1
            elif check_elf_file(so_path)[0]:
                print(f"  ⚠️  {relative}: has 4KB alignment but patch failed")

        if patched_count == 0:
            print("  No patches needed (all .so files already 16KB-aligned)")
            return True

        # Repack
        output_path = apk_path.with_suffix('.patched.apk')
        print(f"  Writing patched APK to: {output_path}")

        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as z_out:
            # First add all the patched .so files
            for so_path in extract_dir.rglob('*.so'):
                relative = so_path.relative_to(extract_dir)
                z_out.write(so_path, str(relative).replace(os.sep, '/'))

            # Then add everything else from the original APK
            with zipfile.ZipFile(apk_path, 'r') as z_in:
                for item in z_in.namelist():
                    if item.startswith('lib/') and item.endswith('.so'):
                        continue  # Already added
                    z_out.writestr(item, z_in.read(item))

        print(f"  ✅ Patched APK saved: {output_path}")
        return True


def patch_directory(dir_path: Path) -> bool:
    """Patch all .so files in a directory."""
    print(f"Patching directory: {dir_path}")

    patched_count = 0
    for so_path in dir_path.rglob('*.so'):
        relative = so_path.relative_to(dir_path)
        changed, num = patch_elf_file(so_path)
        if changed:
            print(f"  ✅ {relative}: patched {num} segment(s)")
            patched_count += 1

    if patched_count == 0:
        print("  No patches needed")
    else:
        print(f"  ✅ Patched {patched_count} files")

    return True


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <apk-or-aab-file-or-directory>")
        sys.exit(1)

    target = Path(sys.argv[1])

    if not target.exists():
        print(f"Error: {target} does not exist")
        sys.exit(1)

    if target.is_file() and (target.suffix in ('.apk', '.aab')):
        if not patch_apk(target):
            sys.exit(1)
    elif target.is_dir():
        if not patch_directory(target):
            sys.exit(1)
    else:
        print(f"Error: {target} is not an APK/AAB file or directory")
        sys.exit(1)


if __name__ == '__main__':
    main()
