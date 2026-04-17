# Shell Rewrite Todo

## Now

- [ ] Add real icon rendering for dock and Spotlight results instead of text initials.
- [ ] Wire Mission Control workspace switching to refresh immediately after focus/dispatch.
- [ ] Persist dismissed notification history in state instead of only in-memory bridge state.
- [ ] Harden Hyprland window-to-app matching with `StartupWMClass` and additional heuristics.
- [ ] Add targeted Rust tests for workspace activation and launch fallback behavior.
- [ ] Add screenshots or recordings for the new shell surfaces in the README.

## Next

- [ ] Build a real settings surface for dock, launcher, appearance, and integration commands.
- [ ] Add notification ingestion from a real notification service instead of runtime placeholders.
- [ ] Add dock auto-hide and hover-reveal behavior from config.
- [ ] Add live app/window thumbnails for Mission Control once a safe screencopy path exists.
- [ ] Add search sections for actions, files, and web suggestions without moving ranking logic into QML.
- [ ] Improve the menu bar clock, media, and network widgets with richer status states.

## Later

- [ ] Wallpaper management and wallpaper-derived tinting, if it still fits the visual direction.
- [ ] Tray hosting and background service indicators.
- [ ] Clipboard history, OCR, and capture flows.
- [ ] Accessibility passes for keyboard navigation and focus visibility.
- [ ] Cross-distro packaging polish beyond Fedora.
- [ ] Optional advanced shell services such as weather or assistant surfaces.
