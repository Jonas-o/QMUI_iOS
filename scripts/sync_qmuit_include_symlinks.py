#!/usr/bin/env python3
# 将 QMUICore / QMUIMainFrame / QMUIComponents / UIKitExtensions 下所有 .h
# 以 basename 为文件名，符号链接到 include/QMUIKit/，与 QMUIKit.h（umbrella）同目录。
# 供 SPM 下 umbrella 里 __has_include("Foo.h") 在消费端能解析。
# 勿放在 include/ 根目录，否则 SwiftPM 会报 umbrella 冲突。
import os
import re

ROOT = os.path.join(os.path.dirname(__file__), "..", "QMUIKit")
ROOT = os.path.normpath(ROOT)
DEST = os.path.join(ROOT, "include", "QMUIKit")
UMBRELLA_HEADER = os.path.join(DEST, "QMUIKit.h")
SOURCE_DIRS = ["QMUICore", "QMUIMainFrame", "QMUIComponents", "UIKitExtensions"]


def parse_umbrella_allowed_headers(path):
    allowed = set()
    pattern = re.compile(r'__has_include\("([^"]+\.h)"\)')
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            m = pattern.search(line)
            if m:
                allowed.add(m.group(1))
    return allowed


def main():
    allowed_headers = parse_umbrella_allowed_headers(UMBRELLA_HEADER)
    headers = []
    for d in SOURCE_DIRS:
        base = os.path.join(ROOT, d)
        for dirpath, _, files in os.walk(base):
            for f in files:
                if f.endswith(".h"):
                    headers.append(os.path.join(dirpath, f))

    desired_names = set()
    for src in sorted(headers):
        name = os.path.basename(src)
        if name == "QMUIKit.h" or name not in allowed_headers:
            continue
        desired_names.add(name)
        dst = os.path.join(DEST, name)
        rel = os.path.relpath(src, DEST)
        if os.path.lexists(dst):
            if os.path.islink(dst) and os.readlink(dst) == rel:
                continue
            os.remove(dst)
        os.symlink(rel, dst)

    removed = 0
    for name in os.listdir(DEST):
        if not name.endswith(".h") or name == "QMUIKit.h":
            continue
        if name not in desired_names:
            os.remove(os.path.join(DEST, name))
            removed += 1

    print("synced", len(desired_names), "header symlinks into", DEST, "removed", removed)


if __name__ == "__main__":
    main()
