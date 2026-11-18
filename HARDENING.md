# Hardening, explained

How the platform is hardened and measured, mechanism by mechanism – what, why, where it lives, how
to check it yourself, how to undo it. The scores and accepted risks are in
[`SECURITY.md`](SECURITY.md); the host's hardening is dk-srv's
[`HARDENING.md`](https://github.com/DimiJonas/dk-srv/blob/main/HARDENING.md).

**Status: phase 0 – the method is set; the mechanisms are added here as they're built.**

## The method

The same way dk-srv hardened the host by the CIS benchmarks:

1. **One guide per layer** ([`SECURITY.md`](SECURITY.md), "Guides per layer"): a published
   benchmark or hardening guide, never our own list.
2. **Measure before**: the tool, its version, the profile, the date – the result goes into
   `SECURITY.md`.
3. **Apply it as code**: every setting lives in a repository and reaches the cluster through Git
   (GitOps from phase 5) – nothing is changed by hand on the cluster.
4. **Measure after**, with the same tool and profile.
5. **Every rule that still fails** is either fixed, marked as not applicable (with why), or accepted
   as a risk **P\<n\>** with its reason.
6. **Keep it hardened**: what can drift is checked continuously – Kyverno refuses what breaks the
   rules, Trivy Operator and scheduled kube-bench runs report changes, alerts reach the phone.
7. **Lessons**: whatever went wrong on the way is written down at the end of this file.

## The layers and their mechanisms

Each mechanism gets its own section in this shape when it's built:

> **What** it does · **why** (the guide's rule, the threat) · **where** it lives (file, component) ·
> **check it yourself** (the command and the expected result) · **undo** it

| Layer | Mechanisms (planned) | Phase |
|---|---|---|
| Images | non-root user, minimal base without shell, read-only root filesystem, no build tools at run time, pinned by digest | 1 |
| Workloads | `securityContext`: `runAsNonRoot`, `allowPrivilegeEscalation: false`, all capabilities dropped, seccomp `RuntimeDefault`; resource requests and limits; no ServiceAccount token unless needed | 3, 4 |
| Namespaces | Pod Security Standards "restricted", default-deny NetworkPolicy, ResourceQuota | 4 |
| Network | Cilium: only the arrows of the target picture are allowed; egress by DNS name; the WAF at the edge | 4 |
| API server | RBAC least privilege, OIDC login for people, audit log, Secrets encrypted at rest, anonymous access off | 4 |
| Admission | Kyverno: the Pod Security rules, signed images only, no `latest` tags | 4, 5 |
| Secrets | SOPS + age in Git; Vault for short-lived database credentials | 4 |
| Identity | Keycloak: own realm, admin console not public, brute-force detection, MFA | 2 |
| Supply chain | signed images (cosign keyless), SBOMs, provenance, scans in CI | 5 |
| Runtime | Falco rules, alerts → ntfy | 6 |
| Host | dk-srv on the k3s node: forwarding, firewall, AIDE and auditd exclusions | 7 |

## Lessons

Nothing yet.
