from tools.bootstrap.packages.linux import PackageGroup, UnsupportedPlatformError
from tools.bootstrap.platforms.base import DetectedPlatform, PlatformAdapter


class ArchAdapter(PlatformAdapter):
    family = "arch"

    def matches(self, platform: DetectedPlatform) -> bool:
        return platform.platform_id == "arch" or "arch" in platform.id_like

    def install_dependencies_command(
        self,
        package_group: PackageGroup,
        assume_yes: bool,
    ) -> list[str]:
        raise UnsupportedPlatformError(
            "Arch support is scaffolded but not implemented yet. "
            "Add an Arch package map and pacman command wiring in tools/bootstrap."
        )
