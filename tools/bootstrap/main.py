#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from tools.bootstrap.packages.linux import (
    PackageGroup,
    UnsupportedPlatformError,
    package_group_for,
)
from tools.bootstrap.platforms.arch import ArchAdapter
from tools.bootstrap.platforms.base import DetectedPlatform, PlatformAdapter
from tools.bootstrap.platforms.fedora import FedoraAdapter
from tools.bootstrap.platforms.gentoo import GentooAdapter

DEFAULT_BUILD_DIR = ROOT_DIR / "build"
DEFAULT_INSTALL_PREFIX = Path.home() / ".local"
DEFAULT_BUILD_TYPE = "Debug"
DEFAULT_HYPRLAND_DIR = Path.home() / ".config/hypr/pro-desk-shell"
DEFAULT_BIN_DIR = Path.home() / ".local/bin"
HYPRLAND_ASSETS_DIR = ROOT_DIR / "tools/bootstrap/assets/hyprland"
HYPRLAND_DISPATCH_SCRIPT = ROOT_DIR / "tools/bootstrap/assets/bin/pro-desk-shell-dispatch.sh"


def is_writable_path(path: Path) -> bool:
    current = path
    while not current.exists() and current != current.parent:
        current = current.parent

    return os.access(current, os.W_OK)


def subprocess_environment() -> dict[str, str]:
    env = os.environ.copy()

    if env.get("CCACHE_DISABLE") == "1" or shutil.which("ccache") is None:
        return env

    cache_dir = Path(env.get("CCACHE_DIR", Path.home() / ".cache/ccache"))
    if is_writable_path(cache_dir):
        return env

    print(f"Disabling ccache because '{cache_dir}' is not writable.")
    env["CCACHE_DISABLE"] = "1"
    return env


def parse_os_release(path: Path) -> dict[str, str]:
    content = path.read_text(encoding="utf-8")
    values: dict[str, str] = {}

    for raw_line in content.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        values[key] = value.strip().strip('"')

    return values


def detect_platform(path: Path = Path("/etc/os-release")) -> DetectedPlatform:
    values = parse_os_release(path)
    platform_id = values.get("ID", "unknown").lower()
    id_like = tuple(values.get("ID_LIKE", "").lower().split())
    return DetectedPlatform(platform_id=platform_id, id_like=id_like)


def adapters() -> tuple[PlatformAdapter, ...]:
    return (
        FedoraAdapter(),
        ArchAdapter(),
        GentooAdapter(),
    )


def resolve_adapter(platform: DetectedPlatform) -> PlatformAdapter:
    for adapter in adapters():
        if adapter.matches(platform):
            return adapter

    raise UnsupportedPlatformError(
        f"No adapter is available for platform '{platform.platform_id}'."
    )


def run_command(
    command: list[str],
    *,
    cwd: Path = ROOT_DIR,
    dry_run: bool = False,
) -> None:
    print(f"+ {shlex.join(command)}", flush=True)
    if dry_run:
        return

    subprocess.run(command, cwd=cwd, check=True, env=subprocess_environment())


def copy_tree_contents(source_dir: Path, destination_dir: Path, *, dry_run: bool) -> None:
    for source_path in sorted(source_dir.rglob("*")):
        relative_path = source_path.relative_to(source_dir)
        destination_path = destination_dir / relative_path
        if source_path.is_dir():
            print(f"+ mkdir -p {destination_path}")
            if not dry_run:
                destination_path.mkdir(parents=True, exist_ok=True)
            continue

        print(f"+ cp {source_path} {destination_path}")
        if dry_run:
            continue

        destination_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_path, destination_path)


def install_hyprland_assets(
    hyprland_dir: Path,
    bin_dir: Path,
    *,
    dry_run: bool,
) -> None:
    copy_tree_contents(HYPRLAND_ASSETS_DIR, hyprland_dir, dry_run=dry_run)

    dispatch_destination = bin_dir / "pro-desk-shell-dispatch"
    print(f"+ cp {HYPRLAND_DISPATCH_SCRIPT} {dispatch_destination}")
    print(f"+ chmod 755 {dispatch_destination}")

    if dry_run:
        return

    bin_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(HYPRLAND_DISPATCH_SCRIPT, dispatch_destination)
    dispatch_destination.chmod(0o755)


