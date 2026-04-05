use crate::{BatterySummary, MediaSummary, PlaybackStatus};

pub fn parse_playerctl_metadata_output(output: &str) -> Option<MediaSummary> {
    let mut lines = output.lines().map(str::trim).filter(|line| !line.is_empty());
    let status = match lines.next()? {
        "Playing" => PlaybackStatus::Playing,
        "Paused" => PlaybackStatus::Paused,
        "Stopped" => PlaybackStatus::Stopped,
        _ => PlaybackStatus::Unknown,
    };
    let title = lines.next().unwrap_or("Nothing playing");
    let artist = lines.next().unwrap_or("Unknown artist");
    Some(MediaSummary::new("playerctl", title, artist, status))
}

pub fn parse_wpctl_volume_output(output: &str) -> Option<i32> {
    let volume_token = output
        .split_whitespace()
        .find(|token| token.contains('.') || token.chars().all(|character| character.is_ascii_digit()))?;
    let numeric = volume_token.parse::<f32>().ok()?;
    Some((numeric * 100.0).round() as i32)
}

pub fn parse_brightnessctl_machine_output(output: &str) -> Option<i32> {
    output
        .split(',')
        .find_map(|segment| segment.trim().strip_suffix('%'))
        .and_then(|value| value.parse::<i32>().ok())
}

pub fn parse_nmcli_active_wifi(output: &str) -> Option<String> {
    output.lines().find_map(|line| {
        let mut parts = line.splitn(2, ':');
        let active = parts.next()?.trim();
        let ssid = parts.next()?.trim();
        if active == "yes" && !ssid.is_empty() {
            Some(ssid.to_owned())
        } else {
            None
        }
    })
}

pub fn parse_upower_output(output: &str) -> Option<BatterySummary> {
    let mut percent = None;
    let mut charging = false;

    for raw_line in output.lines() {
        let line = raw_line.trim();
        if let Some(value) = line.strip_prefix("percentage:") {
            percent = value.trim().strip_suffix('%')?.trim().parse::<i32>().ok();
        } else if let Some(value) = line.strip_prefix("state:") {
            let state = value.trim();
            charging = matches!(state, "charging" | "fully-charged");
        }
    }

    percent.map(|value| BatterySummary::new(value, charging))
}
