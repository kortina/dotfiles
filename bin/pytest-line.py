#!/usr/bin/env python3
import ast
import sys
import subprocess


def main():
    # Get the file path and line number from the command-line arguments
    file_path, line_num = sys.argv[1].split(":")
    line_num = int(line_num)

    with open(file_path, "r") as f:
        source = f.read()

    parsed = ast.parse(source)

    test_name = None
    for node in parsed.body:
        if isinstance(node, ast.FunctionDef):
            if line_num >= node.lineno and line_num <= node.end_lineno:
                test_name = node.name
                break

    print(test_name)

    # Run the test using pytest
    cmd = ["pytest", file_path, "-k", test_name, "-vv"]
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Test failed with exit code {e.returncode}")
    else:
        print("Test passed")


if __name__ == "__main__":
    main()
