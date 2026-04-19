# AGENTS.md

## Purpose

This document tells AI coding agents how to work effectively in `pro-desk-shell`.

The codebase is no longer a Qt/QML shell. The frontend is now AGS-based.

The goal is not just to "make it work", but to keep the project:

- architecturally clean
- easy to scale
- easy to test
- easy to review
- low in duplication
- consistent with the current AGS + Rust boundaries

## Current Stack

The repository is a Linux desktop shell, Fedora-first and Hyprland-oriented, built with:

- `AGS` for shell windows, composition, and interaction flow
- `GJS` + `GTK3` for the runtime frontend layer
- `Rust` for domain logic, config, parsing, state modeling, and Hyprland/system adapters
- `Python` for bootstrap/install/build/run orchestration via `./devsh`

## Read This Before Coding

Before making changes, read at least:

1. `README.md`
2. `docs/architecture/bootstrap.md`
3. `docs/contributing.md`
4. The files directly related to the task

If the task touches the frontend shell:

- `ags/config.js`
- `rust/crates/shell-cli/src/main.rs`
- `rust/crates/shell-hyprland/src/lib.rs`
- `rust/crates/shell-core/src/*.rs`

If the task touches build/bootstrap/dev workflow:

- `tools/bootstrap/main.py`
- `tools/bootstrap/platforms/*.py`
- `tools/bootstrap/packages/linux.py`

Do not start from assumptions when the current code already shows the intended boundary.

## Architecture Summary

Current data flow is intentionally layered:

1. `ags/` renders shell windows and UI states.
2. `ags/` calls `shell-cli` for snapshots and actions.
3. `shell-cli` exposes a narrow JSON/action bridge.
4. `shell-hyprland` talks to Hyprland IPC and system tools.
5. `shell-core` owns pure domain logic, config, state, reducers, parsers, and path helpers.

Critical rule: AGS must not become the business logic layer.

## Layer Boundaries

### `ags/`

Use `ags/` for:

- window composition
- CSS styling
- UI-only state
- interaction flow
- invoking explicit CLI actions

Do not put these here:

- Hyprland parsing
- config persistence rules
- desktop-entry parsing
- app search ranking rules
- shell business logic that should live in Rust

AGS should behave like a view/presentation layer, not a hidden backend.

### `rust/crates/shell-core/`

This is the preferred home for pure logic.

Use `shell-core` for:

- config models
- defaults
- reducers
- pure transformations
- parsers from raw text to domain data
- path helpers
- domain state structs
- search and ranking logic

Do not couple this crate to AGS, GJS, GTK, or transport-specific Hyprland wiring unless there is a very strong reason.

### `rust/crates/shell-hyprland/`

This is the runtime adapter layer.

Use `shell-hyprland` for:

- Hyprland socket discovery
- IPC requests and event handling
- Hyprland JSON parsing and mapping
- system tool integration
- runtime snapshot assembly from external systems

Do not turn this crate into a UI state layer.

### `rust/crates/shell-cli/`

This is the only frontend bridge between Rust and AGS.

Use `shell-cli` for:

- JSON snapshots for the frontend
- narrow shell action commands
- light config mutation commands

Do not use this crate for:

- large business rules
- duplicated parsers from `shell-core`
- broad runtime integration logic that belongs in `shell-hyprland`

Hard rule: if logic can live in `shell-core`, it should not live in the CLI bridge.

### `tools/bootstrap/`

Use bootstrap tooling for:

- platform detection
- dependency installation
- build/run/update/install orchestration
- AGS runtime checks
- future distro extension points

Do not mix shell runtime logic into bootstrap code.

## How To Choose The Right Layer

When adding logic, ask these questions in order:

1. Is it pure business/domain logic?
   Put it in `shell-core`.
2. Does it depend on Hyprland or system tools?
   Put it in `shell-hyprland`.
3. Is it only about exposing state/actions to AGS?
   Put it in `shell-cli`.
4. Is it only presentation or UI composition?
   Put it in `ags/`.
5. Is it only about install/build/dev workflow?
   Put it in `tools/bootstrap/`.

If a change blurs boundaries, stop and refactor toward thin adapters and a stronger domain layer.

## Design Principles

### SOLID in this repository

- Each file, struct, component, and adapter should have one main reason to change.
- Prefer extension through new helpers, adapters, reducers, or components.
- Keep bridge APIs small.
- Domain logic should not depend on UI frameworks.

### DRY, KISS, YAGNI

