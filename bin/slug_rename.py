#!/usr/bin/env python3
import argparse
import os
import re
import shutil
import subprocess


class Settings:
    debug = False


def run_cmd(cmd_args: list):
    cmd = " ".join(cmd_args)
    if Settings.debug:
        print(f"running:\n{cmd}")
    subprocess.run(cmd_args, check=True)


def main():
    parser = argparse.ArgumentParser(
        description="""Slugify rename a file (replace all special chars with hyphens) """
    )
    parser.add_argument(
        "--debug",
        dest="debug",
        action="store_true",
        help="Set debug mode output.",
    )
    parser.add_argument(
        "file",
        type=str,
        help="file to rename",
        default=None,
    )
    args = parser.parse_args()
    orig = args.file

    if args.debug:
        Settings.debug = True

    if not os.path.exists(orig):
        parser.error(f"file/dir '{args.file}' does not exist.")

    orig_base = os.path.basename(orig)
    orig_abs = os.path.abspath(orig)
    orig_abs_dir = os.path.dirname(orig_abs)
    orig_name, orig_ext = os.path.splitext(orig_base)
    slug_name = re.sub(r"[^a-zA-Z0-9]+", "-", orig_name).strip("-")
    new_name = f"{slug_name}{orig_ext}"
    new_abs = os.path.join(orig_abs_dir, new_name)

    print(f'mv "{orig_abs}" "{new_abs}"')
    shutil.move(orig_abs, new_abs)


if __name__ == "__main__":
    main()
