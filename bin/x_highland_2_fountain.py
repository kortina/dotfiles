#!/usr/bin/env python3
import argparse
import filecmp
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
        description="""Given a file, such as,
            my_screenplay.highland
        extract the plaintext fountain file to:
            my_screenplay.highland.x.fountain
        By default, sets filemode to readonly, 0444.
    """
    )
    parser.add_argument(
        "--no-readonly",
        dest="no_readonly",
        action="store_true",
        help="Set file to readonly 0444 by default. Set --no-readonly to skip.",
        default=1,
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
        help="input file",
        default=None,
    )
    parser.add_argument(
        "--output",
        type=str,
        help="output file",
        default=None,
    )
    args = parser.parse_args()
    f_highland = args.file

    if args.debug:
        Settings.debug = True

    if not os.path.isfile(f_highland):
        parser.error(f"file '{args.file}' does not exist.")
    if not re.search(r"\.highland$", f_highland):
        parser.error(f"file {args.file}' does not appear to be a .highland file.")

    base_highland = os.path.basename(f_highland)
    abs_f_highland = os.path.abspath(f_highland)
    abs_dir_highland = os.path.dirname(abs_f_highland)

    abs_dir_tmp = "/tmp/highland"
    if not os.path.isdir(abs_dir_tmp):
        # make the /tmp/highland directory if nec
        os.makedirs(abs_dir_tmp)

    f_tmp_highland = os.path.join(abs_dir_tmp, base_highland)

    print(f"f_tmp_highland: {f_tmp_highland}")
    # remove .highland in /tmp/highland
    if os.path.exists(f_tmp_highland):
        os.remove(f_tmp_highland)

    # copy highland file to tmp
    cmd_args = ["cp", abs_f_highland, f_tmp_highland]
    run_cmd(cmd_args)

    # get path to textbundle
    f_textbundle = re.sub(r"(\.highland)", ".textbundle", base_highland)

    # remove .textbundle in /tmp/highland
    if os.path.exists(f_textbundle):
        shutil.rmtree(f_textbundle)

    # get path to fountain in textbundle
    abs_f_txt = os.path.join(abs_dir_tmp, f_textbundle, "text.fountain")
    # unzip in tmp
    cmd_args = ["unzip", "-qo", f_tmp_highland, "-d", abs_dir_tmp]
    run_cmd(cmd_args)

    # get path to new x.fountain
    if args.output:
        abs_f_fountain = args.output
    else:
        f_fountain = f"{base_highland}.x.fountain"
        abs_f_fountain = os.path.join(abs_dir_highland, f_fountain)

    # if x.fountain exists
    if os.path.isfile(abs_f_fountain):
        # exit if there is no diff
        if filecmp.cmp(abs_f_txt, abs_f_fountain):
            if Settings.debug:
                print(f"No change: {abs_f_fountain}")
            return

        # make sure the target is not read-only, so we can overwrite it
        cmd_args = ["chmod", "0644", abs_f_fountain]
        run_cmd(cmd_args)

    # copy the plaintext file to original directory
    cmd_args = ["cp", abs_f_txt, abs_f_fountain]
    run_cmd(cmd_args)

    # set file readonly
    if not args.no_readonly:
        cmd_args = ["chmod", "0444", abs_f_fountain]
        run_cmd(cmd_args)


if __name__ == "__main__":
    main()
