# azure-infra

## Repository

Shared Azure infrastructure (Bicep) for my projects: resource group, Container Apps environment, SQL Server, and other resources reused across multiple projects (`shared-todo`, `product-catalog`, future ones). Per-project resources (an app's own Container App, Container Apps Job, database, Static Web App) are not provisioned here; they live in each app repo's own `infra/` folder, referencing what this repo provisions.

Read `README.md` before making changes: it documents what this repo provisions and how consuming repos reference it. Check `docs/adr/` before revisiting a past decision (Bicep over Terraform, the shared/per-project boundary, the naming convention, SQL Server auth).

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

- `main.bicep` - entry point (subscription scope): creates/adopts the resource group, calls each module scoped into it.
- `main.bicepparam` - parameter values for `main.bicep` (no secrets; the SQL admin's Entra login/object ID are identifiers, not credentials).
- `modules/` - one Bicep file per resource type (`cae.bicep`, `sql.bicep`, `alerts.bicep`); `cae.bicep` also creates the Log Analytics workspace it depends on.
- `docs/adr/` - significant, hard-to-reverse decisions.
- `docs/bootstrap-project-identity.md` - how to create a project's CD identity, role assignments, federated credential, and SQL grants; repeated for every new project.

### Validation

Run `az bicep build --file main.bicep` (also resolves `modules/`) and `az bicep build-params --file main.bicepparam` before considering a change done; CI (`.github/workflows/ci.yml`) runs the same on push/PR to `main`. Neither applies anything; see `README.md` for the deploy commands.

### Open Questions

- TODO: how a consuming repo's `infra/` references this repo's resources (`existing` resource IDs passed as parameters, or a documented lookup convention) is not decided yet.
- TODO: the old, manually created `rg-shared-prod-brs` (and everything in it, including `product-catalog`'s resources) is being abandoned in favor of `rg-shared-prod`, which this repo now provisions and has been applied; `product-catalog` still needs to be migrated separately, and the old resource group deleted once nothing depends on it.
