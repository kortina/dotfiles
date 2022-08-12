#!/usr/bin/env python3
import argparse
import os
import re
import subprocess
import tinify


class Settings:
    debug = False


def run_cmd(cmd_args: list, cwd=None):
    cmd = " ".join(cmd_args)
    if Settings.debug:
        print(f"running:\n{cmd}")
    subprocess.run(cmd_args, check=True, cwd=cwd)


def main():
    parser = argparse.ArgumentParser(
        description="""Given an image file, such as,
            img.png
        convert to jpg and make tiny:
            img.tiny.jpg
    """
    )
    parser.add_argument(
        "--debug",
        dest="debug",
        action="store_true",
        help="Set debug mode output.",
    )
    parser.add_argument(
        "--keep-original",
        dest="keep",
        action="store_true",
        help="Do not delete original file.",
    )
    parser.add_argument(
        "file",
        type=str,
        help="input img file",
        default=None,
    )
    args = parser.parse_args()
    f_source = args.file
    is_jpg = False
    rx_jpg = re.compile(r"\.(jpg|jpeg)$", re.I)

    if args.debug:
        Settings.debug = True

    if not os.path.isfile(f_source):
        parser.error(f"file '{args.file}' does not exist.")

    is_jpg = True if re.search(rx_jpg, f_source) else False

    if re.search(r"\.tiny\.jpg$", f_source):
        print(f"already tiny: {args.file}")
        return

    source_fn = os.path.basename(f_source)

    source_abs_path = os.path.abspath(f_source)
    cwd = os.path.dirname(source_abs_path)

    no_ext_fn = re.sub(r"(\.[^\.]+)$", "", source_fn)
    # jpg_fn = f"{no_ext_fn}.jpg"
    jpg_abs_path = os.path.join(cwd, f"{no_ext_fn}.jpg")
    tiny_abs_path = os.path.join(cwd, f"{no_ext_fn}.tiny.jpg")

    if not is_jpg and not os.path.isfile(jpg_abs_path):
        print(f"convert to jpg: {source_fn}")
        # convert to jpg with imagemagick
        cmd_args = ["convert", source_fn, jpg_abs_path]
        run_cmd(cmd_args, cwd)
        source_fn = jpg_abs_path

    if os.path.isfile(tiny_abs_path):
        print(f"already exists: {tiny_abs_path}")
        return

    tinify.key = os.environ.get("TINY_JPG_API_KEY")
    print(f"tinify: {source_fn}")
    source = tinify.from_file(source_fn)
    source.to_file(tiny_abs_path)

    if not args.keep:
        if os.path.isfile(tiny_abs_path):
            print(f"rm: {args.file}")
            os.remove(args.file)
        else:
            print(f"ERROR, no tiny file: {tiny_abs_path}")


if __name__ == "__main__":
    main()
