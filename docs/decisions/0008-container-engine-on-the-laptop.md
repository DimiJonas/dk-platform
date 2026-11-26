# 0008: Container engine on the laptop: Docker Engine, rootful first, rootless later

- **Status:** accepted
- **Date:** 2026-11-26
- **Decision-maker:** DimiJonas

## Context and problem

Until the production server exists, phases 1 to 6 run on the admin laptop (Ubuntu). From phase 1
on, it needs a container engine: to build the images, to run them together with Compose, to run
the local pipeline's tools (most of them ship as containers), and from phase 3 on to run the k3d
cluster, whose Kubernetes nodes are containers themselves. The engine has to be chosen before the
first image is built.

## Decision drivers

- everything from phase 1 to 6 works as documented, so the time goes into the platform, not into
  tooling problems – above all k3d in phases 3 to 6
- the privilege the engine gives on the laptop, which also holds the age key, the SSH keys and later
  the cluster credentials
- learning value: how container engines work, and what running them without root changes
- the common, real-world setup

## Considered options

1. Docker Engine, rootful (the daemon runs as root)
2. Docker Engine in rootless mode (the daemon runs as the user, inside a user namespace)
3. Podman, rootless (no daemon; every container started by the user)

## Decision

**Chosen option: 1 now, 2 later** – Docker Engine on the laptop, first in its default rootful mode;
later the laptop moves to rootless mode as a step of its own. When that happens and how far it
goes (the image builds and Compose only, or the k3d cluster as well) is an open decision in the
[roadmap](../../ROADMAP.md#open-decisions).

**Reasoning:** Rootful Docker is what most documentation, tools and CI systems assume, and it is the
one setup k3d fully supports, so the first phases can concentrate on images, Compose and Kubernetes.
Moving to rootless mode afterwards is a migration worth doing deliberately: the laptop runs on a
known-good setup first, then the change shows what rootless mode needs (subordinate user and group
IDs, a user-level daemon, cgroup delegation) and what it breaks – a lesson that a direct rootless
start would hide. Podman was the most secure by design, but k3d calls its Podman support
experimental and needs manual workarounds for it, which would put the cluster phases at risk;
building images with Podman stays possible at any time, since images follow the OCI standard.

## Consequences

- Good: Compose, the scanners and k3d work as their documentation describes.
- Good: the move to rootless mode is learned as a migration, with a before and after.
- Bad: while the daemon is rootful, membership in the `docker` group is effectively root on the
  laptop – whoever can talk to the daemon's socket can start a container that mounts the host's
  filesystem. Accepted for this period as [P2](../../SECURITY.md#accepted-risks-and-known-gaps):
  the laptop has one user, and that user already holds the keys that matter; the Docker socket is
  never mounted into a container.
- Bad: rootless mode may not carry the whole plan. Kubernetes in rootless containers is documented
  for kind and minikube, not for k3d, and the cluster tools of phases 4 and 6 (Cilium, Falco) load
  eBPF programs into the host's kernel, which a user namespace normally can't do. Hence the open
  decision on how far the move goes.
- Revisit when: the move to rootless mode is decided; or k3d supports Podman fully.

## Confirmation

- `docker info` shows the engine and, after the move, `rootless` among its security options.
- [`setup-commands.md`](../../setup-commands.md#0-the-laptop-) lists the installation, and later
  the move, as tested commands.
- P2 in [`SECURITY.md`](../../SECURITY.md#accepted-risks-and-known-gaps) is closed (or narrowed)
  when the move is done.

## The options in detail

### 1. Docker Engine, rootful

A daemon (`dockerd`) runs as root; the `docker` command sends it requests through a Unix socket.

- For: the default almost everything is written for; k3d is built for it.
- Against: access to the socket is root-equivalent; a container escape lands as root on the host.

### 2. Docker Engine, rootless

The daemon and the containers run as the user, inside a user namespace: root inside a container
is the ordinary user outside. Installed with `dockerd-rootless-setuptool.sh`.

- For: an escape from a container lands as the ordinary user, not root; the same commands.
- Against: needs subordinate IDs and cgroup v2 delegation; some features behave differently
  (low ports, networking); k3d on rootless Docker is not documented.

### 3. Podman, rootless

No daemon: each container is a child process of the user's command, rootless by default; the same
command-line syntax as Docker.

- For: the most secure by design; no root-owned socket at all.
- Against: k3d's Podman support is experimental and needs manual setup (cgroup delegation, its own
  network with DNS, a socket that imitates Docker's).

## More information

- [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Docker: rootless mode](https://docs.docker.com/engine/security/rootless/)
- [Docker: the daemon's attack surface](https://docs.docker.com/engine/security/#docker-daemon-attack-surface)
- [k3d: using Podman](https://k3d.io/stable/usage/advanced/podman/) (experimental)
- [Kubernetes: running node components as a non-root user](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-in-userns/)
- [Podman](https://podman.io/)
- Roadmap step 0.7
