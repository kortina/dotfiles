#!/usr/bin/env python3

import time


def slp():
    time.sleep(0.05)


def slp_print(s: str):
    for c in s:
        print(c, end="", flush=True)
        slp()
    print()


def deeptruth():
    s = """................................"""
    s2 = """...... DEEPFAKE DETECTED! ......
...... CONFIDENCE: 99.5%  ......
................................"""
    slp_print(s)
    print(s2)


if __name__ == "__main__":
    deeptruth()
