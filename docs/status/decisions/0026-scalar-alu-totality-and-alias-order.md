# ADR 0026: Scalar ALU totality and alias order

- Status: accepted
- Scope: all 107 accepted scalar ALU forms
- Requirement: PTO-REQ-SCALAR-ALU-001, PTO-REQ-SCALAR-OPERAND-001

## Decision

Scalar ALU arithmetic is fixed-width. Sixty-four-bit results wrap modulo
`2^64`; word results operate on the low 32 bits, wrap modulo `2^32`, and sign
extend the final 32-bit result. Shift counts use the low six bits for 64-bit
operations and the low five bits for word operations. Signed and unsigned
minimum and maximum operations compare the complete selected width.

Integer division does not trap. A zero divisor returns a zero quotient and the
unchanged dividend as the remainder. Signed minimum divided by negative one
returns the signed minimum and a zero remainder. The same rules apply at 64 and
32 bits, and pair-result division writes quotient before remainder.

Pair-result operations compute both results from snapshots of every source
before either destination is written. They then write destination zero followed
by destination one. If both destinations name the same absolute register, the
second result is the final value. If both destinations push the same temporary
queue, the second result is newest and the first result is next-newest. A
discard destination has no register or queue effect.

All single-result ALU operations likewise snapshot every GPR or T/U source
before the destination effect. A queue push therefore cannot change the value
consumed by the same instruction. Source selectors T#1 through T#4 and U#1
through U#4 are non-consuming. Destination codes 0 and 24 through 29 discard;
destination 30 pushes U and destination 31 pushes T.

Bitfield width, offset, wrapping, byte reversal, and insertion follow ADR 0025.
Concatenation shifts range from zero through 127. A 64-bit concatenation shift
of 64 selects the former high half as the low result, while a shift of 127
selects its highest bit. Word concatenation operates on the packed low 32-bit
halves and returns zero results for shifts of 64 or greater.

Materialization and extension forms preserve their encoded signedness.
Conditional select treats only zero as false. Its `SrcRType` encodings `00`,
`01`, and `10` are unmodified aliases; encoding `11` negates the selected
right operand before the destination write. `C.SETC.TGT` and `C.SETRET` retain
the control effects assigned by the canonical ALU catalog.

## Rationale

The accepted catalog permits all Reg5 source and destination selector values
and does not forbid destination overlap in pair-result forms. Making snapshot
and destination order explicit gives those legal encodings deterministic
semantics instead of relying on host evaluation order. The fixed-width corner
rules are the existing PTO reference behavior and are now closure requirements,
not incidental test examples.

## Verification

The canonical scalar catalog and mirrored ALU ASL units bind every accepted
form to its effect class. The independent ALU boundary and alias tests are
owned through `spec/evidence/release-traceability-readiness.json`; no separate
behavioral evidence ledger is normative.
`TestScalarALUBoundaryMatrix` covers arithmetic, logic, shifts, extrema,
multiply/divide, pair results, bitfields, concatenation, materialization,
extension, selection, and control-effect bounds. `TestScalarALUAliasMatrix`
executes decoded single- and pair-result forms across absolute, discard, T, and
U destination equivalence classes, including source overlap and ordered pair
writes.
