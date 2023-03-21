#!/usr/bin/env python3
# This is a light wrapper around https://github.com/ttscoff/gather-cli
# It does not overwrite the file if it already exists.
# And it appends the current date / time of download as a comment to the end of the file.
import argparse
import datetime
import os
import re
import subprocess

HOME = os.environ.get("HOME")


class Settings:
    DEBUG = False
    GATHER_DIR = f"{HOME}/x/_gather/"


def run(cmd: list[str]) -> str:
    _cmd = " ".join(cmd)
    if Settings.DEBUG:
        print("------------")
        print("running:")
        print(_cmd)
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 1:
        print(f"[ERROR]: {_cmd}")
        print(result.stdout)
        raise SystemExit
    if Settings.DEBUG:
        print(result.stdout)
    return result.stdout


def main():
    parser = argparse.ArgumentParser(
        description="""Download and save markdown for the URL in the clipboard using gather.
    """
    )
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()
    Settings.debug = args.verbose

    filename = "%slug.md"
    tmp_path = f"{HOME}/tmp/{filename}"
    final_dir = Settings.GATHER_DIR

    cmd = ["gather", "-p", "--metadata-yaml", "-f", tmp_path]
    out = run(cmd)

    # grab the actual tmp_path since filename uses %s
    m = re.search(r"Saved to file: ([\S]+)$", out)
    fn = None
    if m:
        tmp_path = m.group(1)
        # grab the actual markdown filename off th tmp_path since filename uses %s
        fn = re.search(r"([^\/]+$)", tmp_path).group(1)
        # only move to final destination if target file does not already exist
        cmd = ["mv", "-n", tmp_path, final_dir]
        run(cmd)
    else:
        print("[ERROR] No tmp file........")
        raise SystemExit(1)

    # cleanup tmp file
    if os.path.exists(tmp_path):
        os.remove(tmp_path)

    # append downloaded date as comment to end of file
    dt = datetime.datetime.now().strftime("%Y-%m-%d--%H-%M")
    msg = f"\n<!-- download-dt: {dt} -->"
    final_path = os.path.join(final_dir, fn)
    with open(final_path, "a") as f:
        f.write(msg)

    print(fn)
    cmd = ["code", final_path]
    run(cmd)


if __name__ == "__main__":
    main()
