---
{
  "id": "ADR-0084",
  "title": "Scalar, system, and queue operations",
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
    "PTO-ACRC-DECISION-BINDING-001",
    "PTO-ACRE-IMPLICIT-STOP-001",
    "PTO-ADD-DECISION-BINDING-001",
    "PTO-ADDTPC-PAGE-001",
    "PTO-AND-DECISION-BINDING-001",
    "PTO-ARCH-ENCODING-OWNERSHIP-001",
    "PTO-BCNT-DECISION-BINDING-001",
    "PTO-BIC-DECISION-BINDING-001",
    "PTO-BIS-DECISION-BINDING-001",
    "PTO-BLOCK-ERCOV-RESERVED-001",
    "PTO-BLOCK-ESAVE-RESERVED-001",
    "PTO-BLOCK-MSET-FILL-001",
    "PTO-BLOCK-XB-RESERVED-001",
    "PTO-BSE-DECISION-BINDING-001",
    "PTO-BWE-DECISION-BINDING-001",
    "PTO-BWI-DECISION-BINDING-001",
    "PTO-BWT-DECISION-BINDING-001",
    "PTO-BXS-DECISION-BINDING-001",
    "PTO-BXU-DECISION-BINDING-001",
    "PTO-C-CMP-EQI-DECISION-BINDING-001",
    "PTO-C-CMP-NEI-DECISION-BINDING-001",
    "PTO-C-EBREAK-CAUSE-001",
    "PTO-C-SETC-EQ-CONDITIONAL-SETTER-001",
    "PTO-C-SETC-NE-CONDITIONAL-SETTER-001",
    "PTO-C-SETC-TGT-SNAPSHOT-001",
    "PTO-C-SETRET-DECISION-BINDING-001",
    "PTO-C-SSRGET-DIRECT-IDS-001",
    "PTO-CLZ-DECISION-BINDING-001",
    "PTO-CTZ-DECISION-BINDING-001",
    "PTO-EBREAK-DECISION-BINDING-001",
    "PTO-FABS-DECISION-BINDING-001",
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-FCVTM-DECISION-BINDING-001",
    "PTO-FCVTN-DECISION-BINDING-001",
    "PTO-FCVTP-DECISION-BINDING-001",
    "PTO-FCVTZ-DECISION-BINDING-001",
    "PTO-FENCE-D-DECISION-BINDING-001",
    "PTO-FENCE-I-DECISION-BINDING-001",
    "PTO-FENTRY-RESTARTABLE-FRAME-001",
    "PTO-FEXIT-RESTARTABLE-FRAME-001",
    "PTO-FMAX-DECISION-BINDING-001",
    "PTO-FMIN-DECISION-BINDING-001",
    "PTO-FNE-DECISION-BINDING-001",
    "PTO-FNES-DECISION-BINDING-001",
    "PTO-FRET-RA-RESTARTABLE-FRAME-001",
    "PTO-FRET-STK-RESTARTABLE-FRAME-001",
    "PTO-HL-ADDI-CONTRACT-001",
    "PTO-HL-ADDIW-CONTRACT-001",
    "PTO-HL-ADDTPC-PAGE-001",
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
    "PTO-HL-PRF-A-CACHE-MODEL-001",
    "PTO-HL-PRF-CACHE-MODEL-001",
    "PTO-HL-PRFI-U-CACHE-MODEL-001",
    "PTO-HL-PRFI-UA-CACHE-MODEL-001",
    "PTO-HL-QMT-GQM-001",
    "PTO-HL-QPOP-GQM-001",
    "PTO-HL-QPUSH-GQM-001",
    "PTO-HL-REM-RESULT-ORDER-001",
    "PTO-HL-REMU-RESULT-ORDER-001",
    "PTO-HL-REMUW-RESULT-ORDER-001",
    "PTO-HL-REMW-RESULT-ORDER-001",
    "PTO-HL-SD-UPO-DECISION-BINDING-001",
    "PTO-HL-SD-UPR-DECISION-BINDING-001",
    "PTO-HL-SETC-ANDI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-EQI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-GEI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-GEUI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-LTI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-LTUI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-NEI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-ORI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETRET-DECISION-BINDING-001",
    "PTO-HL-SH-UPO-DECISION-BINDING-001",
    "PTO-HL-SH-UPR-DECISION-BINDING-001",
    "PTO-HL-SSRGET-DECISION-BINDING-001",
    "PTO-HL-SSRSET-DECISION-BINDING-001",
    "PTO-HL-SUBI-CONTRACT-001",
    "PTO-HL-SUBIW-CONTRACT-001",
    "PTO-HL-SW-UPO-DECISION-BINDING-001",
    "PTO-HL-SW-UPR-DECISION-BINDING-001",
    "PTO-HL-XORI-CONTRACT-001",
    "PTO-HL-XORIW-CONTRACT-001",
    "PTO-J-DECISION-BINDING-001",
    "PTO-JR-DECISION-BINDING-001",
    "PTO-LSRGET-BARG-001",
    "PTO-MCOPY-RESTART-001",
    "PTO-OR-DECISION-BINDING-001",
    "PTO-PRF-NONFAULTING-HINT-001",
    "PTO-PRFI-U-NONFAULTING-HINT-001",
    "PTO-REV-DECISION-BINDING-001",
    "PTO-SCVTF-DECISION-BINDING-001",
    "PTO-SD-U-ADR-CONTRACT-001",
    "PTO-SD-XOR-ADR-CONTRACT-001",
    "PTO-SDI-ADR-CONTRACT-001",
    "PTO-SDI-U-ADR-CONTRACT-001",
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
    "PTO-SETC-TGT-ADR-CONTRACT-001",
    "PTO-SETRET-ADR-CONTRACT-001",
    "PTO-SH-ADR-CONTRACT-001",
    "PTO-SH-PCR-ADR-CONTRACT-001",
    "PTO-SH-U-ADR-CONTRACT-001",
    "PTO-SHI-ADR-CONTRACT-001",
    "PTO-SHI-U-ADR-CONTRACT-001",
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
    "PTO-SSRGET-ADR-CONTRACT-001",
    "PTO-SSRSET-ADR-CONTRACT-001",
    "PTO-SSRSWAP-ADR-CONTRACT-001",
    "PTO-SUB-ADR-CONTRACT-001",
    "PTO-SUBI-ADR-CONTRACT-001",
    "PTO-SUBIW-ADR-CONTRACT-001",
    "PTO-SUBW-ADR-CONTRACT-001",
    "PTO-SW-ADD-ADR-CONTRACT-001",
    "PTO-SW-ADR-CONTRACT-001",
    "PTO-SW-AND-ADR-CONTRACT-001",
    "PTO-SW-OR-ADR-CONTRACT-001",
    "PTO-SW-PCR-ADR-CONTRACT-001",
    "PTO-SW-SMAX-ADR-CONTRACT-001",
    "PTO-SW-SMIN-ADR-CONTRACT-001",
    "PTO-SW-U-ADR-CONTRACT-001",
    "PTO-SW-UMAX-ADR-CONTRACT-001",
    "PTO-SW-UMIN-ADR-CONTRACT-001",
    "PTO-SW-XOR-ADR-CONTRACT-001",
    "PTO-SWAPB-ADR-CONTRACT-001",
    "PTO-SWAPD-ADR-CONTRACT-001",
    "PTO-SWAPH-ADR-CONTRACT-001",
    "PTO-SWAPW-ADR-CONTRACT-001",
    "PTO-SWI-ADR-CONTRACT-001",
    "PTO-SWI-U-ADR-CONTRACT-001",
    "PTO-TLB-IA-ADR-CONTRACT-001",
    "PTO-TLB-IALL-ADR-CONTRACT-001",
    "PTO-TLB-IAV-ADR-CONTRACT-001",
    "PTO-TLB-IV-ADR-CONTRACT-001",
    "PTO-UCVTF-DECISION-BINDING-001",
    "PTO-XOR-ADR-CONTRACT-001",
    "PTO-XORI-ADR-CONTRACT-001",
    "PTO-XORIW-ADR-CONTRACT-001",
    "PTO-XORW-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-BLOCK-ERCOV",
    "PTO-BLOCK-ESAVE",
    "PTO-BLOCK-FENTRY",
    "PTO-BLOCK-FEXIT",
    "PTO-BLOCK-FRET-RA",
    "PTO-BLOCK-FRET-STK",
    "PTO-BLOCK-HL-QMT",
    "PTO-BLOCK-HL-QPOP",
    "PTO-BLOCK-HL-QPUSH",
    "PTO-BLOCK-MCOPY",
    "PTO-BLOCK-MSET",
    "PTO-BLOCK-XB",
    "PTO-SCALAR-ACRC",
    "PTO-SCALAR-ACRE",
    "PTO-SCALAR-ADD",
    "PTO-SCALAR-ADDTPC",
    "PTO-SCALAR-AND",
    "PTO-SCALAR-BCNT",
    "PTO-SCALAR-BIC",
    "PTO-SCALAR-BIS",
    "PTO-SCALAR-BSE",
    "PTO-SCALAR-BWE",
    "PTO-SCALAR-BWI",
    "PTO-SCALAR-BWT",
    "PTO-SCALAR-BXS",
    "PTO-SCALAR-BXU",
    "PTO-SCALAR-C-CMP-EQI",
    "PTO-SCALAR-C-CMP-NEI",
    "PTO-SCALAR-C-EBREAK",
    "PTO-SCALAR-C-SETC-EQ",
    "PTO-SCALAR-C-SETC-NE",
    "PTO-SCALAR-C-SETC-TGT",
    "PTO-SCALAR-C-SETRET",
    "PTO-SCALAR-C-SSRGET",
    "PTO-SCALAR-CLZ",
    "PTO-SCALAR-CTZ",
    "PTO-SCALAR-EBREAK",
    "PTO-SCALAR-FABS",
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-FCVTM",
    "PTO-SCALAR-FCVTN",
    "PTO-SCALAR-FCVTP",
    "PTO-SCALAR-FCVTZ",
    "PTO-SCALAR-FENCE-D",
    "PTO-SCALAR-FENCE-I",
    "PTO-SCALAR-FMAX",
    "PTO-SCALAR-FMIN",
    "PTO-SCALAR-FNE",
    "PTO-SCALAR-FNES",
    "PTO-SCALAR-HL-ADDI",
    "PTO-SCALAR-HL-ADDIW",
    "PTO-SCALAR-HL-ADDTPC",
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
    "PTO-SCALAR-HL-LUI",
    "PTO-SCALAR-HL-MADDW",
    "PTO-SCALAR-HL-ORI",
    "PTO-SCALAR-HL-ORIW",
    "PTO-SCALAR-HL-PRF",
    "PTO-SCALAR-HL-PRF-A",
    "PTO-SCALAR-HL-PRFI-U",
    "PTO-SCALAR-HL-PRFI-UA",
    "PTO-SCALAR-HL-REM",
    "PTO-SCALAR-HL-REMU",
    "PTO-SCALAR-HL-REMUW",
    "PTO-SCALAR-HL-REMW",
    "PTO-SCALAR-HL-SD-UPO",
    "PTO-SCALAR-HL-SD-UPR",
    "PTO-SCALAR-HL-SETC-ANDI",
    "PTO-SCALAR-HL-SETC-EQI",
    "PTO-SCALAR-HL-SETC-GEI",
    "PTO-SCALAR-HL-SETC-GEUI",
    "PTO-SCALAR-HL-SETC-LTI",
    "PTO-SCALAR-HL-SETC-LTUI",
    "PTO-SCALAR-HL-SETC-NEI",
    "PTO-SCALAR-HL-SETC-ORI",
    "PTO-SCALAR-HL-SETRET",
    "PTO-SCALAR-HL-SH-UPO",
    "PTO-SCALAR-HL-SH-UPR",
    "PTO-SCALAR-HL-SSRGET",
    "PTO-SCALAR-HL-SSRSET",
    "PTO-SCALAR-HL-SUBI",
    "PTO-SCALAR-HL-SUBIW",
    "PTO-SCALAR-HL-SW-UPO",
    "PTO-SCALAR-HL-SW-UPR",
    "PTO-SCALAR-HL-XORI",
    "PTO-SCALAR-HL-XORIW",
    "PTO-SCALAR-J",
    "PTO-SCALAR-JR",
    "PTO-SCALAR-LSRGET",
    "PTO-SCALAR-OR",
    "PTO-SCALAR-PRF",
    "PTO-SCALAR-PRFI-U",
    "PTO-SCALAR-REV",
    "PTO-SCALAR-SCVTF",
    "PTO-SCALAR-SD-U",
    "PTO-SCALAR-SD-XOR",
    "PTO-SCALAR-SDI",
    "PTO-SCALAR-SDI-U",
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
    "PTO-SCALAR-SETC-TGT",
    "PTO-SCALAR-SETRET",
    "PTO-SCALAR-SH",
    "PTO-SCALAR-SH-PCR",
    "PTO-SCALAR-SH-U",
    "PTO-SCALAR-SHI",
    "PTO-SCALAR-SHI-U",
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
    "PTO-SCALAR-SSRGET",
    "PTO-SCALAR-SSRSET",
    "PTO-SCALAR-SSRSWAP",
    "PTO-SCALAR-SUB",
    "PTO-SCALAR-SUBI",
    "PTO-SCALAR-SUBIW",
    "PTO-SCALAR-SUBW",
    "PTO-SCALAR-SW",
    "PTO-SCALAR-SW-ADD",
    "PTO-SCALAR-SW-AND",
    "PTO-SCALAR-SW-OR",
    "PTO-SCALAR-SW-PCR",
    "PTO-SCALAR-SW-SMAX",
    "PTO-SCALAR-SW-SMIN",
    "PTO-SCALAR-SW-U",
    "PTO-SCALAR-SW-UMAX",
    "PTO-SCALAR-SW-UMIN",
    "PTO-SCALAR-SW-XOR",
    "PTO-SCALAR-SWAPB",
    "PTO-SCALAR-SWAPD",
    "PTO-SCALAR-SWAPH",
    "PTO-SCALAR-SWAPW",
    "PTO-SCALAR-SWI",
    "PTO-SCALAR-SWI-U",
    "PTO-SCALAR-TLB-IA",
    "PTO-SCALAR-TLB-IALL",
    "PTO-SCALAR-TLB-IAV",
    "PTO-SCALAR-TLB-IV",
    "PTO-SCALAR-UCVTF",
    "PTO-SCALAR-XOR",
    "PTO-SCALAR-XORI",
    "PTO-SCALAR-XORIW",
    "PTO-SCALAR-XORW"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-0062"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "not-required",
  "legacy_ids": [
    "PRD-146",
    "PRD-147",
    "PRD-148",
    "PRD-149",
    "PRD-150",
    "PRD-151",
    "PRD-152",
    "PRD-153",
    "PRD-154",
    "PRD-155",
    "PRD-156",
    "PRD-157",
    "PRD-158",
    "PRD-159",
    "PRD-160",
    "PRD-161",
    "PRD-162",
    "PRD-163",
    "PRD-164",
    "PRD-165",
    "PRD-166",
    "PRD-167",
    "PRD-168",
    "PRD-169",
    "PRD-170",
    "PRD-171",
    "PRD-172",
    "PRD-173"
  ]
}
---
# ADR 0084: Scalar, system, and queue operations

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 148: `HL.PRF` assigns three cache-hint models

