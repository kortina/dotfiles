from .s3screenshots import S3ScreenshotHandler
from unittest import TestCase
import sys

if sys.version_info >= (3, 3):
    from unittest.mock import MagicMock
else:
    from mock import MagicMock


class S3ScreenshotHandlerTests(TestCase):
    def test_new_filename(self):
        i = S3ScreenshotHandler()
        r = "abcdbcdefgh"
        i._random_suffix = MagicMock(return_value=r)
        self.assertEqual(
            i._new_filename("Screen Shot 2017-03-19 at 6.52.13 PM.png"),
            "screen-shot-2017-03-19-18.52.13-{0}.png".format(r),
        )

    def test_new_filename_manual(self):
        i = S3ScreenshotHandler()
        r = "abcdbcdefgh"
        i._random_suffix = MagicMock(return_value=r)
        fn = "some-random-file.s3s.png"
        self.assertEqual(i._new_filename(fn), fn)

    def test_new_filepath(self):
        i = S3ScreenshotHandler()
        r = "abcdbcdefgh"
        i._random_suffix = MagicMock(return_value=r)
        self.assertEqual(
            i._new_filepath(
                "/Users/kortina/Desktop/Screen Shot 2017-03-19 at 6.52.13 PM.png"
            ),
            "/Users/kortina/Desktop/screen-shot-2017-03-19-18.52.13-{0}.png".format(r),
        )
