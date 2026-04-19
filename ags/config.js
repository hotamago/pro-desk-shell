import App from "resource:///com/github/Aylur/ags/app.js";
import Utils from "resource:///com/github/Aylur/ags/utils.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";
import GLib from "gi://GLib?version=2.0";

const POLL_INTERVAL_MS = 3000;
const DEFAULT_TERMINAL = "kitty -1";

function emptyPayload() {
    return {
        status_line: "AGS shell is booting.",
        config: {
            appearance: {
                accent_color: "#56d6ff",
                accent_color_secondary: "#ffb36b",
                accent_color_tertiary: "#7fffb4",
                enable_transparency: true,
                style_preset: "macos",
                theme_name: "macos-sunrise",
            },
            dock: {
                pinned_apps: [],
                auto_hide: false,
                magnification: 18,
                show_running_indicators: true,
            },
            launcher: {
                max_results: 8,
            },
            menu_bar: {
                compact_mode: false,
            },
            background: {
                wallpaper_path: "",
                wallpaper_mode: "cover",
                ambient_blur: 24,
            },
            integrations: {
                terminal: DEFAULT_TERMINAL,
                browser: "xdg-open https://duckduckgo.com",
                file_manager: "xdg-open .",
                network_settings: "nm-connection-editor",
                volume_mixer: "pavucontrol",
            },
        },
        snapshot: {
            compositor_name: "Hyprland",
            workspaces: [],
            active_workspace: "Desktop",
            active_window: {
                title: "Pro Desk Shell",
                class_name: "desktop",
                is_floating: false,
                is_fullscreen: false,
            },
            active_app_id: null,
            app_catalog: [],
            dock_items: [],
            windows: [],
            mission_control_workspaces: [],
            media: {
                source: "none",
                title: "",
                artist: "",
                status: "Stopped",
            },
            battery: {
                percent: 0,
                is_charging: false,
            },
            network: {
                name: "Offline",
                state_label: "Disconnected",
            },
            notification_history: [],
            quick_settings: {
                volume_percent: 0,
                brightness_percent: 0,
            },
            capabilities: {
                has_hyprland: false,
                has_playerctl: false,
                has_wpctl: false,
                has_brightnessctl: false,
                has_nmcli: false,
                has_upower: false,
            },
        },
    };
}

function shellCliPath() {
    return GLib.getenv("PRO_DESK_SHELL_CLI")
        || `${GLib.get_current_dir()}/build/cargo/debug/shell_cli`;
}

function errToMessage(error) {
    if (typeof error === "string") {
        return error;
    }

    if (error && typeof error.message === "string") {
        return error.message;
    }

    return `${error}`;
}

async function runCli(args) {
    const command = [shellCliPath(), ...args];
    const output = await Utils.execAsync(command);
    return `${output}`.trim();
}

async function readJson(args, fallback) {
    try {
        const output = await runCli(args);
        if (output.length === 0) {
            return fallback;
        }
        return JSON.parse(output);
    } catch (_error) {
        return fallback;
    }
}

const shellPayload = Variable(emptyPayload());
const launcherOpen = Variable(false);
const overviewOpen = Variable(false);
const panelMode = Variable("");
const launcherQuery = Variable("");
const launcherResults = Variable([]);
const statusMessage = Variable("");
const clockLabel = Variable("", {
    poll: [1000, () => new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })],
});

let refreshInFlight = false;

function currentShell() {
    return shellPayload.value;
}

function closeTransientSurfaces() {
    launcherOpen.value = false;
    overviewOpen.value = false;
    panelMode.value = "";
}

async function refreshShell() {
    if (refreshInFlight) {
        return;
    }

    refreshInFlight = true;
    try {
        const nextPayload = await readJson(["snapshot"], emptyPayload());
        shellPayload.value = nextPayload;

        if (launcherOpen.value) {
            await updateLauncherResults(launcherQuery.value);
        }
    } catch (error) {
        statusMessage.value = errToMessage(error);
    } finally {
        refreshInFlight = false;
    }
}

async function callCli(args, refresh = true) {
    try {
        await runCli(args);
        statusMessage.value = "";
        if (refresh) {
            await refreshShell();
        }
    } catch (error) {
        statusMessage.value = errToMessage(error);
    }
}

