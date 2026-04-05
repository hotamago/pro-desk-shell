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
