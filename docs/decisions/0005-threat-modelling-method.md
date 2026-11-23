# 0005: How the platform is threat-modelled

- **Status:** accepted
- **Date:** 2026-11-23
- **Decision-maker:** DimiJonas

## Context and problem

Before the platform is built, its threats are analysed: what we're working on, what can go wrong,
what we do about it, and whether it was enough (the four questions of the Threat Modeling
Manifesto). The method needs five choices: the scope, the format and tool, how threats are rated,
whether privacy gets its own look, and where the resulting requirements are kept.

## Decision drivers

- learning: thinking each threat through, not collecting generated lists
- consistent with the earlier decisions (pictures as code, everything in the repositories)
- proportionate for a private project with a small circle of known users
- privacy of the storybook's content is a main concern
- the result must be usable: every threat leads to something that is built and checked

## Considered options

| Choice | Options |
|---|---|
| Scope | (1) the target only · (2) the target plus the transition · (3) the target, the transition and a re-model of today's server |
| Format and tool | (1) Markdown and Mermaid by hand · (2) OWASP Threat Dragon · (3) OWASP pytm · (4) Threagile |
| Rating | (1) likelihood × impact on a 3×3 grid with own definitions · (2) OWASP Risk Rating Methodology · (3) no rating |
| Privacy | (1) STRIDE only · (2) STRIDE plus a LINDDUN pass over the flows with personal data · (3) the full LINDDUN process |
| Requirements | (1) in the threat model · (2) a separate requirements document · (3) GitHub issues |

## Decision

| Choice | Chosen |
|---|---|
| Scope | **The target**, in [`docs/threat-model.md`](../threat-model.md); **the transition** (migration, two servers side by side, cutover, retiring the old server) separately and shorter, in [`docs/threat-model-transition.md`](../threat-model-transition.md) |
| Format and tool | **Markdown and Mermaid by hand** (1); a threat-modelling-as-code tool is tried later as a CI exercise (phase 5) |
| Rating | **3×3 grid** (1), with definitions centred on who gets access to the content |
| Privacy | **STRIDE plus a LINDDUN pass** (2) |
| Requirements | **A separate document** (2), [`docs/security-requirements.md`](../security-requirements.md) |

**Reasoning:**

- *Scope:* the threat model is about the target. The transition has risks of its own and is worth
  analysing too, but it is temporary, so it gets its own, less prominent document.
- *Format:* writing the model by hand teaches the most and is consistent with ADR 0003 (pictures as
  code) and the rest of the documentation. Automated tools are worth hands-on experience later,
  once there is a finished model to compare their output with.
- *Rating:* a 3×3 grid is reasonable for a private project; the OWASP Risk Rating Methodology would
  be overkill. In this app everyone in the circle may edit everything, so impact is defined by who
  gets access: the threat to avoid above all is an outsider reaching the content or taking control
  of the server. A targeted attack is unlikely – the app is private and not advertised anywhere
  except the public code.
- *Privacy:* the privacy of the storybook's content is a main concern, so LINDDUN can't be left
  out; one pass over the relevant flows is proportionate. Findings without a reasonable fix are
  accepted deliberately, with their reason.
- *Requirements:* the threat model changes rarely, the requirements are worked through in every
  phase – so they're kept apart, both in the repository rather than in an external tracker.

## Consequences

- Good: every threat is thought through; each one leads to a requirement with a check, and the
  requirements are what the phases tick off.
- Good: privacy findings are visible decisions, not accidents.
- Bad: no tool suggests threats that were overlooked – the review at the end of every phase, and
  the later tool exercise, partly make up for it.
- Bad: IDs (T-, R-, TT-) are kept consistent by hand.
- Revisit when: the model gets too large to keep consistent by hand, or the circle of users widens.

## Confirmation

Each phase's end in the roadmap includes: the phase's requirements checked, the threat model
reviewed for new components and flows.

## More information

- [Threat Modeling Manifesto](https://threatmodelingmanifesto.org/)
- [OWASP Threat Modeling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html)
- [LINDDUN](https://linddun.org/)
- [OWASP Threat Dragon](https://owasp.org/www-project-threat-dragon/),
  [OWASP pytm](https://github.com/OWASP/pytm), [Threagile](https://github.com/Threagile/threagile)
- [OWASP Risk Rating Methodology](https://owasp.org/www-community/OWASP_Risk_Rating_Methodology)