`HL.PRF.model` code `0` denotes an L1 prefetch hint, code `1` denotes L2, and
code `2` denotes L3. Codes `3` through `31` are reserved and MUST raise
`IllegalInstruction` before either source register is read or any
architectural effect occurs.

For a legal model, `HL.PRF` forms its effective address from `SrcL`, the
selected `SrcRType` transformation, and `shamt`. The cache target is a
non-binding performance hint: execution performs no architecturally visible
cache-placement update, register write, memory access, memory event, or
reservation change, and it cannot raise a data-access fault. Successful
execution advances `TPC` by six bytes.

## Decision 149: `ACRE` is an implicit SYS-block stop

`ACRE` is legal only as the terminating scalar instruction of a SYS block.
It is itself the block stop: software MUST NOT encode a separate `BSTOP` after
it as part of the same block. Executing `ACRE` requests an atomic commit of the
current SYS block and performs `ACR_ENTER` as that commit's terminating control
transfer.

If `ACRE` appears in a non-SYS block, or if another instruction is placed after
it in the same block, the block raises `Illegal Block Exception` before any
context validation, recovery, ACR switch, validity consumption, request-epoch
update, or other `ACRE` effect. The existing `RRA_Type` rule remains unchanged:
codes `0` and `1` are exact aliases and codes `2` through `15` are reserved.