async function updateLauncherResults(query) {
    launcherQuery.value = query;
    const results = await readJson(["search", query], []);
    launcherResults.value = Array.isArray(results) ? results : [];
}

function toggleLauncher() {
    const nextState = !launcherOpen.value;
    closeTransientSurfaces();
    launcherOpen.value = nextState;
    if (nextState) {
        updateLauncherResults(launcherQuery.value);
    }
}

function toggleOverview() {
    const nextState = !overviewOpen.value;
    closeTransientSurfaces();
    overviewOpen.value = nextState;
}

function togglePanel(mode) {
    launcherOpen.value = false;
    overviewOpen.value = false;
    panelMode.value = panelMode.value === mode ? "" : mode;
}

async function activateDockItem(appId) {
    const item = currentShell().snapshot.dock_items.find((candidate) => candidate.app_id === appId);
    if (!item) {
        return;
    }

    if (item.running) {
        const targetWindow = currentShell().snapshot.windows.find((window) => window.app_id === appId);
        if (targetWindow) {
            await callCli(["focus-window", targetWindow.window_id]);
            return;
        }
    }

    await callCli(["launch-app", appId]);
}

async function launchFirstSearchResult() {
    const first = launcherResults.value[0];
    if (!first) {
        return;
    }

    await callCli(["launch-app", first.app_id]);
    closeTransientSurfaces();
}

function initialLabel(value) {
    const trimmed = `${value || ""}`.trim();
    if (trimmed.length === 0) {
        return "?";
    }

    const parts = trimmed.split(/\s+/).filter(Boolean);
    if (parts.length > 1) {
        return `${parts[0].charAt(0)}${parts[1].charAt(0)}`.toUpperCase();
    }

    return trimmed.slice(0, 2).toUpperCase();
}

function iconFor(item) {
    if (item.icon_path && item.icon_path.length > 0) {
        return item.icon_path;
    }
    if (item.icon_name && item.icon_name.length > 0) {
        return item.icon_name;
    }
    return "application-x-executable-symbolic";
}

function AppIcon(item, size = 40, active = false) {
    return Widget.Box({
        class_name: active ? "app-icon active" : "app-icon",
        width_request: size,
        height_request: size,
        child: Widget.Icon({
            icon: iconFor(item),
            size: Math.max(18, size - 10),
        }),
    });
}

function TopBar() {
    return Widget.Window({
        name: "top-bar",
        layer: "top",
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        class_name: "shell-root",
        child: Widget.Box({
            class_name: shellPayload.bind().as((payload) =>
                payload.config.menu_bar.compact_mode
                    ? "shell-surface top-bar compact"
                    : "shell-surface top-bar"
            ),
            spacing: 12,
            margin_top: 16,
            margin_start: 18,
            margin_end: 18,
            children: [
                Widget.Button({
                    class_name: "shell-button accent",
                    on_clicked: () => toggleLauncher(),
                    child: Widget.Label({ label: "launcher" }),
                }),
                Widget.Button({
                    class_name: "shell-button",
                    on_clicked: () => toggleOverview(),
                    child: Widget.Label({
                        label: shellPayload.bind().as((payload) => payload.snapshot.active_workspace || "Desktop"),
                    }),
                }),
                Widget.Box({ hexpand: true }),
                Widget.Box({
                    vertical: true,
                    class_name: "title-block",
                    children: [
                        Widget.Label({
                            class_name: "title",
                            label: shellPayload.bind().as((payload) =>
                                payload.snapshot.active_window.title || "Pro Desk Shell"
                            ),
                        }),
                        Widget.Label({
                            class_name: "subtitle soft",
                            label: shellPayload.bind().as((payload) =>
                                payload.snapshot.active_window.class_name
                                || statusMessage.value
                                || payload.status_line
                            ),
                        }),
                    ],
                }),
                Widget.Box({ hexpand: true }),
                Widget.Box({
                    spacing: 10,
                    hpack: "end",
                    children: [
                        Widget.Box({
                            class_name: "pill",
                            child: Widget.Label({
                                class_name: "subtitle muted",
                                label: shellPayload.bind().as((payload) =>
                                    payload.snapshot.network.name || "network"
                                ),
                            }),
                        }),
                        Widget.Box({
                            class_name: "pill",
                            child: Widget.Label({
                                class_name: "subtitle muted",
                                label: shellPayload.bind().as((payload) =>
                                    `${payload.snapshot.battery.percent}%`
                                ),
                            }),
                        }),
                        Widget.Box({
                            class_name: "pill",
                            child: Widget.Label({
                                class_name: "subtitle",
                                label: clockLabel.bind(),
                            }),
                        }),
                        Widget.Button({
                            class_name: "shell-button",
                            on_clicked: () => togglePanel("notifications"),
                            child: Widget.Label({
                                label: shellPayload.bind().as((payload) =>
                                    `notify ${payload.snapshot.notification_history.length}`
                                ),
                            }),
                        }),
                        Widget.Button({
                            class_name: "shell-button",
                            on_clicked: () => togglePanel("control"),
                            child: Widget.Label({ label: "control" }),
                        }),
                    ],
                }),
            ],
        }),
    });
}

