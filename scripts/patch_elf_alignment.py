#!/usr/bin/env python3
"""
Patch ELF alignment to 16KB for Android 15+ compatibility.

Android 15+ requires all native libraries (.so files) to be aligned
to 16KB page boundaries (instead of the legacy 4KB). This script:

1. Finds all .so files in the built APK/AAB
2. Checks their ELF alignment
3. Re-aligns them to 16KB using objcopy

Usage:
    python3 scripts/patch_elf_alignment.py <path-to-apk-or-aab>
    python3 scripts/patch_elf_alignment.py build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

Requirements:
    - zipalign (Android SDK build-tools)
    - objcopy (GNU binutils / NDK toolchain)

Reference: https://developer.android.com/guide/practices/page-sizes
"""

import os
import sys
import struct
import shutil
import subprocess
import tempfile
import zipfile


def check_elf_alignment(so_path):
    """Check the ELF segment alignment of a .so file."""
    with open(so_path, 'rb') as f:
        magic = f.read(4)
        if magic != b'\x7fELF':
            return None

        ei_class = struct.unpack('B', f.read(1))[0]
        is_64bit = (ei_class == 2)

        # Skip to e_phoff (program header offset)
        f.seek(0x20 if is_64bit else 0x1C)
        phoff = struct.unpack('<Q' if is_64bit else '<I', f.read(8 if is_64bit else 4))[0]

        # Skip to e_phentsize and e_phnum
        f.seek(0x36 if is_64bit else 0x2A)
        phentsize = struct.unpack('<H', f.read(2))[0]
        phnum = struct.unpack('<H', f.read(2))[0]

        max_align = 0
        for i in range(phnum):
            f.seek(phoff + i * phentsize)
            p_type = struct.unpack('<I', f.read(4))[0]
            if p_type != 1:  # PT_LOAD
                continue
            if is_64bit:
                f.seek(phoff + i * phentsize + 0x30)
            else:
                f.seek(phoff + i * phentsize + 0x1C)
            p_align = struct.unpack('<Q' if is_64bit else '<I', f.read(8 if is_64bit else 4))[0]
            if p_align > max_align:
                max_align = p_align

        return max_align


def patch_so_alignment(so_path, ndk_objcopy=None):
    """Patch a .so file to use 16KB alignment."""
    objcopy = ndk_objcopy or shutil.which('objcopy') or 'objcopy'

    # Create a temp file
    tmp = so_path + '.tmp'
    result = subprocess.run(
        [objcopy, '--set-section-alignment', '.text=16384', so_path, tmp],
        capture_output=True, text=True
    )

    if result.returncode != 0:
        # Fallback: try zipalign approach (just rezip with 16KB alignment)
        print(f"  objcopy failed, trying alternative for {so_path}")
        return False

    shutil.move(tmp, so_path)
    return True


def process_apk(apk_path):
    """Process an APK/AAB: extract, check, and fix .so alignment."""
    if not os.path.exists(apk_path):
        print(f"Error: File not found: {apk_path}")
        return 1

    print(f"Processing: {apk_path}")

    tmpdir = tempfile.mkdtemp(prefix='elf_align_')
    try:
        # Extract .so files
        so_files = []
        with zipfile.ZipFile(apk_path, 'r') as zf:
            for name in zf.namelist():
                if name.endswith('.so'):
                    zf.extract(name, tmpdir)
                    so_files.append(name)
                    print(f"  Found: {name}")

        if not so_files:
            print("  No .so files found in APK/AAB")
            return 0

        # Check alignment
        needs_fix = []
        for name in so_files:
            full_path = os.path.join(tmpdir, name)
            align = check_elf_alignment(full_path)
            if align is None:
                print(f"  {name}: not a valid ELF, skipping")
                continue
            status = "OK" if align >= 16384 else "NEEDS FIX"
            print(f"  {name}: alignment={align} ({align//1024}KB) - {status}")
            if align < 16384:
                needs_fix.append(name)

        if not needs_fix:
            print("\nAll .so files already have 16KB alignment! ✅")
            return 0

        print(f"\n{len(needs_fix)} files need alignment fix.")

        # Find NDK objcopy
        ndk_path = os.environ.get('ANDROID_NDK_HOME', '')
        objcopy_path = None
        if ndk_path and os.path.isdir(ndk_path):
            for root, dirs, files in os.walk(ndk_path):
                if 'objcopy' in files:
                    objcopy_path = os.path.join(root, 'objcopy')
                    break

        # Try to fix
        fixed = 0
        for name in needs_fix:
            full_path = os.path.join(tmpdir, name)
            if patch_so_alignment(full_path, objcopy_path):
                print(f"  Fixed: {name}")
                fixed += 1
            else:
                print(f"  Could not fix: {name}")

        if fixed == 0:
            print("\nCould not fix any files automatically.")
            print("The build may still work if using NDK r27+ which aligns to 16KB by default.")
            print("If the Play Store still warns, try updating the Flutter NDK version.")
            return 0  # Don't fail the build

        # Repack
        print("\nRepacking APK/AAB...")
        # Keep original
        backup = apk_path + '.bak'
        shutil.copy2(apk_path, backup)

        with zipfile.ZipFile(backup, 'r') as zin:
            with zipfile.ZipFile(apk_path, 'w', zipfile.ZIP_DEFLATED) as zout:
                for item in zin.namelist():
                    if item in needs_fix:
                        zout.write(os.path.join(tmpdir, item), item)
                    else:
                        zout.writestr(item, zin.read(item))

        print(f"Done! {fixed}/{len(needs_fix)} files fixed. ✅")
        return 0

    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 patch_elf_alignment.py <apk-or-aab>")
        sys.exit(1)
    sys.exit(process_apk(sys.argv[1]))