## Decision 147: `HL.MADDW` returns two sign-extended word halves

`HL.MADDW` reads the low 32 bits of `SrcL`, `SrcR`, and `SrcD` and interprets
each as a signed two's-complement value. It computes the signed 64-bit result
`signed32(SrcL) * signed32(SrcR) + signed32(SrcD)` modulo 2^64.

`RegDst0` receives the sign extension to `PTO_XLEN` of result bits `31:0`.
`RegDst1` receives the sign extension to `PTO_XLEN` of result bits `63:32`.
All three source values MUST be snapshotted before either destination is
written. Destination writes occur in `RegDst0` then `RegDst1` order and follow
the ordinary Reg5 destination-alias semantics.

## Decision 146: `HL.LUI` places its immediate in the upper 32 bits

`HL.LUI` reconstructs the encoded 32-bit immediate and writes it to result
bits `63:32`. Result bits `31:0` are zero. Equivalently, the materialized
value is `ZeroExtend64(imm32) << 32`.

The immediate is not sign-extended and is not shifted by twelve bits. Encoded
zero materializes zero. This upper-half operation is distinct from `HL.LIS`,
which sign-extends its encoded 32-bit immediate without shifting it.

## Decision 150: software-breakpoint immediates are trap-cause payloads

`C.EBREAK imm5` and `EBREAK imm4` MUST raise the software-breakpoint
exception with trap number 50. The encoded immediate MUST be zero-extended
into the 24-bit `TRAPNO` cause field visible to the trap handler. The faulting
instruction PC MUST remain available through trap argument zero.

