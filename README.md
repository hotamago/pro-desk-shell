# Pro Desk Shell

Pro Desk Shell is a Fedora-first Hyprland desktop shell built with `Qt6`, `QML`, `CMake`, `layer-shell-qt`, and `Rust`.
The repository now includes a real shell foundation: a top bar, launcher, notification center, quick settings surface, wallpaper/theme controls, a session surface, and a settings window backed by a Rust bridge.

The architecture stays intentionally split:

- `cpp/` owns Qt startup and `layer-shell-qt` window configuration
- `qml/` owns surface composition and presentation
- `rust/crates/shell-core/` owns config, shell state, actions, XDG paths, and pure parsers
- `rust/crates/shell-hyprland/` owns Hyprland IPC plus shell-critical runtime adapters
- `rust/crates/shell-ui-bridge/` owns the `cxx-qt` seam exposed to QML
- `tools/bootstrap/` owns package installation and managed Hyprland asset installation

## Status

Current shell work includes:

- an `ii`-inspired shell UI rebuilt locally in this repo
- persisted config at `~/.config/pro-desk-shell/config.json`
- runtime state at `~/.local/state/pro-desk-shell`
- Hyprland snapshot loading for workspaces and active window state
- a mailbox-based action bridge for Hyprland keybind dispatch
- managed Hyprland fragments installable through `./devsh install-hyprland`

Current limitations:

- the shell is still v1 and does not yet implement every planned desktop feature
- several long-tail services remain deferred, including clipboard history, OCR/screen tools, AI/chat, weather, and tray hosting
- Fedora is the only fully implemented bootstrap target today

## Getting started

### Prerequisites

You need a Linux environment with:

- `python3`
- `cmake`
- `cargo` and `rustc`
- a Qt6 development toolchain
- `layer-shell-qt` development files

On Fedora, the bootstrap CLI can install the shell-critical packages for you.

### Useful commands

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

### Running the shell

Developer window mode:

```bash
./devsh run
```

Layer-shell mode:

```bash
PRO_DESK_SHELL_USE_LAYER_SHELL=1 ./devsh run
```

### Installing managed Hyprland fragments

```bash
./devsh install-hyprland
```

This installs:

- Hyprland fragments into `~/.config/hypr/pro-desk-shell`
- the dispatch helper into `~/.local/bin/pro-desk-shell-dispatch`

Then source `~/.config/hypr/pro-desk-shell/main.conf` from your main Hyprland config.

## Verification

Current verification commands:

```bash
python3 -m unittest discover -s tools/bootstrap/tests
CARGO_TARGET_DIR=/tmp/pro-desk-shell-cargo-test cargo test --manifest-path rust/Cargo.toml
CARGO_TARGET_DIR=/tmp/pro-desk-shell-cargo-test cargo build --manifest-path rust/Cargo.toml -p shell_ui_bridge
./devsh build
```

`cargo test` still uses `default-members`, so it exercises the pure-Rust crates first. The bridge crate should be verified with a targeted build or the full CMake path.

## Repository layout

```text
.
├── .github/workflows/
├── cpp/
├── docs/
├── qml/
├── rust/
│   └── crates/
│       ├── shell-core/
│       ├── shell-hyprland/
│       └── shell-ui-bridge/
├── tools/bootstrap/
├── CMakeLists.txt
└── devsh
```

## Contributing

Contributions are welcome around:

- Hyprland IPC hardening
- richer shell services and panels
- QML surface polish and animation work
- Fedora packaging and release automation
- distro adapter work beyond Fedora

Start with [Contributor Guide](./docs/contributing.md) and [Bootstrap Architecture](./docs/architecture/bootstrap.md).

## License

This project is licensed under the [GNU General Public License v3.0](./LICENSE).
