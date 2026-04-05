# Pro Desk Shell

Pro Desk Shell is a Fedora-first desktop shell scaffold for Wayland and Hyprland, built with `Qt6`, `QML`, `CMake`, `layer-shell-qt`, and `Rust`. The project is intentionally split so UI composition stays declarative, compositor-facing logic stays testable in Rust, and the Qt/Wayland bootstrap seam remains thin and replaceable.

The repository is still in an early phase, but it already includes a working layer-shell application skeleton, a bootstrap CLI, initial project architecture, and CI/CD wiring for validation and release snapshots.

## Project goals

- Build a desktop shell that feels native to modern Wayland compositors.
- Keep core state and system integration outside QML so behavior stays testable.
- Support Fedora first, while making room for additional Linux distributions over time.
- Make local setup, build, and release automation easy for contributors to understand.

## Current status

Today the repository provides:

- a `Qt6` + `QML` shell application with `layer-shell-qt` bootstrap code
- a Rust workspace split into focused crates for shell state, compositor integration, and the QML bridge
- a Python bootstrap entrypoint exposed as `./devsh`
- a simple desktop test UI for iterating on shell layout and UX
- automated validation for `main` and release publishing from the `release` branch

Current limitations:

- Fedora is the only fully implemented bootstrap target today
- Hyprland integration is still placeholder-oriented rather than production-complete
- the UI is a test surface, not yet a finished shell experience

## Architecture at a glance

The project is intentionally layered:

- `cpp/`: Qt application startup and `layer-shell-qt` window wiring
- `qml/`: visual composition and component structure only
- `rust/crates/shell-core/`: compositor-agnostic shell state and pure Rust behavior
- `rust/crates/shell-hyprland/`: Hyprland integration seam
- `rust/crates/shell-ui-bridge/`: the only Rust crate that speaks directly to Qt via `cxx-qt`
- `tools/bootstrap/`: local developer automation and distro bootstrap logic

Design rules for the repo:

- QML owns presentation, not business logic.
- Rust owns domain state and compositor-facing logic.
- `layer-shell-qt` remains in the C++ bootstrap layer.
- Bootstrap/install logic stays centralized in `./devsh`.

More background is available in [Bootstrap Architecture](./docs/architecture/bootstrap.md).

## Supported platforms

### Fully supported today

- Fedora

### Scaffolded, not yet implemented

- Arch Linux
- Gentoo

The distro adapter model already exists, so new platform support mostly means extending package mapping and installation behavior instead of rewriting the entire bootstrap flow.

## Getting started

### Prerequisites

You need a Linux environment with:

- `python3`
- `cmake`
- `cargo` and `rustc`
- a Qt6 development toolchain
- `layer-shell-qt` development files

On Fedora, the project bootstrap can install the required packages for you.

### Install dependencies

```bash
./devsh install --yes
./devsh install --yes --deps-only
```

If your machine is already provisioned and you only want to configure/build the project:

```bash
./devsh build
```

### Useful local commands

```bash
./devsh doctor
./devsh build
./devsh build --build-type Release --build-dir build-release
./devsh run
./devsh update --yes
```

### What `./devsh` does

`./devsh` is the canonical project entrypoint. It wraps the bootstrap code in `tools/bootstrap/main.py` and handles:

- distro detection
- dependency installation
- CMake configuration
- project builds
- local install/update flows

Available build types:

- `Debug`
- `Release`
- `RelWithDebInfo`
- `MinSizeRel`

## Running the shell locally

The fastest local development loop is:

```bash
./devsh build
./devsh run --skip-build
```

If you want a fresh configure-and-run in one step:

```bash
./devsh run
```

If you want to test the actual layer-shell path instead of the default developer window mode:

```bash
PRO_DESK_SHELL_USE_LAYER_SHELL=1 ./devsh run
```

If your environment has `ccache` configured but its cache directory is not writable, the bootstrap CLI now automatically disables `ccache` for the subprocess rather than failing the build.

## Verification

Current verification commands:

```bash
python3 -m unittest discover -s tools/bootstrap/tests
cargo test --manifest-path rust/Cargo.toml
./devsh build
```

Useful lower-level checks:

```bash
./devsh doctor
./devsh build --build-type Release --build-dir build-release
```

## CI/CD

The repository ships two GitHub Actions workflows:

- `main.yml`: validates pushes and pull requests targeting `main`
- `release.yml`: validates the `release` branch, builds a release bundle, and publishes a GitHub prerelease snapshot

Release workflow behavior:

- tests must pass before release packaging starts
- the release bundle contains the built binary, `README.md`, and `LICENSE`
- release assets are uploaded to GitHub Releases with a generated snapshot tag

## Repository layout

```text
.
├── .github/workflows/       # CI/CD
├── cpp/                     # Qt bootstrap and layer-shell window setup
├── docs/                    # Architecture and contributor documentation
├── qml/                     # Declarative UI
├── rust/
│   └── crates/
│       ├── shell-core/      # Pure Rust shell domain state
│       ├── shell-hyprland/  # Hyprland adapter seam
│       └── shell-ui-bridge/ # Qt bridge crate exposed to QML
├── tools/bootstrap/         # Bootstrap CLI and distro adapters
├── CMakeLists.txt
└── devsh
```

## Contributing

Contributions are welcome, especially around:

- compositor state modeling
- Hyprland IPC integration
- shell UX exploration in QML
- distro adapter support beyond Fedora
- packaging, testing, and release automation

Start with [Contributor Guide](./docs/contributing.md). It covers environment setup, project conventions, testing expectations, and the release branch workflow.

## Roadmap

Near-term priorities:

- replace placeholder compositor state with live Hyprland data
- evolve the test UI into reusable shell surfaces
- expand distro bootstrap coverage
- harden packaging and binary release outputs

## License

This project is licensed under the [MIT License](./LICENSE).
