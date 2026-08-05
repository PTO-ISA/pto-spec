# Instruction documentation layout

- `tile/` contains the 106 canonical PTO ISA 0.58.0 Tile instruction pages.
- `bundle/` contains Block/Header syntax, encoding, and lifecycle pages.
- The generated aggregate references (`tile.md`, `bundle-command.md`, and the
  scalar family tables) are catalog projections used by formal review.  They
  are not a second per-instruction Markdown hierarchy.

Every Tile page name equals its catalog operation name.  For example,
`TADD.md` exists only at `docs/instructions/tile/TADD.md`; its generated Complete
page is `docs/html/doc-instructions-tile-tadd.html`.
