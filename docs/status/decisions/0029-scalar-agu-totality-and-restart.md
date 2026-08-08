# ADR 0029: Scalar AGU totality, aliases, and restart

- Status: accepted
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

An independent executable ISA/model comparison is supporting evidence only.
Shared address arithmetic and access rules are recorded as corroboration;
profile-specific or missing queue, permission, event, and restart behavior is
not imported into PTO.

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