For `C.EBREAK`, all five-bit values `0` through `31` are assigned. For
`EBREAK`, all four-bit values `0` through `15` are assigned. Encoded zero is a
real zero-valued cause payload; it does not mean that the field is absent.

The architecture MUST NOT maintain a second independent `_BreakpointTag`
state. Software-breakpoint entry MUST atomically publish the saved
pre-instruction context, trap number, zero-extended immediate cause, and
faulting-PC argument before transferring to the trap vector. Rejected decode
or legality checks MUST NOT modify trap state.

## Decision 151: frame-template instructions are part of PTO

`FENTRY`, `FEXIT`, `FRET.RA`, and `FRET.STK` are formal PTO instructions. They
are standalone template blocks and valid block-start control-flow targets.
Their encodings, canonical assembly, legality, ordered effects, fault
behavior, and restart behavior MUST be identical across implementations of
the common architecture.

The encoded register range is the inclusive callee-save ring `R2..R23`.
Singleton, full-ring, and wrap ranges are legal; endpoints outside that ring
are illegal. The immediate is a byte count whose representable values are
multiples of eight. If the selected range contains `N` registers, the frame
size MUST be at least `8*N`; malformed endpoints or insufficient frame size
raise Illegal Instruction before any register, stack, memory, target, or
template-progress effect.

`FENTRY` snapshots the selected source registers before destructive effects,
subtracts the frame size from `sp`, then stores the `N` snapshots in range
order to consecutive eight-byte slots descending from the caller `sp`.
`FEXIT` adds the frame size to `sp`, then loads those slots in range order into
the selected destination registers.

`FRET.RA` publishes the return target read from the pre-restore `ra`, adds the
frame size to `sp`, restores the selected range, and completes the return.
`FRET.STK` is legal only when the range begins at `ra`; it adds the frame size
to `sp`, restores `ra` from stack slot zero, publishes that restored target,
then restores the remaining selected registers and completes the return.
Every return target MUST be validated as a legal block-start marker before a
return effect becomes visible.

The template is restartable at its ordered architectural event boundaries.
Phase-zero validation faults have no template effect. For a recoverable fault
during an event, earlier committed events remain visible, the faulting event
has no effect, and recovery retries exactly that event without repeating any
earlier register, stack, memory, target, or progress effect. Each event and
its progress advance commit atomically.

## Decision 152: `MCOPY` is a non-overlapping restartable memory template

`MCOPY [RegSrc0, RegSrc1, RegSrc2]` is a formal PTO standalone template
block. `RegSrc0` supplies the destination byte address, `RegSrc1` supplies the
source byte address, and `RegSrc2` supplies an unsigned byte count using the
complete XLEN value. A zero byte count is legal and produces no memory access.

