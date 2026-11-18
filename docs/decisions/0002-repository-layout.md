# 0002: App repositories, a public platform repository and a private environment repository

- **Status:** accepted
- **Date:** 2026-11-17
- **Decided by:** the owner (DimiJonas)
- **Prepared by:** Claude (options, information, recommendation)

## Context and problem

The platform brings three new kinds of content: the shared platform (cluster setup, components,
policies, docs), each app's deployment (Dockerfiles, Kubernetes manifests), and the environments
(the domain, which version of each app runs where, encrypted secrets). The domain and secrets must
never be public; everything else should be visible as a showcase. Which repository holds what?

## Decision drivers

- the domain and secrets never in a public repository (hard rule)
- the work visible to others
- an app's code and its deployment change together
- room for more apps on the same platform ([ADR 0004](0004-one-platform-for-all-apps.md))
- a clear, logged moment when something goes live

## Considered options

1. One repository for everything, including the environments
2. App repositories (with their own manifests) + a public platform repository + a private
   environment repository
3. Like 2, but all apps' manifests in the platform repository
4. Platform and environments together in one private repository, apps public

## Decision

**Chosen option: 2.**

| Repository | Holds | Visibility |
|---|---|---|
| each app (`storybook`, later others; `dk-home`) | code, Dockerfiles, CI, its Kubernetes base manifests (`deploy/`) | public (`dk-home` private: its picture) |
| `dk-platform` | what all apps share: cluster setup, platform components, policies, Argo CD bootstrap, docs, decisions | public |
| `dk-platform-env` | per environment (local, production): the domain, which version of each app and component runs, overlays, SOPS-encrypted secrets | private |
| `dk-srv` | the host (unchanged in its role) | public |

**Reason (owner, in his own words):** "It's the most versatile and extendable. Only the
environment files have to be private. All other repos are nice to showcase and don't have anything
to hide."

Claude's recommendation was the same.

## Consequences

- Good: the public repositories show all the work; the private one holds only what must be private.
- Good: going live is one logged commit: the environment repository raises the version it pins
  (e.g. storybook's `deploy/` at a tag) – nothing in an app repository goes live by itself.
- Good: a new app brings its own `deploy/`; the platform repository doesn't grow per app.
- Bad: several repositories to keep in step; Argo CD needs a read-only token for the private one.
- Bad: a change across app and platform needs two commits in two repositories.
- Revisit when: the coordination effort outweighs the benefit, or a second person works on it.

## Confirmation

gitleaks in every repository's CI (phase 5); a check that no public repository contains the domain;
Argo CD reads only `dk-platform-env` (and what it pins).

## The options in detail

### 1. One repository for everything

- For: one place, one history.
- Against: it would have to be private (domain, secrets) – no showcase; or public and break the
  rule.

### 2. App repositories + public platform + private environments

- For: as above – public by default, private only where needed; app and deployment versioned
  together.
- Against: more repositories to coordinate.

Why the environment repository stays private although SOPS encrypts its secrets: it contains the
domain; encrypted data is only safe while the key stays secret and the algorithm holds, and
published ciphertext can be collected now and broken later; and file names and structure show
which secrets exist.

### 3. Like 2, but all app manifests in the platform repository

- For: all Kubernetes YAML in one place.
- Against: every app change needs commits in two repositories; the platform repository grows with
  every app.

### 4. Platform and environments in one private repository

- For: one repository fewer.
- Against: the platform work, the main showcase, isn't visible.

## More information

- [Argo CD: best practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
  (separating configuration from source code)
- dk-platform-env was created as public for a moment and changed to private before anything was
  pushed – nothing was ever visible.
