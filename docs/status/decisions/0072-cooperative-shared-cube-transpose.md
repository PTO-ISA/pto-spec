# ADR 0072: Cooperative Shared CUBE Inputs and Transpose

- Status: accepted
- Issue: [#105](https://github.com/PTO-ISA/pto-spec/issues/105)
- Umbrella: [#72](https://github.com/PTO-ISA/pto-spec/pull/72)
- Baseline: `30cd155cf635f0bf41429dbd5751fc7737268fb4`
- Requirement: `PTO-CUBE-SHARED-TRANSPOSE-001`
- Depends on: accepted `PTO-CUBE-CELL-STATE-001` and
  `PTO-CUBE-LOCAL-MATRIX-001`

## Decision

Shared Tiles remain ordinary two-dimensional descriptors. They never persist a
CUBE CELL layout, ND/DN orientation, transpose state, or per-operation Matrix
role.

Cooperative TMATMUL-family operations may bind the right primary operand, or
both A and B primary operands, from published Shared Tiles according to the
operation's complete-bundle schema. Local C/D and every Local primary operand
continue to use the CUBE layout contract. TGEMV remains Local-only and rejects
every Shared primary binding.

When only B is Shared, D inherits the `CUBE_M16` or `CUBE_M32` layout class of
Local A. When both A and B are Shared, an ACC form inherits the layout class of
Local C. A non-ACC all-Shared form selects `CUBE_M16` for `1 <= M <= 16` and
`CUBE_M32` for `17 <= M <= 32`. No additional layout selector is encoded.

## Transpose encoding

The existing `B.FPATR` command assigns two previously reserved bits:

- bit 7 is `TransA`;
- bit 8 is `TransB`; and
- bits 9 and 10 remain reserved zero.

The canonical no-transpose command encodes both controls as zero. `TransA=1`
is legal only when A is Shared. `TransB=1` is legal only when B is Shared. A
transpose request for a corresponding Local input raises Tile legality before
source snapshots, consumption, or destination allocation.

Shared inputs are read through their ordinary logical descriptor. After all
four PEs have completed rendezvous and Shared-readiness preflight, the selected
transpose is applied to the logical input consumed by CUBE. The transformation
does not modify the Shared descriptor, payload, publication state, or lifetime.

## PE mask and rendezvous

LB0=M remains the logical row count for one PE. It is not a core-total M. Each
participating PE computes M result rows. The group-visible row count is derived
from the number and fixed identity of participating PEs.

Any nonzero four-bit PE mask is legal. Multiple set bits are allowed. All four
PEs reach the cooperative rendezvous and perform complete Shared source
readiness and schema preflight. Only PEs whose bit is set perform the selected
computation, allocate Local destinations, and publish output state.

PE mask zero is a strict no-op before descriptor reads, Shared readiness,
dimension/layout/type checks, faults, allocation, source effects, or output
publication.

## Preflight and ordering

The cooperative operation completes these checks before any selected PE
snapshots a source or allocates a destination:

- exact Local/Shared operand schema and role ordering;
- B.FPATR presence, field legality, and reserved bits;
- TransA/TransB correspondence to Shared inputs;
- all four PEs' rendezvous participation;
- publication and complete readiness of every referenced Shared Tile;
- selected PEs' Local descriptor, dimension, layout, dtype, capacity, and
  destination availability; and
- operation-specific auxiliary and post-process schema.

Rejection preserves all Local and Shared state. A successful cooperative read
does not create GM ordering and does not define an order among unrelated Shared
or Local accesses.

## Defaults and protected behavior

- `TransA=0` and `TransB=0` select no logical transpose.
- Existing B.FPATR post-processing fields and their numeric semantics remain
  unchanged.
- Fixed PE identities, per-PE TSize, and Shared core-private visibility remain
  unchanged.
- Partial masks select destination producers; they do not change logical M for
  an individual selected PE.
- Existing Matrix function numbers and start encodings remain unchanged.

## Explicit exclusions

This decision adds no persistent Shared CUBE layout, GM/Shared CUBE conversion,
Shared TGEMV form, hidden orientation state, or implicit memory fence.

## Acceptance criteria

The accepted ASL, generated documentation, and independent decoded tests
prove:

1. B.FPATR 00, 01, 10, and 11 transpose controls and exact logical results;
2. bits 9 and 10 remain decode-reserved;
3. transpose acceptance only for the corresponding Shared input;
4. right-only and two-Shared primary schemas;
5. all single-bit and representative multi-bit nonzero masks;
6. four-PE rendezvous/readiness with selected-PE-only allocation and publish;
7. strict zero-mask no-effect before all legality and readiness checks;
8. unchanged Shared descriptors and payload after successful reads;
9. TGEMV Shared rejection; and
10. rollback on every late cooperative preflight failure.
