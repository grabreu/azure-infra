# Resource names follow <abbrev>-<app>[-<component>]-<env>[-<uniqueness-suffix>], without a region segment

`<abbrev>` is the official Microsoft Cloud Adoption Framework abbreviation for the resource type (`ca`, `cae`, `caj`, `sql`, `sqldb`, `log`, `id`, ...). `<app>` is `shared` for resources in this repo, or the project's slug for per-project resources, hyphens and all (e.g. `shared-todo`, not `sharedtodo`); splitting it would make the pattern ambiguous to parse in theory, but nothing here ever parses it, and every other place the project is named (the repo, the domain, the image) already uses the hyphen.

`<component>` only appears on a resource that could be mistaken for the whole product **and** has a sibling of the same resource type to disambiguate from, e.g. `-api-` on the Container App (`ca-shared-todo-api-prod`) because a Container App serves traffic and a project's frontend could be a separate Container App instead of living elsewhere. A Container Apps Job or a database don't get a component: neither is the kind of resource anyone mistakes for "the whole product" in the first place (a Job is legibly a background task, not a product), and there's no sibling of that type to tell apart (a static frontend has no database and no migration job of its own).

`<env>` is `prod` today, kept even with a single environment: most Azure resource types can't be renamed, and a more complex project may need a `stg` counterpart later. Region is left out: every resource is deployed to Brazil South, a constant with no realistic alternative, so it adds no distinguishing information, unlike environment.

**Consequences**: if a second region is ever needed, every existing resource would need to be recreated under a new name, since nothing today reserves that segment.
