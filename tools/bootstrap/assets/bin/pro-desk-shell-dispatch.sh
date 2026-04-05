#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"

case "$action" in
  launcher.toggle|overview.toggle|notifications.toggle|quick-settings.toggle|wallpaper.toggle|session.toggle|lock|restart-shell)
    ;;
  *)
    printf 'Unknown Pro Desk Shell action: %s\n' "$action" >&2
    exit 2
    ;;
esac

state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
mailbox="${state_home}/pro-desk-shell/action-request.txt"

mkdir -p "$(dirname "$mailbox")"
printf '%s\n' "$action" > "$mailbox"
