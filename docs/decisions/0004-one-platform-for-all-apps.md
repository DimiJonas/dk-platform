# 0004: One cluster for all own apps on the domain, a namespace per app

- **Status:** accepted
- **Date:** 2026-11-17
- **Decided by:** the owner (DimiJonas)
- **Prepared by:** Claude (options, information, recommendation)

## Context and problem

The storybook is the first app; more of my own apps may follow on subdomains of the same domain,
with the landing page (dk-home) linking to them. Does each app get its own platform, or do they
share one?

## Decision drivers

- isolation between apps
- RAM on one small server (Keycloak, monitoring, Argo CD cost the same per cluster)
- one login for all apps; one set of policies, monitoring and updates
- effort to run and to patch
- learning value

## Considered options

1. One cluster, one namespace per app
2. One cluster per app
3. Kubernetes only for the storybook; other apps on the host as today (systemd, dk-srv)
4. Virtual clusters (vCluster) per app inside one cluster

## Decision

**Chosen option: 1.** One k3s cluster for all apps I develop myself; each app in its own
namespace with its own NetworkPolicies, RBAC, Vault paths and database role; the platform services
(Traefik, cert-manager, Keycloak, Vault, Argo CD, Kyverno, monitoring) shared. The landing page is
one of the apps.

**Reason (owner, in his own words):** "It fits my vision for my domain and my app environment. I
only run apps that I develop myself, so the risk of all apps sharing one cluster is acceptable for
me. Also I can still run untrusted apps in a separate cluster if I ever want to run untrusted apps.
I don't like the vCluster option as that is too much complexity, and Kubernetes only for the
storybook seems like a bit of a waste."

Claude's recommendation was the same.

## Consequences

- Good: the platform services exist once – the RAM goes to the apps; one login across all apps.
- Good: a new app is a namespace and a `deploy/` folder, not a new platform.
- Bad: all apps share one kernel and one control plane. A break-out from a container, or a
  compromised cluster component, can reach every app. Accepted, because all apps are my own.
- Bad: one app can starve the others – limited with resource requests, limits and quotas per
  namespace.
- **Rule:** untrusted workloads (code I don't control, apps open to strangers) don't share this
  cluster – they get their own node or cluster.
- **Open:** third-party services I might want to host – e.g. a voice chat server, a proxy, a VPN
  for my own access – are neither my own code nor untrusted strangers' apps. Before one of them
  runs here, a new ADR decides where it goes.
- Revisit when: the first third-party or untrusted service is wanted, or the apps' trust levels
  start to differ.

## Confirmation

Every app has its own namespace with Pod Security "restricted", a default-deny NetworkPolicy and a
ResourceQuota (Kyverno checks it, phase 4); the architecture's component list
([`docs/architecture.md`](../architecture.md)) shows each app's namespace.

## The options in detail

### 1. One cluster, a namespace per app

"Soft" multi-tenancy: separation by Kubernetes means (namespaces, RBAC, NetworkPolicies, quotas,
policies), not by separate kernels.

- For: platform services once; one login; one place to patch and watch.
- Against: shared kernel and control plane; noisy neighbours.

### 2. One cluster per app

- For: strong separation.
- Against: every platform component per cluster – RAM and patching multiply; on one server the
  kernel is shared anyway.

### 3. Kubernetes only for the storybook

- For: simple apps stay simple.
- Against: two ways to run apps, two sets of documents and hardening.

### 4. Virtual clusters (vCluster)

Each app gets its own API server, RBAC and resources, running inside the host cluster.

- For: stronger separation of the Kubernetes API between apps.
- Against: more moving parts and RAM; the kernel is still shared; too much complexity for now.

## More information

- [Kubernetes: multi-tenancy](https://kubernetes.io/docs/concepts/security/multi-tenancy/)
- [vCluster](https://www.vcluster.com/docs)