function DockItem(item) {
    return Widget.Box({
        vertical: true,
        spacing: 6,
        child: Widget.Box({
            vertical: true,
            spacing: 6,
            children: [
                Widget.Button({
                    class_name: item.active ? "dock-item active" : "dock-item",
                    on_clicked: () => activateDockItem(item.app_id),
                    child: Widget.Box({
                        vertical: true,
                        spacing: 8,
                        children: [
                            AppIcon(item, 46, item.active),
                            Widget.Label({
                                class_name: "subtitle",
                                label: item.display_name,
                            }),
                        ],
                    }),
                }),
                currentShell().config.dock.show_running_indicators && (item.running || item.active)
                    ? Widget.Box({
                        class_name: "pill",
                        hpack: "center",
                        child: Widget.Label({
                            class_name: "subtitle muted",
                            label: item.active ? "active" : `${item.window_count}`,
                        }),
                    })
                    : Widget.Box({}),
            ],
        }),
    });
}

function Dock() {
    return Widget.Window({
        name: "dock",
        layer: "top",
        anchor: ["bottom", "left", "right"],
        exclusivity: "ignore",
        class_name: "shell-root",
        child: Widget.Box({
            hpack: "center",
            margin_bottom: 22,
            child: Widget.Box({
                class_name: shellPayload.bind().as((payload) =>
                    payload.config.dock.auto_hide
                        ? "shell-surface dock-surface auto-hide"
                        : "shell-surface dock-surface"
                ),
                spacing: 14,
                children: shellPayload.bind().as((payload) =>
                    payload.snapshot.dock_items.map((item) => DockItem(item))
                ),
            }),
        }),
    });
}

function LauncherWindow() {
    const entry = Widget.Entry({
        class_name: "search-entry",
        hexpand: true,
        placeholder_text: "Search and launch apps",
        text: launcherQuery.bind(),
        on_change: (self) => updateLauncherResults(self.text || ""),
        on_accept: () => launchFirstSearchResult(),
    });

    return Widget.Window({
        name: "launcher",
        layer: "overlay",
        anchor: ["top", "left", "right", "bottom"],
        keymode: "on-demand",
        exclusivity: "ignore",
        visible: launcherOpen.bind(),
        class_name: "shell-root overlay-backdrop",
        setup: (self) => self.keybind("Escape", () => closeTransientSurfaces()),
        child: Widget.Box({
            vpack: "start",
            hpack: "center",
            margin_top: 104,
            child: Widget.Box({
                class_name: "shell-surface overlay-card",
                vertical: true,
                spacing: 16,
                children: [
                    entry,
                    Widget.Label({
                        class_name: "subtitle muted",
                        xalign: 0,
                        label: launcherResults.bind().as((items) =>
                            items.length > 0 ? "Top matches" : "No matches"
                        ),
                    }),
                    Widget.Scrollable({
                        min_content_height: 330,
                        hscroll: "never",
                        child: Widget.Box({
                            vertical: true,
                            spacing: 10,
                            children: launcherResults.bind().as((results) =>
                                results.map((item, index) =>
                                    Widget.Box({
                                        spacing: 10,
                                        children: [
                                            Widget.Button({
                                                class_name: index === 0 ? "result-button accent" : "result-button",
                                                hexpand: true,
                                                on_clicked: async () => {
                                                    await callCli(["launch-app", item.app_id]);
                                                    closeTransientSurfaces();
                                                },
                                                child: Widget.Box({
                                                    spacing: 14,
                                                    children: [
                                                        AppIcon(item),
                                                        Widget.Box({
                                                            vertical: true,
                                                            hexpand: true,
                                                            vpack: "center",
                                                            children: [
                                                                Widget.Label({
                                                                    class_name: "title",
                                                                    xalign: 0,
                                                                    label: item.display_name,
                                                                }),
                                                                Widget.Label({
                                                                    class_name: "subtitle soft",
                                                                    xalign: 0,
                                                                    label: item.app_id,
                                                                }),
                                                            ],
                                                        }),
                                                    ],
                                                }),
                                            }),
                                            Widget.Button({
                                                class_name: "chip-button",
                                                on_clicked: () => callCli(["toggle-dock-pin", item.app_id]),
                                                child: Widget.Label({ label: "pin" }),
                                            }),
                                        ],
                                    })
                                )
                            ),
                        }),
                    }),
                    Widget.Box({
                        hpack: "end",
                        spacing: 10,
                        children: [
                            Widget.Button({
                                class_name: "shell-button",
                                on_clicked: () => closeTransientSurfaces(),
                                child: Widget.Label({ label: "close" }),
                            }),
                        ],
                    }),
                ],
            }),
        }),
    });
}

