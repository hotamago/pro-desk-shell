import os
import shutil

from tools.bootstrap.packages.linux import PackageGroup
from tools.bootstrap.platforms.base import DetectedPlatform, PlatformAdapter


class FedoraAdapter(PlatformAdapter):
    family = "fedora"
    ags_copr = "solopasha/hyprland"

    def _privilege_prefix(self) -> list[str]:
        if os.geteuid() == 0 or shutil.which("sudo") is None:
            return []

        return ["sudo"]

    def matches(self, platform: DetectedPlatform) -> bool:
        return platform.platform_id == "fedora" or "fedora" in platform.id_like

    def pre_install_commands(
        self,
        package_group: PackageGroup,
        assume_yes: bool,
    ) -> list[list[str]]:
        if "aylurs-gtk-shell" not in (*package_group.build, *package_group.runtime):
            return []

        command = [*self._privilege_prefix(), "dnf", "copr", "enable"]
        if assume_yes:
            command.append("-y")
        command.append(self.ags_copr)
        return [command]

    def install_dependencies_command(
        self,
        package_group: PackageGroup,
        assume_yes: bool,
    ) -> list[str]:
        command = [*self._privilege_prefix(), "dnf", "install"]
        if assume_yes:
            command.append("-y")
        command.extend(package_group.build)
        command.extend(package_group.runtime)
        return command
