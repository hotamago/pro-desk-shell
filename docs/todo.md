# Shell Rewrite Todo

## Now

- [ ] Stabilize the AGS widget tree and remove any runtime quirks from the first migration pass.
- [ ] Persist dismissed notification history in state instead of only showing placeholder runtime history.
- [ ] Add targeted Rust tests for CLI snapshot/action commands.
- [ ] Harden Hyprland window-to-app matching with `StartupWMClass` and additional heuristics.
- [ ] Add screenshots or recordings for the AGS shell surfaces in the README.

## Next

- [ ] Split `ags/config.js` into reusable AGS modules once the migration settles.
- [ ] Build a richer settings surface for dock, launcher, appearance, and integration commands.
- [ ] Add notification ingestion from a real notification service instead of runtime placeholders.
- [ ] Add better dock auto-hide and hover-reveal behavior from config.
- [ ] Add live app/window thumbnails for Mission Control once a safe screencopy path exists.
- [ ] Add search sections for actions, files, and web suggestions without moving ranking logic into AGS.
- [ ] Improve the top bar clock, media, and network widgets with richer status states.

## Later

- [ ] Wallpaper management and wallpaper-derived tinting, if it still fits the visual direction.
- [ ] Tray hosting and background service indicators.
- [ ] Clipboard history, OCR, and capture flows.
- [ ] Accessibility passes for keyboard navigation and focus visibility.
- [ ] Cross-distro packaging polish beyond Fedora.
- [ ] Optional advanced shell services such as weather or assistant surfaces.
