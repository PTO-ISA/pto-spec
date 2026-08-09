# ADR 0057: Tile Classification and Execution-Engine Aliases

- **Status**: accepted
- **Date**: 2026-08-09
- **Deciders**: PTO ISA maintainers

## Context

The active Tile tree used migration-era categories such as `tile-tile-elementwise`,
`reduction`, and `complex-layout`, while the PTO programming surface already
defines eight stable instruction classes. The binary carrier name `TEPL` also
mixed an encoding identity with an execution-engine classification. That made
navigation, engine ownership, and downstream assembly terminology drift even
though the Mode/Function encoding itself remained valid.

## Decision

The normative owners are the mnemonic ASL records below `asl/tile/` and the
engine/alias clauses in `asl/arch/overview/`. This ADR records rationale only.

PTO uses these instruction classes: Sync and Config; Elementwise Tile-Tile;
Tile-Scalar and Immediate; Reduce and Expand; Memory and Data Movement; Matrix
and Matrix-Vector; Layout and Rearrangement; and Irregular and Complex. Direct
Tile operations currently occupy the latter seven classes. Classification is
semantic and remains independent of execution-engine selection.

Every direct Tile operation names exactly one engine: `VEC`, `TLSU`, `CUBE`, or
`SFU`. `VEC` is restricted to elementwise operations. Operations requiring
specialized or complex hardware use `SFU`; memory/data-transfer operations use
`TLSU`; matrix operations use `CUBE`. A semantic class does not imply an engine:
for example, a data-rearrangement operation may use TLSU, while a complex
elementwise operation may use SFU.

The existing TEPL Mode/Function bit encoding is unchanged. `BSTART.VEC` and
`BSTART.SFU` are accepted assembly aliases constrained by the selected Tile
operation's engine. `BSTART.TEPL` remains an accepted compatibility spelling.
Canonical assembly and disassembly render `BSTART.VEC` or `BSTART.SFU`, never
`BSTART.TEPL`. Alias selection cannot create a new encoding, change selector
ownership, or change instruction semantics.

## Consequences

- ASL paths, mirrored Markdown, and mirrored independent tests use the PTO
  instruction classes rather than encoding-family directories.
- Catalog projections expose both semantic class and execution engine while
  retaining Mode, Function, selector, mask, and match unchanged.
- Downstream assemblers may accept the TEPL compatibility spelling, but all new
  generated text and disassembly use the engine-specific canonical spelling.
- Historical comparison evidence may retain the word TEPL only when it names
  an immutable external snapshot or the unchanged binary carrier.
