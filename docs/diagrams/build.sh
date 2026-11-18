#!/usr/bin/env bash
# Builds every TikZ picture in this folder (<name>.tex) into <name>.svg next to it.
# Needs: pdflatex with TikZ (texlive-pictures, texlive-latex-extra) and pdftocairo (poppler-utils).
#
#   docs/diagrams/build.sh            all pictures
#   docs/diagrams/build.sh now        only now.tex
#
# The SVGs are committed (GitHub can't run TeX); commit the .tex and its .svg together.
# Each SVG is scaled to WIDTH pixels (default 1000): GitHub shows pictures at most at their own size,
# and TeX's natural size would make the text too small; GitHub shrinks it to fit the page.
set -euo pipefail
WIDTH=${WIDTH:-1000}
cd "$(dirname "$0")"
for tool in pdflatex pdftocairo; do
  command -v "$tool" >/dev/null || { echo "$tool is missing (see setup-commands.md, part 0)" >&2; exit 1; }
done
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [ $# -gt 0 ]; then names=("$@"); else names=(); for f in *.tex; do names+=("${f%.tex}"); done; fi
for name in "${names[@]}"; do
  [ -f "$name.tex" ] || { echo "No such picture: $name.tex" >&2; exit 1; }
  if ! pdflatex -interaction=nonstopmode -halt-on-error -output-directory "$tmp" "$name.tex" >"$tmp/$name.out" 2>&1; then
    echo "$name.tex doesn't compile – the end of TeX's log:" >&2
    tail -n 25 "$tmp/$name.out" >&2
    exit 1
  fi
  pdftocairo -svg "$tmp/$name.pdf" "$tmp/$name.svg"
  # only the <svg> element's width/height change; the viewBox keeps the drawing's own coordinates.
  # pdftocairo writes the size with or without a unit (width="604.052" or width="604.052pt"),
  # depending on its cairo version; the unit doesn't matter, only the ratio of width and height.
  awk -v target="$WIDTH" '
    function size(attr,   s) {
      if (!match($0, " " attr "=\"[0-9.]+[a-z]*\"")) return 0
      s = substr($0, RSTART + length(attr) + 3, RLENGTH - length(attr) - 4)
      sub(/[a-z]+$/, "", s)
      return s + 0
    }
    !done && /<svg / {
      w = size("width"); h = size("height")
      if (w <= 0 || h <= 0) {
        print "build.sh: cannot read the picture size from this line of the SVG:" > "/dev/stderr"
        print $0 > "/dev/stderr"
        exit 1
      }
      sub(/ width="[0-9.]+[a-z]*"/,  sprintf(" width=\"%d\"", target))
      sub(/ height="[0-9.]+[a-z]*"/, sprintf(" height=\"%d\"", h * target / w + 0.5))
      done = 1
    }
    { print }' "$tmp/$name.svg" >"$name.svg"
  echo "built $name.svg"
done
