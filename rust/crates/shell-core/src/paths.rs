use std::env;
use std::path::PathBuf;

const SHELL_DIRECTORY_NAME: &str = "pro-desk-shell";
const CONFIG_FILE_NAME: &str = "config.json";
const ACTION_MAILBOX_FILE_NAME: &str = "action-request.txt";

pub fn xdg_config_home() -> PathBuf {
    env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            env::var_os("HOME")
                .map(PathBuf::from)
                .unwrap_or_else(|| PathBuf::from("."))
                .join(".config")
        })
}

pub fn xdg_state_home() -> PathBuf {
    env::var_os("XDG_STATE_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            env::var_os("HOME")
                .map(PathBuf::from)
                .unwrap_or_else(|| PathBuf::from("."))
                .join(".local/state")
        })
}

pub fn xdg_data_home() -> PathBuf {
    env::var_os("XDG_DATA_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            env::var_os("HOME")
                .map(PathBuf::from)
                .unwrap_or_else(|| PathBuf::from("."))
                .join(".local/share")
        })
}

pub fn xdg_data_dirs() -> Vec<PathBuf> {
    let configured = env::var_os("XDG_DATA_DIRS")
        .map(|value| env::split_paths(&value).collect::<Vec<_>>())
        .unwrap_or_else(|| {
            vec![
                PathBuf::from("/usr/local/share"),
                PathBuf::from("/usr/share"),
            ]
        });

    configured
        .into_iter()
        .filter(|path| !path.as_os_str().is_empty())
        .collect()
}

pub fn desktop_applications_dirs() -> Vec<PathBuf> {
    let mut directories = vec![xdg_data_home().join("applications")];
    directories.extend(
        xdg_data_dirs()
            .into_iter()
            .map(|path| path.join("applications")),
    );

    directories
}

pub fn icon_search_dirs() -> Vec<PathBuf> {
    let mut directories = vec![
        xdg_data_home().join("icons"),
        xdg_data_home().join("pixmaps"),
    ];

    if let Some(home) = env::var_os("HOME") {
        directories.push(PathBuf::from(home).join(".icons"));
    }

    for path in xdg_data_dirs() {
        directories.push(path.join("icons"));
        directories.push(path.join("pixmaps"));
    }

    directories
}

pub fn config_dir() -> PathBuf {
    xdg_config_home().join(SHELL_DIRECTORY_NAME)
}

pub fn config_file_path() -> PathBuf {
    config_dir().join(CONFIG_FILE_NAME)
}

pub fn state_dir() -> PathBuf {
    xdg_state_home().join(SHELL_DIRECTORY_NAME)
}

pub fn action_mailbox_path() -> PathBuf {
    state_dir().join(ACTION_MAILBOX_FILE_NAME)
}
