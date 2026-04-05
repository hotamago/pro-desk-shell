import unittest
from pathlib import Path
import tempfile
from unittest import mock

from tools.bootstrap.packages.linux import (
    PackageGroup,
    UnsupportedPlatformError,
    package_group_for,
)
from tools.bootstrap.main import (
    build_parser,
    dependency_install_command,
    layer_shell_build_support_present,
    subprocess_environment,
)
from tools.bootstrap.platforms.base import DetectedPlatform


class PackageResolutionTests(unittest.TestCase):
    def test_fedora_group_contains_qt_and_layer_shell_packages(self) -> None:
        group = package_group_for("fedora")

        self.assertIsInstance(group, PackageGroup)
        self.assertIn("layer-shell-qt-devel", group.build)
        self.assertIn("qt6-qtwayland", group.runtime)
        self.assertIn("hyprland", group.optional)

    def test_unsupported_family_raises_clear_error(self) -> None:
        with self.assertRaises(UnsupportedPlatformError):
            package_group_for("arch")

    def test_layer_shell_build_support_requires_cmake_config(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            system_prefix = root / "usr"
            cmake_dir = system_prefix / "lib64/cmake/LayerShellQt"
            cmake_dir.mkdir(parents=True)

            self.assertFalse(
                layer_shell_build_support_present(search_roots=(root / "missing",))
            )

            config_path = cmake_dir / "LayerShellQtConfig.cmake"
            config_path.write_text("", encoding="utf-8")
            self.assertTrue(layer_shell_build_support_present(search_roots=(system_prefix,)))

    def test_arch_install_path_raises_adapter_specific_message(self) -> None:
        with self.assertRaisesRegex(UnsupportedPlatformError, "Arch support is scaffolded"):
            dependency_install_command(
                DetectedPlatform(platform_id="arch", id_like=()),
                assume_yes=True,
            )

    def test_subprocess_environment_disables_ccache_when_cache_dir_is_not_writable(self) -> None:
        with mock.patch("tools.bootstrap.main.shutil.which", return_value="/usr/bin/ccache"):
            with mock.patch("tools.bootstrap.main.is_writable_path", return_value=False):
                with mock.patch.dict("os.environ", {}, clear=True):
                    with mock.patch("builtins.print"):
                        env = subprocess_environment()

        self.assertEqual(env["CCACHE_DISABLE"], "1")

    def test_build_parser_accepts_release_build_type(self) -> None:
        parser = build_parser()
        args = parser.parse_args(["build", "--build-type", "Release"])

        self.assertEqual(args.command, "build")
        self.assertEqual(args.build_type, "Release")

    def test_install_parser_accepts_deps_only(self) -> None:
        parser = build_parser()
        args = parser.parse_args(["install", "--yes", "--deps-only"])

        self.assertEqual(args.command, "install")
        self.assertTrue(args.yes)
        self.assertTrue(args.deps_only)

    def test_fedora_install_command_skips_sudo_when_unavailable(self) -> None:
        with mock.patch("tools.bootstrap.platforms.fedora.os.geteuid", return_value=1000):
            with mock.patch("tools.bootstrap.platforms.fedora.shutil.which", return_value=None):
                command = dependency_install_command(
                    DetectedPlatform(platform_id="fedora", id_like=()),
                    assume_yes=True,
                )

        self.assertEqual(command[:3], ["dnf", "install", "-y"])


if __name__ == "__main__":
    unittest.main()
