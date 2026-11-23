# Naming convention and tags

Names follow `<type>-<workload>[-<component>]-<env>-<region>`:

- `<type>`: `rg`, `cr`, `log`, `appi`, `cae`, `ca`, `caj`, `sql`, `sqldb`, `st`, `kv`, `id`, `ais`, `ag`, `alert`, `budget`.
- `<workload>`: `grabreu` for shared resources, the project name otherwise, without hyphens (`crewtasks`).
- `<component>`: the publishable or role, when needed (`api`, `worker`, `migration`, `cd`).
- `<env>`: `prod`. `<region>`: `brs`.

Exceptions: the Container Registry and the Storage account have no hyphens (`crgrabreuprod`, `stgrabreuprodbrs`); databases drop env and region (`sqldb-crewtasks`); storage tables start with the project's workload (`prontowatchalertstate`). Length limits: Key Vault 24, Storage account 24, Container App 32.

Everything lives in one resource group, so tags separate projects:

| Tag | Value |
|---|---|
| `project` | `platform` or the project name |
| `env` | `prod` |
| `owner` | `grabreu` |

`env` and `owner` are inherited from the resource group through Azure Policy (`modules/policy.bicep`); `project` is set on each resource. Databases get their project's tag.

**Consequences**: most Azure resources can't be renamed; changing a name means recreating the resource.
