# Bootstrap Architecture

## Goals

- Keep the first scaffold small but build-oriented.
- Preserve clean seams between Wayland windowing, Rust logic, and QML UI.
- Make the install/update path easy for users now and extensible for more distros later.

## Layer breakdown

### C++ bootstrap

`cpp/` owns:

- `QGuiApplication`
- `QQmlApplicationEngine`
- `layer-shell-qt` activation
- root window configuration

This layer stays intentionally thin so Wayland protocol specifics do not leak into QML or core Rust crates.

### QML UI

`qml/` owns:

- visual composition
- layout
- bindings
- component structure

It should not own business logic or system integration logic.

### Rust domain crates

`rust/crates/shell-core/` contains pure Rust state and helpers that are easy to unit test.

`rust/crates/shell-hyprland/` is the compositor adapter seam. It should eventually own:

- socket discovery
- command IPC client
- event stream parsing
- Hyprland-specific data mapping into generic shell state

`rust/crates/shell-ui-bridge/` is the only crate allowed to depend directly on `cxx-qt`. It converts Rust state into QML-visible `QObject`s and protects the rest of the workspace from Qt coupling.

## Bootstrap CLI layout

`tools/bootstrap/main.py` is the single entrypoint used by `./devsh`.

`tools/bootstrap/packages/` stores declarative package groups.

`tools/bootstrap/platforms/` stores distro-specific installation behavior.

This split keeps distro growth mostly data-oriented:

- add package names
- add or update adapter logic
- keep build/install orchestration shared

## Why `layer-shell-qt` lives in C++

`layer-shell-qt` is a Qt-side window integration concern. The shell window must be created and configured around `QWindow` / `QQuickWindow` lifecycle, so the natural ownership point is the C++/Qt bootstrap seam. That avoids forcing protocol/windowing concerns through the Rust domain model.

## Current verification scope

- `shell_core` has unit tests for placeholder shell state behavior.
- bootstrap package resolution has Python unit tests.
- `rust/Cargo.toml` uses `default-members` so plain `cargo test` exercises the pure-Rust crates first.
- `shell-ui-bridge` should be verified with `cargo build -p shell_ui_bridge` or the CMake build path rather than a Rust test harness.
- full Qt/CMake build verification depends on host packages such as `Qt6`, `layer-shell-qt`, and a Qt toolchain being installed.
