# dk-platform

The Kubernetes platform for my own apps on my domain – first of all
[Storybook](https://github.com/DimiJonas/storybook), a private photo journal that is in daily use.
Built as a realistic, hardened setup (k3s, GitOps, single sign-on, policies, signed images,
monitoring), and as the way I learn DevSecOps, security engineering, IAM and cloud engineering
properly: every step is explained before it's built, every decision is recorded with its options
and reasons, and every hardening is measured against a published guide.

**Status: phase 0 – foundations.** Nothing runs on Kubernetes yet. Production is still the hardened
VPS ([dk-srv](https://github.com/DimiJonas/dk-srv)) and stays untouched until a planned cutover.
Where things stand: [`ROADMAP.md`](ROADMAP.md), "Where we are".

## Now and target

**Now** – one hardened VPS: nginx in front, the backend as its own user in a systemd sandbox,
PostgreSQL, photos on disk, dk-srv around everything.

![The storybook today: phones and browsers reach nginx on a hardened VPS; nginx serves the app, the photos and the landing page and passes the API to the backend, which runs in a systemd sandbox next to PostgreSQL; a nightly encrypted backup is pulled to the laptop; dk-srv hardens and watches the server](docs/diagrams/now.svg)

**Target** – a hardened k3s node: Traefik in front, one namespace per app, the photo conversion
isolated in its own worker, Keycloak and Vault for identities and secrets, and the platform's
guards (Argo CD, Cilium, Kyverno, monitoring) around everything.

![The target: phones and browsers reach Traefik on a k3s node; Traefik routes to the landing page, Keycloak and the storybook's frontend and backend; the backend uses PostgreSQL, the photos volume, Keycloak and Vault; an isolated photo worker converts uploads; Argo CD deploys from GitHub and the private environment repository; Cilium, Kyverno and monitoring guard the platform](docs/diagrams/target.svg)

The red numbers are the **trust boundaries** – the places where something less trusted meets
something more trusted. The same number means the same boundary in both pictures; the threat
model (phase 0) goes through each of them. Each component, step by step:
[`docs/architecture.md`](docs/architecture.md).

## Repositories

| Repository | What | Visibility |
|---|---|---|
| [storybook](https://github.com/DimiJonas/storybook) | the app; later also its Dockerfiles, CI and Kubernetes manifests (`deploy/`) | public |
| [dk-srv](https://github.com/DimiJonas/dk-srv) | the host: CIS hardening, checks, notifications; adapted for a k3s node in phase 7 | public |
| dk-home | the landing page of the domain; becomes a small container app | private |
| **dk-platform** (this one) | the platform: cluster setup, shared components, policies, documentation, decisions | public |
| dk-platform-env | the environments: the domain, which app version runs where, encrypted secrets | private |

Why this split: [ADR 0002](docs/decisions/0002-repository-layout.md). Nothing in the public
repositories belongs to one server: no domain (examples use `example.org`), no addresses, no keys,
no server size or provider.

## Documentation

| File | What's in it |
|---|---|
| [`ROADMAP.md`](ROADMAP.md) | the phases and steps, how we work, where we are, the open decisions |
| [`docs/architecture.md`](docs/architecture.md) | now and target, component by component; what the move has to handle |
| [`docs/decisions/`](docs/decisions/) | the decisions (ADRs): options, reasons, consequences |
| [`docs/learning-map.md`](docs/learning-map.md) | every technology: what it is, what it's for here, where to read |
| [`SECURITY.md`](SECURITY.md) | the guides per layer, the measured scores, the accepted risks |
| [`HARDENING.md`](HARDENING.md) | how the hardening is done and measured, mechanism by mechanism |
| [`setup-commands.md`](setup-commands.md) | from a new machine to everything running – and adding a node |
| [`maintenance-commands.md`](maintenance-commands.md) | what to do in which situation |
| [`docs/diagrams/`](docs/diagrams/) | the TikZ pictures and how to build them |

Each platform component gets its own `README.md` next to its configuration (template:
[`docs/templates/component-readme.md`](docs/templates/component-readme.md)).

## Status

A personal project, built alongside daily life – no fixed dates. Next: the threat model.

© All rights reserved. The code is public to read; there is no license for reuse.
