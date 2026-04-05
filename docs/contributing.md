# Contributor Guide

## Welcome

Thanks for helping build Pro Desk Shell.

The project is still early, which means contributors can shape both the architecture and the day-to-day developer experience. The codebase is intentionally small right now, but it already has clear boundaries between UI, Qt bootstrap code, Rust domain logic, and bootstrap automation. Keeping those seams clean is one of the most important ways to help the project scale.

## Provenance and licensing

This repository is `GPL-3.0-only`.

Keep implementation work native to this codebase. Do not import external shell code, config bundles, or art assets into tracked project files without an explicit licensing and provenance review.

## Before you start

Please read:

- [README](../README.md)
- [Bootstrap Architecture](./architecture/bootstrap.md)

Those two documents explain the current scope, supported platforms, and why the repository is split the way it is.

## Development environment

### Supported development platform

Fedora is the primary contributor platform today.

Arch and Gentoo adapters exist only as scaffolding. Contributions to finish those adapters are welcome, but Fedora remains the reference environment for local setup and CI.

### Bootstrap commands

The repository entrypoint is `./devsh`.

Useful commands:

```bash
./devsh doctor
./devsh install --yes
./devsh install --yes --deps-only
./devsh build
./devsh build --build-type Release --build-dir build-release
./devsh run
PRO_DESK_SHELL_USE_LAYER_SHELL=1 ./devsh run
./devsh update --yes
./devsh install-hyprland
```

### Validation commands

Run these before opening a pull request:

```bash
python3 -m unittest discover -s tools/bootstrap/tests
cargo test --manifest-path rust/Cargo.toml
./devsh build
```

## Codebase boundaries

Keeping code in the right layer matters more than adding code quickly.

### `qml/`

Use QML for:

- layout
- visual composition
- bindings
- UI states that are purely presentational

Avoid:

- business logic in QML JavaScript
- compositor-specific logic
- shell state mutation rules that belong in Rust

### `rust/crates/shell-core/`

Use `shell-core` for:

- pure shell/domain state
- transformations and defaults
- logic that should remain testable without Qt or Hyprland

### `rust/crates/shell-hyprland/`

Use `shell-hyprland` for:

- Hyprland socket discovery
- Hyprland event parsing
- compositor-specific mapping into generic shell state
- shell-critical runtime adapters used by the top bar and quick settings surfaces

### `rust/crates/shell-ui-bridge/`

Use `shell-ui-bridge` for:

- exposing Rust state to QML
- `cxx-qt` bridge types
- Qt-facing glue code only

Try not to move core domain logic here.

### `cpp/`

Use `cpp/` for:

- `QGuiApplication` startup
- `QQmlApplicationEngine` ownership
- `layer-shell-qt` integration
- root window configuration

Keep this layer thin. If something can live in Rust or QML without leaking platform/bootstrap concerns, it usually should.

### `tools/bootstrap/`

Use the bootstrap tooling for:

- distro detection
- dependency installation
- shared build/update/run logic
- future platform extension points

If you add a new distro, prefer extending the adapter and package data model instead of branching logic all over the entrypoint.

## Coding conventions

### General

- Prefer small, reviewable changes.
- Keep naming boring and clear.
- Avoid introducing accidental architecture drift for short-term convenience.

### Python bootstrap code

- Keep orchestration logic explicit.
- Favor predictable subprocess behavior over clever shell tricks.
- Add tests for behavior changes in `tools/bootstrap/tests/`.

### Rust

- Keep pure logic in `shell-core` whenever possible.
- Add unit tests when changing domain behavior.
- Avoid coupling new crates directly to Qt unless there is a strong reason.

### QML

- Build components, not one giant file.
- Keep state readable and bindings simple.
- Preserve the rule that QML is primarily for composition and presentation.

## Pull requests

When opening a PR, please include:

- what changed
- why the change is needed
- how you validated it
- any follow-up work you intentionally left out

Helpful PR characteristics:

- one focused concern per PR
- passing validation commands
- clear screenshots or recordings for visible UI changes
- notes about distro-specific assumptions when relevant

## CI and release flow

### `main` branch

The `main` workflow validates:

- bootstrap Python tests
- Rust tests
- a full project build

### `release` branch

The `release` workflow:

1. runs the same validation gates
2. builds a release binary
3. packages release assets
4. publishes a GitHub prerelease snapshot

This means contributor changes should be safe to validate on `main`, while the `release` branch remains the place where packaged snapshots are produced.

## Good first contribution areas

Examples of high-value contributions:

- improve shell state modeling in `shell-core`
- add more automated tests for the bootstrap CLI
- improve desktop shell UX in QML
- wire real Hyprland data into the bridge
- expand the mailbox and keybind path into richer shell control APIs
- add or finish distro adapters
- tighten packaging and release automation

## Reporting issues

When reporting a bug, include:

- distro and version
- compositor/session details
- command you ran
- expected behavior
- actual behavior
- logs or screenshots when useful

For build issues, `./devsh doctor` output is especially helpful.

## Questions and proposals

Early architecture discussions are welcome. If you are unsure where a feature belongs, open the conversation before adding a lot of code. That is especially helpful for:

- new cross-platform abstractions
- QML to Rust boundary changes
- new release/distribution strategies
- compositor-specific integrations
