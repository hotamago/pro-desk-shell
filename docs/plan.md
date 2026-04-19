# Shell Rewrite Plan

## Vision

Pro Desk Shell is moving from the abandoned Qt/QML frontend to an AGS-based desktop shell.
The target v1 experience is macOS-inspired in interaction quality and visual polish while staying Fedora-first and Hyprland-oriented.

The rewritten shell should feel like an actual OS surface:

- menu bar at the top
- dock at the bottom
- Spotlight-style search and launch
- Control Center on the right
- Notification Center on the right
- Mission Control-style workspace and window overview

## UX Principles

- AGS stays presentational and interaction-focused.
- Rust owns app indexing, search, dock derivation, workspace grouping, config, and shell actions.
- The shell should look calm, light, glassy, and intentional rather than theme-pack noisy.
- Keyboard access is first-class for Spotlight and Mission Control.
- Preview mode must degrade gracefully when Hyprland or system tools are unavailable.

## Architecture Direction

- `shell-core` owns desktop-entry parsing, app search ranking, dock state derivation, workspace/window grouping, config defaults, and shell models.
- `shell-hyprland` owns runtime scanning, Hyprland IPC, app launch, workspace activation, window focusing, and system-tool adapters.
- `shell-cli` owns AGS-facing JSON snapshots and explicit action commands only.
- `ags/` owns windows, layout, CSS, motion, and presentation.

## Surface Inventory

### Shell core now

- `ags/config.js` as the AGS shell entrypoint
- top bar window
- dock window
- launcher window
- right-side panel for control center and notifications
- overview window

### Planned next layers

- better multi-monitor window placement
- better notification sourcing and persistence
- window thumbnails for Mission Control
- desktop wallpaper management
- tray hosting and background service surfaces

## Delivery Phases

1. Rust CLI bridge and AGS shell foundation
2. Top bar and dock behavior
3. Launcher search and real app launch
4. Control panel and notification panel
5. Overview workspace flow
6. Settings, persistence polish, and richer integrations
