# Setup commands

From a new machine to everything running – in order. Each part says where its commands run:
**laptop**, **server** or **cluster** (`kubectl` from the laptop).

Parts that belong to a later phase are listed with that phase; their commands are written when the
step is built and tested, never before. Until the cutover (phase 7), the production server is set up
by dk-srv's [`setup-commands.txt`](https://github.com/DimiJonas/dk-srv/blob/main/setup-commands.txt)
and storybook's `project_setup_commands.txt`.

| Part | What | Phase | |
|---|---|---|---|
| 0 | The laptop: tools and repositories | 0 | ✅ |
| 1 | The local cluster (k3d) | 3 | 🔜 |
| 2 | A new server: the host (dk-srv, adapted for k3s) | 7 | 🔜 |
| 3 | The cluster on the server (k3s) | 7 | 🔜 |
| 4 | The platform components (Argo CD first, then everything through Git) | 4–6 | 🔜 |
| 5 | The apps (storybook, dk-home) and their data | 3, 7 | 🔜 |
| 6 | Another node | when needed | 🔜 |

---

## 0. The laptop ✅

**laptop** (Ubuntu). Git and access to GitHub are already set up.

The repositories, side by side in one folder:

```sh
mkdir -p ~/src && cd ~/src
git clone git@github.com:DimiJonas/dk-platform.git
git clone git@github.com:DimiJonas/dk-platform-env.git
```

(`storybook` and `dk-srv` are cloned there too, if they aren't yet.)

For the TikZ pictures (only needed to change one – GitHub shows the committed SVGs):

```sh
sudo apt install texlive-pictures texlive-latex-extra texlive-fonts-recommended poppler-utils
docs/diagrams/build.sh          # in dk-platform: rebuilds every picture
```

Mermaid pictures need nothing: GitHub draws them, and so do most editors' markdown previews.

The tools for the later phases (Docker, k3d, kubectl, helm, sops, age, …) are added to this part
when they're first used – Docker Engine in phase 1, rootful to start with, and later the move to
its rootless mode ([ADR 0008](docs/decisions/0008-container-engine-on-the-laptop.md)).

## 1. The local cluster (k3d) 🔜

Phase 3.

## 2. A new server: the host 🔜

Phase 7: a fresh Ubuntu 24.04 server hardened by dk-srv (its `setup-commands.txt`), plus what a k3s
node needs: forwarding, the pod and service networks in the firewall, the registries and Let's
Encrypt in the egress rules, AIDE and auditd exclusions for k3s's folders.

## 3. The cluster on the server (k3s) 🔜

Phase 7: k3s with the hardened settings from phase 4.

## 4. The platform components 🔜

Phases 4–6: Argo CD is installed by hand once; it installs everything else from Git
(dk-platform and dk-platform-env).

## 5. The apps and their data 🔜

Phase 3 (locally), phase 7 (on the server): the apps through Argo CD; the data from a backup
(database dump, photos) – the same steps as the restore test.

## 6. Another node 🔜

When one server isn't enough. In k3s a node joins with a token (`k3s agent`); around it:

- the new machine is hardened by dk-srv like the first
- the firewalls of both nodes allow the cluster's traffic between them (and only between them)
- the photos' ReadWriteOnce volume can be used on one node only: backend and photo worker stay on
  that node, or the photos move to object storage (an open decision, see the roadmap)
- the hardening and the measurements are repeated for the new node
