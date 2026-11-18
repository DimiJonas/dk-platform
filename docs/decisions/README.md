# Decisions (ADRs)

Every decision that shapes the platform is recorded here as an **ADR** (architecture decision
record), in the [MADR](https://adr.github.io/madr/) format: the problem, what mattered, the options
considered, the decision with the owner's own reason, and the consequences.

**How a decision is made** ([ADR 0001](0001-record-decisions-as-madr.md)): Claude lays out the
options with the information that matters and a recommendation, clearly marked as Claude's; the
owner decides and gives his reason in his own words; the ADR records both (quoted with spelling
fixed; anything added for context is in [square brackets]).

**Rules:** one file per decision, numbered `NNNN-short-title.md`, never renumbered. An accepted ADR
isn't changed – a later decision that changes it is a new ADR, and the old one's status becomes
"superseded by NNNN". Small corrections (typos, links) are fine.

New ADR: copy [`adr-template.md`](adr-template.md) to the next number.

## Index

| # | Decision | Status | Date |
|---|---|---|---|
| [0001](0001-record-decisions-as-madr.md) | Record decisions as ADRs in the MADR format; the owner decides with his own reason | accepted | 2026-11-17 |
| [0002](0002-repository-layout.md) | App repositories + public platform repository + private environment repository | accepted | 2026-11-17 |
| [0003](0003-diagrams-as-code.md) | Pictures as code: Mermaid by default, TikZ where layout matters | accepted | 2026-11-17 |
| [0004](0004-one-platform-for-all-apps.md) | One cluster for all own apps on the domain, a namespace per app | accepted | 2026-11-17 |

Decisions made before this repository existed are in the roadmaps of
[storybook](https://github.com/DimiJonas/storybook/blob/main/ROADMAP.md) and
[dk-srv](https://github.com/DimiJonas/dk-srv/blob/main/ROADMAP.md) ("Decided:" sections) and stay
there.