The source interval `[source, source + length)` and destination interval
`[destination, destination + length)` MUST NOT overlap. Address-range overflow
or overlap raises Illegal Instruction before any source read, destination
write, memory event, reservation change, last-command update, or template
progress effect.

Execution is restartable at its ordered memory-step boundaries. Each memory
step performs the architecturally ordered source read and corresponding
destination write for the next portion of the range. The step effect and its
progress advance commit atomically. If a recoverable memory fault occurs,
earlier committed steps remain visible, the faulting step has no architectural
effect, and recovery retries exactly that step without repeating any earlier
read, write, reservation, event, or progress effect. Completion therefore
implements a forward copy for the non-overlapping ranges; it is not an
instruction-wide snapshot operation and has no 63-byte architectural limit.

## Decision 153: General Queue Management is part of PTO

General Queue Management is formal PTO architecture. Its three canonical
mnemonics are `HL.QMT`, `HL.QPUSH`, and `HL.QPOP`. These spellings are retained
without aliases to `HL.PUSH` or `HL.POP`.

The three occupied 48-bit encoding families are executable PTO instruction
families rather than externally reserved space. Their complete legality,
queue-state, result, notification, ordering, exception, and restart contracts
MUST be defined in PTO ASL. The earlier PTO profile rule that rejected these
handlers before effects is superseded for these three mnemonics.

## Decision 154: `HL.QMT` flag, capacity, and result contract

`HL.QMT` manages the GQM queue identified by the address read from `SrcL`.
The instruction admits the bare form and every combination of the encoded
`i`, `e`, `s`, and `r` bits except a combination containing both `s` and `r`.
The canonical suffix spelling is `e`; the historical spelling `b` is not an
alias.

Without `i`, the primary operation queries the queue and returns its remaining
number of 64-bit entries. With `i`, `SrcR[9:0]` supplies a capacity from zero
through 1023 64-bit entries, the queue is reinitialized to that capacity, and
the primary result is the allocated byte count. `SrcR` is not read when `i`
is clear. There is no separate 1024-byte capacity limit.

After the primary query or initialization, `e` broadcasts a BWE event
notification, `s` suspends the queue so that reads remain permitted but writes
are rejected, and `r` restores ordinary read/write operation. When combined,
these actions occur in that order. The result status uses bits `[63:62]`:
zero denotes success, one denotes detected queue-data corruption, and values
two and three are reserved. Unused result bits are zero.

## Decision 155: GQM operands use the common absolute-or-relative selector domain

Every encoded GQM source and destination register field uses the common
five-bit scalar selector domain. A source or destination may name an absolute
architectural register `R0..R23` or a valid block-relative `t` or `u` queue
entry. The canonical assembler accepts both forms for `HL.QMT`, `HL.QPUSH`,
and `HL.QPOP`; it does not restrict GQM destinations to relative queues.

Absolute `R0` retains the ordinary zero-register behavior: reads produce zero
and writes are discarded. Relative sources observe the ordinary availability
and dependency rules, while relative destinations append to their selected
result queue. Invalid selector encodings or unavailable relative sources fail
according to the common scalar-selector contract before any GQM state change.

## Decision 156: `HL.QMT` initialization and missing-queue behavior

`HL.QMT.i` atomically creates the queue identified by `SrcL` when it does not
exist, or replaces it when it already exists. Replacement discards every old
entry and resets the queue to its ordinary readable and writable state before
the optional notification and state action defined by the same instruction.
A zero-capacity initialization creates a valid empty, writable queue.

A bare query, suspend, or restore action applied to an uninitialized queue
returns result status one with a zero primary result. It does not create a
queue, broadcast an event, or change queue state. The result is the sole
architectural failure report for this runtime condition; result status values
two and three remain reserved.

## Decision 157: `HL.QPOP` removes the unused encoded source

`HL.QPOP` admits the bare form and suffixes `.e`, `.r`, and `.er`. Encoded
bits `[40:36]` are not a source-register field. They are reserved-zero and
MUST be zero; a nonzero value raises Illegal Instruction before reading
`SrcL`, observing or changing a queue, broadcasting an event, or writing
either destination.

The instruction has exactly one source selector, `SrcL`, and two destination
selectors, `RegDst0` and `RegDst1`. All three selectors use the absolute-or-
relative domain defined for GQM operands. No implementation may read a hidden
or placeholder `SrcR` value.

## Decision 158: `HL.QPOP` is an atomic acquire-capable queue pop

`HL.QPOP` atomically attempts to remove the head 64-bit entry from the GQM
queue whose address is read from `SrcL`. A suspended queue remains readable,
so suspension does not prevent a pop. The bare and `.e` forms have acquire
semantics: memory operations ordered after a successful pop observe memory
operations released before the corresponding non-relaxed push. Suffix `.r`
makes the queue operation relaxed and removes that acquire edge.

On success, `RegDst0` receives the popped entry and result status is zero. An
empty queue returns zero data with status one and does not change the queue.
An uninitialized or corrupt queue returns zero data with status two and does
not change the queue. Status three is reserved. `RegDst1[12:0]` receives the
post-attempt remaining entry count, `RegDst1[63:62]` receives status, and all
other result bits are zero.

Suffix `.e` broadcasts a BWE event only after a successful pop. Empty,
uninitialized, corrupt, selector, or legality failures do not broadcast. The
queue update and both destination results commit as one instruction effect;
destination aliases follow the ordinary ordered multi-destination write rule.

