from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import retain_release as retention


class RetentionTests(unittest.TestCase):
    def test_preserves_current_newer_and_special_releases(self):
        releases = [dict(id=i, tag_name=t, draft=False, prerelease=False)
                    for i, t in enumerate(["v5.0.0", "6.0.1", "6.0.2", "7.0.0", "preview"])]
        self.assertEqual([r["tag_name"] for r in retention.candidates(releases, "6.0.2")],
                         ["v5.0.0", "6.0.1"])

    def test_only_known_package_names(self):
        for name in ["notelytask_6.0.2.apk", "notelytask-6.0.2-1.x86_64.rpm", "app-release.apk"]:
            self.assertTrue(retention.package(name))
        for name in ["other.apk", "notes.txt", "source.zip"]:
            self.assertFalse(retention.package(name))

    def test_missing_or_partial_upload_blocks_cleanup(self):
        with tempfile.TemporaryDirectory() as directory:
            files = [Path(directory) / f"notelytask_1.0.0.{ext}" for ext in ["apk", "deb", "rpm"]]
            for p in files:
                p.write_bytes(b"test")
            assets = [dict(name=p.name, state="uploaded", size=4) for p in files]
            retention.verify(files, assets)
            with self.assertRaises(ValueError):
                retention.verify(files, assets[:-1])
            assets[0]["size"] = 1
            with self.assertRaises(ValueError):
                retention.verify(files, assets)

    def test_pagination(self):
        with patch.object(retention, "api", side_effect=[list(range(100)), [100]]) as api:
            self.assertEqual(len(retention.pages("releases")), 101)
            self.assertEqual(api.call_count, 2)


if __name__ == "__main__":
    unittest.main()
