# Bootstrap Architecture

## Goals

- Keep the shell bootstrap small and developer-friendly.
- Preserve clean seams between the AGS frontend, Rust logic, and Hyprland integration.
- Make the install/update path easy for users now and extensible for more distros later.

## Layer breakdown

### AGS frontend

`ags/` owns:

- shell windows
- GTK composition
- CSS styling
- overlay interaction flow
- invoking the Rust CLI bridge for snapshots and actions

It should stay presentational and interaction-oriented. It should not become the place where Hyprland parsing, config rules, or desktop-entry logic live.

### Rust domain crates

`rust/crates/shell-core/` contains pure Rust state and helpers that are easy to unit test.

`rust/crates/shell-hyprland/` is the compositor adapter seam. It should eventually own:

- socket discovery
- command IPC client
- event stream parsing
- Hyprland-specific data mapping into generic shell state
- shell-critical system adapters used by the top bar and quick settings surfaces

`rust/crates/shell-cli/` is the frontend bridge. It exposes JSON snapshots and narrow commands that the AGS frontend can call without pulling UI concerns back into Rust core crates.

## Bootstrap CLI layout

`tools/bootstrap/main.py` is the single entrypoint used by `./devsh`.
It now builds the Rust shell bridge, runs the AGS frontend, installs AGS-oriented dependencies, and installs the managed Hyprland fragments plus dispatch helper.

`tools/bootstrap/packages/` stores declarative package groups.

`tools/bootstrap/platforms/` stores distro-specific installation behavior.

This split keeps distro growth mostly data-oriented:

- add package names
- add or update adapter logic
- keep build/install orchestration shared

## Why AGS owns the shell windows

AGS is the chosen shell presentation layer because it gives the project a faster path for GTK-based shell surfaces and iteration. Window creation, styling, and compositor-facing widget layout belong there, while Rust continues to own the data and action semantics.

## Current verification scope

- `shell_core` has unit tests for shell state defaults and parser behavior.
- bootstrap package resolution has Python unit tests.
- `rust/Cargo.toml` uses `default-members` so plain `cargo test` exercises the Rust crates used by the shell.
- `shell_cli` should be verified with `cargo build -p shell_cli`.
- AGS runtime verification depends on host packages such as `ags`, `gjs`, and `gtk-layer-shell` being installed, plus an active Hyprland session socket.
