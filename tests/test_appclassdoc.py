"""AppClassDoc tests."""

import os.path
import tempfile

import appclassdoc


_TESTS_DIR = os.path.dirname(__file__)
_SOURCE_DIR = os.path.join(_TESTS_DIR, 'src')


def test_generation():
    """Test the generation of AppClassDoc API docs."""
    with tempfile.TemporaryDirectory() as temp_dir:
        appclassdoc.generate_appclassdoc(temp_dir, True, True, _SOURCE_DIR,
                                         verbose_output=True)
