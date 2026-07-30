# ADR 0027: Scalar BRU totality and target legality

- Status: accepted
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
read the commit argument outside a bundle body and P0 inside a bundle body; all
other predicates and bundle state are preserved.

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

An independent executable ISA/model comparison corroborates halfword-scaled
offsets, signed relative displacements, predicate-based conditional control,
wrapped PC-relative arithmetic, and synchronized return-address effects. Its
additional start-marker target policy is intentionally not imported: PTO v0
does not expose the state needed to evaluate that policy. PTO owns the rules
above, and the comparison is evidence rather than authority.

## Verification

`spec/evidence/scalar-bru-totality.json` binds all six BRU effect classes and
all 66 stable form IDs to decoded boundary, modifier, target, alias, predicate,
bundle-preservation, and fault obligations. The generated totality functions
execute raw encodings through `ExecuteScalarInstruction`; helper-only tests do
not close `S4-T4`.
