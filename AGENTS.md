# AGENTS.md

## Purpose

This document tells AI coding agents how to work effectively in `pro-desk-shell`.

The goal is not just to "make it work", but to keep the codebase:

- architecturally clean
- easy to scale
- easy to test
- easy to review
- low in duplication
- consistent with existing project boundaries

This repository is a Linux desktop shell, Fedora-first, Hyprland-oriented, built with:

- `C++17` + `Qt6` for app bootstrap and `layer-shell-qt`
- `QML` for UI composition and presentation
- `Rust` for domain logic, state, parsing, runtime adapters, and the QML bridge
- `Python` for bootstrap/install/build orchestration via `./devsh`
- `CMake` as the top-level build entrypoint

## Read This Before Coding

Before making changes, read at least:

1. `README.md`
2. `docs/architecture/bootstrap.md`
3. `docs/contributing.md`
4. The files directly related to the task

If the task touches shell runtime UI, also read:

- `qml/App.qml`
- `rust/crates/shell-ui-bridge/src/shell_state.rs`
- `rust/crates/shell-hyprland/src/lib.rs`
- `rust/crates/shell-core/src/*.rs`

If the task touches build/bootstrap/dev workflow, also read:

- `CMakeLists.txt`
- `tools/bootstrap/main.py`
- `tools/bootstrap/platforms/*.py`
- `tools/bootstrap/packages/linux.py`

Do not start with assumptions when the current code already shows the intended boundary.

## Architecture Summary

Current data flow is intentionally layered:

1. `cpp/` starts the Qt application and QML engine.
2. `shell-ui-bridge` exposes Rust-backed state into QML through `cxx-qt`.
3. `shell-ui-bridge` consumes runtime snapshots from `shell-hyprland`.
4. `shell-hyprland` talks to Hyprland IPC and system CLI tools.
5. `shell-core` owns pure domain logic, config, state, reducers, parsers, and path helpers.
6. `qml/` renders the UI and triggers narrow, explicit actions exposed by the bridge.

Critical rule: `QML` must not become the business logic layer.

## Layer Boundaries

### `cpp/`

Use `cpp/` only for:

- `QGuiApplication`
- `QQmlApplicationEngine`
- `layer-shell-qt`
- root window setup
- thin startup wiring

Do not put these here:

- shell state logic
- Hyprland parsing
- config persistence
- domain rules

If code does not need direct ownership of Qt window/bootstrap lifecycle, it probably belongs in Rust.

### `qml/`

Use `qml/` for:

- layout
- visual composition
- presentation-only state
- animation
- bindings
- invoking explicitly exposed bridge actions

Do not put these here:

- system command parsing
- complex business logic
- compositor/runtime integration rules
- config persistence rules
- Hyprland-specific data processing

QML should behave like a view/presentation layer, not a hidden backend.

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
- logic that should be easy to unit test

Do not couple this crate to Qt, QML, or transport-specific Hyprland wiring unless there is a very strong reason.

### `rust/crates/shell-hyprland/`

This is the runtime adapter layer.

Use `shell-hyprland` for:

- Hyprland socket discovery
- IPC requests and event handling
- Hyprland JSON parsing and mapping
- system tool integration
- runtime snapshot assembly from external systems

Do not turn this crate into a UI state layer or a Qt bridge layer.

### `rust/crates/shell-ui-bridge/`

This is the only bridge between Rust and QML.

Use `shell-ui-bridge` for:

- `cxx-qt`
- QML-visible objects and properties
- mapping domain/runtime state into QML-facing values
- narrow invokables from UI into Rust

Do not use this crate for:

- large business rules
- duplicated parsers from `shell-core`
- broad runtime integration logic

Hard rule: if logic can live in `shell-core`, it should not live in the bridge.

### `tools/bootstrap/`

Use bootstrap tooling for:

- platform detection
- dependency installation
- build/run/update/install orchestration
- future distro extension points

Do not mix shell runtime logic into bootstrap code.

## How To Choose The Right Layer

When adding logic, ask these questions in order:

1. Is it pure business/domain logic?
   Put it in `shell-core`.
2. Does it depend on Hyprland or system tools?
   Put it in `shell-hyprland`.
3. Is it only about exposing state/actions to QML?
   Put it in `shell-ui-bridge`.
4. Is it only presentation or UI composition?
   Put it in `qml/`.
5. Is it only about app/window bootstrap?
   Put it in `cpp/`.
6. Is it only about install/build/dev workflow?
   Put it in `tools/bootstrap/`.

If a change blurs boundaries, stop and refactor toward thin adapters and a stronger domain layer.

## Design Principles

### SOLID in this repository

#### Single Responsibility

- Each file, struct, component, and adapter should have one main reason to change.
- Avoid "god objects" that read config, call system tools, format UI strings, and mutate state all in one place.

#### Open/Closed

- Prefer extension through new helpers, adapters, reducers, or components.
- Avoid broad edits across unrelated layers for a small feature when a clean seam can be added instead.

#### Liskov Substitution

- If you introduce abstractions, implementations must keep the contract predictable.
- Do not create generic APIs with surprising special-case behavior.

#### Interface Segregation

- Keep bridge APIs small.
- Expose only the properties and invokables QML actually needs.

#### Dependency Inversion

- Domain logic should not depend on UI frameworks.
- Adapters should depend on domain types, not the reverse.

### DRY, KISS, YAGNI

