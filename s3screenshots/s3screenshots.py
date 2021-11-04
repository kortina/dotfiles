#!/usr/bin/env python

import boto
from boto.s3.key import Key
import logging
import os
import random
import re
import string
import subprocess
import time
from watchdog.observers import Observer
from watchdog.events import RegexMatchingEventHandler, EVENT_TYPE_DELETED

# system generated screenshot regex
REGEX_SYSTEM = r".*\/Screen Shot.*\.png"
# manual file upload regex
REGEX_MANUAL = r".*\.s3s\.(png|jpg|jpeg|gif)"


def copy_to_clipboard(s):
    process = subprocess.Popen(
        "pbcopy", env={"LANG": "en_US.UTF-8"}, stdin=subprocess.PIPE
    )
    process.communicate(s.encode("utf-8"))


def notify_osx(title, text):
    s = '''display notification "{}" with title "{}"'''.format(text, title)
    process = subprocess.Popen(
        ["osascript", "-"], env={"LANG": "en_US.UTF-8"}, stdin=subprocess.PIPE
    )
    process.communicate(s.encode("utf-8"))


class S3ScreenshotHandler(RegexMatchingEventHandler):
    @classmethod
    def _osx_username(klass):
        return os.environ.get("S3_SCREENSHOTS_OSX_USER")

    def _bucket_name(self):
        return os.environ.get("S3_SCREENSHOTS_AWS_BUCKET")

    def _aws_id(self):
        return os.environ.get("S3_SCREENSHOTS_AWS_ID")

    def _aws_secret(self):
        return os.environ.get("S3_SCREENSHOTS_AWS_SECRET")

    @classmethod
    def start(klass):
        logging.basicConfig(
            level=logging.DEBUG,
            format="%(asctime)s - %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        path = "/Users/{0}/Desktop".format(klass._osx_username())
        regexes = [REGEX_SYSTEM, REGEX_MANUAL]
        event_handler = klass(regexes=regexes, ignore_directories=True)
        observer = Observer()
        # observer = Observer(timeout=3.0)
        observer.schedule(event_handler, path, recursive=True)
        observer.start()
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            observer.stop()
        observer.join()

    def on_moved(self, event):
        logging.info(event)
        self._mv_and_upload_file(event.dest_path)

    def on_created(self, event):
        logging.info(event)
        self._mv_and_upload_file(event.src_path)

    def on_modified(self, event):
        logging.info(event)
        if event.event_type != EVENT_TYPE_DELETED:
            self._mv_and_upload_file(event.src_path)

    def _random_suffix(self):
        size = 8
        chars = string.ascii_lowercase + string.digits
        return "".join(random.choice(chars) for _ in range(size))

    def _matches_a_pattern(self, filename):
        if self._match_groups(filename) is not None:
            return True
        if re.search(REGEX_MANUAL, filename):
            return True
        return False

    def _match_groups(self, filename):
        r = r"(\d{4}-\d{2}-\d{2}) at (\d{1,2}).(\d{2}\.\d{2}) (AM|PM)\.png"
        return re.search(r, filename)

    def _new_filename(self, filename):
        if re.search(REGEX_MANUAL, filename):
            return filename
        m = self._match_groups(filename)
        cdate = m.group(1)
        hour = int(m.group(2))
        if m.group(4) == "PM" and hour != 12:
            hour += 12
        if m.group(4) == "AM" and hour == 12:  # 12 AM
            hour = 0
        hour = str(hour).zfill(2)
        minute_second = m.group(3)
        return "screen-shot-{0}-{1}.{2}-{3}.png".format(
            cdate, hour, minute_second, self._random_suffix()
        )

    def _new_filepath(self, filepath):
        filename = os.path.basename(filepath)
        dirname = os.path.dirname(filepath)
        return os.path.join(dirname, self._new_filename(filename))

    def _upload_file(self, new_filepath):
        conn = boto.connect_s3(self._aws_id(), self._aws_secret())

        b = conn.get_bucket(self._bucket_name())
        k = Key(b)
        k.key = os.path.basename(new_filepath)
        logging.info("Uploading {0} to {1}".format(k.key, self._bucket_name()))
        k.set_contents_from_filename(new_filepath)

    def _mv_and_upload_file(self, filepath):
        # skip if our regex didn't match the screenshot
        if not self._matches_a_pattern(os.path.basename(filepath)):
            return

        new_filepath = self._new_filepath(filepath)
        if not os.path.exists(filepath):
            logging.warning("file no longer exists: {}".format(filepath))
            return

        # mv
        os.rename(filepath, new_filepath)
        logging.warning("___uploading___")
        self._upload_file(new_filepath)
        # rm
        os.remove(new_filepath)
        filename = os.path.basename(new_filepath)
        # sugar
        copy_to_clipboard(self._http_link(filename))
        notify_osx(
            "Uploaded Screenshot to S3",
            "{0}: Copied link to clipboard.".format(filename),
        )

    def _http_link(self, filename):
        return "https://s3.amazonaws.com/{0}/{1}".format(self._bucket_name(), filename)


if __name__ == "__main__":
    S3ScreenshotHandler.start()
