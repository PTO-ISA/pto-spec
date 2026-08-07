# Instruction documentation layout

- `scalar/` contains one generated page per accepted Scalar mnemonic, grouped
  as AGU, ALU, AMO, BRU, FSU, and SYS.
- `block/` contains one generated page per Block mnemonic, grouped by encoding,
  execution, attributes, operands, and lifecycle.
- `tile/` contains one generated page per canonical Tile operation, using the
  PTO Tile classification and recording the exact BSTART-to-BSTOP composition.
- The generated aggregate references (`tile.md`, `block-command.md`, and the
  scalar family tables) are catalog projections used by formal review.  They
  are not a second per-instruction Markdown hierarchy.

Each generated Markdown page embeds byte-for-byte ASL regions from its matching
mnemonic file. Use [the generated index](index.md) for aggregate tables and the
MkDocs navigation for the categorized per-mnemonic hierarchy.