- Do not duplicate parsers, mappings, command builders, or style tokens.
- Extract helpers when repetition is meaningful, not prematurely.
- Prefer readable code over clever code.
- Do not introduce future-facing abstractions without a real present need.

### Composition Over Inheritance

- In QML, prefer reusable components.
- In Rust and Python, prefer small modules/helpers/composition over deep hierarchies.

## General Coding Standards

Always:

- use clear, boring names
- keep functions focused
- avoid hidden side effects
- return or log actionable error messages with context
- keep defaults intentional
- avoid new dependencies unless clearly justified
- avoid touching generated or build output unless explicitly required

Never:

- move complex business logic into QML JavaScript
- duplicate domain mapping across crates
- let the bridge become a second domain layer
- scatter hardcoded system commands across the codebase
- create vague buckets like `helpers`, `misc`, or `common` without domain meaning
- add abstraction just to make the code look "enterprise"

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
- split parsing/mapping helpers into named functions when it improves clarity
- use constructors/helpers where they reduce scattered state assembly
- add tests when behavior changes

Do not:

- mix IO, parsing, mapping, formatting, and mutation in one long function
- invent traits/enums too early without clear multiple-use justification
- keep reusable logic trapped in `shell-ui-bridge`

### QML

Prefer:

- small components
- simple bindings
- reusable style primitives
- consistency with existing `ShellTheme`, `SurfaceCard`, buttons, and fields

Do:

- keep inline JavaScript minimal
- extract repeated UI patterns into components
- use `required property` where appropriate
- reuse current fonts, colors, and tokens when possible

Do not:

- build complex branching behavior in QML JavaScript
- hardcode a large new set of unrelated visual tokens when shared ones already exist
- create giant multi-concern QML files

### C++

Keep it thin and practical.

Do:

- limit changes to startup, engine wiring, and layer-shell integration
- keep QML load failures and bootstrap errors explicit

Do not:

- move domain logic into `cpp/`
- use C++ as a dumping ground just because Qt already exists there

### Python

Prefer:

- explicit flow
- predictable subprocess handling
- pure helpers where practical
- clean platform adapter separation

Do:

- extend distro support via package maps and adapters
- add unit tests in `tools/bootstrap/tests/`
- keep CLI behavior obvious and stable

Do not:

- rely on clever shell tricks
- pile unrelated branching into the main entrypoint
- spread platform logic around the repo outside the adapter model

## Feature Growth Rules

When adding a feature, prefer this sequence:

1. Add or refine domain data in `shell-core`
2. Add pure parsing/transformation/reducer logic in `shell-core`
3. Add runtime integration in `shell-hyprland`
4. Expose the smallest necessary API in `shell-ui-bridge`
5. Render and compose it in `qml/`

Do not start from the UI and force architecture downward unless the task is an intentionally tiny prototype. Even then, keep the upgrade path clean.

## Reuse Rules

The goal is less code and better reuse, not abstraction for its own sake.

Good places to reuse:

- parser patterns
- snapshot mapping patterns
- reusable UI cards/buttons/fields
- subprocess/platform command construction
- validation/checklist flow

Do not force reuse when:

- the semantics are different even if the shape looks similar
- the abstraction makes naming weaker
- the helper makes call sites harder to read

## State, Config, and Side Effects

### Config

- Persistent config currently lives at `~/.config/pro-desk-shell/config.json`
- Config changes should go through explicit models and persistence paths
- UI code should not write config files directly

### Runtime State

- Runtime state currently lives under `~/.local/state/pro-desk-shell`
- A mailbox action flow already exists; reuse it instead of inventing cross-layer command paths without a strong reason

### Side Effects

- Side effects belong in adapter/integration layers
- Domain layers should receive clean input and return clean output

## Testing And Verification

Before finishing a task, run as much of this set as the environment supports:

```bash
python3 -m unittest discover -s tools/bootstrap/tests
CARGO_TARGET_DIR=/tmp/pro-desk-shell-cargo-test cargo test --manifest-path rust/Cargo.toml
CARGO_TARGET_DIR=/tmp/pro-desk-shell-cargo-test cargo build --manifest-path rust/Cargo.toml -p shell_ui_bridge
./devsh build
```

If the task is documentation-only, at minimum verify:

- the markdown is clear
- the content matches the current repository architecture
- it does not contradict `README.md` or `docs/`

## Pre-Edit Checklist

- Confirm the correct architectural layer
- Read the directly related files
- Check whether an existing helper/component/function already solves part of the problem
- Understand the current data flow
- Avoid touching `build/`, `rust/target/`, or `__pycache__/` unless explicitly required

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

- QML directly calling shell commands
- bridge code parsing raw command output that belongs in `shell-core` or `shell-hyprland`
- Hyprland-specific shapes leaking widely into QML
- duplicated domain logic across `shell-core`, `shell-hyprland`, and `shell-ui-bridge`
- small features requiring edits across too many layers because APIs were left vague
- files that load state, mutate UI flags, persist config, and format display strings all together without separation

## Documentation Expectations

When adding a meaningful new module, integration, or architectural flow, update one or more of these when appropriate:

- `README.md`
- `docs/architecture/bootstrap.md`
- `docs/contributing.md`
- short local module comments where they materially help future maintainers

## One-Sentence Rule

Keep `cpp` thin, keep `QML` presentational, keep `shell-ui-bridge` as a bridge, keep `shell-hyprland` as the runtime adapter, and push real logic into `shell-core` whenever possible.
