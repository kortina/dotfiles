#!/usr/bin/env python3
import ast
import re
from typing import Any, Optional, Pattern


def _log(msg: str) -> None:
    if True:
        print(msg)
    return ""


class MethodFinder(ast.NodeVisitor):
    def __init__(self, line_to_match, test_pattern=None):
        self.matched_function = None
        self.line_to_match = line_to_match
        self.test_pattern = test_pattern or re.compile("(?:^|[\\b_\\./-])[Tt]est")
        self.function_lines = {}

    def visit_FunctionDef(self, node):
        if self.test_pattern.match(node.name):
            self.current_function = node.name

        self.generic_visit(node)

    def generic_visit(self, node):
        current_line_num = getattr(node, "lineno", -1)
        if self.line_to_match == current_line_num and hasattr(self, "current_function"):
            self.matched_function = self.current_function
        elif current_line_num > 0 and hasattr(self, "current_function"):
            self.function_lines[current_line_num] = self.current_function

        super(MethodFinder, self).generic_visit(node)


def test_at_line(
    test_file: str, linenum: int, test_pattern: Optional[Pattern[Any]] = None
):
    with open(test_file, "r") as f:
        ast_node = ast.parse(f.read())
    finder = MethodFinder(linenum, test_pattern)
    finder.visit(ast_node)
    matched_function = finder.matched_function
    while matched_function is None and linenum > 0:
        linenum -= 1
        matched_function = finder.function_lines.get(linenum)
    return matched_function


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="""Given a test_file:linenum, such as,
        testing/test_assertion.py:73
        return the name of the test at that line:
        `test_rewrite_assertions_pytester_plugin`
    """
    )
    parser.add_argument(
        "file_and_line", type=str, help="file_and_line", default=None,
    )
    args = parser.parse_args()
    test_file, linenum = args.file_and_line.split(":")
    pattern = None
    matched_function = test_at_line(test_file, int(linenum), pattern)
    _log(f"Matched function: {matched_function} at {test_file}:{linenum}")


if __name__ == "__main__":
    main()
