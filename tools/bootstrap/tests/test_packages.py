import unittest
from pathlib import Path
import tempfile

from tools.bootstrap.packages.linux import (
    PackageGroup,
    UnsupportedPlatformError,
    package_group_for,
)
from tools.bootstrap.main import (
    dependency_install_command,
    layer_shell_build_support_present,
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


if __name__ == "__main__":
    unittest.main()
