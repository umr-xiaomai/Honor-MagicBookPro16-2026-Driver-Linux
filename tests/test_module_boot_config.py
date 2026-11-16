"""Exercise boot configuration against fixture files and fake generators."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
BASH = os.environ.get("HONOR_TEST_BASH") or shutil.which("bash")
if not BASH and os.name == "nt":
    git = shutil.which("git")
    candidate = Path(git).parent.parent / "bin" / "bash.exe" if git else None
    if candidate and candidate.is_file():
        BASH = str(candidate)


@unittest.skipUnless(BASH, "Bash is required")
class BootConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.config = self.root / "config"
        self.observed = self.root / "observed"
        self.generator = self.root / "generator.sh"

    def invoke(self, helper, function, *args):
        return subprocess.run(
            [BASH, "-c", 'source "$1"; shift; "$@"', "test",
             (REPO / helper).as_posix(), function, *map(str, args)],
            capture_output=True, text=True, timeout=10,
        )

    def keyboard(self, failure=0):
        self.generator.write_text(
            '. "$1"\n'
            'printf "%s\\n%s\\n" "${GRUB_CMDLINE_LINUX:-}" '
            '"${GRUB_CMDLINE_LINUX_DEFAULT:-}" > "$2"\n'
            f'exit {failure}\n',
            newline="\n",
        )
        return self.invoke(
            "keyBoard/grub-config.sh", "honor_keyboard_apply_grub_workaround",
            self.config.as_posix(), BASH, self.generator.as_posix(),
            self.config.as_posix(), self.observed.as_posix(),
        )

    def audio(self, replacement, failure=0):
        self.generator.write_text(f"exit {failure}\n", newline="\n")
        return self.invoke(
            "audioCodec/config-update.sh", "honor_audio_update_config",
            self.config.as_posix(), replacement, BASH, self.generator.as_posix(),
        )

    def test_generic_grub_source_gets_workaround_and_preserves_existing_args(self):
        self.config.write_text(
            'GRUB_CMDLINE_LINUX="quiet foo=bar"\n'
            'GRUB_CMDLINE_LINUX_DEFAULT="splash"\n'
            'GRUB_TIMEOUT=5\n'
        )
        result = self.keyboard()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.observed.read_text().splitlines(),
                         ["quiet foo=bar i8042.dumbkbd=1", "splash"])
        self.assertIn("GRUB_TIMEOUT=5", self.config.read_text())

    def test_repeated_install_does_not_duplicate_block_or_parameter(self):
        self.config.write_text('GRUB_CMDLINE_LINUX="quiet"\n')
        for _ in range(2):
            result = self.keyboard()
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text().count("# BEGIN HONOR XWC-P"), 1)
        self.assertEqual(self.observed.read_text().count("i8042.dumbkbd=1"), 1)

    def test_existing_default_parameter_is_not_duplicated(self):
        self.config.write_text(
            'GRUB_CMDLINE_LINUX="quiet"\n'
            'GRUB_CMDLINE_LINUX_DEFAULT="splash i8042.dumbkbd=1"\n'
        )
        result = self.keyboard()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.observed.read_text().count("i8042.dumbkbd=1"), 1)

    def test_grub_generator_failure_restores_exact_original_config(self):
        original = 'GRUB_CMDLINE_LINUX="quiet"\n'
        self.config.write_text(original)
        result = self.keyboard(failure=17)
        self.assertEqual(result.returncode, 17)
        self.assertIn("i8042.dumbkbd=1", self.observed.read_text())
        self.assertEqual(self.config.read_text(), original)
        self.assertIn("restored", result.stderr)

    def test_malformed_managed_block_does_not_modify_original_config(self):
        original = 'GRUB_TIMEOUT=5\n# BEGIN HONOR XWC-P KEYBOARD WORKAROUND\n'
        self.config.write_text(original)
        result = self.keyboard()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(), original)
        self.assertFalse(self.observed.exists())

    def test_audio_generator_failure_restores_original_config(self):
        self.config.write_text("custom original\n")
        replacement = self.root / "new.conf"
        replacement.write_text("experimental model\n")
        result = self.audio(replacement.as_posix(), failure=23)
        self.assertEqual(result.returncode, 23)
        self.assertEqual(self.config.read_text(), "custom original\n")
        self.assertIn("restored", result.stderr)

    def test_audio_failure_removes_new_config_when_none_existed(self):
        replacement = self.root / "new.conf"
        replacement.write_text("experimental model\n")
        result = self.audio(replacement.as_posix(), failure=23)
        self.assertEqual(result.returncode, 23)
        self.assertFalse(self.config.exists())

    def test_audio_removal_failure_restores_original_config(self):
        self.config.write_text("legacy config\n")
        result = self.audio("", failure=23)
        self.assertEqual(result.returncode, 23)
        self.assertEqual(self.config.read_text(), "legacy config\n")

    def test_successful_audio_install_and_removal_remain_applied(self):
        replacement = self.root / "new.conf"
        replacement.write_text("experimental model\n")
        result = self.audio(replacement.as_posix())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(), "experimental model\n")
        result = self.audio("")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.config.exists())


if __name__ == "__main__":
    unittest.main()
