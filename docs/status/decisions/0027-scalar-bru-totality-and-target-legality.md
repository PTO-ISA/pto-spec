---
{
  "id": "ADR-0027",
  "title": "Scalar BRU totality and target legality",
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
    "PTO-ADDTPC-PAGE-001",
    "PTO-C-CMP-EQI-DECISION-BINDING-001",
    "PTO-C-CMP-NEI-DECISION-BINDING-001",
    "PTO-C-SETC-EQ-CONDITIONAL-SETTER-001",
    "PTO-C-SETC-NE-CONDITIONAL-SETTER-001",
    "PTO-HL-ADDTPC-PAGE-001",
    "PTO-HL-SETC-ANDI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-EQI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-GEI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-GEUI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-LTI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-LTUI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-NEI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-ORI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETRET-DECISION-BINDING-001",
    "PTO-J-DECISION-BINDING-001",
    "PTO-JR-DECISION-BINDING-001",
    "PTO-SETC-AND-CONDITIONAL-SETTER-001",
    "PTO-SETC-ANDI-CONDITIONAL-SETTER-001",
    "PTO-SETC-EQ-CONDITIONAL-SETTER-001",
    "PTO-SETC-EQI-CONDITIONAL-SETTER-001",
    "PTO-SETC-GE-CONDITIONAL-SETTER-001",
    "PTO-SETC-GEI-CONDITIONAL-SETTER-001",
    "PTO-SETC-GEU-CONDITIONAL-SETTER-001",
    "PTO-SETC-GEUI-CONDITIONAL-SETTER-001",
    "PTO-SETC-LT-CONDITIONAL-SETTER-001",
    "PTO-SETC-LTI-CONDITIONAL-SETTER-001",
    "PTO-SETC-LTU-CONDITIONAL-SETTER-001",
    "PTO-SETC-LTUI-CONDITIONAL-SETTER-001",
    "PTO-SETC-NE-CONDITIONAL-SETTER-001",
    "PTO-SETC-NEI-CONDITIONAL-SETTER-001",
    "PTO-SETC-OR-CONDITIONAL-SETTER-001",
    "PTO-SETC-ORI-CONDITIONAL-SETTER-001",
    "PTO-SETRET-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-SCALAR-ADDTPC",
    "PTO-SCALAR-C-CMP-EQI",
    "PTO-SCALAR-C-CMP-NEI",
    "PTO-SCALAR-C-SETC-EQ",
    "PTO-SCALAR-C-SETC-NE",
    "PTO-SCALAR-CMP-AND",
    "PTO-SCALAR-CMP-ANDI",
    "PTO-SCALAR-CMP-EQ",
    "PTO-SCALAR-CMP-EQI",
    "PTO-SCALAR-CMP-GE",
    "PTO-SCALAR-CMP-GEI",
    "PTO-SCALAR-CMP-GEU",
    "PTO-SCALAR-CMP-GEUI",
    "PTO-SCALAR-CMP-LT",
    "PTO-SCALAR-CMP-LTI",
    "PTO-SCALAR-CMP-LTU",
    "PTO-SCALAR-CMP-LTUI",
    "PTO-SCALAR-CMP-NE",
    "PTO-SCALAR-CMP-NEI",
    "PTO-SCALAR-CMP-OR",
    "PTO-SCALAR-CMP-ORI",
    "PTO-SCALAR-HL-ADDTPC",
    "PTO-SCALAR-HL-CMP-ANDI",
    "PTO-SCALAR-HL-CMP-EQI",
    "PTO-SCALAR-HL-CMP-GEI",
    "PTO-SCALAR-HL-CMP-GEUI",
    "PTO-SCALAR-HL-CMP-LTI",
    "PTO-SCALAR-HL-CMP-LTUI",
    "PTO-SCALAR-HL-CMP-NEI",
    "PTO-SCALAR-HL-CMP-ORI",
    "PTO-SCALAR-HL-SETC-ANDI",
    "PTO-SCALAR-HL-SETC-EQI",
    "PTO-SCALAR-HL-SETC-GEI",
    "PTO-SCALAR-HL-SETC-GEUI",
    "PTO-SCALAR-HL-SETC-LTI",
    "PTO-SCALAR-HL-SETC-LTUI",
    "PTO-SCALAR-HL-SETC-NEI",
    "PTO-SCALAR-HL-SETC-ORI",
    "PTO-SCALAR-HL-SETRET",
    "PTO-SCALAR-J",
    "PTO-SCALAR-JR",
    "PTO-SCALAR-SETC-AND",
    "PTO-SCALAR-SETC-ANDI",
    "PTO-SCALAR-SETC-EQ",
    "PTO-SCALAR-SETC-EQI",
    "PTO-SCALAR-SETC-GE",
    "PTO-SCALAR-SETC-GEI",
    "PTO-SCALAR-SETC-GEU",
    "PTO-SCALAR-SETC-GEUI",
    "PTO-SCALAR-SETC-LT",
    "PTO-SCALAR-SETC-LTI",
    "PTO-SCALAR-SETC-LTU",
    "PTO-SCALAR-SETC-LTUI",
    "PTO-SCALAR-SETC-NE",
    "PTO-SCALAR-SETC-NEI",
    "PTO-SCALAR-SETC-OR",
    "PTO-SCALAR-SETC-ORI",
    "PTO-SCALAR-SETRET"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0027: Scalar BRU totality and target legality

> Conditional-branch clauses for `B.EQ`, `B.NE`, `B.LT`, `B.GE`, `B.LTU`,
> `B.GEU`, `B.Z`, and `B.NZ` are superseded by ADR 0067. Other BRU decisions
> in this record remain active.

- Scope: all 66 accepted scalar BRU forms
- Requirement: PTO-REQ-SCALAR-CONTROL-001,
  PTO-REQ-SCALAR-EXECUTION-001, PTO-REQ-BUNDLE-STATE-001,
  PTO-REQ-SCALAR-OPERAND-001

## Decision

Scalar conditions consume complete 64-bit operands. `EQ` and `NE` compare the
bit patterns, `LT` and `GE` compare signed values, and `LTU` and `GEU` compare
unsigned values. `Z` is true only for zero and `NZ` is true for every nonzero
value. Comparison results and commit conditions are canonical words: zero for
false and one for true.

Register comparisons interpret `SrcRType` encodings `00`, `01`, and `10` as
unmodified, sign-extended-low-word, and zero-extended-low-word respectively.
For relational comparison forms, encoding `11` is an unmodified alias because
the assembly grammar has no negated relational source. For logical `AND` and
`OR` comparison forms, encoding `11` applies bitwise NOT. Signed immediates are
sign extended and unsigned immediates are zero extended. Immediate `SETC`
forms shift that extended word left by the decoded five-bit `shamt`; discarded
high bits follow ordinary 64-bit bitvector arithmetic.

Comparison and commit instructions snapshot every Reg5 source before any
destination or commit-state update. The complete 32-code Reg5 source namespace
therefore includes all T and U queue entries. Comparison destinations use the
normal discard, absolute-GPR, push-U, and push-T rules. `C.CMP.EQI` and
`C.CMP.NEI` snapshot T#1 and then push their result to T.

Relative branches and jumps add the sign-extended decoded offset, shifted left
by one, to the pre-increment TPC. A conditional branch that is not taken writes
pre-increment TPC plus four. Arithmetic wraps modulo `2^64`. `B.Z` and `B.NZ`
always read the bundle commit argument established by `SETC.*`. The separate
32-bit P0 through P7 predicate registers and all other bundle state are
preserved.

`JR` adds its sign-extended, halfword-scaled offset to the snapshotted source.
Its encoded `SrcZero` field is absent from the assembly grammar and is an
ignored alias field: all 32 values select the same architectural operation.
An odd resulting target raises `Fault_InstructionPC`, reports that target,
installs no target TPC, and saves the complete pre-instruction context. An even
target is installed directly. PTO v0 has no architectural instruction-memory
map or bundle-start-marker state for ordinary scalar control flow. Consequently
relative control transfers have no marker or fetchability fault, and `JR` has
no target fault beyond the odd-address check. A profile that introduces an
instruction-memory target policy must name and test a new architectural hook;
it cannot silently refine this portable rule.

`ADDTPC` and `HL.ADDTPC` use signed 20-bit and 32-bit immediates respectively,
shift them left by one, and write through the normal Reg5 destination rules.
Their catalog constraint rejects R10 as an encoded destination. `SETRET` and
`HL.SETRET` use unsigned 20-bit and 32-bit immediates, shift them left by one,
and atomically write the same wrapped target to R10 and the bundle return
address. Normal sequential TPC advancement remains the dispatch boundary's
responsibility.

## Rationale

The catalog accepts every Reg5 source selector used by BRU forms and leaves
source/destination overlap legal. The target rules must therefore define queue
sources, source snapshots, destination pushes, wrapping, and fault effects
rather than relying on host evaluation order or an implementation fetch unit.

## Verification

`spec/evidence/scalar-bru-totality.json` binds all six BRU effect classes and
all 66 stable form IDs to decoded boundary, modifier, target, alias, predicate,
bundle-preservation, and fault obligations. The generated totality functions
execute raw encodings through `ExecuteScalarInstruction`; helper-only tests do
not close `S4-T4`.