## Decision 159: `HL.QPUSH` is an atomic release-capable queue push

`HL.QPUSH` admits the bare form and every nonempty combination of suffixes
`.h`, `.e`, and `.r`. `SrcL` supplies the GQM queue address, `SrcR` supplies
one 64-bit entry, and `RegDst` receives the operation result. These selectors
use the common absolute-or-relative GQM selector domain. The canonical event
suffix is `.e`; the historical `.b` spelling is not an alias.

Without `.h`, the entry is appended at the queue tail. With `.h`, it is
inserted at the queue head. The bare, `.h`, `.e`, and `.he` forms have release
semantics: a corresponding non-relaxed pop that observes this entry also
observes memory writes ordered before the push. Suffix `.r` makes the queue
operation relaxed and removes that release edge.

On success, result status is zero and `RegDst[9:0]` contains the post-push
remaining capacity. A full queue returns status one without changing the
queue. A suspended initialized queue also returns status one with its actual
unchanged remaining capacity; it produces no queue update, release edge, or
event. An uninitialized or corrupt queue returns status two without changing
the queue. Status three is reserved. `RegDst[63:62]` contains status and every
other result bit is zero.

Suffix `.e` broadcasts a BWE event only after a successful push. Full,
suspended, uninitialized, corrupt, selector, or legality failures do not
broadcast. The queue update and result commit as one instruction effect.

## Decision 160: `ADDTPC` uses a signed page-scaled immediate

`ADDTPC` computes `TPC + (SignExtend(imm20) << 12)` and writes the wrapping
XLEN result to its selected scalar destination. Encoded immediate zero denotes
the current instruction TPC. The instruction is the high-part PC-relative
address materialization operation and may be paired with a low 12-bit add.

## Decision 161: conditional branch forms are reserved in PTO

`B.EQ`, `B.NE`, `B.LT`, `B.GE`, `B.LTU`, `B.GEU`, `B.Z`, and `B.NZ` are not
active PTO instructions. Their complete encoding forms are reserved for the
two-level block-body architecture and MUST remain unavailable to PTO
instructions or aliases.

A PTO decoder MUST reject every one of these reserved forms before reading an
operand or changing architectural, pending-block, queue, memory, descriptor,
trap, or control-flow state. PTO assemblers MUST reject these spellings, and a
canonical PTO disassembler MUST NOT emit them. The reservation may be revised
only by a later architecture decision that assigns an explicit PTO contract.

## Decision 162: `C.SETC.TGT` snapshots its target into `BARG.BPCN`

`C.SETC.TGT SrcL` MUST read the complete selected 64-bit scalar source when
the instruction executes and atomically write that value to the active
block's `BARG.BPCN`. The instruction stores a target value, not a register
selector. A later change to the selected absolute register or T/U queue MUST
NOT change the pending block target.

All 32 common scalar source selectors are valid. An unavailable relative
source fails at `C.SETC.TGT` before changing `BARG.BPCN`, TPC, queue state, or
any other architectural or pending-block state. Target applicability and
alignment are validated at the architecturally defined block-transfer
boundary; the source value is not reread there.

## Decision 163: `C.SETC.TGT` is unique within one block

At most one `C.SETC.TGT` may execute in a block. If the active block already
contains a successful `C.SETC.TGT`, a second occurrence MUST raise Illegal
Block Exception before reading its source or changing `BARG.BPCN`, TPC,
queue state, or any other architectural or pending-block state.

The uniqueness state is private to the active block. It is initialized clear
when the block begins, set only after a successful `C.SETC.TGT` target
snapshot, and cleared with the rest of the retiring block state after a
successful commit. A failed first occurrence does not consume the block's
single permitted occurrence.

## Decision 164: `HL.ADDTPC` uses a signed page-scaled immediate

`HL.ADDTPC` computes `TPC + (SignExtend(imm32) << 12)` and writes the
wrapping XLEN result to its selected scalar destination. Encoded immediate
zero denotes the current instruction TPC. The instruction is the extended
high-part PC-relative address materialization operation and may be paired with
a low 12-bit add.

## Decision 165: one `SETC.*` condition setter resolves an active conditional block

A `SETC.*` condition-setting instruction is applicable only while an active
block has `BARG.TYPE=COND`. In every other context it MUST raise Illegal Block
Exception before reading a source or changing TPC, queues, commit state, BARG,
or any other architectural or pending-block state.

At most one successful `SETC.*` condition setter may execute in one block,
across all condition-setting mnemonics. A second occurrence MUST raise Illegal
Block Exception before reading its source or changing state. A failed first
occurrence does not consume the block's single permitted occurrence.

The successful instruction MUST snapshot all scalar sources, compute its
canonical zero-or-one condition, and atomically write that value to the commit
argument and `BARG.TAKEN` while preserving `BARG.BPC`, `BARG.BPCN`,
`BARG.BlockType`, and `BARG.TYPE`. The uniqueness state is initialized clear
when a block begins and is cleared with the retiring block state after a
successful commit.

## Decision 166: `LSRGET` reads the active block's BARG word view

`LSRGET LSR_ID, ->RegDst` reads the current active block's BARG state. It is
not a system-register access and MUST NOT apply system-register address,
privilege, access-class, or ring selection rules.