def configure_project(
    build_dir: Path,
    install_prefix: Path,
    build_type: str,
    dry_run: bool,
) -> None:
    run_command(
        [
            "cmake",
            "-S",
            str(ROOT_DIR),
            "-B",
            str(build_dir),
            f"-DCMAKE_BUILD_TYPE={build_type}",
            f"-DCMAKE_INSTALL_PREFIX={install_prefix}",
        ],
        dry_run=dry_run,
    )


def build_project(build_dir: Path, dry_run: bool) -> None:
    run_command(["cmake", "--build", str(build_dir)], dry_run=dry_run)


def install_project(build_dir: Path, dry_run: bool) -> None:
    run_command(["cmake", "--install", str(build_dir)], dry_run=dry_run)


def run_binary(build_dir: Path, dry_run: bool) -> None:
    binary_path = build_dir / "pro-desk-shell"
    run_command([str(binary_path)], dry_run=dry_run)


def install_dependencies(
    platform: DetectedPlatform,
    *,
    assume_yes: bool,
    dry_run: bool,
) -> None:
    command = dependency_install_command(platform, assume_yes=assume_yes)
    run_command(command, dry_run=dry_run)


def dependency_install_command(
    platform: DetectedPlatform,
    *,
    assume_yes: bool,
) -> list[str]:
    adapter = resolve_adapter(platform)
    try:
        package_group = package_group_for(adapter.family)
    except UnsupportedPlatformError:
        package_group = PackageGroup(build=(), runtime=())

    return adapter.install_dependencies_command(package_group, assume_yes)


def update_checkout(dry_run: bool) -> None:
    if not (ROOT_DIR / ".git").exists():
        print("Skipping git pull because this checkout is not a git repository.")
        return

    run_command(["git", "pull", "--ff-only"], dry_run=dry_run)


def layer_shell_build_support_present(
    search_roots: tuple[Path, ...] = (Path("/usr"), Path("/usr/local")),
) -> bool:
    candidate_suffixes = (
        Path("lib64/cmake/LayerShellQt/LayerShellQtConfig.cmake"),
        Path("lib/cmake/LayerShellQt/LayerShellQtConfig.cmake"),
        Path("lib64/cmake/layershellqt/layershellqt-config.cmake"),
        Path("lib/cmake/layershellqt/layershellqt-config.cmake"),
    )

    for root in search_roots:
        for suffix in candidate_suffixes:
            if (root / suffix).exists():
                return True

    return False


def hyprland_socket_present() -> bool:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not runtime_dir or not signature:
        return False

    socket_path = Path(runtime_dir) / "hypr" / signature / ".socket.sock"
    return socket_path.exists()


