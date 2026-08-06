# Instruction documentation layout

- `scalar/` contains the Scalar ISA reference: 474 accepted binary forms plus
  register, architecture, and source-reference pages.
- `block/` contains Block ISA syntax, encoding, operand binding, and lifecycle
  pages.
- `tile/` contains the 109 canonical PTO ISA 0.58.0 Tile operation pages.
- The generated aggregate references (`tile.md`, `block-command.md`, and the
  scalar family tables) are catalog projections used by formal review.  They
  are not a second per-instruction Markdown hierarchy.

Every Tile page name equals its catalog operation name. For example,
`TADD.md` exists only at `docs/instructions/tile/TADD.md`; its generated Complete
page is `docs/html/doc-instructions-tile-tadd.html`.
