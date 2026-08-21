# ADR 0054: Tile execution-engine classification

## Status

Accepted.

## Context

The packed Mode/Function Tile encoding has historically been called TEPL.
That name identifies an encoding carrier, but it does not identify one
implementation engine: some accepted operations are simple element-wise
vector work while others require complex reduction, transcendental,
rearrangement, or irregular-function hardware. Treating TEPL as an execution
unit hides this distinction and causes PTO and Linx documentation to drift.

## Decision

PTO defines exactly four architectural Tile execution-engine classes:

- `VEC` executes only element-wise operations, including tile/tile,
  tile/scalar, selection, conversion, and fused multiply-add operations whose
  result is independently computed per destination element.
- `SFU` executes operations that require complex hardware, including
  transcendental functions, reductions and expansions, rearrangement, sort,
  histogram, quantization, and other irregular operations.
- `TLSU` executes Tile memory and data-movement operations.
- `CUBE` executes matrix and matrix-vector operations.

The accepted operation partition is exactly 35 VEC, 52 SFU, 10 TLSU, and 12
CUBE operations. Every accepted Tile operation MUST carry one `engine` and one
`classification` field in the normative Tile catalog. The generated ASL MUST
expose `TileEngineOfOperation` so executable tests can observe this partition.

TEPL remains the name of the existing packed Mode/Function binary carrier and
`TileDecode_TEPL` remains its decode-family spelling. TEPL is not an execution
engine. Assembly accepts `BSTART.VEC` and `BSTART.SFU` as engine-specific
aliases for the same carrier; canonical disassembly selects the alias from the
decoded operation's engine. `BSTART.TEPL` remains an accepted carrier spelling.
This decision changes no mask, match, Mode, Function, selector, or operand.

For the common PTO/Linx v0.58 subset, Linx MUST consume the exact PTO engine
and classification values. Linx-only instructions may add definitions only in
PTO-reserved encoding space and MUST NOT change a common operation's engine.

## Consequences

- Architecture and generated documentation report encoding-family counts and
  execution-engine counts separately.
- A VEC operation classified outside the element-wise categories is rejected
  by the catalog gate.
- An accepted TEPL-carrier operation maps to exactly VEC or SFU.
- Accepted TLSU and CUBE operations map to their namesake engines.
- Existing TEPL binary encodings remain unchanged; VEC/SFU are aliases, not new
  encodings.
