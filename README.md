# Pro Desk Shell

Rust + Qt6 + Hyprland shell scaffold for building a Wayland layer-shell desktop bar and future dashboard on Fedora first, with a bootstrap architecture that can grow into more Linux distributions later.

## Current phase

This repository is currently in bootstrap phase:

- Native shell app scaffolded with `CMake`, `Qt6`, `QML`, `layer-shell-qt`, and `cxx-qt`
- Rust workspace split into `shell_core`, `shell_hyprland`, and `shell_ui_bridge`
- Python bootstrap CLI exposed through `./devsh`
- Fedora dependency install implemented
- Arch and Gentoo adapters scaffolded with explicit "not implemented yet" behavior

## Quick start

```bash
./devsh install --yes
```

Useful commands:

```bash
./devsh doctor
./devsh build
./devsh run
./devsh update --yes
```

## Repository layout

```text
.
├── CMakeLists.txt
├── cpp/                     # Qt / layer-shell bootstrap seam
├── qml/                     # Declarative UI only
├── rust/
│   └── crates/
│       ├── shell-core/      # Pure Rust shell domain state
│       ├── shell-hyprland/  # Hyprland IPC integration seam
│       └── shell-ui-bridge/ # cxx-qt bridge crate exposed to QML
├── tools/bootstrap/         # Multi-distro bootstrap CLI
└── docs/architecture/       # Architecture notes and extension guidance
```

## Dependency policy

- UI composition lives in QML.
- System and compositor logic lives in Rust.
- `layer-shell-qt` stays in the C++ bootstrap layer.
- QML JavaScript business logic is intentionally avoided.

## Multi-distro roadmap

The bootstrap entrypoint is already distro-adapter based. Right now only Fedora has an implemented package map and installation command. To add another platform, extend:

- `tools/bootstrap/packages/linux.py`
- `tools/bootstrap/platforms/`
- `tools/bootstrap/main.py`

## Verification

Current low-level verification commands:

```bash
python3 -m unittest discover -s tools/bootstrap/tests
(cd rust && cargo test)
(cd rust && cargo build -p shell_ui_bridge)
```
