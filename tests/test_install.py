"""Exercise orchestration using stub modules; never call a system installer."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


BASH = shutil.which("bash")
if os.name == "nt" and not BASH:
    for candidate in (Path(shutil.which("git") or ".").parent.parent / "bin/bash.exe", Path("C:/Program Files/Git/bin/bash.exe")):
        if candidate.is_file():
            BASH = str(candidate)
            break


@unittest.skipUnless(BASH, "Bash is required")
class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        shutil.copyfile(Path(__file__).resolve().parents[1] / "install.sh", self.root / "install.sh")
        for module in ("touchBar", "keyBoard", "audioCodec", "fingerPrint", "batteryCharge"):
            folder = self.root / module
            folder.mkdir()
            (folder / "install.sh").write_text('printf "STUB %s\\n" "$*"\n', encoding="utf-8", newline="\n")

    def run_installer(self, *args):
        return subprocess.run([BASH, "install.sh", *args], cwd=self.root, capture_output=True, text=True, timeout=20)

    def test_default_dry_run_passes_flag_to_every_module(self):
        result = self.run_installer("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count("STUB --dry-run"), 5)

    def test_module_options_preserve_argument_boundaries(self):
        (self.root / "touchBar/install.sh").write_text('printf "ARG <%s>\\n" "$@"\n', encoding="utf-8", newline="\n")
        result = self.run_installer("--dry-run", "--module", "touchBar", "--", "--acpi-dir", "path with spaces")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("ARG <path with spaces>", result.stdout)
        self.assertNotIn("[keyBoard]", result.stdout)

    def test_module_failure_is_propagated_and_stops_following_modules(self):
        (self.root / "keyBoard/install.sh").write_text("exit 17\n", encoding="utf-8", newline="\n")
        result = self.run_installer("--dry-run")
        self.assertEqual(result.returncode, 17)
        self.assertIn("failed", result.stderr)
        self.assertNotIn("[audioCodec]", result.stdout)
        self.assertNotIn("Setup finished", result.stdout)

    def test_invalid_requests_fail_before_dispatch(self):
        for args in (("--module", "unknown"), ("--module",), ("--module", "touchBar", "--module", "touchBar"), ("--", "--acpi-dir", "somewhere"), ("--diagnose", "--module", "touchBar")):
            with self.subTest(args=args):
                result = self.run_installer(*args)
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("STUB", result.stdout)


if __name__ == "__main__":
    unittest.main()