def print_doctor_report(platform: DetectedPlatform) -> int:
    checks = (
        ("wayland-session", bool(os.environ.get("WAYLAND_DISPLAY"))),
        ("cmake", shutil.which("cmake") is not None),
        ("cargo", shutil.which("cargo") is not None),
        ("rustc", shutil.which("rustc") is not None),
        ("qmake6", shutil.which("qmake6") is not None or shutil.which("qmake-qt6") is not None),
        ("layer-shell-cmake-package", layer_shell_build_support_present()),
        ("hyprland-socket", hyprland_socket_present()),
        ("playerctl", shutil.which("playerctl") is not None),
        ("wpctl", shutil.which("wpctl") is not None),
        ("brightnessctl", shutil.which("brightnessctl") is not None),
        ("nmcli", shutil.which("nmcli") is not None),
        ("upower", shutil.which("upower") is not None),
    )

    print(f"Detected platform: {platform.platform_id}")
    if platform.id_like:
        print(f"ID_LIKE: {' '.join(platform.id_like)}")

    for name, ok in checks:
        status = "ok" if ok else "missing"
        print(f"[{status}] {name}")

    critical_names = {"cmake", "cargo", "rustc", "qmake6", "layer-shell-cmake-package"}
    critical_failures = [name for name, ok in checks if name in critical_names and not ok]
    return 1 if critical_failures else 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Bootstrap the Pro Desk Shell workspace.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    def add_common_flags(command_parser: argparse.ArgumentParser) -> None:
        command_parser.add_argument(
            "--build-dir",
            type=Path,
            default=DEFAULT_BUILD_DIR,
            help="Build directory to use for cmake.",
        )
        command_parser.add_argument(
            "--prefix",
            type=Path,
            default=DEFAULT_INSTALL_PREFIX,
            help="Install prefix used by cmake --install.",
        )
        command_parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Print commands without executing them.",
        )
        command_parser.add_argument(
            "--build-type",
            default=DEFAULT_BUILD_TYPE,
            choices=("Debug", "Release", "RelWithDebInfo", "MinSizeRel"),
            help="CMake build type to configure.",
        )

    install_parser = subparsers.add_parser("install", help="Install dependencies, build, and install.")
    add_common_flags(install_parser)
    install_parser.add_argument("--yes", action="store_true", help="Pass non-interactive approval flags.")
    install_parser.add_argument(
        "--skip-deps",
        action="store_true",
        help="Skip the system package installation step.",
    )
    install_parser.add_argument(
        "--deps-only",
        action="store_true",
        help="Install system dependencies only, without configuring, building, or installing the project.",
    )

    build_parser_cmd = subparsers.add_parser("build", help="Configure and build the project.")
    add_common_flags(build_parser_cmd)

    run_parser = subparsers.add_parser("run", help="Build and run the shell binary.")
    add_common_flags(run_parser)
    run_parser.add_argument(
        "--skip-build",
        action="store_true",
        help="Run the built binary without rebuilding first.",
    )

    update_parser = subparsers.add_parser("update", help="Update the checkout and reinstall.")
    add_common_flags(update_parser)
    update_parser.add_argument("--yes", action="store_true", help="Pass non-interactive approval flags.")
    update_parser.add_argument(
        "--skip-deps",
        action="store_true",
        help="Skip the system package installation step.",
    )
    update_parser.add_argument(
        "--skip-pull",
        action="store_true",
        help="Do not run git pull before rebuilding.",
    )

    doctor_parser = subparsers.add_parser("doctor", help="Check local build prerequisites.")
    doctor_parser.add_argument(
        "--os-release",
        type=Path,
        default=Path("/etc/os-release"),
        help="Path to the os-release file used for platform detection.",
    )

    hyprland_parser = subparsers.add_parser(
        "install-hyprland",
        help="Install managed Hyprland shell fragments and the dispatch helper.",
    )
    hyprland_parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print file operations without applying them.",
    )
    hyprland_parser.add_argument(
        "--hyprland-dir",
        type=Path,
        default=DEFAULT_HYPRLAND_DIR,
        help="Destination directory for managed Hyprland fragments.",
    )
    hyprland_parser.add_argument(
        "--bin-dir",
        type=Path,
        default=DEFAULT_BIN_DIR,
        help="Destination directory for the Pro Desk Shell dispatch helper.",
    )

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "doctor":
        platform = detect_platform(args.os_release)
        return print_doctor_report(platform)

    if args.command == "install-hyprland":
        install_hyprland_assets(args.hyprland_dir, args.bin_dir, dry_run=args.dry_run)
        return 0

    platform = detect_platform()

    if args.command == "install":
        if not args.skip_deps:
            install_dependencies(platform, assume_yes=args.yes, dry_run=args.dry_run)
        if args.deps_only:
            return 0
        configure_project(args.build_dir, args.prefix, args.build_type, args.dry_run)
        build_project(args.build_dir, args.dry_run)
        install_project(args.build_dir, args.dry_run)
        return 0

    if args.command == "build":
        configure_project(args.build_dir, args.prefix, args.build_type, args.dry_run)
        build_project(args.build_dir, args.dry_run)
        return 0

    if args.command == "run":
        if not args.skip_build:
            configure_project(args.build_dir, args.prefix, args.build_type, args.dry_run)
            build_project(args.build_dir, args.dry_run)
        run_binary(args.build_dir, args.dry_run)
        return 0

    if args.command == "update":
        if not args.skip_pull:
            update_checkout(args.dry_run)
        if not args.skip_deps:
            install_dependencies(platform, assume_yes=args.yes, dry_run=args.dry_run)
        configure_project(args.build_dir, args.prefix, args.build_type, args.dry_run)
        build_project(args.build_dir, args.dry_run)
        install_project(args.build_dir, args.dry_run)
        return 0

    parser.error(f"Unsupported command: {args.command}")
    return 2


if __name__ == "__main__":
    sys.exit(main())
