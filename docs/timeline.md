# Shell Rewrite Timeline

## Milestone 1: Foundation And Theme

- Deliver the new `qml/App.qml` shell root and macOS-inspired glass theme.
- Acceptance: shell root renders in preview mode, overlay orchestration works, old QML tree is gone.
- Dependencies: bridge must expose runtime snapshot basics and overlay state.

## Milestone 2: Menu Bar And Dock

- Deliver top menu bar, bottom dock, active app state, pin/unpin behavior, and running indicators.
- Acceptance: dock shows pinned plus running apps, clicks launch or focus apps, menu bar reflects active workspace/window.
- Dependencies: app catalog indexing, dock derivation, focus and launch actions.

## Milestone 3: Spotlight And App Launch

- Deliver Spotlight search, result ranking, keyboard-first interaction, and real desktop-entry launch.
- Acceptance: search returns real installed apps and Enter launches the top match.
- Dependencies: desktop-entry parsing, search ranking helpers, bridge search result exposure.

## Milestone 4: Control Center And Notifications

- Deliver the right-side control surface for media, volume, brightness, network, battery, and notification history.
- Acceptance: sliders can request runtime updates and notification list is dismissible.
- Dependencies: system adapters, bridge commands, notification list model.

## Milestone 5: Mission Control

- Deliver full-screen workspace overview with window cards and focus actions.
- Acceptance: overview groups windows by workspace and clicking a card requests focus.
- Dependencies: Hyprland client listing, workspace grouping, focus-window action.

## Milestone 6: Settings And Polish

- Deliver persistence UI, icon polish, animation refinement, docs cleanup, and richer shell integration.
- Acceptance: shell config changes are editable from UI and the project docs reflect the current shipped shell.
- Dependencies: stable v1 surface behavior and agreed config schema.
