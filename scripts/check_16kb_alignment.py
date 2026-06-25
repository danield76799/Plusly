#!/usr/bin/env python3
"""
Check if all ELF .so files in an APK/AAB are 16KB aligned.
Exits with 1 if any .so is not aligned, so CI can fail fast.
"""
import os
import sys
import struct
import zipfile
import tempfile
import shutil


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


def check_archive(path, prefix=''):
    bad = []
    good = []
    with zipfile.ZipFile(path, 'r') as zf:
        for name in zf.namelist():
            if not name.endswith('.so'):
                continue
            with tempfile.NamedTemporaryFile(delete=False) as tmp:
                tmp.write(zf.read(name))
                tmp_path = tmp.name
            align = check_elf_alignment(tmp_path)
            os.unlink(tmp_path)
            if align is None:
                continue
            status = 'OK' if align >= 16384 else 'FAIL'
            print(f"{prefix}{name}: {align // 1024}KB - {status}")
            if align < 16384:
                bad.append(name)
            else:
                good.append(name)
    return bad, good


def main():
    if len(sys.argv) < 2:
        print("Usage: check_16kb_alignment.py <apk-or-aab>")
        sys.exit(1)
    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"File not found: {path}")
        sys.exit(1)

    all_bad = []
    all_good = []

    if path.endswith('.aab'):
        # AAB contains module zips (base.zip etc.)
        tmpdir = tempfile.mkdtemp(prefix='aab_check_')
        try:
            with zipfile.ZipFile(path, 'r') as aab:
                for item in aab.namelist():
                    if item.endswith('.zip'):
                        module_path = os.path.join(tmpdir, os.path.basename(item))
                        with open(module_path, 'wb') as f:
                            f.write(aab.read(item))
                        bad, good = check_archive(module_path, prefix=f"{item}: ")
                        all_bad.extend([f"{item}/{b}" for b in bad])
                        all_good.extend([f"{item}/{g}" for g in good])
        finally:
            shutil.rmtree(tmpdir, ignore_errors=True)
    else:
        bad, good = check_archive(path)
        all_bad = bad
        all_good = good

    print(f"\nGood: {len(all_good)}, Bad: {len(all_bad)}")
    if all_bad:
        print("BAD files:")
        for f in all_bad:
            print(f"  {f}")
        sys.exit(1)
    print("All .so files are 16KB aligned ✅")
    sys.exit(0)


if __name__ == '__main__':
    main()
