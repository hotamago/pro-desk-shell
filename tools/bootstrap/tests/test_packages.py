import unittest
from pathlib import Path
from unittest import mock

from tools.bootstrap.packages.linux import (
    PackageGroup,
    UnsupportedPlatformError,
    package_group_for,
)
from tools.bootstrap.main import (
    ags_runtime_support_present,
    build_parser,
    dependency_install_command,
    subprocess_environment,
)
from tools.bootstrap.platforms.fedora import FedoraAdapter
from tools.bootstrap.platforms.base import DetectedPlatform


class PackageResolutionTests(unittest.TestCase):
    def test_fedora_group_contains_ags_and_gtk_shell_packages(self) -> None:
        group = package_group_for("fedora")

        self.assertIsInstance(group, PackageGroup)
        self.assertIn("git", group.build)
        self.assertIn("gtk-layer-shell-devel", group.build)
        self.assertIn("gobject-introspection-devel", group.build)
        self.assertIn("aylurs-gtk-shell", group.runtime)
        self.assertIn("gjs", group.runtime)
        self.assertIn("playerctl", group.runtime)
        self.assertIn("brightnessctl", group.runtime)
        self.assertIn("hyprland", group.optional)

    def test_unsupported_family_raises_clear_error(self) -> None:
        with self.assertRaises(UnsupportedPlatformError):
            package_group_for("arch")

    def test_ags_runtime_support_checks_path(self) -> None:
        with mock.patch("tools.bootstrap.main.shutil.which", return_value="/usr/bin/ags"):
            self.assertTrue(ags_runtime_support_present())

        with mock.patch("tools.bootstrap.main.shutil.which", return_value=None):
            self.assertFalse(ags_runtime_support_present())

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

    def test_install_hyprland_parser_accepts_custom_paths(self) -> None:
        parser = build_parser()
        args = parser.parse_args(
            [
                "install-hyprland",
                "--hyprland-dir",
                "/tmp/hypr/pro-desk-shell",
                "--bin-dir",
                "/tmp/bin",
            ]
        )

        self.assertEqual(args.command, "install-hyprland")
        self.assertEqual(args.hyprland_dir, Path("/tmp/hypr/pro-desk-shell"))
        self.assertEqual(args.bin_dir, Path("/tmp/bin"))

    def test_fedora_install_command_skips_sudo_when_unavailable(self) -> None:
        with mock.patch("tools.bootstrap.platforms.fedora.os.geteuid", return_value=1000):
            with mock.patch("tools.bootstrap.platforms.fedora.shutil.which", return_value=None):
                command = dependency_install_command(
                    DetectedPlatform(platform_id="fedora", id_like=()),
                    assume_yes=True,
                )

        self.assertEqual(command[:3], ["dnf", "install", "-y"])

    def test_fedora_pre_install_enables_ags_copr(self) -> None:
        group = package_group_for("fedora")
        adapter = FedoraAdapter()

        with mock.patch("tools.bootstrap.platforms.fedora.os.geteuid", return_value=1000):
            with mock.patch("tools.bootstrap.platforms.fedora.shutil.which", return_value=None):
                commands = adapter.pre_install_commands(group, assume_yes=True)

        self.assertEqual(commands, [["dnf", "copr", "enable", "-y", "solopasha/hyprland"]])


if __name__ == "__main__":
    unittest.main()
