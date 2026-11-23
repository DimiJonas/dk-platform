# Security requirements

What the platform must do, derived from the [threat model](threat-model.md) (T-xx) and the
[transition's threat model](threat-model-transition.md) (TT-xx). Each requirement says which
threats it answers, **how it's verified**, whether today's server already does it, and its status
on the platform. Each phase works through its section; a requirement is ✅ only when its check has
passed. Scores and accepted risks: [`SECURITY.md`](../SECURITY.md).

**Today** (on the current server): ✅ in place · ◐ partly · – not yet, or doesn't apply today
**Status** (on the platform): 🔜 planned · 🔄 in progress · ✅ verified · ⚠️ accepted (see
[`SECURITY.md`](../SECURITY.md#accepted-risks-and-known-gaps))

Requirements marked *(proposed)* have an open decision; it's made, with its options, in the phase
named.

## Phase 1: containers and the photo worker

| ID | Requirement | Threats | Verified by | Today | Status |
|---|---|---|---|---|---|
| R-05 | Every request is authorized in the backend: a perspective only by its author, later the per-storybook rights; covered by automated tests | T-04 | a test suite: Ben's session against Anna's perspective → 403, and so on per rule | ◐ the check exists, no tests | 🔜 |
| R-07 | No injection: parameterized SQL only, React's escaping, a CSP without inline scripts; code scanning in CI (phase 5) | T-06 | Semgrep rules in CI; the CSP header checked | ◐ SQL and CSP yes, no scanning | 🔜 |
| R-13 | The backend has only the rights it needs: non-root, read-only root filesystem, no ServiceAccount token, egress only to its allow-list (R-52), its own database role with the least rights | T-12 | the pod spec (Kyverno, phase 4); the role's grants listed; an egress test | ◐ systemd sandbox (1.4), egress per server | 🔜 |
| R-14 | The photo worker is isolated: no incoming connections, outgoing only to PostgreSQL, non-root, read-only root filesystem, all capabilities dropped, seccomp `RuntimeDefault`, no ServiceAccount token, a tight memory limit | T-13 | connectivity tests (nothing reaches it; it reaches nothing but PostgreSQL); the pod spec | – the conversion runs inside the backend | 🔜 |
| R-15 | Hostile input is bounded: a pixel limit, a time limit per job, attempts counted – a job that keeps failing ends as "failed" | T-14, T-15 | test files (a decompression bomb, a broken image) → the job fails, the worker keeps running | ◐ sharp's default pixel limit | 🔜 |
| R-16 | A compromised worker can do little harm: its database role only on the job table; photo backups append-only and off the node (R-44); unexpected activity in the worker raises an alert (phase 6) | T-16 | the role's grants; a backup test; a Falco test event | ◐ backups append-only | 🔜 |
| R-17 | *(proposed)* Positions are sent to Nominatim with reduced precision – e.g. rounded to about 1 km, enough for the town | T-17 | the request in a test shows rounded coordinates | – exact | 🔜 |
| R-18 | An exact position never stays: it's removed from the original whether or not the town lookup works | T-18 | an upload with GPS while Nominatim is blocked → the stored original has no position | – stays until a retry | 🔜 |
| R-19 | *(proposed)* The originals' other metadata (camera model and serial, …) is decided: removed, or kept deliberately | T-19 | `exiftool` on a stored original | – kept | 🔜 |
| R-30 | Dependencies are controlled: lockfiles, `npm ci`, minimal base images, Trivy; in CI (phase 5) also SBOMs and update pull requests with review | T-12, T-31 | Trivy and SBOM per image; the CI jobs | ◐ lockfiles, nightly `npm audit` | 🔜 |

## Phase 2: identity with Keycloak

| ID | Requirement | Threats | Verified by | Today | Status |
|---|---|---|---|---|---|
| R-01 | Every account has a second factor or a passkey | T-01 | a login without the second factor is impossible | – (storybook's gap A8) | 🔜 |
| R-02 | Password guessing is slowed and noticed: Keycloak's brute-force detection, a rate limit on the login at the edge, the same answer for unknown and known accounts | T-01 | repeated wrong logins → slowed down, notified; an unknown name answers like a known one | ✅ login limiter, nginx limit, dummy hash | 🔜 |
| R-03 | The session cookie stays as it is today: HttpOnly, Secure, SameSite=Strict, `__Host-`; sessions server-side and revocable; lifetimes defined | T-02 | the response headers; a revoked session is rejected | ✅ | 🔜 |
| R-04 | Requests that change data must come from the app's own origin | T-03 | a request with a foreign `Origin` → 403 | ✅ | 🔜 |
| R-20 | Keycloak's admin console isn't reachable from the internet; the master realm only for administration, with MFA; the apps in their own realm | T-20 | a request for the admin console from outside → refused | – | 🔜 |
| R-22 | OIDC is done right: Authorization Code with PKCE, a confidential client, exact redirect URIs, state and nonce, tokens validated (issuer, audience, expiry) | T-22 | tests with a wrong redirect URI, a missing state, a foreign token → refused | – | 🔜 |
| R-23 | Tokens stay in the backend (BFF): never in the browser, in URLs or in logs | T-23 | the browser's storage holds no token; the logs searched | – (no tokens today) | 🔜 |
| R-24 | A Keycloak outage doesn't end running sessions, and the admin can still get in without Keycloak (break-glass) | T-24 | Keycloak stopped → the app's sessions keep working until they expire; the break-glass path tried | – | 🔜 |

## Phase 3: Kubernetes basics

| ID | Requirement | Threats | Verified by | Today | Status |
|---|---|---|---|---|---|
| R-06 | Photos only after the login check: every route to them goes through ForwardAuth; no other way to the volume | T-05 | a request for a known photo without a session → 401; the routes listed | ✅ `auth_request` | 🔜 |
| R-08 | HTTPS only at the edge: HSTS, certificates from cert-manager, modern TLS versions only | T-07 | a TLS test (e.g. testssl.sh); HTTP → redirect | ✅ HTTPS, HSTS | 🔜 |
| R-09 | Floods and oversized requests are bounded: rate limits per route (login, upload, tiles), body size limits, requests and limits on every pod, a quota per namespace | T-08 | a load test beyond the limits → 429 / 413; the quotas listed | ◐ rate and size limits | 🔜 |
| R-10 | The edge stays current and can be shut: Traefik and the WAF updated quickly (Renovate, phase 5), scanned; maintenance mode and lockdown as Kubernetes actions | T-09 | the update pull requests; the scan report; lockdown tried | ✅ nightly security check, lockdown | 🔜 |
| R-11 | Changes are traceable: the app's change history kept; access logs at the edge and in Keycloak | T-10 | a change shows up in the history with its author | ✅ change history | 🔜 |
| R-12 | Responses reveal no internals: generic error messages, no version headers | T-11 | headers and error pages checked | ✅ | 🔜 |
| R-43 | Backups are encrypted with age; the private key only on the laptop; pulled with a read-only key | T-45 | a backup file is age-encrypted; the pull key can't write | ✅ | 🔜 |
| R-44 | Backups are out of the node's reach: pulled, not pushed; photos append-only; versions kept (7 days, 12 months) | T-46 | the node can't delete the laptop's copies | ✅ | 🔜 |
| R-45 | Restoring is proven: a monthly automatic restore test; a failed or missing backup raises an alert | T-47 | the test's log; a simulated failure → notification | ◐ failures notified; a backup that never runs isn't | 🔜 |
| R-47 | Logs with personal data are limited: a retention period, readable only by the admin, no tokens or secrets in logged URLs | T-50 | the retention settings; a sample of the logs | ◐ not set deliberately | 🔜 |

## Phase 4: cluster security

| ID | Requirement | Threats | Verified by | Today | Status |
|---|---|---|---|---|---|
| R-26 | No plaintext secret in Git: SOPS only; gitleaks before every commit and in CI (phase 5) | T-26 | a test commit with a fake secret is stopped | ◐ `.gitignore`, `.env` never committed | 🔜 |
| R-27 | The age keys are kept safe: only on the laptop, in the password manager and as one cluster Secret; a rotation procedure written and tried | T-27 | a rotation drill | ◐ the backup key only on the laptop | 🔜 |
| R-28 | Kubernetes Secrets are protected: encrypted at rest, no broad read rights in RBAC, ServiceAccount tokens only where needed | T-28 | kube-bench; `kubectl auth can-i get secrets` per ServiceAccount → no | – | 🔜 |
| R-29 | Vault is hardened: the root token revoked after setup, unseal keys offline, one policy per workload, an audit device, Kubernetes auth bound to ServiceAccount and namespace, short lifetimes | T-29, T-30 | the token and policy listing; a pod with another ServiceAccount → refused | – | 🔜 |
| R-36 | Daily administration with short-lived OIDC tokens and RBAC; the cluster-admin credential kept offline as break-glass | T-37 | the daily kubeconfig holds no certificate; break-glass tried | – | 🔜 |
| R-37 | The Kubernetes API isn't reachable from the internet: only through an admin path (an SSH tunnel or a VPN – decided in this phase); anonymous access off | T-38 | a port scan from outside → closed | – | 🔜 |
| R-40 | Containers can't easily break out: Pod Security "restricted" for the apps, seccomp, non-root, no privilege escalation; the host's kernel current; Falco watching (phase 6) | T-41 | a privileged test pod is refused; kube-bench, Kubescape | ◐ systemd sandbox | 🔜 |
| R-41 | Every privileged platform component (e.g. Cilium, Falco) is listed with its reason, as an explicit exception | T-42 | the list in `SECURITY.md` matches the cluster | – | 🔜 |
| R-42 | Admin actions are traceable: the API server's audit log, auditd on the host | T-43 | a `kubectl` change appears in the audit log | ◐ auditd | 🔜 |
| R-50 | No noisy neighbours: requests and limits on every pod, a quota per namespace, logs and metrics limited by size, disk space alerts | T-53 | the quotas; an alert test | ◐ journal size limited | 🔜 |
| R-51 | The configuration is checked, not trusted: everything through Git; Kyverno policies; kube-bench and Kubescape on a schedule; connectivity tests that prove the expected refusals | T-44 | the scheduled reports; the test suite passes | ◐ USG, AIDE, drift check on the host | 🔜 |
| R-52 | Outgoing traffic only by allow-list per pod: default-deny, then the backend → Nominatim, ntfy; the edge → the tile server; cert-manager → Let's Encrypt; the platform → registries, GitHub | T-54 | `curl` tests per pod: allowed → works, anything else → refused | ◐ egress firewall for the whole server | 🔜 |

## Phase 5: supply chain and GitOps

| ID | Requirement | Threats | Verified by | Today | Status |
|---|---|---|---|---|---|
| R-21 | Keycloak runs the latest supported release; security releases installed within days | T-21 | the running version against the latest | – | 🔜 |
| R-25 | The platform tools (Argo CD, Grafana) only for the admin group; app users get no tool rights | T-25 | an app user's login to Grafana → refused | – | 🔜 |
| R-31 | Only signed images, by digest: cosign keyless signatures checked at admission by Kyverno; third-party images pinned | T-32 | an unsigned image is refused | – | 🔜 |
| R-32 | Git, the source of truth, is protected: 2FA or passkey, branch protection, Argo CD deploys only what dk-platform-env pins | T-33 | the branch rules; Argo CD's applications | ◐ 2FA | 🔜 |
| R-33 | The CI has least privilege: minimal workflow permissions, third-party actions pinned by commit hash, no secrets for outside pull requests, signing only from `main` | T-34 | a review of the workflows; a workflow linter in CI | – no CI yet | 🔜 |
| R-34 | Argo CD is restricted: its UI not public (or single sign-on with MFA only), its admin user off, projects limit what it may deploy where, a read-only repository token | T-35 | its settings; `can-i` checks | – | 🔜 |
| R-35 | Platform components come from their official sources, pinned by version and digest; changes reviewed on update | T-36 | the pinned versions | – | 🔜 |

## Phase 6: observability and runtime security

| ID | Requirement | Threats | Verified by | Today | Status |
|---|---|---|---|---|---|
| R-46 | *(proposed)* Notifications carry no names or IP addresses through ntfy.sh – or ntfy runs on the platform itself | T-49 | a sample notification | – name and IP sent | 🔜 |
| R-48 | The watchers are watched: an outside uptime check and a heartbeat – a missing heartbeat raises an alert | T-51 | Alertmanager stopped → the missing heartbeat is reported | ◐ the site watch | 🔜 |
| R-49 | Grafana, Prometheus and Loki aren't public: single sign-on and the admin group only | T-52 | a request from outside → refused | – | 🔜 |

## Phase 7: go-live and the transition

| ID | Requirement | Threats | Verified by | Today | Status |
|---|---|---|---|---|---|
| R-38 | The node's ports are closed to the internet except 80, 443 and SSH: kubelet, the datastore, the network overlay blocked by the host firewall | T-39 | a port scan from outside | ✅ ufw: only 80, 443, SSH | 🔜 |
| R-39 | SSH stays as dk-srv hardened it: keys only, fail2ban, a notification per login | T-40 | USG and dk-srv's checks | ✅ | 🔜 |
| R-53 | The migration copies stay encrypted end to end: age-encrypted, over SSH; plain only inside the target | TT-01 | the transfer's commands and files | – | 🔜 |
| R-54 | A write freeze at cutover: the old server in maintenance mode before the final copy, so no change lands on both | TT-02 | the runbook's order; a change attempt during the freeze is refused | – | 🔜 |
| R-55 | Rehearsal data is handled like production: real data only on the encrypted laptop, deleted after the rehearsal | TT-03 | nothing left after the rehearsal | – | 🔜 |
| R-56 | The DNS switch is prepared: a short TTL beforehand, certificates tested on the new system first, the change checked twice | TT-04 | the runbook; the certificate in place before the switch | – | 🔜 |
| R-57 | The old server is retired cleanly: its data wiped, the provider's snapshots and backups deleted, its keys, tokens and notification topics revoked or rotated | TT-05 | a checklist, each item ticked | – | 🔜 |
| R-58 | A rollback is defined and tried: what happens to data written on the new system | TT-06 | a rollback during the rehearsal | – | 🔜 |
| R-59 | Users are told through a known channel, before it happens: the login changes (new password or passkey – never through a link in an unexpected message), and backups keep removed photos | TT-07, T-48 | the message sent before the cutover | – | 🔜 |
