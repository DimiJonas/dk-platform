# 0006: Resource policy: trimmed scanners, Guaranteed only for the core, single replicas

- **Status:** accepted
- **Date:** 2026-11-23
- **Decision-maker:** DimiJonas

## Context and problem

Everything runs on one node, and the plan has many components: the apps, identity and secrets,
GitOps, policies, monitoring and four security tools (Trivy Operator, Kubescape, kube-bench,
Falco) that partly overlap. The [resource budget](../resource-budget.md) shows that the security
tools alone, with their charts' defaults, would request about as much memory as the apps. Three
questions decide what the node has to carry: how the security tools run, which pods get which
quality-of-service class, and how many copies of each pod run and how they are updated.

## Decision drivers

- the memory one node can carry, with room for nightly peaks
- what is protected first when memory runs out: data and logins before tooling
- learning the common, real-world ways – not special constructions
- each tool used for what it is best at, little duplicate work
- simple operations for one person

## Considered options

### D1 – the security tools

1. Every tool as its chart installs it, all features on
2. Scans only on demand: run by hand or as one-off Jobs before and after a change, nothing permanent
3. Each tool for its own job, trimmed: Trivy Operator for vulnerabilities (daily rescans, one scan
   at a time), Kubescape for configuration only (nightly), kube-bench as a nightly CronJob, Falco
   for runtime

### D2 – quality-of-service classes

1. Everything Guaranteed (request = limit)
2. Guaranteed for what holds data or logins (PostgreSQL, Keycloak and its database, Vault) and the
   network (Cilium); Burstable for the rest; BestEffort refused
3. Requests only, no limits; BestEffort allowed for small tools

### D3 – replicas and updates

1. One replica each, every update as Recreate (old pod stopped, then the new one started)
2. One replica each; rolling updates for small stateless pods, Recreate for Keycloak and Vault;
   requests at most 80 % of the allocatable memory
3. Two replicas for the edge and the apps, rolling updates everywhere

## Decision

**Chosen options: D1 – 3, D2 – 2, D3 – 2.**

- **D1:** Trivy Operator scans each new image and rescans when a report is older than 24 hours
  (`scannerReportTTL`, the default), with `scanJobsConcurrentLimit: 1` instead of 10. The
  Kubescape operator runs configuration scanning only, nightly; its vulnerability scanning,
  runtime observability, node scanning, SBOM generation and admission controller are switched off
  – vulnerabilities come from Trivy, runtime from Falco. kube-bench runs as a nightly CronJob
  against the k3s profile of the CIS Kubernetes Benchmark. Falco runs permanently (a runtime tool
  has to).
- **D2:** Guaranteed: PostgreSQL, Keycloak, Keycloak's PostgreSQL, Vault, Cilium. Burstable:
  everything else, each pod with a memory request and a limit. A Kyverno rule refuses pods
  without requests (BestEffort).
- **D3:** one replica per component. Rolling updates for small stateless pods (frontend, dk-home,
  backend, Traefik, most platform tools); Recreate for Keycloak (two instances would double its
  memory and form a cache cluster during the update) and Vault (its storage belongs to one
  instance). PostgreSQL as a one-replica StatefulSet is replaced pod by pod, which amounts to the
  same. The sum of all requests stays at or below 80 % of the node's allocatable memory.

**Reasoning:** The aim is to learn how these tools are commonly run, and a nightly scan is enough
for a platform of this size; the trimmed setup lets each tool do the part it is best at instead
of three tools scanning the same images. Running nothing permanently would save memory but
teaches little about operating scanners in a cluster, and every feature on would cost more memory
than the apps need. For the classes, what holds data and logins and the network must be the last
thing the node gives up; everything else may be evicted first and restarts on its own. Forbidding
BestEffort with Kyverno is also practice in writing policies. Rolling and Recreate are both used
so that both strategies are learned where each one fits; a second replica would only double memory
on a single node without protecting against the node's own failure.

## Consequences

- Good: the full set fits on a node of about 10 GiB, the core on about 7 GiB
  ([budget](../resource-budget.md#totals)), with 20 % room for bursts.
- Good: under memory pressure the kubelet evicts Burstable tools before PostgreSQL, Keycloak,
  Vault or Cilium.
- Good: one source per finding – Trivy for CVEs, Kubescape and kube-bench for configuration,
  Falco for behaviour.
- Bad: a vulnerability published during the day is found at the next rescan, up to 24 hours
  later. Accepted: images are also scanned in CI (phase 5).
- Bad: single replicas – every update of a Recreate component and every node restart is a short
  outage. Accepted for a family app (see the threat model's impact scale).
- Bad: Kubescape remains the most expensive tool (about 0.9 GiB of requests) for a partly
  overlapping job.
- Revisit when: phase 4 is measured – whether Kubescape stays, or kube-bench plus Kyverno's
  policy reports cover enough; a second node arrives (then replicas and spreading make sense).

## Confirmation

- A Kyverno policy refuses BestEffort pods (tested with a pod without requests, phase 4).
- `kubectl get pods -A -o custom-columns=NS:.metadata.namespace,POD:.metadata.name,QOS:.status.qosClass`
  shows Guaranteed exactly for the five components.
- The Trivy Operator's and Kubescape's Helm values in dk-platform-env show the trimmed settings.
- The requests' sum against the allocatable memory, checked after each phase in
  [`resource-budget.md`](../resource-budget.md).

## The options in detail

### D1 – 1. Everything on

- For: the most findings; no configuration work.
- Against: about 0.9 GiB more for Kubescape's vulnerability and runtime features alone, Trivy with
  up to ten parallel scan jobs; three tools reporting the same CVEs.

### D1 – 2. Only on demand

- For: almost no permanent memory.
- Against: nothing notices a new CVE or a drifted setting by itself; not how clusters are usually
  run.

### D1 – 3. Each tool for its own job, trimmed

- For: the common pattern – an operator for continuous vulnerability reports, a benchmark job, a
  runtime sensor; clear responsibilities.
- Against: some configuration per tool; findings up to a day late.

### D2 – 1. Everything Guaranteed

- For: the most predictable; nothing bursts.
- Against: every pod reserves its peak – the node fills with reserved but unused memory.

### D2 – 2. Guaranteed for the core, Burstable for the rest

- For: the important pods are protected, the rest shares memory efficiently.
- Against: the Burstable pods may be evicted under pressure (they restart).

### D2 – 3. Requests only, BestEffort allowed

- For: the least configuration.
- Against: no upper bound – one leaking pod can starve the node (threat T-53); BestEffort pods are
  evicted first and unpredictably.

### D3 – 1. Recreate everywhere

- For: the least memory during updates.
- Against: every update is an outage, also where a rolling update would be free.

### D3 – 2. Rolling where cheap, Recreate where needed

- For: no outage for small stateless pods; both strategies learned.
- Against: short outages for Keycloak and Vault updates.

### D3 – 3. Two replicas

- For: updates without outage; practice with spreading pods.
- Against: double memory; on one node no protection against the node's own failure.

## More information

- [Resource budget](../resource-budget.md)
- [Kubernetes: Pod quality of service classes](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/)
- [Kubernetes: node-pressure eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/)
- [Kubernetes: Deployment strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy)
- [Trivy Operator](https://aquasecurity.github.io/trivy-operator/), [Kubescape](https://kubescape.io/),
  [kube-bench](https://github.com/aquasecurity/kube-bench), [Falco](https://falco.org/)
- Roadmap step 0.6
