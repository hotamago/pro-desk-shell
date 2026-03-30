#[derive(Clone, Debug, PartialEq, Eq)]
pub struct WorkspaceSummary {
    id: i32,
    name: String,
}

impl WorkspaceSummary {
    pub fn new(id: i32, name: impl Into<String>) -> Self {
        Self {
            id,
            name: name.into(),
        }
    }

    pub fn id(&self) -> i32 {
        self.id
    }

    pub fn name(&self) -> &str {
        &self.name
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ShellSnapshot {
    compositor_name: Option<String>,
    workspaces: Vec<WorkspaceSummary>,
    active_workspace: Option<String>,
}

impl ShellSnapshot {
    pub fn new(
        compositor_name: Option<String>,
        workspaces: Vec<WorkspaceSummary>,
        active_workspace: Option<String>,
    ) -> Self {
        Self {
            compositor_name,
            workspaces,
            active_workspace,
        }
    }

    pub fn placeholder() -> Self {
        Self::new(
            Some(String::from("Hyprland")),
            vec![
                WorkspaceSummary::new(1, "1:web"),
                WorkspaceSummary::new(2, "2:code"),
            ],
            Some(String::from("1:web")),
        )
    }

    pub fn compositor_name(&self) -> &str {
        self.compositor_name
            .as_deref()
            .unwrap_or("Unknown compositor")
    }

    pub fn active_workspace_name(&self) -> &str {
        self.active_workspace
            .as_deref()
            .unwrap_or("workspace:unknown")
    }

    pub fn workspaces(&self) -> &[WorkspaceSummary] {
        &self.workspaces
    }
}
