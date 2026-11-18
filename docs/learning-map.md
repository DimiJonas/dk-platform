# Learning map

Every technology of the platform: what it is in one line, what it's for here, the phase where it's
learned and used, and where to read. The deep explanation comes right before each step (the
"learn" part of the cycle in [`ROADMAP.md`](../ROADMAP.md)); this page is the overview.

## Phase 0 – Foundations

| Technology | What it is | For us | Read |
|---|---|---|---|
| Threat modelling, STRIDE | a systematic look at data flows and trust boundaries; STRIDE = spoofing, tampering, repudiation, information disclosure, denial of service, elevation of privilege | the risks of the new architecture, before building it | [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling) |
| ADRs (MADR) | one short record per decision: options, reasons, consequences | every decision of this project | [MADR](https://adr.github.io/madr/) |
| Mermaid, TikZ | pictures written as code | every picture in the repositories | [Mermaid](https://mermaid.js.org/), [PGF/TikZ manual](https://tikz.dev/) |

## Phase 1 – Containers

| Technology | What it is | For us | Read |
|---|---|---|---|
| OCI images and containers | a packaged filesystem in layers + a process confined by kernel features (namespaces, cgroups, seccomp, capabilities) | every part of the storybook as an image | [OCI](https://opencontainers.org/), [Docker docs](https://docs.docker.com/) |
| Multi-stage Dockerfiles | build in one stage, copy only the result into a small runtime image | small images without build tools | [Docker: multi-stage builds](https://docs.docker.com/build/building/multi-stage/) |
| Minimal / distroless base images | runtime images without shell or package manager | less to attack, fewer CVEs | [distroless](https://github.com/GoogleContainerTools/distroless) |
| Docker Compose | several containers described in one file | all parts running locally, before Kubernetes | [Compose](https://docs.docker.com/compose/) |
| hadolint | a linter for Dockerfiles | Dockerfile best practices, checked | [hadolint](https://github.com/hadolint/hadolint) |
| Trivy | a scanner for CVEs, misconfigurations and secrets | CVE counts per image, before/after | [Trivy](https://trivy.dev/) |
| PostgreSQL job queue | `SELECT … FOR UPDATE SKIP LOCKED`: workers take jobs without blocking each other | the photo worker | [PostgreSQL: SELECT, locking clause](https://www.postgresql.org/docs/current/sql-select.html#SQL-FOR-UPDATE-SHARE) |

## Phase 2 – IAM for the apps

| Technology | What it is | For us | Read |
|---|---|---|---|
| OAuth 2.0 | a framework for delegated access with tokens | the base of OIDC | [RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749), [OAuth 2.0 Security BCP (RFC 9700)](https://datatracker.ietf.org/doc/html/rfc9700) |
| OpenID Connect | the login layer on top of OAuth 2.0 (ID tokens, user info) | the apps' login through Keycloak | [OpenID Connect](https://openid.net/developers/how-connect-works/) |
| Authorization Code + PKCE | the login flow for apps; PKCE stops a stolen code from being used | the backend as OIDC client | [RFC 7636](https://datatracker.ietf.org/doc/html/rfc7636) |
| BFF (backend for frontend) | the tokens stay in the backend; the browser only has a session cookie | no tokens in the browser | [OAuth for browser-based apps](https://datatracker.ietf.org/doc/draft-ietf-oauth-browser-based-apps/) |
| Keycloak | an identity provider: realms, clients, users, flows, MFA, brute-force detection | identities for all apps and tools | [Keycloak docs](https://www.keycloak.org/documentation) |
| WebAuthn / passkeys | login with a key on the device, can't be phished | the second factor (or the only one) | [passkeys.dev](https://passkeys.dev/) |
| Authorization models | roles (RBAC), attributes (ABAC), relationships (ReBAC) | per-storybook permissions: what Keycloak knows, what the app decides | [OWASP Authorization Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) |

## Phase 3 – Kubernetes basics

| Technology | What it is | For us | Read |
|---|---|---|---|
| Kubernetes | desired state + control loops; one API for everything | the platform | [Kubernetes docs](https://kubernetes.io/docs/concepts/) |
| k3s, k3d | a small Kubernetes distribution; k3d runs it in Docker | k3d on the laptop, k3s on the server | [k3s](https://docs.k3s.io/), [k3d](https://k3d.io/) |
| Workloads | Pods, Deployments, StatefulSets, Jobs, CronJobs | the storybook's parts, backups | [Workloads](https://kubernetes.io/docs/concepts/workloads/) |
| Networking | Services, Ingress, Gateway API | how requests reach the apps | [Services and networking](https://kubernetes.io/docs/concepts/services-networking/) |
| Configuration | ConfigMaps, Secrets, probes, requests and limits | settings, health, resources | [Configuration](https://kubernetes.io/docs/concepts/configuration/) |
| Storage | PersistentVolumes and Claims | PostgreSQL, the photos | [Storage](https://kubernetes.io/docs/concepts/storage/) |
| Traefik | the reverse proxy and ingress controller of k3s; middlewares (ForwardAuth, rate limits, plugins) | the edge | [Traefik docs](https://doc.traefik.io/traefik/) |
| cert-manager | certificates from ACME (Let's Encrypt), renewed automatically | TLS | [cert-manager](https://cert-manager.io/docs/) |

## Phase 4 – Cluster security

| Technology | What it is | For us | Read |
|---|---|---|---|
| RBAC, ServiceAccounts | who (person or workload) may do what in the Kubernetes API | least privilege for me and every pod | [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) |
| Pod Security Standards | three built-in levels of what a pod may do; "restricted" is the strictest | every app pod | [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) |
| NetworkPolicy, Cilium | which pod may talk to which; Cilium (eBPF) adds egress by DNS name | default-deny, the worker's isolation, the backend's egress | [NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Cilium](https://docs.cilium.io/) |
| Kyverno | policy as code: checks (and can change) everything sent to the API | rules for all pods; signed images only | [Kyverno](https://kyverno.io/docs/) |
| WAF: Coraza + OWASP CRS | reads incoming HTTP requests and blocks known attack patterns | a layer at the edge, in front of the apps | [Coraza](https://coraza.io/), [OWASP CRS](https://coreruleset.org/) |
| SOPS + age | encrypted secrets that can live in Git | dk-platform-env | [SOPS](https://getsops.io/), [age](https://age-encryption.org/) |
| Vault | a secrets server: auth methods, secrets engines, leases, policies | short-lived database credentials | [Vault docs](https://developer.hashicorp.com/vault/docs), alternative [OpenBao](https://openbao.org/) |
| Encryption at rest, audit log | Secrets encrypted in the cluster's database; a log of every API request | the API server's own protection | [Encrypting data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/), [Auditing](https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/) |
| kube-bench | checks a cluster against the CIS Kubernetes Benchmark | the score before/after (k3s profile) | [kube-bench](https://github.com/aquasecurity/kube-bench), [k3s CIS self-assessment](https://docs.k3s.io/security/self-assessment) |
| Kubescape | checks against NSA/CISA, MITRE ATT&CK and other frameworks | a second, broader measurement | [Kubescape](https://kubescape.io/) |
| Trivy Operator | Trivy inside the cluster: scans what actually runs | CVEs and misconfigurations, continuously | [Trivy Operator](https://aquasecurity.github.io/trivy-operator/) |

## Phase 5 – Supply chain and GitOps

| Technology | What it is | For us | Read |
|---|---|---|---|
| GitHub Actions + OIDC | CI that can prove its identity without stored keys | builds, scans, signing | [GitHub OIDC](https://docs.github.com/en/actions/concepts/security/about-security-hardening-with-openid-connect) |
| Semgrep, gitleaks | code scanning; secret scanning | every push | [Semgrep](https://semgrep.dev/docs/), [gitleaks](https://github.com/gitleaks/gitleaks) |
| SBOM (syft) | the list of everything inside an image | knowing what we ship | [syft](https://github.com/anchore/syft) |
| cosign, Sigstore | keyless signing: a short-lived certificate from the CI's identity, logged publicly | every image signed | [Sigstore](https://docs.sigstore.dev/) |
| SLSA, provenance | how an artifact was built, attested | build provenance | [SLSA](https://slsa.dev/) |
| Renovate | automatic update pull requests, also for image digests | staying current (Keycloak needs it most) | [Renovate](https://docs.renovatebot.com/) |
| Argo CD | GitOps: the cluster follows Git | all deployments | [Argo CD](https://argo-cd.readthedocs.io/) |

## Phase 6 – Observability and runtime security

| Technology | What it is | For us | Read |
|---|---|---|---|
| Prometheus, Alertmanager | metrics and alerts | alerts → ntfy on the phone | [Prometheus](https://prometheus.io/docs/) |
| Grafana | dashboards | with single sign-on | [Grafana](https://grafana.com/docs/grafana/latest/) |
| Loki | log storage, queried like Prometheus | logs off the pods | [Loki](https://grafana.com/docs/loki/latest/) |
| Falco | watches system calls (eBPF) and reports suspicious behaviour | "a shell in the photo worker" becomes an alert | [Falco](https://falco.org/docs/) |

## Phase 8 – AWS

| Technology | What it is | For us | Read |
|---|---|---|---|
| AWS IAM | policies, roles, trust policies, IAM Identity Center | IAM in a cloud, in depth | [AWS IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/) |
| EKS Pod Identity / IRSA | AWS roles for pods | workload identity in the cloud | [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/) |
| KMS, CloudTrail, GuardDuty, Security Hub | keys, audit log, threat detection, posture (CIS AWS Foundations) | the cloud's security services | [AWS security docs](https://docs.aws.amazon.com/security/) |
| Terraform + IaC scanning | infrastructure as code, checked before it's applied | everything on AWS | [Terraform](https://developer.hashicorp.com/terraform/docs), [Checkov](https://www.checkov.io/) |
