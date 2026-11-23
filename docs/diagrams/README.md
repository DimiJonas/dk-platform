# Pictures (TikZ)

The pictures that need exact positions ([ADR 0003](../decisions/0003-diagrams-as-code.md)); all
others are Mermaid blocks in the markdown files.

| Source | Picture | Shown in |
|---|---|---|
| [`now.tex`](now.tex) | [`now.svg`](now.svg) – the storybook today on one hardened VPS | README, architecture |
| [`target.tex`](target.tex) | [`target.svg`](target.svg) – the target on a hardened k3s node | README, architecture |
| [`dfd-level0.tex`](dfd-level0.tex) | [`dfd-level0.svg`](dfd-level0.svg) – the threat model's level-0 data-flow diagram | threat model |
| [`dk-diagram.sty`](dk-diagram.sty) | – the shared look: colours, boxes, trust-boundary circles, legend | every picture |

**Building:** `./build.sh` (all) or `./build.sh now` (one) – needs `pdflatex` with TikZ and
`pdftocairo` ([`setup-commands.md`](../../setup-commands.md), part 0). It compiles each `.tex` to a
PDF in a temporary folder and converts it to an SVG next to the source. The text becomes outlines,
so the SVG looks the same everywhere; the white background keeps it readable in GitHub's dark mode.
Commit the `.tex` and its `.svg` together.

**The look:** purple = the apps, teal = identity and secrets, grey = platform and the outside
world, circles = processes (data-flow diagrams only: styles `proc`, `iproc`, `pproc`), cylinders =
stored data, dashed frames = machines and namespaces (trust zones), red circles = trust boundaries
(the same number means the same boundary in every picture; the legend explains them).

**A new picture:** copy one of the `.tex` files, keep `\usepackage{dk-diagram}`, `\dkbackground`
at the end, and `\dklegend{x,y}` if it shows trust boundaries.
