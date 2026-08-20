# ADR 0071: Local CUBE Matrix Operand Contract

- Status: accepted
- Issue: [#104](https://github.com/PTO-ISA/pto-spec/issues/104)
- Umbrella: [#72](https://github.com/PTO-ISA/pto-spec/pull/72)
- Baseline: `328ab1989572b93d5ef5b1e2b726e906b30cbb3c`
- Requirement: `PTO-CUBE-LOCAL-MATRIX-001`
- Depends on: accepted `PTO-CUBE-CELL-STATE-001` and
  `PTO-CUBE-CELL-TRANSPORT-001`

## Decision

Local primary operands of the CUBE Matrix family must use persistent CUBE
layouts:

- A uses `CUBE_M16` or `CUBE_M32` and has logical shape M x K;
- B uses `CUBE_N8` and has logical shape K x N;
- C, when present, uses the same M layout class as A and has shape M x N; and
- D uses the same M layout class as A and has shape M x N.

The ordinary Local primary-operand Matrix path is removed. An ordinary Local A,
B, C, or D is illegal before source snapshots or destination allocation.
Ordinary Shared primary inputs are owned by the cooperative Shared decision.

## Dimensions and layout compatibility

LB0=M, LB1=N, and LB2=K are positive logical dimensions independent of per-PE
`TSize`. They are not required to be powers of two.

`CUBE_M16` accepts `1 <= M <= 16`; `CUBE_M32` accepts `1 <= M <= 32`. When
`M <= 16`, either layout class is legal if A, C, D, dtype, derived geometry,
and capacity agree. N and K may span multiple CELLs and are bounded by the
operand descriptors, selected TSize, and architectural model limits rather
than by one-CELL dimensions.

For every primary operand:

- the descriptor layout and dtype-specific CELL geometry must be legal;
- valid dimensions must match the resolved M/N/K roles exactly;
- every valid source element must be defined;
- required bytes must fit the operand's allocation; and
- no valid access may alias CELL padding as an operand.

## Ordinary auxiliary Tiles

Bias and MX scale operands remain ordinary Local Tiles. They retain their
operation-owned dtype, shape, layout, definedness, and alias rules and are not
repacked into a CUBE layout.

Bias is exactly one row-major 1 x N accumulator-type source. MX scales retain
their E8M0 row-major shapes derived independently for A and B. Supplying an
ordinary auxiliary Tile does not make an ordinary primary Tile legal.

## TGEMV

TGEMV remains a Local-only M=1 specialization of the corresponding Matrix
family operation. Its matrix/vector primary inputs use the same CUBE layout
classes: the M-side operand uses M16 or M32 with valid M=1 and the N-side
operand uses N8. Shared TGEMV is not introduced.

## Preflight and faults

Complete operation, dimension, layout, dtype, shape, capacity, definedness,
binding, and auxiliary-Tile legality precedes source snapshots, destination
allocation, payload computation, or lifetime effects. A recognized Matrix
operation with an illegal tuple raises Tile legality and preserves every
descriptor, payload, and source.

## Defaults and protected behavior

- Each omitted dimension retains its existing independent default of one when
  that operation permits omission.
- No omitted command or descriptor field infers a CUBE layout.
- Existing Matrix start function numbers and instruction encodings are
  unchanged.
- Operation-specific input dtype pairs, accumulator types, Bias rules, MX scale
  requirements, and PostProcess mode legality remain independently enforced.
- Zero PE mask precedence remains a strict no-op before active shape checks.

## Explicit exclusions

This decision does not own Shared rendezvous, transpose encoding, partial PE
masks, accumulator C/D identity, or atomic PostProcess output publication.

## Acceptance criteria

The accepted ASL, generated documentation, and independent decoded tests prove:

1. mandatory M16/M32 A/C/D and N8 B roles;
2. ordinary Local primary-operand rejection;
3. M16 and M32 acceptance overlap for M<=16 and M32 acceptance above 16;
4. arbitrary positive M/N/K, N>8, and multi-CELL K/N tails;
5. exact per-PE TSize capacity boundaries and padding exclusion;
6. ordinary Bias and optional MX scale behavior;
7. Local-only TGEMV with M=1;
8. dtype/layout/shape/definedness failures before effects; and
9. unchanged Matrix instruction encodings.