function ControlPanel() {
    return Widget.Box({
        vertical: true,
        spacing: 14,
        children: [
            Widget.Label({ class_name: "title", xalign: 0, label: "Control Center" }),
            Widget.Box({
                class_name: "metric-card",
                vertical: true,
                spacing: 6,
                children: [
                    Widget.Label({ class_name: "subtitle muted", xalign: 0, label: "Now Playing" }),
                    Widget.Label({
                        class_name: "title",
                        xalign: 0,
                        label: shellPayload.bind().as((payload) =>
                            payload.snapshot.media.title || "Nothing playing"
                        ),
                    }),
                    Widget.Label({
                        class_name: "subtitle soft",
                        xalign: 0,
                        label: shellPayload.bind().as((payload) => payload.snapshot.media.artist || "Idle"),
                    }),
                ],
            }),
            Widget.Box({
                class_name: "metric-card",
                vertical: true,
                spacing: 10,
                children: [
                    Widget.Label({ class_name: "subtitle muted", xalign: 0, label: "Audio" }),
                    Widget.Box({
                        spacing: 10,
                        children: [
                            Widget.Button({
                                class_name: "shell-button",
                                on_clicked: () =>
                                    callCli(["set-volume", `${currentShell().snapshot.quick_settings.volume_percent - 5}`]),
                                child: Widget.Label({ label: "-" }),
                            }),
                            Widget.Box({
                                class_name: "pill",
                                hexpand: true,
                                child: Widget.Label({
                                    label: shellPayload.bind().as((payload) =>
                                        `Volume ${payload.snapshot.quick_settings.volume_percent}%`
                                    ),
                                }),
                            }),
                            Widget.Button({
                                class_name: "shell-button",
                                on_clicked: () =>
                                    callCli(["set-volume", `${currentShell().snapshot.quick_settings.volume_percent + 5}`]),
                                child: Widget.Label({ label: "+" }),
                            }),
                        ],
                    }),
                    Widget.Label({ class_name: "subtitle muted", xalign: 0, label: "Brightness" }),
                    Widget.Box({
                        spacing: 10,
                        children: [
                            Widget.Button({
                                class_name: "shell-button",
                                on_clicked: () =>
                                    callCli(["set-brightness", `${currentShell().snapshot.quick_settings.brightness_percent - 5}`]),
                                child: Widget.Label({ label: "-" }),
                            }),
                            Widget.Box({
                                class_name: "pill",
                                hexpand: true,
                                child: Widget.Label({
                                    label: shellPayload.bind().as((payload) =>
                                        `Brightness ${payload.snapshot.quick_settings.brightness_percent}%`
                                    ),
                                }),
                            }),
                            Widget.Button({
                                class_name: "shell-button",
                                on_clicked: () =>
                                    callCli(["set-brightness", `${currentShell().snapshot.quick_settings.brightness_percent + 5}`]),
                                child: Widget.Label({ label: "+" }),
                            }),
                        ],
                    }),
                ],
            }),
            Widget.Box({
                class_name: "metric-card",
                vertical: true,
                spacing: 10,
                children: [
                    Widget.Label({ class_name: "subtitle muted", xalign: 0, label: "Shell Behavior" }),
                    Widget.Button({
                        class_name: "shell-button",
                        on_clicked: () =>
                            callCli([
                                "set-menu-bar-compact-mode",
                                `${!currentShell().config.menu_bar.compact_mode}`,
                            ]),
                        child: Widget.Label({
                            label: shellPayload.bind().as((payload) =>
                                payload.config.menu_bar.compact_mode
                                    ? "Disable compact menu bar"
                                    : "Enable compact menu bar"
                            ),
                        }),
                    }),
                    Widget.Button({
                        class_name: "shell-button",
                        on_clicked: () =>
                            callCli(["set-dock-auto-hide", `${!currentShell().config.dock.auto_hide}`]),
                        child: Widget.Label({
                            label: shellPayload.bind().as((payload) =>
                                payload.config.dock.auto_hide
                                    ? "Disable dock auto-hide"
                                    : "Enable dock auto-hide"
                            ),
                        }),
                    }),
                    Widget.Button({
                        class_name: "shell-button",
                        on_clicked: () =>
                            callCli([
                                "set-dock-show-running-indicators",
                                `${!currentShell().config.dock.show_running_indicators}`,
                            ]),
                        child: Widget.Label({
                            label: shellPayload.bind().as((payload) =>
                                payload.config.dock.show_running_indicators
                                    ? "Hide running indicators"
                                    : "Show running indicators"
                            ),
                        }),
                    }),
                ],
            }),
            Widget.Box({
                spacing: 10,
                children: [
                    Widget.Button({
                        class_name: "shell-button",
                        on_clicked: () => callCli(["request-lock"], false),
                        child: Widget.Label({ label: "lock" }),
                    }),
                    Widget.Button({
                        class_name: "shell-button",
                        on_clicked: () => refreshShell(),
                        child: Widget.Label({ label: "refresh" }),
                    }),
                ],
            }),
        ],
    });
}

