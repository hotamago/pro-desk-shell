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
            "git",
            "golang",
            "gobject-introspection-devel",
            "gtk3-devel",
            "gtk-layer-shell-devel",
            "meson",
            "ninja-build",
            "npm",
            "cargo",
            "rustc",
        ),
        runtime=(
            "aylurs-gtk-shell",
            "brightnessctl",
            "gjs",
            "playerctl",
            "NetworkManager",
            "upower",
        ),
        optional=(
            "hyprland",
            "wl-clipboard",
            "pavucontrol",
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
