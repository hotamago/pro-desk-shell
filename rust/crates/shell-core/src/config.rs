use std::fs;

use serde::{Deserialize, Serialize};

use crate::paths::{config_dir, config_file_path};

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct ShellConfig {
    pub appearance: AppearanceConfig,
    pub bar: BarConfig,
    pub dock: DockConfig,
    pub background: BackgroundConfig,
    pub integrations: IntegrationCommands,
    pub launcher: LauncherConfig,
    pub menu_bar: MenuBarConfig,
    pub shell: ShellConfigSection,
}

impl Default for ShellConfig {
    fn default() -> Self {
        Self {
            appearance: AppearanceConfig::default(),
            bar: BarConfig::default(),
            dock: DockConfig::default(),
            background: BackgroundConfig::default(),
            integrations: IntegrationCommands::default(),
            launcher: LauncherConfig::default(),
            menu_bar: MenuBarConfig::default(),
            shell: ShellConfigSection::default(),
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct AppearanceConfig {
    pub accent_color: String,
    pub accent_color_secondary: String,
    pub accent_color_tertiary: String,
    pub enable_transparency: bool,
    pub style_preset: String,
    pub theme_name: String,
}

impl Default for AppearanceConfig {
    fn default() -> Self {
        Self {
            accent_color: String::from("#56d6ff"),
            accent_color_secondary: String::from("#ffb36b"),
            accent_color_tertiary: String::from("#7fffb4"),
            enable_transparency: true,
            style_preset: String::from("macos"),
            theme_name: String::from("macos-sunrise"),
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct BarConfig {
    pub dense: bool,
    pub show_media: bool,
    pub show_system_summary: bool,
    pub show_workspace_numbers: bool,
    pub panel_height: i32,
}

impl Default for BarConfig {
    fn default() -> Self {
        Self {
            dense: false,
            show_media: true,
            show_system_summary: true,
            show_workspace_numbers: true,
            panel_height: 88,
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct DockConfig {
    pub pinned_apps: Vec<String>,
    pub auto_hide: bool,
    pub magnification: i32,
    pub show_running_indicators: bool,
}

impl Default for DockConfig {
    fn default() -> Self {
        Self {
            pinned_apps: vec![
                String::from("org.gnome.Nautilus"),
                String::from("firefox"),
                String::from("kitty"),
                String::from("code"),
            ],
            auto_hide: false,
            magnification: 18,
            show_running_indicators: true,
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct BackgroundConfig {
    pub wallpaper_path: String,
    pub wallpaper_mode: String,
    pub ambient_blur: i32,
}

impl Default for BackgroundConfig {
    fn default() -> Self {
        Self {
            wallpaper_path: String::new(),
            wallpaper_mode: String::from("cover"),
            ambient_blur: 24,
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct IntegrationCommands {
    pub terminal: String,
    pub browser: String,
    pub file_manager: String,
    pub network_settings: String,
    pub volume_mixer: String,
}

impl Default for IntegrationCommands {
    fn default() -> Self {
        Self {
            terminal: String::from("kitty -1"),
            browser: String::from("xdg-open https://duckduckgo.com"),
            file_manager: String::from("xdg-open ."),
            network_settings: String::from("nm-connection-editor"),
            volume_mixer: String::from("pavucontrol"),
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct LauncherConfig {
    pub max_results: usize,
}

impl Default for LauncherConfig {
    fn default() -> Self {
        Self { max_results: 8 }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct MenuBarConfig {
    pub compact_mode: bool,
}

impl Default for MenuBarConfig {
    fn default() -> Self {
        Self {
            compact_mode: false,
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct ShellConfigSection {
    pub launcher_style: String,
    pub workspace_label_mode: String,
}

impl Default for ShellConfigSection {
    fn default() -> Self {
        Self {
            launcher_style: String::from("ii"),
            workspace_label_mode: String::from("named"),
        }
    }
}

pub fn load_or_create_config() -> Result<ShellConfig, String> {
    let path = config_file_path();
    if path.exists() {
        let content = fs::read_to_string(&path)
            .map_err(|error| format!("Could not read '{}': {error}", path.display()))?;
        let config: ShellConfig = serde_json::from_str(&content)
            .map_err(|error| format!("Could not parse '{}': {error}", path.display()))?;
        return Ok(config);
    }

    let config = ShellConfig::default();
    persist_config(&config)?;
    Ok(config)
}

pub fn persist_config(config: &ShellConfig) -> Result<(), String> {
    let dir = config_dir();
    fs::create_dir_all(&dir)
        .map_err(|error| format!("Could not create '{}': {error}", dir.display()))?;

    let path = config_file_path();
    let content = serde_json::to_string_pretty(config)
        .map_err(|error| format!("Could not serialize shell config: {error}"))?;
    fs::write(&path, content)
        .map_err(|error| format!("Could not write '{}': {error}", path.display()))
}
