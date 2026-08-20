# ADR 0070: GM/Local CUBE Layout Transport

- Status: accepted
- Issue: [#103](https://github.com/PTO-ISA/pto-spec/issues/103)
- Umbrella: [#72](https://github.com/PTO-ISA/pto-spec/pull/72)
- Baseline: `0b8ce516ffe998b24c4bae4c1a9dbca2e0d76510`
- Proposed requirement: `PTO-CUBE-CELL-TRANSPORT-001`
- Depends on: proposed `PTO-CUBE-CELL-STATE-001`

## Decision

`B.DATR.Layout` assigns six explicit GM/Local CUBE transformations:

| Code | Spelling | Legal operation | Direction |
| ---: | --- | --- | --- |
| 21 | `ND2M32` | `TLOAD` | GM ordinary to Local `CUBE_M32` |
| 22 | `ND2M16` | `TLOAD` | GM ordinary to Local `CUBE_M16` |
| 23 | `ND2N8` | `TLOAD` | GM ordinary to Local `CUBE_N8` |
| 24 | `M322ND` | `TSTORE` | Local `CUBE_M32` to GM ordinary |
| 25 | `M162ND` | `TSTORE` | Local `CUBE_M16` to GM ordinary |
| 26 | `N82ND` | `TSTORE` | Local `CUBE_N8` to GM ordinary |

Codes 21 through 23 are illegal for TSTORE. Codes 24 through 26 are illegal
for TLOAD. All six are illegal for a Shared Tile binding. A recognized but
direction-incompatible conversion raises Tile legality before allocation,
source consumption, or memory effects.

## Raw representation

Conversion preserves the concrete Tile dtype and every valid element's raw
representation. It is a layout transform, not TCVT: it performs no numerical
rounding, saturation, canonicalization, widening, narrowing, or type change.

Every dtype with an assigned CUBE b32, b16, b8, or b4 mapping may use the
matching conversion when the operation's own dtype profile permits it.
`HiF4X2` and every b64 dtype reject because they have no legal CUBE CELL state.

## TLOAD behavior

GM-to-Local TLOAD derives the persistent destination layout from the selected
ND2* code and consumes logical dimensions from the operation's existing
dimension schema. Before the first effect it validates:

- exact conversion direction and Local destination form;
- dtype and CELL mapping;
- positive valid dimensions;
- derived CELL geometry and per-PE TSize capacity;
- base, logical row stride, and the complete valid GM footprint; and
- destination availability.

TLOAD reads GM only for valid logical elements. Physical CELL positions outside
the valid region receive the resolved PadValue and do not cause GM reads.
After all reads succeed, it atomically publishes the Local CUBE descriptor,
payload, and definedness state.

## TSTORE behavior

Local-to-GM TSTORE requires the source descriptor to match the selected M*2ND
or N82ND code. It preflights the complete valid destination footprint before
the first write. It writes only valid logical elements in ordinary GM order;
physical CELL padding positions never write memory.

TSTORE does not change the persistent Local descriptor, payload, or lifetime.

## Fault and restart ordering

Wrong direction, Shared participation, unsupported dtype, descriptor mismatch,
invalid dimensions, insufficient capacity, undefined valid source data, and
invalid memory footprints reject before effects. A recoverable memory fault
retries the first uncommitted access and does not duplicate allocation, source
effects, or preceding memory writes.

## Defaults and protected behavior

- Layout code zero retains the existing ordinary non-converting transfer.
- Omission never infers a CUBE conversion.
- GM/Shared remains ordinary base-plus-row-stride transport.
- Existing logical-element row-stride and packed-memory rules remain unchanged.
- PE mask zero remains a strict no-op before conversion and memory legality.

## Explicit exclusions

This decision defines no GM/Shared conversion, Local/Shared conversion,
in-place payload reinterpretation, CUBE-to-CUBE conversion, Matrix execution,
or new dimension command.

## APPLY acceptance criteria

A later APPLY change must land this decision as accepted together with ASL,
generated documentation, and independent decoded tests that prove:

1. all six exact encodings and direction restrictions;
2. b32/b16/b8/b4 raw-bit round trips, including M16-b4 interleave;
3. multi-CELL K/N ordering and partial-tail PadValue behavior;
4. no GM access outside the valid region;
5. `HiF4X2`, b64, Shared, and wrong-direction rejection before effects;
6. first, middle, and last memory-fault rollback and exact restart; and
7. unchanged ordinary TLOAD/TSTORE behavior.

This proposed decision is not executable or release evidence and must not merge
independently of its APPLY implementation.
