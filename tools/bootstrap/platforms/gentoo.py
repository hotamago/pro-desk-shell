from tools.bootstrap.packages.linux import PackageGroup, UnsupportedPlatformError
from tools.bootstrap.platforms.base import DetectedPlatform, PlatformAdapter


class GentooAdapter(PlatformAdapter):
    family = "gentoo"

    def matches(self, platform: DetectedPlatform) -> bool:
        return platform.platform_id == "gentoo" or "gentoo" in platform.id_like

    def install_dependencies_command(
        self,
        package_group: PackageGroup,
        assume_yes: bool,
    ) -> list[str]:
        raise UnsupportedPlatformError(
            "Gentoo support is scaffolded but not implemented yet. "
            "Add an ebuild-oriented package map and emerge command wiring in tools/bootstrap."
        )