- Do not duplicate parsers, mappings, command builders, or style tokens.
- Prefer readable code over clever code.
- Do not introduce future-facing abstractions without a real present need.

## General Coding Standards

Always:

- use clear, boring names
- keep functions focused
- avoid hidden side effects
- return or log actionable error messages with context
- keep defaults intentional
- avoid new dependencies unless clearly justified

Never:

- move complex business logic into AGS frontend code
- duplicate domain mapping across crates
- let the CLI bridge become a second domain layer
- scatter hardcoded system commands across the codebase
- create vague buckets like `helpers`, `misc`, or `common` without domain meaning

## Language-Specific Guidance

### Rust

Prefer:

- pure functions
- immutable-by-default flows
- small structs with obvious responsibilities
- `Result` errors with context
- targeted unit tests for parser/reducer behavior

Do:

- push pure logic into `shell-core`
- keep adapter code in `shell-hyprland`
- keep AGS-facing JSON/action glue in `shell-cli`

Do not:

- mix IO, parsing, mapping, formatting, and mutation in one long function
- invent traits or abstractions too early

### AGS / JavaScript

Prefer:

- small components
- simple reactive state
- reusable CSS classes
- keeping GTK widget trees readable

Do:

- keep shell data loading behind the CLI bridge
- keep AGS-specific logic local to windows/components
- use CSS for visual consistency

Do not:

- reimplement Rust logic in frontend JavaScript when a Rust seam already exists
- build giant all-knowing frontend modules if a component split makes things clearer
- hide shell behavior in ad-hoc subprocess strings everywhere

### Python

Prefer:

- explicit flow
- predictable subprocess handling
- clean platform adapter separation

Do:

- extend distro support via adapter logic and package maps
- add unit tests in `tools/bootstrap/tests/`

Do not:

- rely on clever shell tricks
- pile unrelated branching into the main entrypoint

## Feature Growth Rules

When adding a feature, prefer this sequence:

1. Add or refine domain data in `shell-core`
2. Add pure parsing/transformation logic in `shell-core`
3. Add runtime integration in `shell-hyprland`
4. Expose the smallest necessary API in `shell-cli`
5. Render and compose it in `ags/`

Do not start from the UI and force architecture downward unless the task is intentionally tiny.

## State, Config, and Side Effects

### Config

- Persistent config lives at `~/.config/pro-desk-shell/config.json`
- Config changes should go through explicit models and persistence paths
- Frontend code should not write config files directly

### Runtime State

- Runtime state lives under `~/.local/state/pro-desk-shell`
- Prefer explicit CLI actions and Rust-side persistence over ad-hoc frontend side effects

### Side Effects

- Side effects belong in adapter/integration layers
- Domain layers should receive clean input and return clean output

## Testing And Verification

Before finishing a task, run as much of this set as the environment supports:

```bash
python3 -m unittest discover -s tools/bootstrap/tests
CARGO_TARGET_DIR=/tmp/pro-desk-shell-cargo-test cargo test --manifest-path rust/Cargo.toml
CARGO_TARGET_DIR=/tmp/pro-desk-shell-cargo-test cargo build --manifest-path rust/Cargo.toml -p shell_cli
./devsh build
./devsh doctor
```

If AGS runtime dependencies are not installed locally, say so clearly when reporting verification.

## Pre-Edit Checklist

- Confirm the correct architectural layer
- Read the directly related files
- Check whether an existing helper/component/function already solves part of the problem
- Understand the current data flow
- Avoid touching generated or build output unless explicitly required

## Pre-Finish Checklist

- Code lives in the correct layer
- No meaningful logic duplication was introduced
- Naming is clear
- Interfaces are narrow and intentional
- Errors include useful context
- Tests were added or updated if behavior changed
- Verification matched the scope of the task
- If something could not be verified, say so clearly

## Anti-Patterns To Avoid

- AGS directly parsing raw shell command output that belongs in Rust
- Hyprland-specific shapes leaking all over the frontend
- duplicated domain logic across `shell-core`, `shell-hyprland`, and `shell-cli`
- small features requiring edits across too many layers because APIs were left vague

## Documentation Expectations

When adding a meaningful new module, integration, or architectural flow, update one or more of these when appropriate:

- `README.md`
- `docs/architecture/bootstrap.md`
- `docs/contributing.md`
- short local module comments where they materially help future maintainers

## One-Sentence Rule

Keep AGS presentational, keep `shell-cli` thin, keep `shell-hyprland` as the runtime adapter, and push real logic into `shell-core` whenever possible.
