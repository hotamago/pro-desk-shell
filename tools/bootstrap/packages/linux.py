from dataclasses import dataclass


class UnsupportedPlatformError(RuntimeError):
    """Raised when the bootstrap CLI does not have package data for a platform."""


@dataclass(frozen=True)
class PackageGroup:
    build: tuple[str, ...]
    runtime: tuple[str, ...]
    optional: tuple[str, ...] = ()


PACKAGE_GROUPS = {
    "fedora": PackageGroup(
        build=(
            "cmake",
            "gcc-c++",
            "ninja-build",
            "cargo",
            "rustc",
            "qt6-qtbase-devel",
            "qt6-qtdeclarative-devel",
            "qt6-qtwayland-devel",
            "wayland-devel",
            "layer-shell-qt-devel",
        ),
        runtime=(
            "qt6-qtwayland",
            "layer-shell-qt",
        ),
        optional=(
            "hyprland",
        ),
    ),
}


def package_group_for(family: str) -> PackageGroup:
    normalized_family = family.strip().lower()

    try:
        return PACKAGE_GROUPS[normalized_family]
    except KeyError as exc:
        raise UnsupportedPlatformError(
            f"No package map is available for platform family '{normalized_family}'."
        ) from exc
