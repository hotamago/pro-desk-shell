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

if ! command -v ags >/dev/null 2>&1; then
  printf 'AGS is not installed or not on PATH.\n' >&2
  exit 127
fi

resolve_launcher_path() {
  if [[ -n "${PRO_DESK_SHELL_AGS_LAUNCHER:-}" && -f "${PRO_DESK_SHELL_AGS_LAUNCHER}" ]]; then
    printf '%s\n' "${PRO_DESK_SHELL_AGS_LAUNCHER}"
    return 0
  fi

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local candidates=(
    "${script_dir}/pro-desk-shell-ags-launcher.mjs"
    "${script_dir}/ags-launcher.mjs"
  )

  for candidate in "${candidates[@]}"; do
    if [[ -f "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  return 1
}

run_action_via_ags() {
  local requested_action="$1"
  local js_expression="globalThis.proDeskDispatch(\\\"${requested_action}\\\")"
  local launcher_path=""
  if launcher_path="$(resolve_launcher_path)" && command -v gjs >/dev/null 2>&1; then
    PRO_DESK_SHELL_AGS_ARGS="-r ${js_expression}" \
      gjs -m "${launcher_path}"
    return
  fi

  ags -r "${js_expression}"
}

case "$action" in
  wallpaper.toggle|session.toggle)
    printf 'Action not implemented in the AGS frontend yet: %s\n' "$action" >&2
    exit 3
    ;;
  restart-shell)
    run_action_via_ags "refresh"
    ;;
  *)
    run_action_via_ags "$action"
    ;;
esac
