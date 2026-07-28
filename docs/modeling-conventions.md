# ASL modeling conventions

## Names and types

- Use `PascalCase` for named ASL types and public instruction functions.
- Prefix enumeration members with their type name, such as `TileLocation_VEC`.
- Use `snake_case` for parameters, locals, record fields, helpers, and state accessors.
- Prefer constrained integers for architectural indices and dimensions.
- Use `bits(N)` for fixed-width architectural values; use `integer` for mathematical indexing and bounds.

## State and semantics

- Model architecture-visible state in named records and expose changes through small accessor procedures.
- Prefer pure functions for instruction value semantics and thin state-updating procedures for instruction execution.
- Iterate only over a tile's valid region unless an instruction explicitly defines behavior for invalid elements.
- Preserve fixed-width wrapping behavior by operating on bitvectors where that behavior is intended.
- Use `assert` for a legality precondition only while fault behavior is unspecified; replace it when the ISA defines a
  visible diagnostic, trap, or status result.

## Source organization

ASLRef consumes the generated `build/pto-spec.asl`. As sources are added, keep them split for reviewability and list
them in dependency order under `ASL_SOURCES` in the `Makefile`.

Every new instruction definition should include:

1. architecture-level preconditions;
2. result or state-transition semantics;
3. comments for intentionally unspecified behavior;
4. at least one executable test.
