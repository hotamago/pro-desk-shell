# Shell Rewrite Timeline

## Milestone 1: AGS Foundation And Theme

- Deliver the new `ags/config.js` shell root, CSS theme, and Rust CLI bridge.
- Acceptance: shell root renders through AGS, overlay orchestration works, and the old QML tree is gone.
- Dependencies: CLI must expose runtime snapshot basics and shell action commands.

## Milestone 2: Top Bar And Dock

- Deliver top bar, bottom dock, active app state, pin/unpin behavior, and running indicators.
- Acceptance: dock shows pinned plus running apps, clicks launch or focus apps, top bar reflects active workspace/window.
- Dependencies: app catalog indexing, dock derivation, focus and launch CLI actions.

## Milestone 3: Launcher And App Launch

- Deliver launcher search, result ranking, keyboard-first interaction, and real desktop-entry launch.
- Acceptance: search returns real installed apps and Enter launches the top match.
- Dependencies: desktop-entry parsing, search ranking helpers, CLI search exposure.

## Milestone 4: Control Panel And Notifications

- Deliver the right-side control surface for media, volume, brightness, network, battery, and notification history.
- Acceptance: controls can request runtime updates and notification list is visible from AGS.
- Dependencies: system adapters, CLI commands, notification list model.

## Milestone 5: Overview

- Deliver full-screen workspace overview with window cards and focus actions.
- Acceptance: overview groups windows by workspace and clicking a card requests focus.
- Dependencies: Hyprland client listing, workspace grouping, focus-window CLI action.

## Milestone 6: Settings And Polish

- Deliver persistence UI, icon polish, animation refinement, docs cleanup, and richer shell integration.
- Acceptance: shell config changes are editable from UI and the project docs reflect the current shipped shell.
- Dependencies: stable v1 surface behavior and agreed config schema.
