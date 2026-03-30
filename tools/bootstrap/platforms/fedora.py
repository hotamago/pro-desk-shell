from tools.bootstrap.packages.linux import PackageGroup
from tools.bootstrap.platforms.base import DetectedPlatform, PlatformAdapter


class FedoraAdapter(PlatformAdapter):
    family = "fedora"

    def matches(self, platform: DetectedPlatform) -> bool:
        return platform.platform_id == "fedora" or "fedora" in platform.id_like

    def install_dependencies_command(
        self,
        package_group: PackageGroup,
        assume_yes: bool,
    ) -> list[str]:
        command = ["sudo", "dnf", "install"]
        if assume_yes:
            command.append("-y")
        command.extend(package_group.build)
        command.extend(package_group.runtime)
        return command
