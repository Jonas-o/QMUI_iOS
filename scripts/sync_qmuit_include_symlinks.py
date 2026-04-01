#!/usr/bin/env python3
# 将 QMUICore / QMUIMainFrame / QMUIComponents / UIKitExtensions 下所有 .h
# 以 basename 为文件名，符号链接到 include/QMUIKit/，与 QMUIKit.h（umbrella）同目录。
# 供 SPM 下 umbrella 里 __has_include("Foo.h") 在消费端能解析。
# 勿放在 include/ 根目录，否则 SwiftPM 会报 umbrella 冲突。
import os

ROOT = os.path.join(os.path.dirname(__file__), "..", "QMUIKit")
ROOT = os.path.normpath(ROOT)
DEST = os.path.join(ROOT, "include", "QMUIKit")
SOURCE_DIRS = ["QMUICore", "QMUIMainFrame", "QMUIComponents", "UIKitExtensions"]


def main():
    headers = []
    for d in SOURCE_DIRS:
        base = os.path.join(ROOT, d)
        for dirpath, _, files in os.walk(base):
            for f in files:
                if f.endswith(".h"):
                    headers.append(os.path.join(dirpath, f))

    for src in sorted(headers):
        name = os.path.basename(src)
        if name == "QMUIKit.h":
            continue
        dst = os.path.join(DEST, name)
        rel = os.path.relpath(src, DEST)
        if os.path.lexists(dst):
            if os.path.islink(dst) and os.readlink(dst) == rel:
                continue
            os.remove(dst)
        os.symlink(rel, dst)
    print("synced", len(headers) - 1, "header symlinks into", DEST)


if __name__ == "__main__":
    main()