function NotificationPanel() {
    return Widget.Box({
        vertical: true,
        spacing: 14,
        children: [
            Widget.Label({ class_name: "title", xalign: 0, label: "Notification Center" }),
            Widget.Label({
                class_name: "subtitle muted",
                xalign: 0,
                label: shellPayload.bind().as((payload) =>
                    `${payload.snapshot.notification_history.length} items in history`
                ),
            }),
            Widget.Scrollable({
                vexpand: true,
                min_content_height: 400,
                hscroll: "never",
                child: Widget.Box({
                    vertical: true,
                    spacing: 10,
                    children: shellPayload.bind().as((payload) =>
                        payload.snapshot.notification_history.map((item) =>
                            Widget.Box({
                                class_name: "metric-card",
                                vertical: true,
                                spacing: 6,
                                children: [
                                    Widget.Label({
                                        class_name: "subtitle muted",
                                        xalign: 0,
                                        label: `${item.app_name} / ${item.timestamp}`,
                                    }),
                                    Widget.Label({ class_name: "title", xalign: 0, label: item.title }),
                                    Widget.Label({
                                        class_name: "subtitle soft",
                                        xalign: 0,
                                        wrap: true,
                                        label: item.body,
                                    }),
                                ],
                            })
                        )
                    ),
                }),
            }),
        ],
    });
}

function RightPanelWindow(name, mode, panelContent) {
    return Widget.Window({
        name,
        layer: "overlay",
        anchor: ["top", "right", "bottom"],
        keymode: "on-demand",
        exclusivity: "ignore",
        visible: panelMode.bind().as((value) => value === mode),
        class_name: "shell-root",
        setup: (self) => self.keybind("Escape", () => closeTransientSurfaces()),
        child: Widget.Box({
            margin_top: 92,
            margin_bottom: 120,
            margin_end: 20,
            child: Widget.Box({
                class_name: "shell-surface panel-surface",
                vertical: true,
                spacing: 14,
                children: [
                    panelContent,
                    Widget.Button({
                        class_name: "shell-button",
                        on_clicked: () => {
                            panelMode.value = "";
                        },
                        child: Widget.Label({ label: "close" }),
                    }),
                ],
            }),
        }),
    });
}

