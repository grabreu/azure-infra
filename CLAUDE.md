# azure-infra

## Repository

Shared Azure infrastructure (Bicep) for the portfolio's app repos: resource group, Container Apps environment, SQL Server, and other resources reused across multiple projects (`shared-todo`, `product-catalog`, future ones). Per-project resources (an app's own Container App, Container Apps Job, database, Static Web App) are not provisioned here; they live in each app repo's own `infra/` folder, referencing what this repo provisions.

Read `README.md` before making changes: it documents what this repo provisions and how consuming repos reference it. `docs/architecture.md` (module layout) and `docs/adr/` (significant, hard-to-reverse decisions, e.g. Bicep over Terraform, the shared/per-project boundary) don't exist yet; add them once the first module lands, and check `docs/adr/` before revisiting a past decision from then on.

## General Rules

- Keep changes scoped to the requested change.
- Prefer existing patterns over introducing new abstractions.
- Do not add dependencies unless they are necessary.
- Do not fill gaps with assumptions when the user hasn't given the information: ask, or mark it as pending.
- Do not claim a validation command passed unless it was actually run.
- Code, comments, commit messages, and documentation are always written in English.
- Do not use em dashes; use a comma, colon, semicolon, parentheses, or a separate sentence instead.

## Git

- Do not create or switch branches unless explicitly requested.
- Do not create commits unless explicitly requested.
- Do not push unless explicitly requested.
- Keep commits focused on the requested change.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) (`type: summary`).

## Documentation

### Audience

Future-you revisiting this months later, or someone browsing the portfolio to see how the shared infra is organized. Not onboarding material; keep it concise and skimmable.

### Content Rules

- State facts concisely. Avoid unnecessary explanations or trailing rationale.
- Do not document information that is already obvious from the repository structure or configuration.
- Do not invent features, API shapes, or future direction: mark undecided things as TODO.
- Document a capability only after it is implemented and verified.
- Use proper Markdown headings (`##`, `###`), not bold text as headings.

---

## Project-Specific Guidelines

### Source

- `main.bicep` - entry point, provisions the shared resources into the resource group. Not created yet.
- `modules/` - reusable Bicep modules, one per resource type. Not created yet.

### Naming convention

`<caf-abbrev>-<app>[-<component>]-<env>[-<uniqueness-suffix>]`, no region segment.

- `<caf-abbrev>`: the official Microsoft CAF abbreviation for the resource type (`ca`, `cae`, `caj`, `sql`, `sqldb`, `id`, ...).
- `<app>`: `shared` for resources reused across projects (this repo's resources); the project slug for per-project resources (defined in that project's own `infra/`).
- `[-<component>]`: only when the resource is not the whole product (e.g. `-api-` when a project has a separate frontend hosted elsewhere).
- `<env>`: `prod` today; kept even with a single environment, since adding one later means recreating most Azure resource types.
- `[-<uniqueness-suffix>]`: only for resources requiring global DNS uniqueness across all of Azure (e.g. the SQL Server's `-grabreu` suffix).

Exception: the resource group (`rg-shared-prod-brs`) keeps its existing name; resource groups can't be renamed, so region stays in that one name as a historical artifact.

### Validation

TODO: no Bicep files yet, no CI. Once `main.bicep` exists, this section documents `az bicep build`/`bicep lint` (or equivalent) and the CI workflow that runs them.

### Open Questions

- TODO: first module (resource group contents: CAE, SQL Server) not written yet; those resources exist today from manual `az cli` creation and need to be imported/codified here.
- TODO: CI validating the Bicep (build/lint) not set up.
- TODO: how a consuming repo's `infra/` references this repo's resources (`existing` resource IDs passed as parameters, or a documented lookup convention) is not decided yet.
