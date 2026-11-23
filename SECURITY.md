# Security of the platform

How the platform is secured, **measured against published guides** – one guide per layer, a score
before and after, and every rule that isn't met either fixed or accepted on purpose with its reason.
The same method as [dk-srv](https://github.com/DimiJonas/dk-srv/blob/main/SECURITY.md) (the host)
and [storybook](https://github.com/DimiJonas/storybook/blob/main/docs/SECURITY.md) (the app).
How each mechanism works: [`HARDENING.md`](HARDENING.md).

**Status: phase 0 – nothing is measured yet, because nothing runs yet.** The tables below are the
plan; the scores are filled in when each layer is built (phase 4 onwards).

Status marks: ✅ done · ➖ doesn't apply · ⚠️ accepted risk (reason below) · 🔜 planned

## Guides per layer

| Layer | Guide | Measured by | Phase | |
|---|---|---|---|---|
| Host (Ubuntu) | CIS Ubuntu Linux 24.04, Level 1 Server | USG (dk-srv) – stays, measured again for the k3s node | 7 | 🔜 |
| Kubernetes (k3s) | CIS Kubernetes Benchmark (v2.x; the exact version is pinned when measured) with k3s's own CIS hardening and self-assessment guides | kube-bench (k3s profile) | 4 | 🔜 |
| Kubernetes, broader | NSA/CISA Kubernetes Hardening Guide (v1.2); OWASP Kubernetes Top 10 (2025); Pod Security Standards | Kubescape; Kyverno policies | 4 | 🔜 |
| Images | Dockerfile best practices; known vulnerabilities | hadolint; Trivy (CVE counts per image) | 1 | 🔜 |
| Supply chain | SLSA build levels | signatures, SBOMs and provenance checked at admission (Kyverno) | 5 | 🔜 |
| Apps | OWASP ASVS 5.0 (storybook: Level 1 + the Level 2 login and session parts) | review; storybook's `docs/SECURITY.md` | 2 | 🔜 |
| PostgreSQL | CIS PostgreSQL 16 Benchmark (the settings that apply inside a container) | settings check | 3, 4 | 🔜 |
| Keycloak, Vault | their official production hardening guides (no CIS benchmark exists) | checklists | 2, 4 | 🔜 |
| Running workloads | runtime rules (unexpected shells, files, connections) | Falco | 6 | 🔜 |
| AWS (phase 8) | CIS AWS Foundations Benchmark | Security Hub | 8 | 🔜 |

## Baseline: what the platform must not be worse than

Today's production, measured on the VPS:

| Measurement | Result | Source |
|---|---|---|
| CIS Ubuntu 24.04 Level 1 Server (USG) | 72.2 % before hardening → **92.7 %** of all rules, **100 %** with 13 accepted risks | dk-srv `SECURITY.md` |
| The backend's systemd sandbox | `systemd-analyze security`: **1.4 "OK"** (9.0 "UNSAFE" without) | storybook `docs/SECURITY.md` |
| The app | OWASP ASVS 5.0 Level 1 + the Level 2 login and session parts; one known gap (A8: no second factor) | storybook `docs/SECURITY.md` |

The container equivalent of the sandbox (non-root, no capabilities, seccomp, read-only filesystem,
no privilege escalation) is measured per workload in phases 1 and 4.

## What's protected, against whom

From the [threat model](docs/threat-model.md) (method: [ADR 0005](docs/decisions/0005-threat-modelling-method.md)):

- **Assets:** the storybooks' photos and texts, the photos' exact positions (never stored, but
  present in uploads), who wrote what, the logins, the platform's own credentials (cluster admin,
  Argo CD, Vault, the age keys, the CI's signing identity), the backups.
- **The threat to avoid above all:** someone outside the circle of users reading or changing the
  content, or taking over a login, the server or the platform.
- **Attackers:** bots and scanners, password guessers, published exploits, crafted uploads,
  compromised dependencies and images, a stolen device, the admin's own mistakes. A targeted,
  skilled attacker is considered unlikely – the app is private and not advertised.
- **Result:** 54 threats to the target (16 of priority high) and 7 to the transition, each
  answered by requirements with a check: [`docs/security-requirements.md`](docs/security-requirements.md)
  – the list each phase works through.

## Scorecards

Filled in per layer when it's built: the guide's sections, what's done, the score before and after,
with date and tool version.

## Accepted risks and known gaps

Numbered **P1, P2, …** (the host's are A1–A13 in dk-srv; the storybook's own is A8).

| | Risk | Why it's accepted |
|---|---|---|
| P1 | The hosting provider can technically access the server (hypervisor, console, disk snapshots) | Unavoidable on a rented server. Limited by keeping what matters encrypted where possible: the backups (age) leave the server, secrets are encrypted at rest (phase 4); the provider is chosen as trustworthy. Out of scope of the threat model. |

## Reporting a problem

If you find a security problem in this repository, please use GitHub's private vulnerability
reporting for it, or open an issue without details and ask for a private contact – thank you.