Exactly three `LSR_ID` values are assigned. ID 0 returns the current block's
`BARG.BPC`. ID 1 returns `BARG.BPCN`; for an architecture profile that assigns
the same word as a local return address, the active block type determines that
word's BPCN-or-LRA interpretation. ID 2 returns the canonical packed BARG
control word containing `BlockType`, `TYPE`, `TAKEN`, and the applicable
ordering attributes. BARG has no `TRAP` field. Every `LSR_ID` value from 3
through 4095 is reserved and MUST raise Illegal Block Exception before writing
the destination, consuming or producing a queue entry, advancing TPC, or
changing any architectural or pending-block state.

The instruction is legal only with an active block and only for a BARG word
applicable to that block type. An absent word, including BPCN in a block type
without BPCN, raises Illegal Block Exception before effects. A successful read
snapshots the selected BARG word and then applies the common Reg5 destination
mapping: codes 1 through 23 write a GPR, code 30 pushes U, code 31 pushes T,
and codes 0 plus 24 through 29 discard the value. It does not otherwise change
BARG, memory, ordering state, descriptors, or control-flow selection.

## Decision 167: `SCVTF` assigns four integer sources and four floating destinations

`SCVTF` converts one signed integer scalar to one floating scalar using the
active scalar floating-point rounding mode. `SrcType` values 0, 1, 2, and 3
select signed 64-bit, 32-bit, 16-bit, and 8-bit input respectively. The input
is interpreted at the selected width and sign-extended before conversion.

`DstType` values 0, 1, 2, and 3 select `FP64`, `FP32`, `FP16`, and `FP8`
output respectively. Every `DstType` value from 4 through 31 is reserved.
There are no reserved `SrcType` values because the field is two bits wide.
Selecting a reserved destination MUST raise Illegal Instruction before reading
the source, writing the destination, updating floating status, changing queue
state, or advancing TPC.

The operation snapshots its complete scalar source before any destination or
status effect. Numeric result, rounding, exceptional-value behavior, and
sticky floating status follow the selected scalar floating-point profile. A
successful result uses the common scalar destination mapping, including
discard, absolute GPR, U-queue push, and T-queue push destinations.

## Decision 168: `C.SSRGET` uses direct low system-register addresses

`C.SSRGET SSRID, ->t` zero-extends its five-bit `SSRID` field directly to the
architectural system-register address. It does not use a compressed remap
table.

Exactly three encodings are assigned. `SSRID=0` reads `THREAD_PTR`, `SSRID=1`
reads `GLOBAL_PTR`, and `SSRID=16` reads `TIME`. Encoded zero therefore selects
`THREAD_PTR`; it is not omission or a default. Every other five-bit value is
reserved and MUST raise Illegal Instruction before producing or consuming a
queue entry or changing any destination or system-register state.

A successful read applies the ordinary system-register permission and access
rules, snapshots the complete XLEN value, and pushes it as the newest T-queue
entry. The pointer registers return their stored values. `TIME` returns the
architectural time visible to the current instruction attempt. A rejected read
does not push or reorder the T queue; only the ordinary instruction-attempt
time advance and exception entry may occur.

## Decision 169: `PRF` is a non-faulting address hint with an ignored encoded destination field

`PRF [SrcL, SrcR<modifier><<shamt>]` snapshots its two scalar sources and
forms `EA = SrcL + (Modify(SrcR, SrcRType) << shamt)` modulo XLEN. `SrcL` and
`SrcR` use the complete Reg5 source namespace. `SrcRType=0` sign-extends the
low 32 bits, `1` zero-extends the low 32 bits, `2` performs full-width
two's-complement negation, and `3` leaves the full-width right source
unchanged. Every five-bit shift value from 0 through 31 is assigned.

The encoded `RegDst` field is architecturally ignored. Every value from 0
through 31 is an assigned semantic alias, no value names a destination, and
the instruction never writes a GPR or pushes a T/U queue entry. Canonical
assembly emits zero in this field and canonical disassembly does not expose
it.

The effective address is a non-binding implementation hint. A successfully
decoded `PRF` performs no architectural translation, alignment or permission
check, memory access, memory event, reservation update, ordering edge, cache
placement guarantee, or other visible state change, and it cannot raise a
data-access exception. An unavailable relative source is rejected according
to the common scalar-source rule before the hint is formed. Otherwise the
instruction retires normally by four bytes. Only a fixed-bit decode failure or
ordinary source-selector failure can reject it.

## Decision 170: `PRFI.U` is an unscaled immediate non-faulting hint with an ignored encoded destination field

`PRFI.U [SrcL, simm]` reads `SrcL` from the complete Reg5 source namespace,
sign-extends the encoded 12-bit immediate, and forms `EA = SrcL +
SignExtend(simm12)` modulo XLEN. The immediate is unscaled; every encoded
12-bit value is assigned and represents a value from -2048 through 2047.

The encoded `RegDst` field is architecturally ignored. Every value from 0
through 31 is an assigned semantic alias, no value names a destination, and
the instruction never writes a GPR or pushes a T/U queue entry. Canonical
assembly emits zero in this field and canonical disassembly does not expose
it.

The effective address supplies a non-binding L1 prefetch intent. A
successfully decoded `PRFI.U` performs no architectural translation,
alignment or permission check, memory access, memory event, reservation
update, ordering edge, cache-placement guarantee, or other visible state
change, and it cannot raise a data-access exception. An unavailable relative
source is rejected according to the common scalar-source rule before the hint
is formed. Otherwise the instruction retires normally by four bytes. Only a
fixed-bit decode failure or ordinary source-selector failure can reject it.

