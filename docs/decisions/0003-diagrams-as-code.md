# 0003: Pictures as code – Mermaid by default, TikZ where layout matters

- **Status:** accepted
- **Date:** 2026-11-17
- **Decision-maker:** DimiJonas

## Context and problem

All repositories of the project should have pictures: architecture, data flows, trust boundaries,
login sequences, pipelines. They should be described in a language (reproducible, reviewable in
Git, easy to fix), and readable on GitHub. Which tool?

## Decision drivers

- pictures written as code, not drawn by hand
- shown on GitHub, ideally without a build step
- enough control over the layout for complex pictures (comparisons, nested boundaries)
- readable in GitHub's dark mode
- little tooling; TeX is already installed on the laptop

## Considered options

1. Mermaid only
2. TikZ only
3. Mermaid by default, TikZ where Mermaid reaches its limits
4. D2
5. PlantUML
6. draw.io (`.drawio.svg`)

## Decision

**Chosen option: 3.** Mermaid inside the markdown wherever it gives a good picture; TikZ when the
picture is complex or the position of things carries meaning. TikZ pictures live in
[`docs/diagrams/`](../diagrams/): the `.tex` source, the shared style `dk-diagram.sty`, and the
generated `.svg` (committed, with a white background), built by `build.sh`.

**Reasoning:** Mermaid is fast to write and rendered by GitHub itself, which makes it the most
convenient default. Where its automatic layout reaches its limits – complex pictures, or pictures
in which the position of elements carries meaning – TikZ gives full control. draw.io is ruled out
because pictures should be written as code, not drawn by hand. D2 and PlantUML would need a build
step just like TikZ, without matching its control; their simpler syntax is not a deciding
advantage here. TeX is already part of the development setup.

**First application:** the "now" and "target" pictures were drafted in both. Mermaid's automatic
layout made the target unreadable (tiny, arrows crossing, no way to mark trust boundaries), so the
pair is TikZ – drawn in the same style, so they can be compared.

## Consequences

- Good: most pictures need no tools at all and render where the text is.
- Good: complex pictures look the way they're meant to, and the pair "now/target" lines up.
- Bad: a TikZ picture needs TeX to change (laptop: yes; GitHub's web editor: no), and its SVG must
  be rebuilt and committed with it.
- Bad: two picture languages to read.
- Revisit when: GitHub renders another language natively that handles complex layouts, or Mermaid's
  layout improves enough.

## Confirmation

Every picture is either a ```` ```mermaid ```` block in a markdown file, or a `.tex` in
`docs/diagrams/` with its `.svg` next to it; `docs/diagrams/build.sh` rebuilds them (a CI check
follows in phase 5).

## The options in detail

| | Mermaid | TikZ | D2 | PlantUML | draw.io |
|---|---|---|---|---|---|
| drawn by GitHub itself | yes | no – commit the SVG | no | no | yes (`.drawio.svg`) |
| control over the layout | low (automatic) | complete | medium | medium | complete, by hand |
| tools needed | none | TeX | its own program | Java | an editor |
| dark mode on GitHub | adapts | white background | background | background | background |
| written as code | yes | yes | yes | yes | no |

- **Mermaid** – flowcharts, sequence diagrams (the OIDC login), state diagrams, small architecture
  pictures. Against: automatic layout breaks down with many boxes, nesting and crossing arrows.
- **TikZ** – complete control, print quality. Against: a build step, a large tool (TeX).
- **D2, PlantUML** – good layouts, but they need a build step like TikZ, without its control.
- **draw.io** – drawn by hand, not code.

## More information

- [Mermaid](https://mermaid.js.org/), [GitHub: creating diagrams](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams)
- [PGF/TikZ manual](https://tikz.dev/)
- How to build the pictures: [`docs/diagrams/README.md`](../diagrams/README.md)
