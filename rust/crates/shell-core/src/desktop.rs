use crate::state::AppEntrySummary;

pub fn parse_desktop_entry(app_id: &str, content: &str) -> Option<AppEntrySummary> {
    let mut in_desktop_entry = false;
    let mut name = None;
    let mut icon_name = String::new();
    let mut exec_command = None;
    let mut keywords = Vec::new();
    let mut startup_wm_class = String::new();
    let mut entry_type = String::new();
    let mut no_display = false;
    let mut hidden = false;

    for raw_line in content.lines() {
        let line = raw_line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }

        if line.starts_with('[') && line.ends_with(']') {
            in_desktop_entry = line == "[Desktop Entry]";
            continue;
        }

        if !in_desktop_entry {
            continue;
        }

        let Some((key, value)) = line.split_once('=') else {
            continue;
        };

        let key = key.trim();
        let value = value.trim();
        match key {
            "Type" => entry_type = value.to_owned(),
            "Name" => name = Some(value.to_owned()),
            "Icon" => icon_name = value.to_owned(),
            "Exec" => exec_command = Some(sanitize_exec_command(value)),
            "Keywords" => {
                keywords = value
                    .split(';')
                    .map(str::trim)
                    .filter(|item| !item.is_empty())
                    .map(ToOwned::to_owned)
                    .collect();
            }
            "StartupWMClass" => startup_wm_class = value.to_owned(),
            "NoDisplay" => no_display = matches!(value, "true" | "True" | "1"),
            "Hidden" => hidden = matches!(value, "true" | "True" | "1"),
            _ => {}
        }
    }

    if hidden || no_display || entry_type != "Application" {
        return None;
    }

    let display_name = name?;
    let exec_command = exec_command.filter(|value| !value.is_empty())?;

    Some(AppEntrySummary::new(
        app_id.to_owned(),
        display_name,
        icon_name,
        exec_command,
        keywords,
        startup_wm_class,
    ))
}

pub fn sanitize_exec_command(value: &str) -> String {
    let mut sanitized = value.replace("%%", "__PERCENT_ESCAPE__");
    for field_code in ["%f", "%F", "%u", "%U", "%d", "%D", "%n", "%N", "%i", "%c", "%k", "%v", "%m"] {
        sanitized = sanitized.replace(field_code, " ");
    }

    sanitized
        .replace("__PERCENT_ESCAPE__", "%")
        .split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
}

pub fn match_window_class_to_app_id(class_name: &str, apps: &[AppEntrySummary]) -> Option<String> {
    let normalized_class = normalize_for_match(class_name);
    if normalized_class.is_empty() {
        return None;
    }

    for app in apps {
        let app_id = normalize_for_match(app.app_id());
        let startup_wm_class = normalize_for_match(app.startup_wm_class());
        let display_name = normalize_for_match(app.display_name());
        if normalized_class == app_id
            || normalized_class == startup_wm_class
            || normalized_class == display_name
            || normalized_class.ends_with(&app_id)
            || (!startup_wm_class.is_empty() && normalized_class.ends_with(&startup_wm_class))
        {
            return Some(app.app_id().to_owned());
        }
    }

    None
}

pub fn search_app_entries(
    apps: &[AppEntrySummary],
    query: &str,
    max_results: usize,
) -> Vec<AppEntrySummary> {
    let max_results = max_results.max(1);
    let normalized_query = normalize_for_match(query);

    let mut ranked = apps
        .iter()
        .cloned()
        .filter_map(|app| {
            let score = if normalized_query.is_empty() {
                1
            } else {
                score_app(&app, &normalized_query)
            };

            if score > 0 {
                Some((score, app))
            } else {
                None
            }
        })
        .collect::<Vec<_>>();

    ranked.sort_by(|left, right| {
        right
            .0
            .cmp(&left.0)
            .then_with(|| left.1.display_name().cmp(right.1.display_name()))
    });
    ranked.truncate(max_results);
    ranked.into_iter().map(|(_, app)| app).collect()
}

fn score_app(app: &AppEntrySummary, normalized_query: &str) -> i32 {
    let display_name = normalize_for_match(app.display_name());
    let app_id = normalize_for_match(app.app_id());
    let startup_wm_class = normalize_for_match(app.startup_wm_class());
    let keyword_hits = app
        .keywords()
        .iter()
        .map(|keyword| normalize_for_match(keyword))
        .collect::<Vec<_>>();

    let mut score = 0;
    if display_name.starts_with(normalized_query) {
        score += 120;
    } else if display_name.contains(normalized_query) {
        score += 80;
    }

    if app_id.starts_with(normalized_query) {
        score += 70;
    } else if app_id.contains(normalized_query) {
        score += 45;
    }

    if !startup_wm_class.is_empty() && startup_wm_class.contains(normalized_query) {
        score += 40;
    }

    if keyword_hits
        .iter()
        .any(|keyword| keyword.starts_with(normalized_query))
    {
        score += 35;
    } else if keyword_hits
        .iter()
        .any(|keyword| keyword.contains(normalized_query))
    {
        score += 20;
    }

    if display_name
        .split_whitespace()
        .any(|part| part.starts_with(normalized_query))
    {
        score += 15;
    }

    score
}

fn normalize_for_match(value: &str) -> String {
    value
        .chars()
        .filter(|character| character.is_ascii_alphanumeric())
        .flat_map(char::to_lowercase)
        .collect::<String>()
}

#[cfg(test)]
mod tests {
    use super::{match_window_class_to_app_id, parse_desktop_entry, sanitize_exec_command, search_app_entries};
    use crate::AppEntrySummary;

    #[test]
    fn strips_exec_field_codes() {
        assert_eq!(
            sanitize_exec_command("kitty --title shell %U"),
            "kitty --title shell"
        );
    }

    #[test]
    fn parses_desktop_entries_for_app_catalog() {
        let app = parse_desktop_entry(
            "kitty",
            "[Desktop Entry]\nType=Application\nName=Kitty\nExec=kitty %U\nIcon=kitty\nKeywords=terminal;shell;\nStartupWMClass=kitty\n",
        )
        .expect("desktop entry should parse");

        assert_eq!(app.display_name(), "Kitty");
        assert_eq!(app.exec_command(), "kitty");
        assert_eq!(app.startup_wm_class(), "kitty");
    }

    #[test]
    fn ranks_prefix_matches_ahead_of_partial_matches() {
        let apps = vec![
            AppEntrySummary::new(
                "firefox",
                "Firefox",
                "firefox",
                "firefox",
                vec![String::from("browser")],
                String::new(),
            ),
            AppEntrySummary::new(
                "org.gnome.Nautilus",
                "Files",
                "folder",
                "nautilus",
                vec![String::from("files")],
                String::new(),
            ),
        ];

        let results = search_app_entries(&apps, "files", 5);
        assert_eq!(results.first().map(AppEntrySummary::display_name), Some("Files"));
    }

    #[test]
    fn matches_window_class_to_app_id() {
        let apps = vec![AppEntrySummary::new(
            "org.gnome.Nautilus",
            "Files",
            "folder",
            "nautilus",
            Vec::new(),
            String::from("org.gnome.Nautilus"),
        )];

        assert_eq!(
            match_window_class_to_app_id("org.gnome.Nautilus", &apps),
            Some(String::from("org.gnome.Nautilus"))
        );
    }
}
