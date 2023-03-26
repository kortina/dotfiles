#!/usr/bin/env python3
import a


TEST_MARKDOWN = """
# Title of Chat

_S_:
You are my kind and helpful assistant.

_U_:
Question asked by user.

_A_:
Response to user.

_U_:
Message 2 from user.

_A_:
Response 2 to user"""

TEST_DICT = {
    "title": "Title of Chat",
    "messages": [
        {"role": "system", "content": "You are my kind and helpful assistant."},
        {"role": "user", "content": "Question asked by user."},
        {"role": "assistant", "content": "Response to user."},
        {"role": "user", "content": "Message 2 from user."},
        {"role": "assistant", "content": "Response 2 to user"},
    ],
}


def test_parse_markdown():
    assert a._parse_markdown(TEST_MARKDOWN) == TEST_DICT


def test_to_markdown():
    assert (
        a._to_markdown(TEST_DICT["title"], TEST_DICT["messages"])
        == TEST_MARKDOWN.strip()
    )
