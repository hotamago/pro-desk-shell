# Pro Desk Shell

Pro Desk Shell is a Fedora-first Hyprland desktop shell built with `AGS`, `GJS`, `GTK3`, and `Rust`.

The current direction is a hard pivot away from Qt/QML. The shell frontend now lives in `ags/`, while Rust remains the source of truth for app indexing, runtime snapshots, config, Hyprland integration, and shell actions.

## Architecture

- `ags/` owns shell presentation, windows, CSS styling, and local interaction flow
- `rust/crates/shell-core/` owns config, shell models, reducers, parsing, and search
- `rust/crates/shell-hyprland/` owns Hyprland IPC, desktop-entry scanning, app launch, and system adapters
- `rust/crates/shell-cli/` owns the JSON/action bridge that AGS calls
- `tools/bootstrap/` owns dependency installation, Rust bridge build/run flow, and Hyprland asset installation

## Status

Current shell work includes:

- top bar, dock, launcher, right-side control/notification panel, and overview in AGS
- persisted config at `~/.config/pro-desk-shell/config.json`
- Hyprland-backed runtime snapshots with preview fallback
- XDG desktop-entry indexing and real app launch
- Hyprland dispatch helper compatible with the AGS frontend

Current limitations:

- AGS runtime dependencies must be installed through `./devsh install` on Fedora
- the frontend is early and still needs more polish, motion, and deeper service integrations
- Mission Control still uses metadata cards rather than live thumbnails
- Fedora is the only fully implemented bootstrap target today

## Getting Started

Useful commands:

```bash
./devsh doctor
./devsh install --yes
./devsh install --yes --deps-only
./devsh build
./devsh run
./devsh run --skip-build
./devsh update --yes
./devsh install-hyprland
```

`./devsh build` builds the Rust shell bridge binary.

`./devsh run` launches the AGS frontend with that Rust bridge injected through environment variables.

## Dependencies

You need a Linux environment with:

- `python3`
- `cargo` and `rustc`
- `ags`
- `gjs`
- `meson`
- `ninja`
- `npm`
- `go`
- GTK layer-shell runtime support

On Fedora, `./devsh install --yes` enables the AGS COPR and installs the shell-critical packages.

## Hyprland Integration

```bash
./devsh install-hyprland
```

This installs:

- Hyprland fragments into `~/.config/hypr/pro-desk-shell`
- the dispatch helper into `~/.local/bin/pro-desk-shell-dispatch`

Then source `~/.config/hypr/pro-desk-shell/main.conf` from your main Hyprland config.

## Verification

```bash
python3 -m unittest discover -s tools/bootstrap/tests
CARGO_TARGET_DIR=/tmp/pro-desk-shell-cargo-test cargo test --manifest-path rust/Cargo.toml
CARGO_TARGET_DIR=/tmp/pro-desk-shell-cargo-test cargo build --manifest-path rust/Cargo.toml -p shell_cli
./devsh build
```

`./devsh run` additionally requires a Hyprland session plus AGS, GJS, and GTK layer-shell runtime support to be available on the host.

## Repository Layout

```text
.
├── ags/
├── docs/
├── rust/
│   └── crates/
│       ├── shell-cli/
│       ├── shell-core/
│       └── shell-hyprland/
├── tools/bootstrap/
└── devsh
```

## Contributing

Start with [Contributor Guide](./docs/contributing.md), [Bootstrap Architecture](./docs/architecture/bootstrap.md), and the continuation docs in [`docs/plan.md`](./docs/plan.md), [`docs/todo.md`](./docs/todo.md), and [`docs/timeline.md`](./docs/timeline.md).

## License

This project is licensed under the [GNU General Public License v3.0](./LICENSE).
