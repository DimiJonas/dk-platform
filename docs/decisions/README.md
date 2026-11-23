# Decisions (ADRs)

Every decision that shapes the platform is recorded here as an **ADR** (architecture decision
record), in the [MADR](https://adr.github.io/madr/) format: the problem, what mattered, the options
considered, the decision with the owner's own reason, and the consequences.

**How a decision is made** ([ADR 0001](0001-record-decisions-as-madr.md)): the options are laid
out with the information that matters before anything is decided; the decision and its reasoning
are recorded together.

**Rules:** one file per decision, numbered `NNNN-short-title.md`, never renumbered. An accepted
decision isn't changed – a later decision that changes it is a new ADR, and the old one's status
becomes "superseded by NNNN". Editorial changes that leave the decision as it is (wording, typos,
links) are fine.

New ADR: copy [`adr-template.md`](adr-template.md) to the next number.

## Index

| # | Decision | Status | Date |
|---|---|---|---|
| [0001](0001-record-decisions-as-madr.md) | Record decisions as ADRs in the MADR format, options laid out before deciding | accepted | 2026-11-17 |
| [0002](0002-repository-layout.md) | App repositories + public platform repository + private environment repository | accepted | 2026-11-17 |
| [0003](0003-diagrams-as-code.md) | Pictures as code: Mermaid by default, TikZ where layout matters | accepted | 2026-11-17 |
| [0004](0004-one-platform-for-all-apps.md) | One cluster for all own apps on the domain, a namespace per app | accepted | 2026-11-17 |
| [0005](0005-threat-modelling-method.md) | Threat modelling: target and transition apart, Markdown and Mermaid, a 3×3 rating, STRIDE plus LINDDUN, requirements separate | accepted | 2026-11-23 |

Decisions made before this repository existed are in the roadmaps of
[storybook](https://github.com/DimiJonas/storybook/blob/main/ROADMAP.md) and
[dk-srv](https://github.com/DimiJonas/dk-srv/blob/main/ROADMAP.md) ("Decided:" sections) and stay
there.
