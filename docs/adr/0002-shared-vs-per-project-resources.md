# Shared resources here, per-project resources in each project repo

This repo provisions what multiple projects reuse: resource group, Container Registry, Container Apps environment, Log Analytics, SQL Server, Storage account, Foundry account, Key Vault. A project's Container App, Job, database, and storage table live in its own `infra/`, referencing these as `existing`.

Alternative: each project owning its own environment and SQL Server, duplicating cost.

**Consequences**: renaming a shared resource means updating every project's `infra/`.

A Container App or Job pulls from the shared registry with its system-assigned identity, which needs `AcrPull` on that registry. The role assignment needs the identity's principal id, so it can only be created after the app or job exists, and creating the app or job with the registry configured (`registries: [{ server, identity: 'system' }]`) before the role exists hangs the deployment in `InProgress`, even with a public image. Cancelling the deployment does not stop it and further changes fail with `ContainerAppsJobOperationInProgress`; the resource has to be deleted. Observed with a Job; Container Apps are assumed to behave the same.

So the first deployment of every project uses a public placeholder image (`mcr.microsoft.com/k8se/quickstart-jobs:latest` for a Job, `mcr.microsoft.com/k8se/quickstart:latest` for an app) and the Bicep leaves `registries` empty unless the image comes from the registry (`startsWith(image, '<loginServer>/')`). The `AcrPull` assignment lives in the same Bicep. A second deployment with the real image, after the role propagates (a minute or two), configures the registry. Later deployments pass the image currently published by CD.