## Decision 171: the reviewed common encoded-form envelope contains 540 forms

The closed PTO common encoded-form envelope contains exactly 466 scalar forms
and 74 block forms. `BSTART.ICALL` and `L.BSTOP` are active additions.
The eight conditional branch forms reserved by Decision 161 in ADR-0084 are excluded from the
active scalar count and remain represented only in extension reservations.
Two-level-only `B.TEXT`, MPAR/MSEQ, Fixup, and long or high-long BSTART forms
are not active PTO instructions; their complete encodings remain owned by the
extension-reservation catalog and MUST NOT be reassigned to another PTO
mnemonic.

The active forms incorporate the accepted field-domain and canonical-assembly
repairs for `B.DIM`, `B.FPATR`, the common BSTART family, `C.SETRET`,
`FENTRY`/`FEXIT`/`FRET.*`, `HL.QMT`/`HL.QPUSH`/`HL.QPOP`, `MCOPY`, and `MSET`.
They also bind `HL.PRF`, `HL.PRF.A`, `HL.PRFI.U`, and `HL.PRFI.UA` to the
three assigned cache-hint models from Decision 148 in ADR-0084. These repairs change decoded
legality or canonical spelling without assigning an unreviewed opcode. The
projection also carries ADR 0028's FSU domains directly: every scalar FSU
form assigns `SrcType` values 0 and 1 and reserves 2 and 3, while conversion
forms assign `DstType` values 0 through 14 and reserve 15 through 31.

The canonical projection of each form's ID, mnemonic, assembly, instruction
length, encoding kind, fixed encoding, fields, and constraints has SHA-256
fingerprint
`129cb7812264b7e4c5edd088b5aedcc528966eb69c06879dc1919c85106e21b4`.
Any later change to that projection MUST be accompanied by a new architecture
decision before the binary-closure gate is updated.

## Decision 172: scalar SYS placement, local BARG reads, and fault ordering are explicit

Except for `LSRGET` and `SETC.TGT`, every mnemonic in the scalar SYS family is
applicable only while executing the body of an active SYS block. A placement
failure MUST raise Illegal Block Exception before encoded-field legality,
source reads, system-register access, maintenance, request publication, trap
entry, queue effects, destination writes, or TPC advancement. `SETC.TGT`
retains its STD/FP BARG applicability rule. `LSRGET` is applicable in any
active block body for which its selected BARG word exists.

`ACRC` is the final scalar operation of its SYS block. A permitted request MUST
mark that terminal position before service-request trap entry so the saved
context retains the rule. After recovery, only `BSTOP` or a following BSTART
may commit the block; any other scalar or block instruction MUST raise Illegal
Block Exception before effects. An illegal request value or ring route MUST
leave the terminal marker clear.

`ACRE` is the implicit stop of its SYS block. Request values zero and one are
exact aliases; values two through fifteen are reserved. For an assigned value,
the complete recovery context MUST be validated without mutation, the current
SYS block MUST commit successfully, and only then may recovery consume and
restore the saved context. Failed validation or failed commit MUST NOT consume
the saved context or partially restore it. No separate `BSTOP` belongs to the
same block after `ACRE`.

`LSRGET` reads BARG rather than the system-register file. ID 0 returns BPC. ID
1 returns BPCN and is applicable only to STD and FP blocks. ID 2 returns the
canonical packed BARG control word: bits 3:0 are BlockType; bits 6:4 are TYPE
for STD/FP and zero otherwise; bit 7 is TAKEN for STD/FP and zero otherwise;
bits 8, 9, 10, 11, and 12 are respectively atomic, acquire, release, far, and
dimension-reduction attributes; all higher bits are zero. The word has no
trap bit. IDs 3 through 4095 and an inapplicable ID 1 MUST raise Illegal Block
Exception before destination or queue effects.

`C.SSRGET` assigns only direct system-register IDs 0, 1, and 16. `ACRE`
assigns only request values 0 and 1. Their constrained complements MUST raise
Illegal Instruction before handler effects. Every system-register write and
swap MUST preflight the complete address, ACR permission, and access class
before reading its Reg5 source. A rejected swap MUST perform neither its read
side nor its destination effect.

`C.EBREAK` and `EBREAK` MUST publish the zero-extended encoded immediate in
the existing 24-bit trap-cause field while publishing software-breakpoint trap
number 50 and the faulting PC argument. No parallel breakpoint-tag state is
architectural.

## Decision 173: HL remainder forms publish remainder before quotient

`HL.REM`, `HL.REMU`, `HL.REMW`, and `HL.REMUW` compute both the remainder and
quotient from source values snapshotted before either destination effect.
`RegDst0` receives the remainder and `RegDst1` receives the quotient. The two
destination writes occur in that order and retain the ordinary Reg5 duplicate
destination and queue-push behavior.

`HL.DIV`, `HL.DIVU`, `HL.DIVW`, and `HL.DIVUW` retain the complementary
result order: `RegDst0` receives the quotient and `RegDst1` receives the
remainder. The decision changes no encoding, operand width, signedness,
zero-divisor arithmetic, overflow behavior, selector domain, or retirement
rule.