function OverviewWindow() {
    return Widget.Window({
        name: "mission-control",
        layer: "overlay",
        anchor: ["top", "left", "right", "bottom"],
        keymode: "on-demand",
        exclusivity: "ignore",
        visible: overviewOpen.bind(),
        class_name: "shell-root overlay-backdrop",
        setup: (self) => self.keybind("Escape", () => closeTransientSurfaces()),
        child: Widget.Box({
            vertical: true,
            spacing: 18,
            margin_top: 28,
            margin_bottom: 28,
            margin_start: 28,
            margin_end: 28,
            children: [
                Widget.Box({
                    spacing: 12,
                    children: [
                        Widget.Label({ class_name: "title", label: "Mission Control" }),
                        Widget.Box({ hexpand: true }),
                        Widget.Button({
                            class_name: "shell-button",
                            on_clicked: () => closeTransientSurfaces(),
                            child: Widget.Label({ label: "close" }),
                        }),
                    ],
                }),
                Widget.Scrollable({
                    hscroll: "automatic",
                    vexpand: true,
                    child: Widget.Box({
                        spacing: 16,
                        children: shellPayload.bind().as((payload) =>
                            payload.snapshot.mission_control_workspaces.map((workspace) =>
                                Widget.Box({
                                    class_name: workspace.is_active
                                        ? "workspace-card active"
                                        : "workspace-card",
                                    vertical: true,
                                    spacing: 12,
                                    children: [
                                        Widget.Box({
                                            spacing: 10,
                                            children: [
                                                Widget.Box({
                                                    vertical: true,
                                                    hexpand: true,
                                                    children: [
                                                        Widget.Label({
                                                            class_name: "title",
                                                            xalign: 0,
                                                            label: workspace.workspace_name,
                                                        }),
                                                        Widget.Label({
                                                            class_name: "subtitle soft",
                                                            xalign: 0,
                                                            label: `${workspace.windows.length} windows`,
                                                        }),
                                                    ],
                                                }),
                                                Widget.Button({
                                                    class_name: "chip-button",
                                                    on_clicked: () =>
                                                        callCli(["activate-workspace", `${workspace.workspace_id}`]),
                                                    child: Widget.Label({
                                                        label: workspace.is_active ? "active" : "switch",
                                                    }),
                                                }),
                                            ],
                                        }),
                                        ...workspace.windows.map((window) =>
                                            Widget.Button({
                                                class_name: window.focused
                                                    ? "window-card focused"
                                                    : "window-card",
                                                on_clicked: () =>
                                                    callCli(["focus-window", window.window_id]),
                                                child: Widget.Box({
                                                    vertical: true,
                                                    spacing: 6,
                                                    children: [
                                                        Widget.Label({
                                                            class_name: "title",
                                                            xalign: 0,
                                                            label: window.title,
                                                        }),
                                                        Widget.Label({
                                                            class_name: "subtitle soft",
                                                            xalign: 0,
                                                            label: `${window.class_name} / ${window.app_id}`,
                                                        }),
                                                        Widget.Label({
                                                            class_name: "subtitle muted",
                                                            xalign: 0,
                                                            label: window.fullscreen
                                                                ? "fullscreen"
                                                                : window.floating
                                                                    ? "floating"
                                                                    : "tiling",
                                                        }),
                                                    ],
                                                }),
                                            })
                                        ),
                                    ],
                                })
                            )
                        ),
                    }),
                }),
            ],
        }),
    });
}

function handleShellAction(action) {
    switch (action) {
    case "launcher.toggle":
        toggleLauncher();
        return "ok";
    case "overview.toggle":
        toggleOverview();
        return "ok";
    case "notifications.toggle":
        togglePanel("notifications");
        return "ok";
    case "quick-settings.toggle":
        togglePanel("control");
        return "ok";
    case "lock":
        callCli(["request-lock"], false);
        return "ok";
    case "refresh":
    case "restart-shell":
        refreshShell();
        return "ok";
    default:
        return "unknown command";
    }
}

globalThis.proDeskDispatch = handleShellAction;

refreshShell();
Utils.interval(POLL_INTERVAL_MS, () => refreshShell());

App.config({
    style: `${App.configDir}/style.css`,
    windows: [
        TopBar(),
        Dock(),
        LauncherWindow(),
        RightPanelWindow("right-panel-control", "control", ControlPanel()),
        RightPanelWindow("right-panel-notifications", "notifications", NotificationPanel()),
        OverviewWindow(),
    ],
});
