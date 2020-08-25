#!/usr/bin/env python3
import argparse
import frontmatter
import re
import subprocess


def main():
    parser = argparse.ArgumentParser("python analyze.py")
    parser.add_argument(
        "post_file", nargs=1, type=str, help="post file", default=None,
    )
    args = parser.parse_args()
    old_filename = args.post_file[0]
    reg = r"^(\d{4}-\d{2}-\d{2})-(.*)$"
    m = re.match(reg, old_filename)
    if not m:
        print("No date in filename")
        return
    dt = m[1]
    new_filename = m[2]
    cmd_args = ["git", "mv", old_filename, new_filename]
    cmd = " ".join(cmd_args)
    print(f"running {cmd}")
    subprocess.run(cmd_args)

    print(f"reading from {new_filename}")
    with open(new_filename) as f:
        post = frontmatter.load(f)
        post.metadata["date"] = dt
        new_content = frontmatter.dumps(post)

    print(f"writing to {new_filename}")
    with open(new_filename, "w") as w:
        w.write(new_content)


if __name__ == "__main__":
    main()
