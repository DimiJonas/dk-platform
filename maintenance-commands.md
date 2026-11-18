# Maintenance commands

What to do in which situation. Find the situation in the index, then follow its section. Each
command says where it runs: **laptop**, **server** or **cluster** (`kubectl` from the laptop).

Situations of later phases are listed with that phase; their steps are written when they're built
and tested. **Until the cutover (phase 7), production is maintained with storybook's
`project_maintenance_commands.txt` and dk-srv's
[`maintenance-commands.txt`](https://github.com/DimiJonas/dk-srv/blob/main/maintenance-commands.txt).**

## Index

| Situation | Section | Phase |
|---|---|---|
| A picture needs changing | [Pictures](#pictures) | ✅ |
| A decision has to be made or recorded | [A new ADR](#a-new-adr) | ✅ |
| The AI session got long – move to a new one | [A new AI session](#a-new-ai-session) | ✅ |
| Deploying a new version of an app | | 5 |
| The site or an app is down | | 3, 6 |
| A critical vulnerability in an app's dependencies → maintenance mode | | 3 |
| A critical vulnerability in the edge (Traefik, TLS) → lockdown | | 3 |
| A phone was lost – end its logins | | 2 |
| Someone may know a password; locking an account | | 2 |
| A secret leaked – rotating it | | 4 |
| A certificate doesn't renew | | 3 |
| Restoring the database or photos from a backup | | 3 |
| The monthly restore test failed | | 3 |
| Updating k3s, Traefik, Keycloak, … | | 5 |
| More capacity needed – adding a node | [setup-commands.md, part 6](setup-commands.md#6-another-node-) | – |
| Measuring the hardening again | | 4 |

---

## Pictures

**laptop**, in dk-platform.

- **Mermaid** (in the markdown files): edit the ```` ```mermaid ```` block; GitHub draws it.
- **TikZ** (`docs/diagrams/<name>.tex`): edit, rebuild, look at it, commit source and SVG together:

  ```sh
  docs/diagrams/build.sh now          # or without a name: all pictures
  xdg-open docs/diagrams/now.svg
  git add docs/diagrams/now.tex docs/diagrams/now.svg
  ```

  The shared look (colours, boxes, the trust-boundary circles, the legend) is in
  `docs/diagrams/dk-diagram.sty` – a change there affects every picture: rebuild all.

## A new ADR

1. Lay out the options with the information that matters.
2. Decide, and write down the reasoning.
3. The ADR is written from [`docs/decisions/adr-template.md`](docs/decisions/adr-template.md) as
   the next number, added to the index in [`docs/decisions/README.md`](docs/decisions/README.md),
   and the decision is removed from the roadmap's "Open decisions".

## A new AI session

When a session gets long and its history is being compressed:

1. Make sure the last delivery is applied and pushed, and [`ROADMAP.md`](ROADMAP.md)'s "Where we
   are" is current.
2. Start a new session with the brief and fresh zips of the repositories, and the line from
   "Where we are" ("Starting a new AI session").
