# HTML and figure design

The book uses a light/dark Quarto theme with sidebar navigation, a table of contents, search, and mathematical rendering. Wide tables and equations scroll within their own regions. Figure panels stack on narrow screens and link to full-resolution images.

Body text uses Arial/Helvetica-compatible local fonts; code uses Menlo/Consolas-compatible fonts. Figures use labels, line types, shapes, and grayscale alternatives to supplement color. Opaque white figure canvases keep their original colors in either reading theme.

The shared colors, typography, and spacing are defined in [design-tokens.csv](supplement/inst/style/design-tokens.csv). `python3 scripts/design.py` generates the matching Quarto style tokens; `python3 scripts/design.py --check` checks token consistency and selected contrast pairs. R figures use `book_theme()`, `book_palette()`, and `book_tokens()` from `supplement/R/book-style.R`.

[Figure documentation](supplement/FIGURES.md) links each illustration to its data and R source. PNG images use the recorded font and graphics device; EPS vector files use Helvetica. Font metrics can differ across platforms and devices.
