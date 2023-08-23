#!/usr/bin/env python3
import csv
import sys
import xml.etree.ElementTree as ET
from collections import defaultdict


# TODO: this is parsing the resources list, NOT the timeline...
def parse_resources(element, media_files):
    for asset in element.iter("asset"):
        media_rep = asset.find("media-rep")
        src_path = media_rep.get("src")
        if src_path is not None:
            src_path = src_path.replace("file://", "")
            media_files[src_path] += 1


# TODO: nb this seems to skip video clips (but does images)
def parse_children(element, media_files):
    clips = [c for c in element.iter("video")]
    for c in clips:
        src_path = c.get("name")
        if src_path is not None:
            src_path = src_path.replace("file://", "")
            media_files[src_path] += 1


def parse_fcpxml(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()

    media_files = defaultdict(int)
    timeline_node = root.find("./library/event/project/sequence")
    parse_children(timeline_node, media_files)

    # parse_children(root, media_files)
    # parse_children(root.find("resources"), media_files)

    sorted_media_files = sorted(media_files.items(), key=lambda x: x[1], reverse=True)

    with open("usage_counts.csv", "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["src_path", "count"])
        print("src_path,count")
        for src_path, count in sorted_media_files:
            writer.writerow([src_path, count])
            print(f"{src_path},{count}")

    print("Usage counts saved to usage_counts.csv")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 script.py fcpxml_file_path")
        sys.exit(1)

    fcpxml_file_path = sys.argv[1]
    parse_fcpxml(fcpxml_file_path)
