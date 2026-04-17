use shell_core::{
    parse_brightnessctl_machine_output, parse_nmcli_active_wifi, parse_playerctl_metadata_output,
    parse_upower_output, parse_wpctl_volume_output, reduce_ui_state, PlaybackStatus, ShellAction,
    ShellUiState,
};

#[test]
fn playerctl_parser_extracts_metadata() {
    let media = parse_playerctl_metadata_output("Playing\nRoad to Focus\nShell Artist")
        .expect("playerctl output should parse");

    assert_eq!(media.title(), "Road to Focus");
    assert_eq!(media.artist(), "Shell Artist");
    assert_eq!(media.status(), PlaybackStatus::Playing);
}

#[test]
fn wpctl_parser_reads_percentages() {
    assert_eq!(parse_wpctl_volume_output("Volume: 0.58"), Some(58));
}

#[test]
fn brightnessctl_parser_reads_machine_output() {
    assert_eq!(
        parse_brightnessctl_machine_output("intel_backlight,backlight,937,1200,78%"),
        Some(78)
    );
}

#[test]
fn nmcli_parser_returns_active_wifi_name() {
    assert_eq!(
        parse_nmcli_active_wifi("no:Guest\nyes:Studio Mesh"),
        Some(String::from("Studio Mesh"))
    );
}

#[test]
fn upower_parser_extracts_battery_state() {
    let battery = parse_upower_output(
        r#"
        state:               charging
        percentage:          84%
        "#,
    )
    .expect("upower output should parse");

    assert_eq!(battery.percent(), 84);
    assert!(battery.is_charging());
}

#[test]
fn reducer_closes_launcher_when_overview_opens() {
    let mut ui_state = ShellUiState {
        launcher_open: true,
        ..ShellUiState::default()
    };

    reduce_ui_state(&mut ui_state, ShellAction::OverviewToggle);

    assert!(!ui_state.launcher_open);
    assert!(ui_state.overview_open);
}
