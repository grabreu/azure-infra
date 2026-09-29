# Resource names follow <abbrev>-<app>[-<component>]-<env>[-<uniqueness-suffix>], without a region segment

`<abbrev>` is the official Microsoft Cloud Adoption Framework abbreviation for the resource type (`ca`, `cae`, `caj`, `sql`, `sqldb`, `log`, `id`, ...). `<app>` is `shared` for resources in this repo, or the project's slug for per-project resources. `<component>` only appears when a resource isn't the whole product, e.g. `-api-` when a project has a separate frontend hosted elsewhere.

`<env>` is `prod` today, kept even with a single environment: most Azure resource types can't be renamed, and a more complex project may need a `stg` counterpart later. Region is left out: every resource is deployed to Brazil South, a constant with no realistic alternative, so it adds no distinguishing information, unlike environment.

**Consequences**: if a second region is ever needed, every existing resource would need to be recreated under a new name, since nothing today reserves that segment.
