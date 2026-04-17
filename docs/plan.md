# Shell Rewrite Plan

## Vision

Pro Desk Shell is moving from a collection of early shell panels to a cohesive desktop shell.
The target v1 experience is macOS-inspired in interaction quality and visual polish while staying Fedora-first and Hyprland-oriented.

The rewritten shell should feel like an actual OS surface:

- menu bar at the top
- dock at the bottom
- Spotlight-style search and launch
- Control Center on the right
- Notification Center on the right
- Mission Control-style workspace and window overview

## UX Principles

- QML stays presentational and animation-focused.
- Rust owns app indexing, search, dock derivation, workspace grouping, and shell actions.
- The shell should look calm, light, glassy, and intentional rather than theme-pack noisy.
- Keyboard access is first-class for Spotlight and Mission Control.
- Preview mode must degrade gracefully when Hyprland or system tools are unavailable.

## Architecture Direction

- `shell-core` owns desktop-entry parsing, app search ranking, dock state derivation, workspace/window grouping, config defaults, and shell models.
- `shell-hyprland` owns runtime scanning, Hyprland IPC, app launch, workspace activation, window focusing, and system-tool adapters.
- `shell-ui-bridge` owns QML-facing properties and invokables only.
- `qml/` owns composition, layout, motion, and presentation.

## Surface Inventory

### Shell core now

- `qml/App.qml` as full shell root
- `components/chrome/MenuBar.qml`
- `components/chrome/Dock.qml`
- `components/overlays/Spotlight.qml`
- `components/overlays/ControlCenter.qml`
- `components/overlays/NotificationCenter.qml`
- `components/overlays/MissionControl.qml`

### Planned next layers

- richer dock icon rendering
- better notification sourcing and persistence
- window thumbnails for Mission Control
- desktop wallpaper management
- tray hosting and background service surfaces

## Delivery Phases

1. Shell foundation, theme, and overlay orchestration
2. Menu bar and dock behavior
3. Spotlight search and real app launch
4. Control Center and Notification Center
5. Mission Control workspace flow
6. Settings, persistence polish, and richer integrations
