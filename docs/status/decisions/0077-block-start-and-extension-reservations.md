---
{
  "id": "ADR-0077",
  "title": "Block start and extension reservations",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-21",
  "accepted": "2026-08-21",
  "rejected": null,
  "superseded": null,
  "baseline": "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f",
  "target_releases": [
    "0.58.1",
    "0.58.2"
  ],
  "affected_ndf": [
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001",
    "PTO-BSTART-CALL-DECISION-BINDING-001",
    "PTO-BSTART-DECISION-BINDING-001",
    "PTO-BSTART-FP-CONTROL-001",
    "PTO-BSTART-ICALL-DECISION-BINDING-001",
    "PTO-BSTART-STD-CONTROL-001",
    "PTO-BSTART-SYS-CONTROL-001",
    "PTO-BSTOP-DECISION-BINDING-001",
    "PTO-C-BSTART-CONTROL-001",
    "PTO-C-BSTART-FP-CONTROL-001",
    "PTO-C-BSTART-STD-CONTROL-001",
    "PTO-C-BSTART-SYS-CONTROL-001",
    "PTO-C-BSTOP-DECISION-BINDING-001",
    "PTO-L-BSTOP-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-BLOCK-BSTART",
    "PTO-BLOCK-BSTART-CALL",
    "PTO-BLOCK-BSTART-FP",
    "PTO-BLOCK-BSTART-ICALL",
    "PTO-BLOCK-BSTART-STD",
    "PTO-BLOCK-BSTART-SYS",
    "PTO-BLOCK-BSTOP",
    "PTO-BLOCK-C-BSTART",
    "PTO-BLOCK-C-BSTART-FP",
    "PTO-BLOCK-C-BSTART-STD",
    "PTO-BLOCK-C-BSTART-SYS",
    "PTO-BLOCK-C-BSTOP",
    "PTO-BLOCK-L-BSTOP"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-0019",
    "ADR-0046",
    "ADR-0051",
    "ADR-0062"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "not-required",
  "legacy_ids": [
    "PRD-031",
    "PRD-032",
    "PRD-033",
    "PRD-034",
    "PRD-035",
    "PRD-036",
    "PRD-037",
    "PRD-038",
    "PRD-039"
  ]
}
---
# ADR 0077: Block start and extension reservations

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 031: `B.TEXT` is extension-reserved and is not a PTO instruction

PTO MUST NOT accept `B.TEXT` assembly, expose `B.TEXT` as a canonical
disassembly, or assign architectural semantics to it. The complete 32-bit
encoding family with fixed low seven bits `0000011` and payload bits `[31:7]`
is reserved as an occupied extension space. PTO MUST NOT allocate another
instruction in that family.

Encountering any instruction in this reserved family MUST raise
`Fault_IllegalInstruction` before changing architectural or pending block
state. In particular, PTO has no out-of-line or separated-block body-address
state, no `SetBundleBodyAddress` operation, and no accepted `simm25` field
contract for this encoding family.

## Decision 032: the long-displacement `BSTART` mnemonic has two forms

The 32-bit encoding with low seven bits `0010001` is
`BSTART DIRECT, <label>`. It MUST NOT accept `CALL` as an alias because the
encoding has no field that can distinguish a call from a direct transfer and
does not encode a return target. Every direct call MUST instead use the fused
`BSTART.CALL <br_label>, <rt_label>, ->ra` instruction.

The 32-bit encoding with low seven bits `0100001` is
`BSTART COND, <label>`. For both forms, `simm25` is sign-extended, shifted left
by one, and added to the address of the BSTART instruction to form the
candidate target. A resulting misaligned address MUST raise
`Fault_InstructionPC` before block state changes.

## Decision 033: `BSTART` initializes BARG and commit selects the continuation

After any retiring block commits successfully, a new `BSTART` initializes one
fresh BARG record. `BARG.BPC` receives the address of this BSTART,
`BARG.BlockType` receives `STD`, and `BARG.BPCN` receives the encoded candidate
target. `BSTART DIRECT` sets `TYPE=DIRECT` and `TAKEN=1`.
`BSTART COND` sets `TYPE=COND` and initializes `TAKEN=0`; an applicable
`SETC.*` operation MAY update `TAKEN` before commit while preserving BPCN.

The BSTART instruction MUST NOT choose or enter the candidate continuation
when it is decoded. `BSTOP` or the next BSTART is the commit boundary that
reads `TYPE`, `TAKEN`, and `BPCN`; a false conditional selects the sequential
next BSTART, while a taken conditional or direct transfer selects BPCN. A
failed retiring-block commit MUST leave the candidate new BARG uninstalled.
BARG contains no `TRAP` field.

## Decision 034: `BSTART.CALL` is one atomic fused call

The only direct-call spelling is
`BSTART.CALL <br_label>, <rt_label>, ->ra`. Its 12-bit signed branch field
computes `call_target = P + (SignExtend(simm12) << 1)`. Its independent
five-bit unsigned return field computes
`return_target = (P + 2) + (ZeroExtend(uimm5) << 1)`, where `P+2` is the
address of the embedded return-target halfword. Encoded zero is a real zero
displacement for each field.

After the retiring block commits successfully, the instruction MUST
atomically initialize a new STD BARG with `BPC=P`, `BPCN=call_target`,
`TYPE=DIRECT`, and `TAKEN=1`, and write `return_target` to architectural `ra`.
Any decode, alignment, applicability, or retiring-commit failure MUST preserve
the old `ra`, BARG, PC state, and candidate new-block state. A single-label
`BSTART CALL, <label>` spelling is not accepted.

## Decision 035: `BSTART.ICALL` is one atomic fused indirect call

The only indirect-call spelling is `BSTART.ICALL <rt_label>, ->ra`. The
32-bit instruction fuses a low compressed `C.BSTART.STD ICALL` halfword with a
high `C.SETRET <rt_label>, ->ra` halfword. The low half selects the indirect
call transfer; the high `uimm5` field computes
`return_target = (P + 2) + (ZeroExtend(uimm5) << 1)`.

The indirect call target is the retiring block's `BARG.BPCN`. The
implementation MUST snapshot and validate that target before retiring BARG is
cleared, successfully commit the retiring block, then atomically initialize
the new STD BARG and write `return_target` to `ra`. Any failure MUST preserve
the old `ra`, BARG, PC state, and candidate new-block state.

Bare `BSTART.{STD,FP,SYS} ICALL` spellings and their compressed, long, or
half-long standalone variants are deleted and MUST NOT execute or appear in
canonical disassembly. Under the general deleted-name rule, deletion alone
does not reserve a former raw encoding; only an independently declared
extension reservation prevents future allocation.

## Decision 036: `BSTART.FP` keeps five public forms and reserves Fixup payloads

PTO accepts exactly these `BSTART.FP` forms:

- `BSTART.FP FALL`, encoded with `simm17=0`;
- `BSTART.FP DIRECT, <label>`;
- `BSTART.FP COND, <label>`;
- `BSTART.FP IND`;
- `BSTART.FP RET`.

For DIRECT and COND, the candidate target is
`P + (SignExtend(simm17) << 1)`. FALL initializes a not-taken fallthrough FP
block. IND and RET select their transfer kind but MUST defer the effective
target to the block's BARG contract and commit boundary; decode MUST NOT
sample a private target or return value as the final continuation.

The nonzero `simm17` values in the FALL family are occupied Fixup-extension
encodings. PTO MUST reject them before effects and MUST NOT allocate another
PTO meaning in that reserved subset. `BSTART.FP CALL, <label>` and bare
`BSTART.FP ICALL` are deleted; calls use Decision 034 in ADR-0077 and Decision 035 in ADR-0077 respectively,
and deleted raw forms are not reservations unless covered by another explicit
extension reservation.

## Decision 037: `BSTART.STD` keeps five public forms and reserves Fixup payloads

PTO accepts exactly these `BSTART.STD` forms:

- `BSTART.STD FALL`, encoded with `simm17=0`;
- `BSTART.STD DIRECT, <label>`;
- `BSTART.STD COND, <label>`;
- `BSTART.STD IND`;
- `BSTART.STD RET`.

DIRECT and COND compute `P + (SignExtend(simm17) << 1)`. FALL initializes a
not-taken fallthrough STD block. IND and RET defer their effective target to
the BARG contract and block commit; decode MUST NOT freeze a private target or
return value as the final continuation.

Nonzero `simm17` values in the FALL family are occupied Fixup-extension
encodings and MUST reject before effects while remaining unavailable for PTO
allocation. `BSTART.STD CALL, <label>` and bare `BSTART.STD ICALL` are
deleted; Decision 034 in ADR-0077 and Decision 035 in ADR-0077 are the only call forms.

## Decision 038: `BSTART.SYS` is a zero-displacement fallthrough form

PTO accepts only `BSTART.SYS FALL`, encoded with `simm17=0`. It initializes a
SYS block whose BARG contains `BPC=P`, `BlockType=SYS`, and the applicable
ordering attributes. SYS BARG has no `BPCN`, `TYPE`, or `TAKEN` field, so this
mnemonic does not select a branch target and the block commits to the
sequential next BSTART.

Nonzero `simm17` values in this encoding family are occupied
Fixup-extension encodings. PTO MUST reject them before effects and MUST NOT
allocate another PTO meaning in that reserved subset. The immediate is not an
accepted operand of PTO assembly when its value is zero; canonical assembly
and disassembly use exactly `BSTART.SYS FALL`.

## Decision 039: machine-parallel and machine-sequential block starts are extension-reserved

`BSTART.MPAR`, `BSTART.MSEQ`, `C.BSTART.MPAR`, and `C.BSTART.MSEQ` are not PTO
instructions. PTO MUST reject their assembly spellings, MUST NOT expose them in
canonical disassembly, and MUST NOT assign execution semantics to them.

The complete raw encoding families currently associated with those four names
are occupied extension space. PTO MUST reserve those families against future
allocation and MUST raise `Fault_IllegalInstruction` before changing
architectural state or pending block state when any member is encountered.

PTO therefore defines no vector-size `Mode` contract for these families, no
compressed default vector size, no machine-parallel or machine-sequential body
entry mechanism, and no block-local execution-mask behavior selected by these
encodings. Any such execution model belongs outside the PTO instruction set.
