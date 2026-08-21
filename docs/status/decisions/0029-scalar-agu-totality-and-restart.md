---
{
  "id": "ADR-0029",
  "title": "Scalar AGU totality, aliases, and restart",
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
    "PTO-HL-PRF-A-CACHE-MODEL-001",
    "PTO-HL-PRF-CACHE-MODEL-001",
    "PTO-HL-PRFI-U-CACHE-MODEL-001",
    "PTO-HL-PRFI-UA-CACHE-MODEL-001",
    "PTO-HL-SD-UPO-DECISION-BINDING-001",
    "PTO-HL-SD-UPR-DECISION-BINDING-001",
    "PTO-HL-SH-UPO-DECISION-BINDING-001",
    "PTO-HL-SH-UPR-DECISION-BINDING-001",
    "PTO-HL-SW-UPO-DECISION-BINDING-001",
    "PTO-HL-SW-UPR-DECISION-BINDING-001",
    "PTO-PRF-NONFAULTING-HINT-001",
    "PTO-PRFI-U-NONFAULTING-HINT-001",
    "PTO-SD-U-ADR-CONTRACT-001",
    "PTO-SDI-ADR-CONTRACT-001",
    "PTO-SDI-U-ADR-CONTRACT-001",
    "PTO-SH-ADR-CONTRACT-001",
    "PTO-SH-PCR-ADR-CONTRACT-001",
    "PTO-SH-U-ADR-CONTRACT-001",
    "PTO-SHI-ADR-CONTRACT-001",
    "PTO-SHI-U-ADR-CONTRACT-001",
    "PTO-SW-ADR-CONTRACT-001",
    "PTO-SW-PCR-ADR-CONTRACT-001",
    "PTO-SW-U-ADR-CONTRACT-001",
    "PTO-SWI-ADR-CONTRACT-001",
    "PTO-SWI-U-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-SCALAR-C-LDI",
    "PTO-SCALAR-C-LWI",
    "PTO-SCALAR-C-SDI",
    "PTO-SCALAR-C-SWI",
    "PTO-SCALAR-HL-LB-PCR",
    "PTO-SCALAR-HL-LB-PO",
    "PTO-SCALAR-HL-LB-PR",
    "PTO-SCALAR-HL-LBI",
    "PTO-SCALAR-HL-LBI-PO",
    "PTO-SCALAR-HL-LBI-PR",
    "PTO-SCALAR-HL-LBIP",
    "PTO-SCALAR-HL-LBP",
    "PTO-SCALAR-HL-LBU-PCR",
    "PTO-SCALAR-HL-LBU-PO",
    "PTO-SCALAR-HL-LBU-PR",
    "PTO-SCALAR-HL-LBUI",
    "PTO-SCALAR-HL-LBUI-PO",
    "PTO-SCALAR-HL-LBUI-PR",
    "PTO-SCALAR-HL-LBUIP",
    "PTO-SCALAR-HL-LBUP",
    "PTO-SCALAR-HL-LD-PCR",
    "PTO-SCALAR-HL-LD-PO",
    "PTO-SCALAR-HL-LD-PR",
    "PTO-SCALAR-HL-LDI",
    "PTO-SCALAR-HL-LDI-PO",
    "PTO-SCALAR-HL-LDI-PR",
    "PTO-SCALAR-HL-LDI-U",
    "PTO-SCALAR-HL-LDI-UPO",
    "PTO-SCALAR-HL-LDI-UPR",
    "PTO-SCALAR-HL-LDIP",
    "PTO-SCALAR-HL-LDIP-U",
    "PTO-SCALAR-HL-LDP",
    "PTO-SCALAR-HL-LH-PCR",
    "PTO-SCALAR-HL-LH-PO",
    "PTO-SCALAR-HL-LH-PR",
    "PTO-SCALAR-HL-LHI",
    "PTO-SCALAR-HL-LHI-PO",
    "PTO-SCALAR-HL-LHI-PR",
    "PTO-SCALAR-HL-LHI-U",
    "PTO-SCALAR-HL-LHI-UPO",
    "PTO-SCALAR-HL-LHI-UPR",
    "PTO-SCALAR-HL-LHIP",
    "PTO-SCALAR-HL-LHIP-U",
    "PTO-SCALAR-HL-LHP",
    "PTO-SCALAR-HL-LHU-PCR",
    "PTO-SCALAR-HL-LHU-PO",
    "PTO-SCALAR-HL-LHU-PR",
    "PTO-SCALAR-HL-LHUI",
    "PTO-SCALAR-HL-LHUI-PO",
    "PTO-SCALAR-HL-LHUI-PR",
    "PTO-SCALAR-HL-LHUI-U",
    "PTO-SCALAR-HL-LHUI-UPO",
    "PTO-SCALAR-HL-LHUI-UPR",
    "PTO-SCALAR-HL-LHUIP",
    "PTO-SCALAR-HL-LHUIP-U",
    "PTO-SCALAR-HL-LHUP",
    "PTO-SCALAR-HL-LW-PCR",
    "PTO-SCALAR-HL-LW-PO",
    "PTO-SCALAR-HL-LW-PR",
    "PTO-SCALAR-HL-LWI",
    "PTO-SCALAR-HL-LWI-PO",
    "PTO-SCALAR-HL-LWI-PR",
    "PTO-SCALAR-HL-LWI-U",
    "PTO-SCALAR-HL-LWI-UPO",
    "PTO-SCALAR-HL-LWI-UPR",
    "PTO-SCALAR-HL-LWIP",
    "PTO-SCALAR-HL-LWIP-U",
    "PTO-SCALAR-HL-LWP",
    "PTO-SCALAR-HL-LWU-PCR",
    "PTO-SCALAR-HL-LWU-PO",
    "PTO-SCALAR-HL-LWU-PR",
    "PTO-SCALAR-HL-LWUI",
    "PTO-SCALAR-HL-LWUI-PO",
    "PTO-SCALAR-HL-LWUI-PR",
    "PTO-SCALAR-HL-LWUI-U",
    "PTO-SCALAR-HL-LWUI-UPO",
    "PTO-SCALAR-HL-LWUI-UPR",
    "PTO-SCALAR-HL-LWUIP",
    "PTO-SCALAR-HL-LWUIP-U",
    "PTO-SCALAR-HL-LWUP",
    "PTO-SCALAR-HL-PRF",
    "PTO-SCALAR-HL-PRF-A",
    "PTO-SCALAR-HL-PRFI-U",
    "PTO-SCALAR-HL-PRFI-UA",
    "PTO-SCALAR-HL-SB-PCR",
    "PTO-SCALAR-HL-SB-PO",
    "PTO-SCALAR-HL-SB-PR",
    "PTO-SCALAR-HL-SBI",
    "PTO-SCALAR-HL-SBI-PO",
    "PTO-SCALAR-HL-SBI-PR",
    "PTO-SCALAR-HL-SBIP",
    "PTO-SCALAR-HL-SBP",
    "PTO-SCALAR-HL-SD-PCR",
    "PTO-SCALAR-HL-SD-PO",
    "PTO-SCALAR-HL-SD-PR",
    "PTO-SCALAR-HL-SD-UPO",
    "PTO-SCALAR-HL-SD-UPR",
    "PTO-SCALAR-HL-SDI",
    "PTO-SCALAR-HL-SDI-PO",
    "PTO-SCALAR-HL-SDI-PR",
    "PTO-SCALAR-HL-SDI-U",
    "PTO-SCALAR-HL-SDI-UPO",
    "PTO-SCALAR-HL-SDI-UPR",
    "PTO-SCALAR-HL-SDIP",
    "PTO-SCALAR-HL-SDIP-U",
    "PTO-SCALAR-HL-SDP",
    "PTO-SCALAR-HL-SDP-U",
    "PTO-SCALAR-HL-SH-PCR",
    "PTO-SCALAR-HL-SH-PO",
    "PTO-SCALAR-HL-SH-PR",
    "PTO-SCALAR-HL-SH-UPO",
    "PTO-SCALAR-HL-SH-UPR",
    "PTO-SCALAR-HL-SHI",
    "PTO-SCALAR-HL-SHI-PO",
    "PTO-SCALAR-HL-SHI-PR",
    "PTO-SCALAR-HL-SHI-U",
    "PTO-SCALAR-HL-SHI-UPO",
    "PTO-SCALAR-HL-SHI-UPR",
    "PTO-SCALAR-HL-SHIP",
    "PTO-SCALAR-HL-SHIP-U",
    "PTO-SCALAR-HL-SHP",
    "PTO-SCALAR-HL-SHP-U",
    "PTO-SCALAR-HL-SW-PCR",
    "PTO-SCALAR-HL-SW-PO",
    "PTO-SCALAR-HL-SW-PR",
    "PTO-SCALAR-HL-SW-UPO",
    "PTO-SCALAR-HL-SW-UPR",
    "PTO-SCALAR-HL-SWI",
    "PTO-SCALAR-HL-SWI-PO",
    "PTO-SCALAR-HL-SWI-PR",
    "PTO-SCALAR-HL-SWI-U",
    "PTO-SCALAR-HL-SWI-UPO",
    "PTO-SCALAR-HL-SWI-UPR",
    "PTO-SCALAR-HL-SWIP",
    "PTO-SCALAR-HL-SWIP-U",
    "PTO-SCALAR-HL-SWP",
    "PTO-SCALAR-HL-SWP-U",
    "PTO-SCALAR-LB",
    "PTO-SCALAR-LB-PCR",
    "PTO-SCALAR-LBI",
    "PTO-SCALAR-LBU",
    "PTO-SCALAR-LBU-PCR",
    "PTO-SCALAR-LBUI",
    "PTO-SCALAR-LD",
    "PTO-SCALAR-LD-PCR",
    "PTO-SCALAR-LDI",
    "PTO-SCALAR-LDI-U",
    "PTO-SCALAR-LH",
    "PTO-SCALAR-LH-PCR",
    "PTO-SCALAR-LHI",
    "PTO-SCALAR-LHI-U",
    "PTO-SCALAR-LHU",
    "PTO-SCALAR-LHU-PCR",
    "PTO-SCALAR-LHUI",
    "PTO-SCALAR-LHUI-U",
    "PTO-SCALAR-LW",
    "PTO-SCALAR-LW-PCR",
    "PTO-SCALAR-LWI",
    "PTO-SCALAR-LWI-U",
    "PTO-SCALAR-LWU",
    "PTO-SCALAR-LWU-PCR",
    "PTO-SCALAR-LWUI",
    "PTO-SCALAR-LWUI-U",
    "PTO-SCALAR-PRF",
    "PTO-SCALAR-PRFI-U",
    "PTO-SCALAR-SB",
    "PTO-SCALAR-SB-PCR",
    "PTO-SCALAR-SBI",
    "PTO-SCALAR-SD",
    "PTO-SCALAR-SD-PCR",
    "PTO-SCALAR-SD-U",
    "PTO-SCALAR-SDI",
    "PTO-SCALAR-SDI-U",
    "PTO-SCALAR-SH",
    "PTO-SCALAR-SH-PCR",
    "PTO-SCALAR-SH-U",
    "PTO-SCALAR-SHI",
    "PTO-SCALAR-SHI-U",
    "PTO-SCALAR-SW",
    "PTO-SCALAR-SW-PCR",
    "PTO-SCALAR-SW-U",
    "PTO-SCALAR-SWI",
    "PTO-SCALAR-SWI-U"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0029: Scalar AGU totality, aliases, and restart

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

- Scope: all 183 accepted scalar AGU forms
- Requirement: PTO-REQ-SCALAR-ADDRESS-001, PTO-REQ-SCALAR-OPERAND-001,
  PTO-REQ-MEMORY-001, PTO-REQ-MEMORY-COMPLETION-001,
  PTO-REQ-SCALAR-EXECUTION-001

## Decision

AGU arithmetic is modulo 2^64. Immediate fields are sign extended to XLEN
before their form-defined scale is applied. PC-relative forms use the current
TPC with bits 1:0 cleared and then add a four-byte-scaled displacement.
Register offsets apply `SrcRType` before scaling: `00` preserves the word,
`01` sign extends its low 32 bits, `10` zero extends its low 32 bits, and `11`
negates the full word. A present `shamt` supplies the scale; otherwise the
catalog-derived element scale applies. The `.U`, `.UPR`, and `.UPO` forms are
unscaled. Compressed forms use their encoded base and scaled signed immediate.

No-update and pre-index accesses use `base + offset`. Post-index accesses use
the original base and publish `base + offset` only after the access completes.
A load-with-update writes its normalized loaded value through `RegDst0` and
then writes the updated base through `RegDst1`. A store-with-update snapshots
its data source before memory effects and writes the updated base through
`RegDst` only after a successful store. A fault suppresses every destination
and writeback effect.

Decoded pair forms never write back a base. They preflight the first address
and then the second address before reading or writing either architectural
element. The first failing original address is reported. Successful pairs
commit and emit events in address order. Pair loads write `RegDst0` before
`RegDst1`; pair stores snapshot both data sources before either store. The
direct ASL pair helpers expose only this decoded no-writeback contract; the
former unreachable pre/post-index helper branches are removed and are not ISA
behavior.

Data-access precedence is alignment, translation, then permission and bounded
memory. PTO v0 translation is identity and has no translation-fault outcome.
PTO v0 reports both a translated-address permission failure and a bounded-
memory failure as `Fault_DataPage`; this shared visible cause is deliberate.
Every data fault records the original, untranslated address. Alignment wins
even when the same address would also fail permission or bounds. No failing
access wider than one byte can bypass that precedence; one-byte accesses are
naturally aligned and therefore proceed to translation and permission. No
failing single or pair access emits a memory event, changes memory, changes a
destination, or publishes writeback.

Recovery restarts an AGU instruction by full reissue. The faulting attempt
retains no hidden pair progress, retained address, or pending writeback. After
software resolves the cause and restores the saved TPC, a new execution
recomputes both addresses and performs the complete instruction exactly once.

Scalar prefetch is a portable non-faulting, event-free hint. It forms its
modulo-2^64 address but does not translate, check permissions, access memory,
or alter reservation state. Every encoded `model` value is legal PTO v0 hint
metadata with no architecture-visible effect. An alternate implementation may
use it microarchitecturally, but may not add a portable fault, event, memory, or
state effect without a separately named profile contract. Address-returning
prefetch forms still publish `base + offset` through their decoded Reg5
destination, including a wrapped result.

The retained `RegDst` field on a non-address-returning prefetch encoding is a
non-writing field: every value is legal and has no architectural effect. It
does not create an assembly destination or an implicit queue push.

All Reg5 sources are read from the pre-instruction state. Codes 0 through 23
select absolute GPRs, 24 through 27 select T#1 through T#4, and 28 through 31
select U#1 through U#4. Destination codes 0 and 24 through 29 discard, codes 1
through 23 write GPRs, code 30 pushes U, and code 31 pushes T. When two pair
destinations name the same GPR the second result remains. When they push the
same queue, the second result is newest and the first is next-newest. Base,
offset, and store-data sources remain the snapshotted values even when a
destination writes or pushes to the same location.

## Rationale

AGU is the address and completion foundation for later atomic and tile-memory
closure. A single nominal execution per form did not prove signed immediate
bounds, modifier variants, modulo wrap, fault precedence, pair atomicity,
restart, or the shared Reg5 topology. Making these rules PTO-owned and
executable prevents later instruction groups from relying on unstated memory
behavior.

Keeping prefetch portable and non-observable preserves useful implementation
freedom without confusing a retained hint selector with architectural state.
Removing the non-decoded pair-writeback helper branch likewise keeps support
code from appearing to widen the accepted ISA.

## Verification

`spec/evidence/scalar-agu-totality.json` owns the exact catalog-derived case
inventory. Generated decoded tests cover all 183 form IDs, immediate limits,
all register modifiers, shift limits, all 32 values of every encoded prefetch
`model` field, modulo wrap, alignment and permission
precedence, first- and second-pair faults, full-reissue restart, non-faulting
prefetch, every temporary Reg5 source and special destination class, and ordered pair
aliases. Absolute GPR and R0 source behavior is retained from the closed Stage
1/2 operand evidence; this package crosses every T/U source selector and every
non-ordinary destination selector for every encoded AGU field. Repository
checks derive the expected inventory from the scalar catalog and reject
missing, extra, or reclassified evidence.
