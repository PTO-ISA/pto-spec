---
{
  "id": "ADR-0026",
  "title": "Scalar ALU totality and alias order",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ADD-DECISION-BINDING-001",
    "PTO-AND-DECISION-BINDING-001",
    "PTO-BCNT-DECISION-BINDING-001",
    "PTO-BIC-DECISION-BINDING-001",
    "PTO-BIS-DECISION-BINDING-001",
    "PTO-BXS-DECISION-BINDING-001",
    "PTO-BXU-DECISION-BINDING-001",
    "PTO-C-SETC-TGT-SNAPSHOT-001",
    "PTO-C-SETRET-DECISION-BINDING-001",
    "PTO-CLZ-DECISION-BINDING-001",
    "PTO-CTZ-DECISION-BINDING-001",
    "PTO-HL-ADDI-CONTRACT-001",
    "PTO-HL-ADDIW-CONTRACT-001",
    "PTO-HL-ANDI-CONTRACT-001",
    "PTO-HL-ANDIW-CONTRACT-001",
    "PTO-HL-BFI-DECISION-BINDING-001",
    "PTO-HL-CCAT-CONTRACT-001",
    "PTO-HL-CCATW-CONTRACT-001",
    "PTO-HL-DIV-DECISION-BINDING-001",
    "PTO-HL-DIVU-DECISION-BINDING-001",
    "PTO-HL-DIVUW-DECISION-BINDING-001",
    "PTO-HL-DIVW-DECISION-BINDING-001",
    "PTO-HL-LIS-DECISION-BINDING-001",
    "PTO-HL-LUI-UPPER-HALF-001",
    "PTO-HL-MADDW-WORD-HALVES-001",
    "PTO-HL-ORI-CONTRACT-001",
    "PTO-HL-ORIW-CONTRACT-001",
    "PTO-HL-REM-RESULT-ORDER-001",
    "PTO-HL-REMU-RESULT-ORDER-001",
    "PTO-HL-REMUW-RESULT-ORDER-001",
    "PTO-HL-REMW-RESULT-ORDER-001",
    "PTO-HL-SUBI-CONTRACT-001",
    "PTO-HL-SUBIW-CONTRACT-001",
    "PTO-HL-XORI-CONTRACT-001",
    "PTO-HL-XORIW-CONTRACT-001",
    "PTO-OR-DECISION-BINDING-001",
    "PTO-REV-DECISION-BINDING-001",
    "PTO-SLL-ADR-CONTRACT-001",
    "PTO-SLLI-ADR-CONTRACT-001",
    "PTO-SLLIW-ADR-CONTRACT-001",
    "PTO-SLLW-ADR-CONTRACT-001",
    "PTO-SRA-ADR-CONTRACT-001",
    "PTO-SRAI-ADR-CONTRACT-001",
    "PTO-SRAIW-ADR-CONTRACT-001",
    "PTO-SRAW-ADR-CONTRACT-001",
    "PTO-SRL-ADR-CONTRACT-001",
    "PTO-SRLI-ADR-CONTRACT-001",
    "PTO-SRLIW-ADR-CONTRACT-001",
    "PTO-SRLW-ADR-CONTRACT-001",
    "PTO-SUB-ADR-CONTRACT-001",
    "PTO-SUBI-ADR-CONTRACT-001",
    "PTO-SUBIW-ADR-CONTRACT-001",
    "PTO-SUBW-ADR-CONTRACT-001",
    "PTO-XOR-ADR-CONTRACT-001",
    "PTO-XORI-ADR-CONTRACT-001",
    "PTO-XORIW-ADR-CONTRACT-001",
    "PTO-XORW-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-SCALAR-ADD",
    "PTO-SCALAR-ADDI",
    "PTO-SCALAR-ADDIW",
    "PTO-SCALAR-ADDW",
    "PTO-SCALAR-AND",
    "PTO-SCALAR-ANDI",
    "PTO-SCALAR-ANDIW",
    "PTO-SCALAR-ANDW",
    "PTO-SCALAR-BCNT",
    "PTO-SCALAR-BIC",
    "PTO-SCALAR-BIS",
    "PTO-SCALAR-BXS",
    "PTO-SCALAR-BXU",
    "PTO-SCALAR-C-ADD",
    "PTO-SCALAR-C-ADDI",
    "PTO-SCALAR-C-AND",
    "PTO-SCALAR-C-MOVI",
    "PTO-SCALAR-C-MOVR",
    "PTO-SCALAR-C-OR",
    "PTO-SCALAR-C-SETC-TGT",
    "PTO-SCALAR-C-SETRET",
    "PTO-SCALAR-C-SEXT-B",
    "PTO-SCALAR-C-SEXT-H",
    "PTO-SCALAR-C-SEXT-W",
    "PTO-SCALAR-C-SLLI",
    "PTO-SCALAR-C-SRLI",
    "PTO-SCALAR-C-SUB",
    "PTO-SCALAR-C-ZEXT-B",
    "PTO-SCALAR-C-ZEXT-H",
    "PTO-SCALAR-C-ZEXT-W",
    "PTO-SCALAR-CLZ",
    "PTO-SCALAR-CSEL",
    "PTO-SCALAR-CTZ",
    "PTO-SCALAR-DIV",
    "PTO-SCALAR-DIVU",
    "PTO-SCALAR-DIVUW",
    "PTO-SCALAR-DIVW",
    "PTO-SCALAR-HL-ADDI",
    "PTO-SCALAR-HL-ADDIW",
    "PTO-SCALAR-HL-ANDI",
    "PTO-SCALAR-HL-ANDIW",
    "PTO-SCALAR-HL-BFI",
    "PTO-SCALAR-HL-CCAT",
    "PTO-SCALAR-HL-CCATW",
    "PTO-SCALAR-HL-DIV",
    "PTO-SCALAR-HL-DIVU",
    "PTO-SCALAR-HL-DIVUW",
    "PTO-SCALAR-HL-DIVW",
    "PTO-SCALAR-HL-LIS",
    "PTO-SCALAR-HL-LIU",
    "PTO-SCALAR-HL-LUI",
    "PTO-SCALAR-HL-MADD",
    "PTO-SCALAR-HL-MADDW",
    "PTO-SCALAR-HL-MIADD",
    "PTO-SCALAR-HL-MISUB",
    "PTO-SCALAR-HL-MUL",
    "PTO-SCALAR-HL-MULU",
    "PTO-SCALAR-HL-ORI",
    "PTO-SCALAR-HL-ORIW",
    "PTO-SCALAR-HL-REM",
    "PTO-SCALAR-HL-REMU",
    "PTO-SCALAR-HL-REMUW",
    "PTO-SCALAR-HL-REMW",
    "PTO-SCALAR-HL-SUBI",
    "PTO-SCALAR-HL-SUBIW",
    "PTO-SCALAR-HL-XORI",
    "PTO-SCALAR-HL-XORIW",
    "PTO-SCALAR-LUI",
    "PTO-SCALAR-MADD",
    "PTO-SCALAR-MADDW",
    "PTO-SCALAR-MAX",
    "PTO-SCALAR-MAXU",
    "PTO-SCALAR-MIN",
    "PTO-SCALAR-MINU",
    "PTO-SCALAR-MUL",
    "PTO-SCALAR-MULU",
    "PTO-SCALAR-MULUW",
    "PTO-SCALAR-MULW",
    "PTO-SCALAR-OR",
    "PTO-SCALAR-ORI",
    "PTO-SCALAR-ORIW",
    "PTO-SCALAR-ORW",
    "PTO-SCALAR-REM",
    "PTO-SCALAR-REMU",
    "PTO-SCALAR-REMUW",
    "PTO-SCALAR-REMW",
    "PTO-SCALAR-REV",
    "PTO-SCALAR-SLL",
    "PTO-SCALAR-SLLI",
    "PTO-SCALAR-SLLIW",
    "PTO-SCALAR-SLLW",
    "PTO-SCALAR-SRA",
    "PTO-SCALAR-SRAI",
    "PTO-SCALAR-SRAIW",
    "PTO-SCALAR-SRAW",
    "PTO-SCALAR-SRL",
    "PTO-SCALAR-SRLI",
    "PTO-SCALAR-SRLIW",
    "PTO-SCALAR-SRLW",
    "PTO-SCALAR-SUB",
    "PTO-SCALAR-SUBI",
    "PTO-SCALAR-SUBIW",
    "PTO-SCALAR-SUBW",
    "PTO-SCALAR-XOR",
    "PTO-SCALAR-XORI",
    "PTO-SCALAR-XORIW",
    "PTO-SCALAR-XORW"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0026: Scalar ALU totality and alias order

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
