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

Do not use an assertion to hide an unresolved architecture decision. Record the gap and obtain a normative decision
before choosing behavior.

## Normative precision

- Give every modeled requirement a stable ID and PTO-owned source link.
- Separate legality predicates from result/state semantics when it improves reviewability.
- Define source/destination aliasing, read-before-write behavior, exceptional values, and partial valid regions.
- State memory, event, and asynchronous ordering explicitly.
- Mark implementation-defined, constrained-unpredictable, or intentionally unspecified behavior in the model and docs.
- Keep target differences behind named profiles.

## Source organization

ASLRef consumes the generated `build/pto-spec.asl`. As sources are added, keep them split for reviewability and list
them in dependency order under `ASL_SOURCES_BEFORE_DECODER` or `ASL_SOURCES_AFTER_DECODER` in the `Makefile`.
Sources that consume generated catalog types or decode functions belong after the decoder.

Every new instruction definition should include:

1. stable requirement traceability;
2. architecture-level legality;
3. result or state-transition semantics;
4. explicit fault, profile, and unspecified behavior;
5. positive, boundary, and negative evidence appropriate to the operation.
