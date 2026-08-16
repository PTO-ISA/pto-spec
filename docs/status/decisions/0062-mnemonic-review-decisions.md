# PTO mnemonic review decisions

- Status: audit complete and frozen
- Date: 2026-08-11

## Review coverage and implementation closure

The mnemonic audit is complete for all 642 active PTO mnemonics. The 32
occupied extension reservations are also reviewed. A mnemonic covered by an
accepted family decision in this ADR or by an earlier accepted architecture
ADR counts as reviewed; it does not need a duplicate mnemonic-local decision.
The frozen audit coverage therefore remains 642/642 active mnemonics and
32/32 occupied reservations.

Audit coverage is distinct from formal implementation closure. A mnemonic can
be fully reviewed while its mnemonic-local ASL operation, complete metadata,
or independent tests are still being implemented. Per-ASL `PTO-REVIEW`
records and the `manual_semantic_audit.py` compatibility entrypoint measure
that later formal implementation closure; they MUST NOT be reported as a
regression of the frozen audit count.

## Current active and reserved encoding inventory

The PTO ISA 0.58.1 binary projection contains 474 Scalar forms and 74 active
Block forms, for 548 active encoded forms. The separate extension catalog
contains 32 occupied extension-reservation entries. Reserved entries are not
active PTO instructions: PTO decoding and assembly MUST reject them, and future
PTO revisions MUST NOT allocate another instruction in their occupied spaces.

The current inventory supersedes acceptance-time totals recorded in earlier
ADRs. Those older totals remain historical evidence of the transition that was
reviewed at the time; they MUST NOT be used as the active decoder, release, or
coverage count. The generated catalogs, instruction-contract closure, and
release manifest are the machine-checked projections of this decision.

## PRD-001: `B.CATR.DR` selects dimension-reduction mode

`B.CATR.DR` is the dimension-reduction-mode selector. It does not select
dynamic rounding and does not select direct-register addressing.

An encoded `DR=0` selects the default multidimensional mode. An encoded
`DR=1` selects dimension-reduction mode for block operations that define that
mode.

## PRD-002: `B.CATR.trap` requests a post-commit trap

An encoded `trap=1` requests a synchronous post-commit trap. The current
block MUST first commit successfully and atomically. After that commit and
before the selected continuation executes, the processor MUST enter the
architectural trap/context path.

The saved trap context MUST retain the selected continuation, and trap return
MUST resume that continuation. A failed or rejected block commit MUST NOT
generate this post-commit trap.

## PRD-003: `B.CATR.far` selects remote block execution

An encoded `far=0` selects the default behavior: the current block executes on
the initiating core.

An encoded `far=1` marks the current block for remote execution. The remote
destination is selected by the existing routing state; `B.CATR` does not
encode a destination. The block inputs MUST be sent to the selected remote
execution target. After remote execution completes, its results MUST be
returned to the initiating core, and the block MUST commit on that initiating
core.

## PRD-004: `B.CATR.atomic` makes the block one transaction

An encoded `atomic=0` selects normal block execution. An encoded `atomic=1`
makes the entire block one non-interleavable, all-or-nothing architectural
transaction.

The block's memory effects and register-output effects MUST become visible
together or MUST all remain ineffective. An interrupt, exception, or other
fault before successful completion MUST NOT expose a partial result.

## PRD-005: `B.CATR` may appear at most once per block

A block MAY omit `B.CATR`, in which case every control attribute has its
default zero value. A block MUST NOT contain more than one `B.CATR`.

Encountering a second `B.CATR` in the same block MUST raise Illegal Block
Exception before the second instruction changes architectural or pending block
state. Attribute bits from multiple `B.CATR` instructions MUST NOT be merged,
and a later instruction MUST NOT overwrite an earlier one.

## PRD-006: `B.CATR.DR` is limited to group-executed tile engines

An encoded `DR=1` is legal only for a block whose selected execution engine is
`VEC`, `SFU`, or `TLSU`.

An encoded `DR=1` in a `CUBE` block or a non-tile block MUST raise Illegal
Block Exception before architectural or pending block effects. An encoded
`DR=0` selects the default multidimensional mode and introduces no additional
engine restriction.

## PRD-007: omitted and encoded `B.DATR.PadValueOrByteId` are distinct

When an operation consumes `PadValueOrByteId` as a padding-value selector, an
omitted `B.DATR` contribution selects `Null`. Omission MUST NOT be represented
by clearing the encoded field.

An explicitly encoded field has the following complete mapping:

| Code | Padding value |
| ---: | --- |
| `00` | `Zero` |
| `01` | `Max` |
| `10` | `Min` |
| `11` | `Null` |

Operation-specific schemas MAY consume the same two encoded bits for another
defined role, such as a byte selector. An operation that consumes neither role
MUST require the field to be zero.

## PRD-008: `B.DATR.CMode` defines six comparison predicates

`B.DATR.CMode` is a comparison-mode selector. It is not a conversion-mode
selector. Its three-bit allocation is:

| Code | Predicate |
| ---: | --- |
| `000` | `EQ` |
| `001` | `NE` |
| `010` | `LT` |
| `011` | `GT` |
| `100` | `LE` |
| `101` | `GE` |
| `110` | reserved for future extension |
| `111` | reserved for future extension |

Reserved values MUST raise an illegal-instruction fault before effects.

## PRD-009: `B.DATR.Layout` has thirteen assigned transformations

The five-bit `Layout` field has exactly the following assigned values:

| Code | Layout |
| ---: | --- |
| `0` | `NORM` |
| `1` | `ND2DN` |
| `3` | `ND2ZN` |
| `4` | `ND2NZ` |
| `6` | `DN2ND` |
| `8` | `DN2ZN` |
| `9` | `DN2NZ` |
| `17` | `ZN2ND` |
| `18` | `ZN2DN` |
| `20` | `ZN2NZ` |
| `27` | `NZ2ND` |
| `28` | `NZ2DN` |
| `30` | `NZ2ZN` |

Every other five-bit value is reserved for future extension and MUST reject
before effects. Each assigned transformation requires an executable layout
mapping; an implementation-defined placeholder is not sufficient.

## PRD-010: omitted `B.DATR.DataType` inherits the block input type

When an operation-specific schema permits the `B.DATR.DataType` contribution
to be omitted, it inherits the data type selected by the block start. Omission
MUST be tracked independently from the encoded value.

An explicitly encoded zero selects `FP64`; it does not mean inherit. Other
assigned codes select their architecture data types. Reserved codes MUST
reject before effects. Every Tile mnemonic MUST explicitly define the defaults
and supported type subset for each optional field it consumes.

## PRD-011: `Canonicalize` converts CUBE-private output through `TCVT`

`B.DATR.Canonicalize` is an assigned field. `Canonicalize=1` is consumed only
by `TCVT` when converting a CUBE-private output representation into the
standard left-matrix Tile representation, including any data-type-dependent
fractal merge or split required by that conversion.

`Canonicalize=0` disables that conversion. Any other operation carrying a
nonzero `Canonicalize` field MUST reject before effects.

## PRD-012: `B.DATR` may appear at most once per block

A block MAY omit `B.DATR` and use the operation-specific defaults defined for
every data attribute. A block MUST NOT contain more than one `B.DATR`.

Encountering a second `B.DATR` in the same block MUST raise Illegal Block
Exception before the second instruction changes architectural or pending block
state. Multiple `B.DATR` instructions MUST NOT be merged, and a later
instruction MUST NOT overwrite an earlier one.

## PRD-013: `B.DIM.RegSrc` names only an absolute GPR

`B.DIM.RegSrc` codes `0..23` name the twenty-four absolute GPRs, including the
architectural zero register at code zero. Codes `24..31` are reserved in
`B.DIM`; they MUST NOT read either temporary queue and MUST reject as an
illegal instruction before effects.

## PRD-014: `B.DIM` writes the low sixteen bits of base plus immediate

`B.DIM` reads the selected absolute GPR, zero-extends the encoded unsigned
seventeen-bit immediate, and performs the addition at `PTO_XLEN` width. It
writes the low sixteen bits of that sum, zero-extended to the LB storage width,
to the LB selected by the instruction form.

Encoded `RegSrc=0` supplies a zero base and encoded `uimm17=0` supplies a zero
immediate. Neither encoded zero denotes omission.

## PRD-015: each LB may be written at most once per block

Within one block, the combined `B.DIM` and compressed dimension-setting forms
MUST write each of `LB0`, `LB1`, and `LB2` at most once.

An attempt to write an LB that has already been written in the current block
MUST raise Illegal Block Exception before changing the LB or any other pending
or architectural block state. A later write MUST NOT overwrite or merge with
the earlier value.

## PRD-016: `B.HINT` may appear at most once per block header

An ordinary block header MAY contain at most one `B.HINT`, regardless of the
encoded hint form. Encountering a second `B.HINT` in the same block header MUST
raise Illegal Block Exception before the second instruction changes pending or
architectural state. Multiple hints MUST NOT be merged, and a later hint MUST
NOT overwrite an earlier hint.

## PRD-017: `B.HINT.TRACE` opens an empty block without auto-termination

The TRACE form is a special block-start operation. Its `B/E` field selects the
trace boundary: zero begins a traced region and one ends it. Executing the form
opens an empty block and records the selected boundary.

The TRACE form MUST NOT complete or commit the empty block by itself. The block
MUST subsequently be terminated by `BSTOP` or by the next `BSTART`, following
the normal block lifecycle and commit rules.

## PRD-018: `B.IOR` fields name absolute GPRs and encoded zero is `zero`

Each `B.IOR` source and destination field accepts exactly the twenty-four
absolute GPR selectors `0..23`. Selectors `24..31` are reserved in `B.IOR` and
MUST reject before effects; relative queue selectors are not legal.

Encoded selector zero names the architectural zero register. Canonical assembly
and disassembly use `zero`, `sp`, `a0..a7`, `ra`, `s0..s8`, and `x0..x3` for
selectors `0..23` respectively. Numeric register names MAY be accepted as input
aliases, but canonical output MUST use those ABI names.

## PRD-019: the complete block schema determines `B.IOR` presence and arity

The effective operation schema is selected after the complete block header has
been assembled. That schema determines which of `RegSrc0..RegSrc2` and
`RegDst` are consumed. An omitted `B.IOR` supplies the operation-defined
defaults for every consumed field. An explicitly encoded zero in a consumed
field supplies the zero register and is not omission.

Fields not consumed by the selected schema MUST be encoded as zero. A nonzero
unused field MUST reject before block effects. Disassembly MUST preserve the
distinction between an omitted instruction and an explicitly encoded all-zero
`B.IOR` so that reassembly preserves the exact instruction stream.

## PRD-020: PTO blocks admit at most one `B.IOR` and permit register aliasing

A PTO block MAY contain at most one `B.IOR`. Encountering a second `B.IOR` in
the same block MUST raise Illegal Block Exception before changing pending or
architectural state, and MUST preserve the first binding.

Source selectors MAY repeat. A source and destination MAY name the same GPR.
Such aliasing does not itself make the block illegal; the selected operation
defines when inputs are read and when an output becomes visible.

## PRD-021: `B.IOR` is available to every schema that declares GPR operands

`B.IOR` is not restricted to a separated block. It MAY appear in any active
`BSTART` block whose effective operation schema declares GPR input or output
fields. If the selected schema consumes no GPR field, an omitted or explicitly
all-zero `B.IOR` supplies the default state, while any nonzero binding MUST
reject before commit.

## PRD-022: TLOAD and TSTORE assign the first two `B.IOR` sources

For `TLOAD` and `TSTORE`, `RegSrc0` supplies the per-PE global-memory base
address and `RegSrc1` supplies the logical row stride in elements. Each
participating PE reads the selected selectors from its own GPR file.

When `B.IOR` is omitted, the base defaults to zero and the row stride defaults
to the operation's resolved column count, producing dense rows. An explicitly
encoded zero selector supplies a zero base or zero stride and MUST NOT select
the omission default.

## PRD-023: `B.IOT` has exactly five Local-Tile forms

`B.IOT` has exactly the five accepted forms that bind zero, one, or two ordered
Local Tile sources and zero or one Local Tile destination. It has no Shared
destination form, no reuse field, and no legacy four-bit size field.

Each six-bit source selector names a relative Local Tile queue entry:
`0..15` select `T#1..T#16`, `16..31` select `U#1..U#16`, `32..47` select
`M#1..M#16`, and `48..63` select `N#1..N#16`. Source operands are consumed in
the encoded program order.

On a destination form, `DstTile=0..3` selects the `T`, `U`, `M`, or `N`
destination hand respectively. It does not expose a physical Tile register.
`TSize=1..7` declares 128 B through 8 KiB of capacity per participating PE;
encoded `TSize=0` is reserved on every destination form.

## PRD-024: `B.IOT.PE_MASK` is a four-PE predicate

Every four-bit `PE_MASK` value is assigned and multiple set bits are legal.
All effective Local Tile bindings in one block MUST use the same nonzero mask,
and any Local/Shared operands composed by that block MUST use the same mask.
An operation MAY impose a stricter mask requirement as part of its own schema.

`PE_MASK=0000` is a strict no-op. It MUST NOT add a binding, read a source,
allocate or rename a destination, update a descriptor, produce a fault, or
change the `B.IOT` sequence-termination state.

## PRD-025: `B.IOT.L` terminates only the binding sequence

The encoded `L` bit is the `last` marker for the current block's effective
`B.IOT` sequence. It is not a source-lifetime or source-release control.

Every block that requires an effective `B.IOT` sequence MUST contain exactly
one nonzero-mask binding with `last=1`, and that binding MUST be the final
effective `B.IOT` in the block. Ending the block without that marker, placing
another effective `B.IOT` after it, or placing more than one effective marker
MUST raise Illegal Block Exception before the offending instruction or commit
changes architectural or pending block state.

## PRD-026: `B.IOT` sources persist and destinations are renamed

Reading a Local Tile source through `B.IOT` MUST NOT modify, release, or
invalidate its payload or descriptor. Successful block completion therefore
does not imply source lifetime termination, regardless of the `last` bit.

A destination form selects a destination hand and requests a new allocation.
Hardware MUST rename that request to a Local Tile register in the selected
hand, then atomically publish the new payload and descriptor at successful
block commit. Consumers refer to the renamed result through the architectural
Local Tile queue model; they do not identify the physical allocation by
reusing the producer's `PE_MASK`.

## PRD-027: `B.IOS` binds absolute Core-private Shared registers

Each core contains one architectural bank of 256 persistent Shared Tile
registers, named `S0..S255`. All four PEs in that core observe the same bank;
another core observes a different bank. `SharedTID=0..255` is an absolute
index, so encoded zero names `S0` and does not mean omission.

`B.IOS Sx, mask=PE_MASK` is the source form and encodes `TSize=0`.
`B.IOS mask=PE_MASK, ->Sx<TSize>` is the destination form and requires
`TSize=1..7`, encoding 128 B through 8 KiB per participating PE. The role
encoded by `TSize` MUST agree with the selected operation schema.

## PRD-028: `B.IOS` uses an ordered four-entry binding stream

One effective `B.IOS` adds one ordered Shared operand binding. A block MAY
contain at most four effective Shared bindings. Two unconsumed bindings in the
same block MUST NOT name the same `Sx`; a duplicate or fifth effective binding
MUST raise Illegal Block Exception before changing the binding stream or other
pending state.

`PE_MASK` is a four-PE predicate and multiple bits are legal. Every effective
Shared binding and every composed Local binding in one block MUST use the same
nonzero mask unless the selected operation defines a stricter rule.
`PE_MASK=0000` is a strict no-op: it adds no binding, performs no schema or
duplicate check, reads no source, allocates nothing, updates no descriptor,
accesses no memory, and produces no fault.

## PRD-029: Shared destinations atomically update persistent state

Each allocated `Sx` retains one per-PE Tile descriptor, a fixed allocation
mask, an initialized-quarter mask, and persistent payload. The first nonzero
destination write establishes its descriptor and allocation mask. A later
destination write MAY update any subset of that allocation mask only when the
descriptor is compatible; it MUST NOT expand the mask or silently replace an
incompatible descriptor. Software MUST allocate another `Sx` for a different
mask or descriptor.

A successful Shared destination operation atomically publishes the compatible
descriptor update and every selected fixed-offset payload quarter. An observer
MUST see either the old complete state or the new complete state, never a torn
descriptor/payload update. A Shared source read does not modify the descriptor,
payload, allocation mask, or initialized mask.

The architecture imposes no ordering between conflicting accesses from
different PEs. Programs MUST avoid conflicting offsets or establish ordering
with separate synchronization mechanisms.

## PRD-030: an uninitialized Shared source reads as undefined state

Reading an `Sx` with no allocated descriptor is legal. The consumer operation
MUST derive a read-only temporary descriptor from its own completed schema,
including its data attributes, dimensions, and any Local counterpart required
by that operation. Every selected payload element is an undefined-register
value.

This read MUST NOT allocate or initialize the Shared register, write back the
temporary descriptor, update any Shared state, or raise an exception solely
because the descriptor or selected quarter was uninitialized. Reading an
allocated but uninitialized quarter follows the same undefined-register rule
for that quarter.

## PRD-031: `B.TEXT` is extension-reserved and is not a PTO instruction

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

## PRD-032: the long-displacement `BSTART` mnemonic has two forms

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

## PRD-033: `BSTART` initializes BARG and commit selects the continuation

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

## PRD-034: `BSTART.CALL` is one atomic fused call

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

## PRD-035: `BSTART.ICALL` is one atomic fused indirect call

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

## PRD-036: `BSTART.FP` keeps five public forms and reserves Fixup payloads

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
`BSTART.FP ICALL` are deleted; calls use PRD-034 and PRD-035 respectively,
and deleted raw forms are not reservations unless covered by another explicit
extension reservation.

## PRD-037: `BSTART.STD` keeps five public forms and reserves Fixup payloads

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
deleted; PRD-034 and PRD-035 are the only call forms.

## PRD-038: `BSTART.SYS` is a zero-displacement fallthrough form

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

## PRD-039: machine-parallel and machine-sequential block starts are extension-reserved

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

## PRD-040: Shared `TMOV` has four distinct movement and publication modes

Shared `TMOV` is distinct from `GMOV`. `GMOV` directly copies a resolved peer
PE Local fragment to a Local destination and does not access an S register.
Shared `TMOV` instead moves data between PE-local Tile state and one persistent,
core-private Shared register selected by `B.IOS`.

`TMOV.L2S.INSERT` uses a Local source bound by `B.IOT` and a Shared destination
bound by `B.IOS`. For each PE selected by `PE_MASK`, it atomically writes the
corresponding Local quarter into the same-index Shared quarter and updates that
quarter's initialized state. It MAY construct or update a partial Shared value;
it does not by itself assert completion of the full Shared publication.

`TMOV.L2S.PUBLISH` uses the same Local-to-Shared direction and first forms the
prospective Shared value by applying the selected-quarter writes. It is legal
only if every quarter in the destination's allocated mask is initialized in
that prospective value. The payload, initialization state, and full-publication
readiness then become visible atomically. If the prospective value is not
complete, the block MUST raise Illegal Block Exception before changing the
Shared destination.

`TMOV.S2L.BROADCAST` reads a fully published Shared value and writes all four PE
Local destinations. PE p receives Shared quarter p; this is a full Core4
distribution, not replication of one quarter. Except for the architectural
`PE_MASK=0000` strict no-op, an executing BROADCAST requires `PE_MASK=1111`, a
fully allocated four-quarter Shared value, and all four quarters ready. A
failure MUST occur before allocating or changing any Local destination.

`TMOV.S2L.EXTRACT` copies only the Shared quarters selected by `PE_MASK` to the
same-index PE Local destination regions. Unselected destination regions remain
unchanged. It MAY read a partial Shared value; reading a selected uninitialized
quarter produces the ordinary undefined-register value for that quarter rather
than a distinct exception. It never modifies the Shared descriptor, payload,
initialization state, or publication state.

For every Shared TMOV mode, `PE_MASK=0000` is a strict no-op before payload
access, allocation, lifetime consumption, readiness checks, or faults. Multiple
set bits are legal wherever the mode does not require the full `1111` mask.
All descriptor, datatype, layout, capacity, mask, allocation, and readiness
checks MUST complete before effects.

## PRD-041: destination-free `TPREFETCH` implicitly selects all four PEs

`TPREFETCH` has no Local or Shared Tile binding and therefore carries no
encoded `PE_MASK`. Its architectural participation mask is implicitly `1111`.
All four PEs issue the operation, and each PE reads the base and row-stride
selectors from its own private GPR file.

The four resulting memory footprints form one block attempt. The complete
combined footprint MUST pass address generation, translation, permission, and
access preflight before any request or memory event becomes effective. A fault
in any participating PE produces one precise fault for the block, exposes no
partial request or event set, and recovery reissues the complete block.

The architecture does not specify which cache level receives prefetched data,
whether a cache line remains resident, or any other cache-placement or
retention policy. Those choices are microarchitectural and MUST NOT create an
additional architectural result beyond the defined footprint, fault,
restart, and memory-ordering behavior.

## PRD-042: `GMOV` permits partial destination participation within a full Core4 collective

`GMOV` is a Core4 collective Local-to-Local fragment transfer. All four PEs
MUST reach the operation in the same dynamic order, and the descriptors and
source readiness of all four PE fragments MUST pass one combined preflight
before any request, destination allocation, destination write, completion
event, or other architectural effect.

`PE_MASK` does not shrink the collective participant or source-readiness set.
A nonzero partial mask is legal: only the selected PEs issue their transfer
request and write their Local destination fragment. Unselected PEs still
participate in rendezvous and readiness preflight but do not issue a request,
allocate a destination, write Tile state, or produce a completion event.

`PE_MASK=0000` is a strict no-op before source access, readiness checks,
destination allocation, lifetime consumption, faults, requests, or events.
For every nonzero mask, failure of convergence, participant agreement,
descriptor compatibility, peer selection, or any source-readiness check MUST
raise Illegal Block Exception before effects in any PE.

## PRD-043: `MGATHER` indexes are signed or unsigned byte displacements

`MGATHER` consumes one scalar base pointer and one Local IndexTile. Each
IndexTile element is a byte displacement that software has already calculated;
it is not a logical element index and is not scaled by the gathered data type.

An IndexTile MAY use a signed `SINT` integer data type or an unsigned integer
data type. A signed displacement is sign-extended from the IndexTile element
width. An unsigned displacement is zero-extended from that width. For every
valid destination element, the effective byte address is the scalar base
pointer plus the extended displacement. Address validity, translation,
permission, alignment, and access-size checks MUST complete according to the
ordinary precise TLSU memory contract before destination or memory-event
effects.

Non-integer IndexTile data types MUST raise Illegal Block Exception before
architectural or pending block effects.

## PRD-044: `MGATHER` pads the physical destination outside its valid rectangle

For `MGATHER`, `ValidRow` MUST NOT exceed `Row`, and `ValidCol` MUST NOT exceed
`Col`. The destination's physical region is `Row x Col`; its gathered valid
rectangle is `ValidRow x ValidCol`.

Every physical destination element outside the valid rectangle MUST be written
with the padding value selected by `B.DATR.PadValueOrByteId`. An omitted
`B.DATR` selects `Null` as defined by the architectural padding-default rule.
The complete valid payload and padded physical remainder become visible as one
destination result; a fault or legality failure MUST expose neither a partial
gathered rectangle nor a partial padding update.

## PRD-045: `MGATHER` requires an explicit scalar base binding

`MGATHER` consumes `RegSrc0` as its scalar base pointer. Its complete block
MUST contain a `B.IOR` binding for `RegSrc0`; omission is illegal and does not
supply an implicit address-zero default.

Software MAY explicitly bind the architectural `zero` register when address
zero is intended. An explicitly encoded `zero` selector therefore supplies a
base pointer value of zero, while omission remains a distinct illegal schema.
Unused `B.IOR` fields MUST remain zero according to the complete block schema.

## PRD-046: indexed TLSU operations use explicit bases and byte displacements

Every indexed TLSU operation consumes an explicit `B.IOR.RegSrc0` scalar base
binding and one Local IndexTile. This rule applies to `MGATHER`,
`MGATHER.MASK`, `MGATHER.CAS`, `MSCATTER`, and `MSCATTER.MASK`.

Each IndexTile element is a byte displacement that software has already
calculated. A signed integer IndexTile element is sign-extended from its
encoded element width; an unsigned integer element is zero-extended. The
effective address is the selected PE's private-GPR base plus that extended
byte displacement. The displacement is not scaled by the transferred data
type. Non-integer IndexTile data types MUST raise Illegal Block Exception
before effects.

Omitting `B.IOR.RegSrc0` is illegal and does not select address zero. Software
MAY explicitly bind the architectural `zero` register to request a zero base.
Unused `B.IOR` fields MUST remain zero according to the complete block schema.

## PRD-047: `MSCATTER` source typing, effects, and duplicate addresses

`MSCATTER` consumes one Local data source Tile and one Local IndexTile with the
same logical shape. The data source Tile MUST use the `BSTART.MSCATTER`
DataType. The IndexTile uses the independent signed-or-unsigned integer byte
displacement rule from PRD-046 and is not required to share the data source
type.

Only elements inside the source Tile's valid rectangle produce memory writes.
The physical source region outside that rectangle produces no access, event,
padding, or other effect. Every participating access MUST pass complete
address generation, translation, permission, alignment, and access-size
preflight before the first write or memory event becomes effective.

If two enabled lanes select overlapping byte addresses, the architecture does
not define which lane's value is the final value at the overlap. Software that
requires a deterministic result MUST avoid such conflicts. Setting
`B.CATR.atomic=1` makes the complete block one non-interleavable,
all-or-nothing transaction as specified by PRD-004, but it does not define an
internal lane order or a duplicate-address winner.

## PRD-048: masked indexed TLSU operations use exact per-element predicates

`MGATHER.MASK` and `MSCATTER.MASK` consume one Local MaskTile whose logical
shape and layout match the corresponding data and Index Tiles. Each MaskTile
element is one architectural predicate represented by the exact value zero or
one. Zero disables the corresponding lane; one enables it. Any other encoded
element value MUST raise Illegal Block Exception before memory, destination,
lifetime, or event effects.

An inactive lane performs no address generation, translation, permission
check, memory access, or memory event. For `MGATHER.MASK`, an inactive lane in
the valid rectangle writes the selected padding value to the corresponding
destination element. For `MSCATTER.MASK`, an inactive lane produces no write.
The complete set of enabled accesses MUST pass preflight before the first
enabled effect becomes visible.

## PRD-049: `TMATMUL` dimensions are `M`, `N`, and `K` in LB order

`BSTART.TMATMUL` uses `LB0=M`, `LB1=N`, and `LB2=K`. Omission of any one of
these fields supplies the value one for that field. An explicitly encoded or
otherwise resolved value of zero is illegal. Each of `M`, `N`, and `K` MUST
be a nonzero power of two.

The left source has valid shape `M x K`, the right source has valid shape
`K x N`, and the destination has valid shape `M x N`. Each physical Tile row
and column extent MUST be a power of two, and the physical extent MUST contain
the complete valid rectangle. Shape, capacity, and compatibility checks MUST
complete before destination allocation or any other effect.

## PRD-050: `TMATMUL` supports mixed same-class input types and fixed accumulator classes

The `BSTART.TMATMUL` DataType selects the left source type. An optional
`B.DATR.DataType` selects the right source type; if that field is absent, the
right source type defaults to the left source type. Absence is distinct from
an explicitly encoded zero, because encoded DataType zero denotes `FP64`,
which is not supported by `TMATMUL`. The block schema MUST therefore preserve
field presence when applying this default.

The supported floating input set is `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`HiF8`, `E4M3`, `E5M2`, `E3M2`, `E2M3`, `E2M1X2`, and `E1M2X2`. The supported
signed input set is `S16`, `S8`, and `S4X2`. The supported unsigned input set
is `U16`, `U8`, and `U4X2`. The two inputs MAY use different types within the
same floating, signed, or unsigned class. A cross-class pair is illegal.

`FP64`, `E8M0`, `HiF4X2`, `S64`, `S32`, `U64`, `U32`, every globally reserved
DataType encoding, and every other type not listed above are reserved or
unsupported for ordinary `TMATMUL` and MUST be rejected before effects.

A floating pair produces an `FP32` accumulator result, a signed pair produces
an `S32` accumulator result, and an unsigned pair produces a `U32` accumulator
result. This result uses the private CUBE output representation. `TCVT`, not
`TMATMUL`, performs conversion to a canonical public representation. A numeric
profile MAY define format-specific arithmetic details, but it MUST preserve
these operand classes, accumulator classes, and encoded numeric controls.

## PRD-051: `TMATMUL` binding, participation, and supplementary fields are closed

The Local form binds a left Local source, a right Local source, and an explicit
new Local destination. The Shared forms bind either a Local left source plus a
Shared right source, or a Shared left source plus a Shared right source; the
destination remains an explicit new Local allocation. `B.IOS` is source-only
for `TMATMUL` and reads only fully published Shared values.

`PE_MASK=0000` is a strict no-op before descriptor access, readiness checks,
allocation, lifetime consumption, faults, or effects. Every executing Local or
Shared binding MUST use `PE_MASK=1111`; a nonzero partial mask is illegal before
effects. All source payloads are snapshotted after complete preflight and before
destination allocation or commit, so source-destination aliasing observes the
old source values and the destination becomes visible only as one complete
result.

`TMATMUL` does not consume mathematical `B.IOR` operands. Its `B.DATR` fields
are closed to `DataType`, `RMode`, and `Sat`. An omitted `DataType` applies the
right-type default in PRD-050, omitted `RMode` selects `RNE`, and omitted `Sat`
selects disabled saturation. `Layout`, `CMode`, `PadValueOrByteId`, and
`Canonicalize` MUST be zero. The private CUBE result remains noncanonical until
an explicit `TCVT` operation.

The earlier statement that `TMATMUL` did not consume `B.FPATR` is superseded
by ADR 0064. Every Matrix CUBE bundle contains exactly one `B.FPATR`; its
all-zero form selects no post-processing, and nonzero modes determine the
additional scalar, Local source, and Local destination schema.

## PRD-052: `TMATMUL.BIAS` adds one `1 x N` right-side broadcast source

`BSTART.TMATMUL.BIAS` inherits the complete dimension, input-type, accumulator,
binding, participation, supplementary-field, preflight, and commit contract of
`BSTART.TMATMUL`. It adds one Bias source after the left and right matrix
sources.

The Bias source valid shape MUST be exactly `1 x N`, its layout MUST be
row-major, and its DataType MUST equal the result accumulator class selected by
PRD-050: `FP32`, `S32`, or `U32`. Its payload uses the same private CUBE result
representation as that accumulator class. For every output row `i` and column
`j`, `Bias[0,j]` is added once to the complete dot product for output `D[i,j]`.
No row broadcast, scalar broadcast, full-matrix Bias, or Bias addition inside
the K reduction is defined.

Bias remains a Local source in both the all-Local and Shared-matrix forms.
Shared bindings MAY supply the right matrix or both matrix operands exactly as
defined for `TMATMUL`; they do not bind the Bias or destination. The complete
matrix and Bias sources are snapshotted after preflight, and the explicit new
Local destination becomes visible only as one complete result.

## PRD-053: `TMATMUL.ACC` uses explicit Local accumulator input and destination

`BSTART.TMATMUL.ACC` inherits the complete dimension, matrix input-type,
accumulator-class, binding, participation, supplementary-field, preflight, and
commit contract of `BSTART.TMATMUL`. It adds one explicit Local accumulator
source `C` before the left and right matrix sources and writes one explicit new
Local destination `D`.

`C` MUST have valid shape `M x N`, the same row-major layout and physical
capacity as `D`, and the same private CUBE accumulator representation and
DataType as the result: `FP32`, `S32`, or `U32`. The result is
`D = C + A x B`, with the encoded `RMode` and `Sat` controls applied according
to the selected numeric profile. There is no implicit ACC operand or implicit
destination.

The operation snapshots `C`, `A`, and `B` after complete preflight and before
writing `D`. `C` and `D` MAY resolve to the same Local Tile; this case has
read-old/write-new behavior and becomes visible only as one complete result.
In Shared-matrix forms, Shared bindings MAY supply the right matrix or both
matrix operands, but `C` and `D` remain explicit Local bindings.

## PRD-054: `TMATMULMX` scales each matrix side independently

`BSTART.TMATMULMX` inherits `TMATMUL` dimension ordering, matrix and destination
shapes, explicit Local destination, Core4 participation, private `FP32` result,
numeric controls, preflight, snapshot, and atomic commit rules. Its matrix
inputs are floating only. Each side independently uses one of `FP16`, `BF16`,
`E4M3`, `E5M2`, `E2M1X2`, or `E1M2X2`; the two sides MAY use different listed
types. Every other type, including `HiF4X2`, is unsupported or reserved for
this opcode and MUST reject before effects.

An `FP16` or `BF16` side is not microscaled and MUST omit its scale source. An
`E4M3`, `E5M2`, `E2M1X2`, or `E1M2X2` side is microscaled and MUST provide one
`E8M0` scale source. Providing a scale for an unscaled side or omitting a scale
for a scaled side is illegal. Consequently the canonical source sequence is
left matrix, optional left scale, right matrix, optional right scale, followed
by the explicit new Local destination; matrix DataTypes determine the sequence
unambiguously.

For a scaled left matrix, the scale valid shape is
`M x ceil(K / 32)`. For a scaled right matrix, it is
`ceil(K / 32) x N`. Scale Tiles use row-major layout, their physical row and
column extents are powers of two containing the complete valid shape, and each
E8M0 element applies to the corresponding group of at most 32 K-dimension
matrix elements. An unscaled side behaves as if every scale factor were the
multiplicative identity; no implicit or materialized scale Tile exists.

Shared bindings remain source-only. They MAY supply the right matrix and its
required scale, or both matrices and whichever scales their DataTypes require.
An omitted scale has no Shared binding slot. The destination is always a new
Local `FP32` private CUBE result, and `TCVT` remains the canonical conversion
boundary.

## PRD-055: `TGEMV` is the Local-only `TMATMUL` specialization with `M=1`

`BSTART.TGEMV` is exactly the ordinary `TMATMUL` contract specialized to
`M=1`. `LB0` is therefore fixed to one; canonical assembly omits it, while an
explicit `LB0` is legal only when it resolves to one. `LB1=N` and `LB2=K`,
with the ordinary omission default one and nonzero power-of-two requirement.

The left source is a row vector with valid shape `1 x K`, the right source is
a matrix with valid shape `K x N`, and the explicit new Local destination has
valid shape `1 x N`. The vector and destination use row-major layout; the
right source follows the ordinary matrix layout and physical-capacity rules.
DataType selection, mixed same-class operands, `FP32`/`S32`/`U32` private
result classes, `B.DATR` controls and defaults, full Core4 participation,
preflight, snapshots, and commit are otherwise unchanged from `TMATMUL`.

`TGEMV` is Local-only. `B.IOS` is illegal and no Shared operand form is
defined. `PE_MASK=0000` is the strict no-op; every executing Local binding uses
`1111`. The canonical binding sequence is the `1 x K` vector, the `K x N`
matrix, and the explicit new `1 x N` Local destination.

## PRD-056: `TADD` applies `PadValue` outside the valid destination rectangle

`TADD` accepts the `B.DATR.PadValueOrByteId` field in its `PadValue`
interpretation. Within `ValidRow x ValidCol`, the destination element is the
profile-defined sum of the corresponding left and right source elements. The
two sources and destination MUST have matching physical rows, physical
columns, valid rows, valid columns, row-major layout, and DataType.

After the valid-rectangle additions are computed, every physical destination
element outside `ValidRow x ValidCol` is handled by the resolved `PadValue`.
`Zero`, `Max`, and `Min` define those elements using the selected DataType's
corresponding value. `Null` leaves those elements undefined. Omission resolves
to `Null`. An explicitly present code `00` selects `Zero`, so omission and
encoded zero remain architecturally distinct.

All source elements required by the valid rectangle MUST be defined before any
destination effect. Both source payloads are snapshotted after complete
preflight, so either source MAY alias the destination with read-old/write-new
behavior. The destination update, including padding definedness, becomes
visible as one complete commit.

## PRD-057: `TADD` has a closed Local VEC block schema

`TADD` is the VEC elementwise addition operation selected by TEPL carrier
`Mode=0, Function=0`. It reads two Local source Tiles in left-to-right binding
order and writes one explicit new Local destination. `B.IOS` and `B.IOR` are
illegal for this operation. All participating `B.IOT` bindings MUST carry the
same `PE_MASK`; each selected PE executes independently, while
`PE_MASK=0000` is a strict no-op before source reads, destination allocation,
or faults.

`LB0` specifies `ValidCol` and MUST resolve to a nonzero 16-bit value. `LB1`
specifies `ValidRow`; omission defaults it to one. `LB2` specifies physical
`Col`; omission defaults it to `ValidCol`. The resolved physical row count is
derived from destination capacity, `Col`, and DataType. `ValidRow` MUST NOT
exceed physical rows and `ValidCol` MUST NOT exceed `Col`. Both sources and
the destination MUST have matching physical rows, physical columns, valid
rows, valid columns, row-major layout, and DataType.

The TADD DataType set is exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Every other DataType encoding is unsupported by TADD and MUST reject
before effects. The selected numeric profile defines addition, exceptional
values, overflow, and its fixed default rounding behavior for each supported
type. TADD does not consume `CMode`, `Sat`, `Canonicalize`, secondary
`DataType`, `RMode`, or `Layout`; any explicit nondefault value in those fields
is illegal.

`PadValueOrByteId` is the only applicable `B.DATR` field and follows PRD-056.
The valid source rectangles MUST be defined before any effect. Descriptor,
schema, mask, field, dimension, allocation, and source-definedness checks all
complete before source snapshots or destination publication.

## PRD-058: `TSUB` is ordered Local VEC subtraction with the binary Tile schema

`TSUB` is selected by TEPL carrier `Mode=0, Function=1`. It reads an ordered
left Local source and right Local source, and writes one explicit new Local
destination. Within `ValidRow x ValidCol`, each destination element is the
selected numeric profile's `left - right` result. Operand order MUST NOT be
commuted. The numeric profile defines floating exceptional values, integer
overflow and underflow, and the fixed default rounding behavior for each
supported DataType.

The block schema, dimensions, allocation, Local-only restriction, equal
`PE_MASK` rule, zero-mask strict no-op, source persistence, destination rename,
preflight, snapshot, and atomic publication rules are the same as the closed
binary VEC schema defined for `TADD`: `LB0` is required nonzero `ValidCol`,
omitted `LB1` gives `ValidRow=1`, omitted `LB2` gives `Col=ValidCol`, and
physical rows are derived from capacity, `Col`, and DataType. Both sources and
the destination MUST match in physical and valid shape, row-major layout, and
DataType. All source elements required by the valid rectangle MUST be defined.

The TSUB DataType set is exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Every other DataType encoding is unsupported by TSUB and MUST reject
before effects. `PadValueOrByteId` is the only applicable `B.DATR` field:
omission selects `Null`, explicit `00` selects `Zero`, `01` selects `Max`, `10`
selects `Min`, and `11` selects `Null`. The selected padding rule applies to
every physical destination element outside the valid rectangle. `CMode`,
`Sat`, `Canonicalize`, secondary `DataType`, `RMode`, and `Layout` are not
consumed, and explicit nondefault values are illegal.

Both source payloads are snapshotted after complete preflight. Either source
MAY alias the destination with read-old/write-new behavior, and both sources
MAY name the same Tile. The complete valid result plus padding definedness is
published as one destination commit; any rejection leaves all descriptors,
payloads, and allocation state unchanged.

## PRD-059: `TMUL` is Local VEC elementwise multiplication

`TMUL` is selected by TEPL carrier `Mode=0, Function=2`. It reads two Local
source Tiles and writes one explicit new Local destination. Within
`ValidRow x ValidCol`, each destination element is the selected numeric
profile's product of the corresponding source elements. The profile defines
floating exceptional values, integer overflow, and its fixed default rounding
behavior.

TMUL uses the same closed Local binary VEC block schema, dimension defaults,
descriptor matching, allocation, mask, source persistence, rename, preflight,
snapshot, and atomic publication rules as TADD. `LB0` is required nonzero
`ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows are derived from capacity, `Col`, and
DataType. Both sources and destination MUST match in physical and valid shape,
row-major layout, and DataType, and every source element used by the valid
rectangle MUST be defined.

The TMUL DataType set is exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Other DataType encodings are unsupported by TMUL and reject before
effects. `PadValueOrByteId` is the only applicable `B.DATR` field and applies
to every physical destination element outside the valid rectangle: omission
selects `Null`, explicit `00` selects `Zero`, `01` selects `Max`, `10` selects
`Min`, and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`,
`Canonicalize`, secondary `DataType`, `RMode`, or `Layout` is illegal.

Both source payloads are snapshotted after complete preflight. Either source
MAY alias the destination with read-old/write-new behavior, and both sources
MAY name the same Tile. `PE_MASK=0000` is a strict no-op before reads,
allocation, or faults. An executing block publishes the complete valid result
and padding definedness as one destination commit; rejection has no
architectural effect.

## PRD-060: `TDIV` is SFU elementwise division with type-specific zero handling

`TDIV` retains the unchanged TEPL carrier `Mode=0, Function=3`, but its
semantic engine is `SFU` because division requires complex execution hardware.
Canonical block assembly uses `BSTART.SFU TDIV, DataType`; the raw encoding is
unchanged and `BSTART.TEPL` remains only the carrier-compatible spelling.

TDIV reads an ordered Local numerator Tile and denominator Tile and writes one
explicit new Local destination. Within `ValidRow x ValidCol`, each destination
element is the selected numeric profile's quotient `numerator / denominator`.
Signed integer DataTypes use signed division, unsigned integer DataTypes use
unsigned division, and floating DataTypes use their floating division profile.
Integer division by zero in any element of the valid denominator rectangle
causes Illegal Block Exception before source snapshots, allocation publication,
or destination effects. Floating division by positive or negative zero is not
a block-legality failure; its result and numeric status follow the selected
floating profile. Denominator elements outside the valid rectangle are not
read and do not participate in zero checking.

TDIV uses the closed Local binary Tile schema: required nonzero `LB0=ValidCol`,
omitted `LB1` default `ValidRow=1`, omitted `LB2` default `Col=ValidCol`,
capacity-derived physical rows, equal source/destination physical and valid
shape, row-major layout, DataType, equal `PE_MASK`, and zero-mask strict no-op.
Both valid source rectangles MUST be defined before effects. The TDIV DataType
set is exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`,
`S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`; every other type is
unsupported and rejects before effects.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Padding applies only outside the valid destination
rectangle. `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, `RMode`, and
`Layout` are not consumed and explicit nondefault values are illegal; the
numeric profile owns TDIV's fixed rounding and exceptional-value behavior.

All legality and integer zero checks complete before both source payloads are
snapshotted. Either source MAY alias the destination with read-old/write-new
behavior. The valid quotient results and padding definedness publish in one
destination commit; any exception leaves descriptors, payloads, and allocation
state unchanged.

## PRD-061: `TREM` is SFU modulo with a divisor-signed result

`TREM` retains the unchanged TEPL carrier `Mode=0, Function=4`, but its
semantic engine is `SFU`. Canonical block assembly uses
`BSTART.SFU TREM, DataType`; no raw encoding changes.

TREM reads an ordered Local dividend Tile and divisor Tile and writes one
explicit new Local destination. Within `ValidRow x ValidCol`, it computes
modulo rather than a truncation-toward-zero language remainder. For signed
integer DataTypes, `q=floor(dividend/divisor)` and
`result=dividend-q*divisor`, so every nonzero result has the divisor's sign and
its magnitude is smaller than the divisor's magnitude. Unsigned DataTypes use
ordinary unsigned remainder. Floating DataTypes use the selected floating
modulo profile with the same divisor-signed result rule.

An integer zero divisor in any valid element causes Illegal Block Exception
before effects. Floating modulo by positive or negative zero is not a
block-legality rejection; its result and numeric status follow the floating
profile. Elements outside the valid divisor rectangle are not read or checked.
The profile also defines signed overflow boundaries and floating exceptional
values.

TREM uses the same closed Local binary Tile schema and defaults as TDIV:
required nonzero `LB0=ValidCol`, omitted `LB1` gives `ValidRow=1`, omitted
`LB2` gives `Col=ValidCol`, physical rows derive from capacity, and both
sources and destination match in physical shape, valid shape, row-major
layout, and DataType. Both source valid rectangles MUST be defined. The exact
TREM DataType set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`; other types
reject before effects.

`PadValueOrByteId` is the only applicable `B.DATR` field, with omission
`Null`, explicit `00` `Zero`, `01` `Max`, `10` `Min`, and `11` `Null`.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal. Equal masks, zero-mask no-op, source
persistence, destination rename, complete preflight, source snapshots,
read-old/write-new aliasing, padding definedness, atomic commit, and rollback
follow the binary Tile contract.

## PRD-062: `TAND` is integer-only Local VEC bitwise AND

`TAND` is selected by TEPL carrier `Mode=0, Function=6`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Within
`ValidRow x ValidCol`, every destination element is the raw bitwise AND of the
corresponding left and right integer elements. Signedness does not change the
bit operation.

The exact supported DataType set is `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`. Floating, compact floating, exponent-only, and packed integer
encodings are unsupported by TAND and reject before effects. TAND uses the
closed Local binary VEC schema: nonzero `LB0=ValidCol` is required; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from capacity, `Col`, and DataType. Both sources and destination MUST
match in physical and valid shape, row-major layout, and DataType, and every
source element read by the valid rectangle MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. `Max` and `Min` use the selected integer DataType's
numeric maximum and minimum. The selector applies to every physical
destination element outside the valid rectangle. Explicit nondefault `CMode`,
`Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or `Layout` is illegal.

TAND takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and treats `PE_MASK=0000` as a strict no-op before reads,
allocation, or faults. Both source payloads are snapshotted only after complete
preflight. Sources MAY be identical and either source MAY alias the destination
with read-old/write-new behavior. The valid bitwise result plus padding
definedness publishes as one destination commit; rejection leaves descriptors,
payloads, and allocation state unchanged.

## PRD-063: `TOR` is integer-only Local VEC bitwise OR

`TOR` is selected by TEPL carrier `Mode=0, Function=7`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Within
`ValidRow x ValidCol`, each destination element is the raw bitwise OR of the
corresponding left and right integer elements. Signedness does not change the
bit operation.

The exact supported DataType set is `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`. Every floating, compact floating, exponent-only, and packed
integer encoding is unsupported by TOR and rejects before effects. TOR uses
the closed Local binary VEC schema: `LB0=ValidCol` is required and nonzero;
omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and
physical rows derive from capacity, `Col`, and DataType. Both sources and the
destination MUST match in physical and valid shape, row-major layout, and
DataType, and all valid source elements MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. `Max` and `Min` use the selected integer DataType's
numeric maximum and minimum. Padding applies outside the valid destination
rectangle. Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary
`DataType`, `RMode`, or `Layout` is illegal.

TOR takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and treats `PE_MASK=0000` as a strict no-op before reads,
allocation, or faults. Both source payloads are snapshotted after complete
preflight. Sources MAY be identical and either source MAY alias the destination
with read-old/write-new behavior. Valid results plus padding definedness publish
as one destination commit; rejection leaves architectural state unchanged.

## PRD-064: `TXOR` is integer-only Local VEC bitwise XOR

`TXOR` is selected by TEPL carrier `Mode=0, Function=8`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Within
`ValidRow x ValidCol`, each destination element is the raw bitwise XOR of the
corresponding left and right integer elements. Signedness does not affect the
bit operation.

TXOR supports exactly `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Floating, compact floating, exponent-only, and packed integer encodings
are unsupported and reject before effects. The closed Local binary VEC schema
requires nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted
`LB2` gives `Col=ValidCol`; and physical rows derive from capacity, `Col`, and
DataType. Both sources and destination MUST match in physical and valid shape,
row-major layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected integer DataType's numeric bounds.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TXOR takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and treats `PE_MASK=0000` as a strict no-op before reads,
allocation, or faults. Both sources persist and are snapshotted after complete
preflight. They MAY be identical and either MAY alias the destination with
read-old/write-new behavior. Valid XOR results plus padding definedness publish
atomically; rejection leaves architectural state unchanged.

## PRD-065: `TSHL` uses element-width-masked logical left shifts

`TSHL` is selected by TEPL carrier `Mode=0, Function=9`. It reads a Local
value Tile as source0 and a Local shift-count Tile as source1, and writes one
explicit renamed Local destination. For an element width `W` of 8, 16, 32, or
64 bits, the shift count is the unsigned value of the low `log2(W)` bits of
the corresponding source1 element. The destination element is the low `W`
bits of `source0 << count`; verification-carrier bits above `W` are zero.
Signedness does not alter this raw left-shift rule.

TSHL supports exactly `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Other DataTypes reject before effects. Its closed Local binary VEC
schema requires nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`;
omitted `LB2` gives `Col=ValidCol`; and physical rows derive from capacity,
`Col`, and DataType. Sources and destination MUST match in physical and valid
shape, row-major layout, and DataType, and all valid source elements MUST be
defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected integer type's numeric bounds.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TSHL takes no `B.IOR` or `B.IOS`, requires equal `PE_MASK` values, and mask
zero is a strict no-op. Sources persist, may be identical, and may alias the
destination. Both payloads are snapshotted after complete preflight; narrowed
valid results plus padding definedness publish atomically, and rejection has no
architectural effect.

## PRD-066: `TSHR` follows integer signedness at the element width

`TSHR` is selected by TEPL carrier `Mode=0, Function=10`. It reads a Local
value Tile as source0 and a Local shift-count Tile as source1, and writes one
explicit renamed Local destination. For element width `W`, the unsigned shift
count is selected by the low `log2(W)` bits of source1. Signed DataTypes use
arithmetic right shift with sign fill; unsigned DataTypes use logical right
shift with zero fill. The low `W` result bits are stored and verification-
carrier bits above `W` are zero.

TSHR supports exactly `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Other types reject before effects. The closed Local binary VEC schema
requires nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted
`LB2` gives `Col=ValidCol`; and physical rows derive from capacity, `Col`, and
DataType. Sources and destination MUST match physical shape, valid shape,
row-major layout, and DataType, and all valid source elements MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected integer type's numeric bounds.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TSHR takes no `B.IOR` or `B.IOS`, requires equal `PE_MASK` values, and mask
zero is a strict no-op. Both sources persist, may be identical, and may alias
the destination. Payloads are snapshotted after complete preflight; the typed
shift results plus padding definedness publish atomically, and rejection has no
architectural effect.

## PRD-067: `TMAX` is typed maximum with deterministic floating ties

`TMAX` is selected by TEPL carrier `Mode=0, Function=11`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Signed
integer DataTypes use signed numeric ordering, unsigned integer DataTypes use
unsigned numeric ordering, and floating DataTypes use the selected numeric
profile's maximum operation.

TMAX supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Other types
reject before effects. For supported floating types, one NaN selects the
non-NaN operand without changing its encoding; two NaNs produce the
destination canonical NaN; signaling NaN reports the selected profile's
invalid condition; equal-sign zero preserves that sign; and a mixed-sign zero
tie produces positive zero. Operand order does not change these results.
Source encodings invalid for the selected operation/profile reject before
effects.

The closed Local binary VEC schema requires nonzero `LB0=ValidCol`; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from capacity, `Col`, and DataType. Both sources and destination MUST
match physical and valid shape, row-major layout, and DataType, and all valid
source elements MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal.

TMAX takes no `B.IOR` or `B.IOS`, requires equal `PE_MASK` values, and mask
zero is a strict no-op. Sources persist, may be identical, and may alias the
destination. Payloads are snapshotted after all legality and value-encoding
checks; the complete result plus padding definedness publishes atomically, and
rejection has no architectural effect.

## PRD-126: `TEXTRACT` uses two optional private-GPR offsets

`TEXTRACT` is selected by TEPL carrier `Mode=3, Function=2` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. The row offset is the unsigned low sixteen bits
of the selected PE's private `B.IOR.RegSrc0`; the column offset is the unsigned
low sixteen bits of `B.IOR.RegSrc1`. An omitted `B.IOR` supplies zero for both
offsets. When `B.IOR` is present, `RegSrc2` and `RegDst` MUST be zero.

`B.DIM` never supplies the offsets. Required nonzero `LB0` supplies destination
`ValidCol`; omitted `LB1` gives destination `ValidRow=1`; omitted `LB2` gives
destination physical `Col=ValidCol`; destination physical rows derive from
capacity, `Col`, and DataType. Before effects, `row_offset + ValidRow` MUST be
at most the source `ValidRow` and `column_offset + ValidCol` MUST be at most
the source `ValidCol`.

For every destination valid element `[r,c]`, the result is source element
`[row_offset+r,column_offset+c]`. The source and destination use the same
DataType. Every assigned Tile DataType except `HiF4X2` is supported; globally
reserved encodings and `HiF4X2` reject before effects. The selected assigned
`Layout` transformation governs destination placement. `PadValueOrByteId`
applies to destination physical elements outside its valid rectangle; omission
selects `Null` and explicit values select `Zero`, `Max`, `Min`, or `Null`.

`TEXTRACT` has no architectural ReLU, quantization, Fix-pipe, auxiliary Tile,
or target-specific overload. It is Local-only; source and destination use the
same `PE_MASK`, with mask zero a strict no-op. The source valid elements needed
by the extraction window MUST be defined. Complete preflight precedes a source
snapshot, and destination contents, padding definedness, and descriptor publish
atomically. The source persists and rejection has no architectural effect.

## PRD-127: `TINSERT` explicitly reads the old destination and writes a renamed result

`TINSERT` is selected by TEPL carrier `Mode=3, Function=3` and executes on the
`SFU` engine. Its architectural Tile operands are an old-destination source,
an insertion source, and one explicit newly allocated destination result. The
result begins as an exact snapshot of the old destination, after which the
insertion source valid rectangle replaces the result window beginning at the
selected row and column offsets. The old destination and insertion source both
persist.

The row offset is the unsigned low sixteen bits of the selected PE's private
`B.IOR.RegSrc0`; the column offset is the unsigned low sixteen bits of
`B.IOR.RegSrc1`. An omitted `B.IOR` supplies zero for both. When `B.IOR` is
present, `RegSrc2` and `RegDst` MUST be zero. `B.DIM` describes the result
geometry and MUST match the old-destination physical and valid shape; it never
supplies the offsets.

The old destination, insertion source, and result use one DataType. Every
assigned Tile DataType except `HiF4X2` is supported. Before effects,
`row_offset + insertion.ValidRow` MUST be at most `result.ValidRow` and
`column_offset + insertion.ValidCol` MUST be at most `result.ValidCol`.
Every insertion-source valid element MUST be defined. Every result element not
covered by the inserted rectangle, including its definedness, is preserved
from the old destination. `PadValueOrByteId` is not applicable because no
uncovered region is synthesized. An assigned `Layout` value may select the
defined source-to-result layout transformation; reserved values reject.

`TINSERT` has no architectural ReLU, quantization, Fix-pipe, auxiliary Tile,
or target-specific mode overload. It is Local-only. All three bindings use the
same `PE_MASK`; mask zero is a strict no-op. Complete preflight precedes both
source snapshots. The copied old state, inserted window, definedness, and new
destination descriptor publish atomically. Legal aliasing always observes old
source values; rejection has no architectural effect.

## PRD-128: `TIMG2COL` reads a feature-map descriptor and two logical matrix offsets

`TIMG2COL` is selected by TEPL carrier `Mode=3, Function=4` and executes on
the `SFU` engine. It reads one Local Matrix-location feature-map Tile and
writes one explicit newly allocated Local Matrix-location destination in the
standard Left-input representation. The source persists.

The source Tile carries a complete architectural feature-map descriptor. Its
layout is either `NC1HWC0`, with dimensions `N,C1,H,W,C0`, or `NDC1HWC0`,
with dimensions `N,D,C1,H,W,C0`. Every dimension is nonzero. The descriptor
also carries nonzero filter height and width, nonzero row and column strides,
nonzero row and column dilations, nonnegative left, right, top, and bottom
padding, a logical channel count no greater than `C1*C0`, and one typed
padding value. A descriptor requesting transposed IMG2COL is not assigned by
this PTO form and is illegal. The descriptor MUST be valid before execution;
`TIMG2COL` neither creates nor modifies it.

The destination row start `posM` is the unsigned low sixteen bits of the
selected PE's private `B.IOR.RegSrc0`; the destination-column start `posK` is
the unsigned low sixteen bits of `B.IOR.RegSrc1`. Omitted `B.IOR` supplies
zero for both. When present, `RegSrc2` and `RegDst` MUST be zero. Required
nonzero `B.DIM.LB0` supplies destination `ValidCol`; omitted `LB1` supplies
destination `ValidRow=1`; omitted `LB2` supplies destination physical
`Col=ValidCol`; physical rows derive from capacity, `Col`, and DataType.
`B.DIM` never supplies filter, stride, dilation, padding, `posM`, or `posK`.

Let `outH = floor((H + padTop + padBottom - dilationH*(filterH-1) - 1) /
strideH) + 1` and define `outW` analogously. Both values MUST be positive.
The logical im2col row extent is `N*D*outH*outW`, where `D=1` for
`NC1HWC0`; the packed column extent is `C1*filterH*filterW*C0`. The complete
destination rectangle beginning at `(posM,posK)` MUST fit those extents.

For result element `[r,c]`, `m=posM+r` selects `n`, `d`, `outRow`, and
`outCol` in that order. `k=posK+c` selects `c1`, `kernelRow`, `kernelCol`,
and `c0` from the packed column order. The corresponding source coordinates
are `inputRow=outRow*strideH + kernelRow*dilationH - padTop` and
`inputCol=outCol*strideW + kernelCol*dilationW - padLeft`. An out-of-range
input coordinate or a packed channel `c1*C0+c0` outside the logical channel
count yields the descriptor's padding value; otherwise the exact source
element is copied. Only actually referenced in-range source elements must be
defined.

Source and destination use the same DataType. This form supports exactly
`FP32`, `FP16`, `BF16`, `S32`, `S16`, `S8`, `U32`, `U16`, and `U8`; every
other assigned or reserved DataType rejects before effects. The feature-map
layout and padding value come only from the source descriptor. `B.DATR` may be
omitted; it supplies no secondary DataType, layout conversion, numeric mode,
or padding override, and every nondefault contribution is illegal.

`TIMG2COL` is Local-only and takes no `B.IOS`. Source and destination use the
same `PE_MASK`; nonzero partial masks are legal and mask zero is a strict
no-op. Complete descriptor, range, type, capacity, definedness, and allocation
preflight precedes a source snapshot. The complete destination payload,
padding definedness, and descriptor publish atomically, and rejection has no
architectural effect.

## PRD-068: `TMIN` is typed minimum with deterministic floating ties

`TMIN` is selected by TEPL carrier `Mode=0, Function=12`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Signed
integer DataTypes use signed numeric ordering, unsigned integer DataTypes use
unsigned numeric ordering, and floating DataTypes use the selected numeric
profile's minimum operation.

TMIN supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Other types
reject before effects. For supported floating types, one NaN selects the
non-NaN operand without changing its encoding; two NaNs produce the
destination canonical NaN; signaling NaN reports the selected profile's
invalid condition; equal-sign zero preserves that sign; and a mixed-sign zero
tie produces negative zero. Operand order does not change these results.
Source encodings invalid for the selected operation/profile reject before
effects.

The closed Local binary VEC schema requires nonzero `LB0=ValidCol`; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from capacity, `Col`, and DataType. Both sources and destination MUST
match physical and valid shape, row-major layout, and DataType, and all valid
source elements MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal.

TMIN takes no `B.IOR` or `B.IOS`, requires equal `PE_MASK` values, and mask
zero is a strict no-op. Sources persist, may be identical, and may alias the
destination. Payloads are snapshotted after all legality and value-encoding
checks; the complete result plus padding definedness publishes atomically, and
rejection has no architectural effect.

## PRD-069: `TCMP` produces a packed one-bit Local predicate Tile

`TCMP` is selected by TEPL carrier `Mode=0, Function=13`. It reads two ordered
Local numeric source Tiles and writes one explicit renamed Local predicate
destination. `B.DATR.CMode` maps `0=EQ`, `1=NE`, `2=LT`, `3=GT`, `4=LE`, and
`5=GE`; encodings 6 and 7 are reserved. Omission retains encoded zero and
therefore selects EQ.

Each logical comparison produces exactly one predicate bit. Logical element
index `i` occupies bit `i mod 8` of byte `floor(i/8)`, so lower logical indices
occupy lower bit positions. The destination is predicate-kind Tile storage,
not a numeric DataType, and retains the sources' logical `Row`, `Col`,
`ValidRow`, and `ValidCol`. Its allocated capacity MUST hold at least
`ceil(Row*Col/8)` bytes.

TCMP supports input types `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`.
Signed and unsigned ordered comparisons use their respective numeric ordering;
floating comparisons use the selected profile. With either floating operand
NaN, EQ/LT/LE/GT/GE produce zero and NE produces one; signaling NaN also
reports the selected profile's invalid condition. Positive and negative zero
compare equal, LE and GE are true, and strict relations are false. Source
encodings invalid for the selected operation/profile reject before effects.

Source dimensions use required nonzero `LB0=ValidCol`, omitted `LB1` default
`ValidRow=1`, omitted `LB2` default `Col=ValidCol`, and capacity-derived rows.
Both sources MUST match physical and valid shape, row-major layout, and
DataType. `CMode` and `PadValueOrByteId` are the only applicable `B.DATR`
fields. Pad omission is `Null`; `Zero` and `Min` write zero predicate bits
outside the valid rectangle; `Max` writes one bits; and `Null` leaves those
bits undefined. Explicit nondefault `Sat`, `Canonicalize`, secondary
`DataType`, `RMode`, or `Layout` is illegal.

TCMP takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. Sources persist and their
valid regions MUST be defined. Complete preflight precedes source snapshots;
the packed predicate payload, padding definedness, and destination descriptor
publish atomically, and rejection has no architectural effect.

## PRD-070: `TABS` is typed elementwise absolute value

`TABS` is selected by TEPL carrier `Mode=0, Function=15`. It reads one Local
source Tile and writes one explicit renamed Local destination. For signed
integer DataTypes, each result is the element-width two's-complement absolute
value: a negative input is negated modulo its width, so the most-negative
value retains its bit pattern. For unsigned integer DataTypes, the operation
is the identity. For floating DataTypes, TABS clears only the sign bit; this
maps negative zero to positive zero and preserves infinity, NaN class, and NaN
payload without raising an invalid condition solely because the operand is a
signaling NaN. Verification-carrier bits above the element width are zero.

TABS supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Other
DataTypes reject before effects. Its closed Local unary VEC schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected DataType's values. Explicit
nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or
`Layout` is illegal.

TABS takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and treats mask zero as a strict no-op before reads,
allocation, or faults. The source persists and MAY alias the destination.
After complete preflight, the source payload is snapshotted and the typed
absolute-value result plus padding definedness publishes atomically. Rejection
leaves descriptors, payloads, and allocation state unchanged.

## PRD-071: `TNOT` complements only the selected integer element width

`TNOT` is selected by TEPL carrier `Mode=0, Function=16`. It reads one Local
source Tile and writes one explicit renamed Local destination. For an element
width `W` of 8, 16, 32, or 64 bits, each result is the low `W` bits of the
bitwise complement of the corresponding source element. Signedness does not
alter the operation. Verification-carrier bits above `W` are zero.

TNOT supports exactly `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Every floating, compact floating, exponent-only, and packed integer
DataType is unsupported and rejects before effects. Its closed Local unary
VEC schema requires nonzero `LB0=ValidCol`; omitted `LB1` gives
`ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows derive
from capacity, `Col`, and DataType. Source and destination MUST match in
physical and valid shape, row-major layout, and DataType, and every valid
source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected integer DataType's numeric bounds.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TNOT takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes the source snapshot; the
width-limited result plus padding definedness publishes atomically, and
rejection has no architectural effect.

## PRD-072: `TNEG` negates at the selected numeric element width

`TNEG` is selected by TEPL carrier `Mode=0, Function=17`. It reads one Local
source Tile and writes one explicit renamed Local destination. For signed and
unsigned integer DataTypes, each result is `0 - source` modulo the selected
8, 16, 32, or 64-bit element width; the most-negative signed value therefore
retains its bit pattern. For floating DataTypes, TNEG toggles only the sign
bit, preserving infinity, NaN class, and NaN payload without raising an
invalid condition solely because the operand is a signaling NaN. Positive and
negative zero exchange encodings. Verification-carrier bits above the element
width are zero.

TNEG supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Other
DataTypes reject before effects. Its closed Local unary VEC schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal.

TNEG takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes the source snapshot; the
typed result plus padding definedness publishes atomically, and rejection has
no architectural effect.

## PRD-073: `TEXP` is floating-only same-type natural exponential

`TEXP` is selected by TEPL carrier `Mode=0, Function=18` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type natural exponential `exp(source)`. The profile owns finite
approximation accuracy, rounding, overflow, underflow, inexact reporting, NaN
propagation, and canonical result requirements.

Independently of profile approximation, `exp(+0)` and `exp(-0)` are positive
one, `exp(+infinity)` is positive infinity, and `exp(-infinity)` is positive
zero. A quiet NaN produces the profile's quiet-NaN result; a signaling NaN
also reports the profile invalid condition and produces a quiet NaN.

TEXP supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TEXP uses the selected
profile's fixed/default rounding behavior.

TEXP takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## PRD-074: `TLOG` is floating-only same-type natural logarithm

`TLOG` is selected by TEPL carrier `Mode=0, Function=19` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type natural logarithm `log(source)`. The profile owns finite
approximation accuracy, rounding, underflow, inexact reporting, NaN
propagation, and canonical result requirements.

Independently of profile approximation, `log(+1)` is positive zero;
`log(+0)` and `log(-0)` are negative infinity and report divide-by-zero;
`log(+infinity)` is positive infinity; and every negative finite nonzero value
and negative infinity produce a quiet NaN and report invalid. A quiet NaN
produces the profile's quiet-NaN result; a signaling NaN additionally reports
invalid and produces a quiet NaN.

`E4M3` does not encode infinity. `TLOG` does not admit saturation, so an
`E4M3` positive or negative zero produces the canonical quiet NaN `0x7F` and
reports `DZ` without reporting `OF`.

TLOG supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TLOG uses the selected
profile's fixed/default rounding behavior.

TLOG takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## PRD-075: `TRECIP` is floating-only same-type reciprocal

`TRECIP` is selected by TEPL carrier `Mode=0, Function=20` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type reciprocal `1.0/source`. The profile owns finite
approximation accuracy, rounding, overflow, underflow, inexact reporting, NaN
propagation, and canonical result requirements.

Positive and negative zero produce positive and negative infinity respectively
and report divide-by-zero; they do not make the instruction illegal. Positive
and negative infinity produce positive and negative zero respectively. A quiet
NaN produces the profile's quiet-NaN result; a signaling NaN additionally
reports invalid and produces a quiet NaN.

`E4M3` does not encode infinity. `TRECIP` does not admit saturation, so either
`E4M3` signed zero produces the canonical quiet NaN `0x7F` and reports `DZ`
without reporting `OF`.

TRECIP supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TRECIP uses the selected
profile's fixed/default rounding behavior.

TRECIP takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## PRD-076: `TSQRT` is floating-only same-type square root

`TSQRT` is selected by TEPL carrier `Mode=0, Function=21` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type square root. The profile owns finite approximation
accuracy, rounding, underflow, inexact reporting, NaN propagation, and
canonical result requirements.

Square root preserves the sign of positive and negative zero, maps positive
infinity to positive infinity, and maps every negative finite nonzero value
and negative infinity to a quiet NaN while reporting invalid. A quiet NaN
produces the profile's quiet-NaN result; a signaling NaN additionally reports
invalid and produces a quiet NaN.

TSQRT supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TSQRT uses the selected
profile's fixed/default rounding behavior.

TSQRT takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## PRD-077: `TRSQRT` is floating-only same-type reciprocal square root

`TRSQRT` is selected by TEPL carrier `Mode=0, Function=22` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type reciprocal square root `1.0/sqrt(source)`. The profile
owns finite approximation accuracy, rounding, overflow, underflow, inexact
reporting, NaN propagation, and canonical result requirements; the operation
is one profile operation rather than two architecturally rounded instructions.

Positive and negative zero produce positive and negative infinity respectively
and report divide-by-zero; they do not make the instruction illegal. Positive
infinity produces positive zero. Every negative finite nonzero value and
negative infinity produce a quiet NaN and report invalid. A quiet NaN produces
the profile's quiet-NaN result; a signaling NaN additionally reports invalid
and produces a quiet NaN.

`E4M3` does not encode infinity. `TRSQRT` does not admit saturation, so either
`E4M3` signed zero produces the canonical quiet NaN `0x7F` and reports `DZ`
without reporting `OF`.

TRSQRT supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TRSQRT uses the selected
profile's fixed/default rounding behavior.

TRSQRT takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## PRD-078: `TRELU` is a same-type Local VEC rectifier

`TRELU` is selected by TEPL carrier `Mode=0, Function=23` and executes on the
`VEC` engine without changing the TEPL carrier encoding. It reads one Local
source Tile and writes one explicit renamed Local destination of the same
DataType. For a signed integer element, a negative value produces
element-width zero and a nonnegative value is preserved. For an unsigned
integer element, TRELU is the identity operation.

For a floating element, every negative finite value and negative infinity
produce positive zero; positive finite values and positive infinity are
preserved; and both positive and negative zero produce positive zero. A quiet
NaN produces the selected numeric profile's quiet-NaN result. A signaling NaN
also reports invalid and produces a quiet NaN. The selected profile owns NaN
payload propagation or canonicalization details.

TRELU supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`.
Exponent-only, other compact floating, packed, pointer, and every other
DataType reject before effects. Its closed Local unary VEC schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal.

TRELU takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and VEC
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## PRD-079: `TSEL` consumes a packed one-bit predicate Tile

`TSEL` is selected by TEPL carrier `Mode=0, Function=26` and executes on the
`VEC` engine. It reads one Local predicate mask Tile and two Local numeric data
Tiles, then writes one explicit renamed Local numeric destination. For logical
element index `i`, mask bit `i mod 8` of byte `floor(i/8)` selects the true
source when one and the false source when zero. Lower logical indices occupy
lower bit positions. The mask MUST use predicate-kind storage produced under
the packed predicate contract; an ordinary numeric Tile is not a legal mask.

The two data sources and destination MUST have identical physical shape,
logical shape, valid shape, row-major layout, and DataType. The mask has the
same logical `Row`, `Col`, `ValidRow`, and `ValidCol`, uses packed predicate
storage with capacity of at least `ceil(Row*Col/8)` bytes, and has every
predicate bit in the valid region defined. Every valid element of both data
sources MUST also be defined. Selection copies the chosen source element's
encoding exactly; it performs no numeric conversion, rounding, saturation,
NaN canonicalization, or floating-status update.

TSEL supports data sources and destination of exactly `FP64`, `FP32`, `TF32`,
`HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`,
`U32`, `U16`, and `U8`. Every other numeric DataType and every non-predicate
mask reject before effects. Required nonzero `LB0` supplies `ValidCol`;
omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and data
Tile physical rows derive from capacity, `Col`, and DataType.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null` for destination elements outside the valid rectangle.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TSEL takes no `B.IOR` or `B.IOS`. Every participating `B.IOT` binding MUST use
the same `PE_MASK`, and mask zero is a strict no-op. All three sources persist;
the two data sources MAY be identical and MAY alias the destination. Complete
preflight precedes predicate and data-source snapshots. The selected payload,
padding definedness, and destination descriptor publish atomically, and
rejection has no architectural effect.

## PRD-080: `TCVT` is the complete typed conversion and canonicalization boundary

`TCVT` is selected by TEPL carrier `Mode=0, Function=27` and executes on the
`VEC` engine. It reads one Local source Tile and writes one explicit renamed
Local destination. The DataType selected by `BSTART.VEC TCVT` is the source
type. An optional `B.DATR.DataType` is the destination type; when that field is
omitted, the destination type inherits the source type. An explicitly encoded
zero selects destination `FP64` and never means inheritance.

Every assigned Tile DataType may be a TCVT source or destination: `FP64`,
`FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `HiF8`, `E4M3`, `E5M2`, `E3M2`,
`E2M3`, `E2M1X2`, `E1M2X2`, `E8M0`, `HiF4X2`, `S64`, `S32`, `S16`, `S8`,
`S4X2`, `U64`, `U32`, `U16`, `U8`, and `U4X2`. Globally reserved DataType
codes reject before effects. `HiF4X2` is supported only by TCVT; using it with
another Tile operation is illegal unless a later architecture revision
explicitly assigns that support.

The source and destination have equal logical `Row`, `Col`, `ValidRow`, and
`ValidCol`, but their physical byte capacities and element packing follow
their own DataTypes and layouts. Packed-X2 formats retain one logical element
per nibble: even logical indices occupy the low nibble and odd logical indices
occupy the high nibble of the same byte. Required nonzero `LB0` supplies
`ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`. Source and destination capacity MUST contain their complete
physical representations, and every valid source element MUST be defined.

`RMode` code zero selects the operation default; code one explicitly selects
RNE; codes two through seven select RTZ, RTM, RTP, RNA, RTO, and RHB
respectively. The operation default is RTZ for floating-to-integer conversion
and RNE for every other conversion that requires rounding. `Sat` omission or
zero disables saturation; `Sat=1` clamps an out-of-range finite result to the
destination type's minimum or maximum before encoding. Without saturation,
integer-to-integer narrowing is modulo the destination width; the selected
numeric profile defines floating overflow, invalid, NaN, infinity, subnormal,
inexact, and format-specific finite conversion results without leaving them
implementation-defined.

`Canonicalize=1` is legal only when the source carries the private CUBE output
representation. It converts that representation into the standard public
left-matrix Tile representation, including any DataType-dependent fractal
merge or split, and requires `Layout=NORM`. A private CUBE source requires
`Canonicalize=1`; an ordinary source requires `Canonicalize=0`.

With `Canonicalize=0`, `Layout=NORM` preserves logical row-major placement;
each of the other twelve assigned Layout codes applies its assigned complete
layout transformation. Every reserved Layout value rejects before effects.
`PadValueOrByteId` is also applicable: omission selects `Null`, while explicit
`00`, `01`, `10`, and `11` select `Zero`, `Max`, `Min`, and `Null` for the
destination region outside the valid rectangle. `CMode` is not applicable and
every explicit nonzero `CMode` is illegal.

TCVT takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete type, encoding, geometry, capacity, layout,
canonicalization, and source-definedness preflight precedes source snapshot
and destination allocation. Converted payload, numeric status, padding
definedness, representation state, and destination descriptor publish
atomically; rejection has no architectural effect.

## PRD-081: `TFMA` is one same-type fused elementwise multiply-add

`TFMA` is selected by TEPL carrier `Mode=0, Function=28` and executes on the
`VEC` engine. It reads Local multiplicand-left, multiplicand-right, and addend
Tiles and writes one explicit renamed Local destination. Each floating result
is one fused `left * right + addend` operation with no architecturally rounded
intermediate product and exactly one selected-profile rounding at the final
result. Each signed or unsigned integer result is the same expression modulo
the element width. Verification-carrier bits above an integer element width
are zero.

TFMA supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Every other
DataType rejects before effects. All three sources and the destination MUST
match physical shape, valid shape, row-major layout, and DataType, and every
valid source element MUST be defined.

For floating DataTypes, the selected numeric profile owns final rounding,
overflow, underflow, inexact, subnormal, NaN payload, and canonical-result
details while preserving fused evaluation. Signaling NaNs report invalid and
produce a quiet NaN. Zero multiplied by infinity, infinity multiplied by zero,
and an infinite product combined with an opposite-signed infinite addend also
report invalid and produce a quiet NaN. Other quiet NaNs propagate according
to the profile. TFMA does not consume an encoded `RMode`, `Sat`, or
`Canonicalize`; it uses the profile's fixed/default arithmetic rounding.

The closed Local ternary VEC schema requires nonzero `LB0=ValidCol`; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from capacity, `Col`, and DataType. `PadValueOrByteId` is the only
applicable `B.DATR` field. Omission selects `Null`; explicit `00`, `01`, `10`,
and `11` select `Zero`, `Max`, `Min`, and `Null`. Explicit nondefault `CMode`,
`Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or `Layout` is illegal.

TFMA takes no `B.IOR` or `B.IOS`. Every participating `B.IOT` binding MUST use
the same `PE_MASK`, and mask zero is a strict no-op. Sources persist, may be
identical, and any source MAY alias the destination. Complete preflight
precedes snapshots of all three source payloads. The fused result, numeric
status, padding definedness, and destination descriptor publish atomically;
rejection has no architectural effect.

## PRD-082: `TADDS` consumes one typed scalar from the selected PE's private GPR

`TADDS` is selected by TEPL carrier `Mode=1, Function=0` and executes on the
`VEC` engine. It reads one Local source Tile, adds one scalar to every element
in the valid rectangle, and writes one explicit renamed Local destination.
The scalar is supplied by `B.IOR.RegSrc0`. For each PE selected by the common
`B.IOT.PE_MASK`, that selector is resolved in that PE's private GPR file.

The low `DataType` element width of the selected 64-bit GPR is the raw encoding
of one scalar element; GPR bits above that width do not participate. Floating
types therefore consume their ordinary bit encoding, signed integers consume
the low-width two's-complement encoding, and unsigned integers consume the
same bits as an unsigned value. Omitting `B.IOR` selects the zero register as
the operation-defined default. An explicitly present all-zero `B.IOR` is a
distinct encoded descriptor but supplies the same zero scalar. `RegSrc1`,
`RegSrc2`, and `RegDst` are unused and MUST be zero when a `B.IOR` is present.

TADDS supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Every other
DataType rejects before effects. The source and destination MUST match
physical and valid shape, row-major layout, and DataType. The selected numeric
profile defines addition, exceptional values, overflow, and fixed/default
rounding for that type; no scalar conversion or extension beyond the raw
low-width interpretation occurs.

The closed Local scalar-VEC schema requires nonzero `LB0=ValidCol`; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from destination capacity, `Col`, and DataType. `PadValueOrByteId` is
the only applicable `B.DATR` field. Omission selects `Null`; explicit `00`,
`01`, `10`, and `11` select `Zero`, `Max`, `Min`, and `Null`. Explicit
nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or
`Layout` is illegal.

`B.IOS` is illegal. The source and destination `B.IOT` bindings use the same
`PE_MASK`; mask zero is a strict no-op before GPR reads, source reads,
allocation, or faults. The source persists and MAY alias the destination.
Complete descriptor, schema, field, type, dimension, capacity, GPR-binding,
mask, allocation, and source-definedness preflight precedes the source and
scalar snapshots. Valid results, numeric status, padding definedness, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## PRD-083: `TSUBS` performs ordered Tile-minus-scalar subtraction

`TSUBS` is selected by TEPL carrier `Mode=1, Function=1` and executes on the
`VEC` engine. For each element in the valid rectangle it computes
`source - scalar`; the scalar is never the left operand. It reads one Local
source Tile and writes one explicit renamed Local destination.

The scalar is supplied by `B.IOR.RegSrc0`, resolved independently in each
selected PE's private GPR file. The low selected-DataType element width is the
raw encoding of one scalar element and higher GPR bits do not participate.
Floating encodings, low-width two's-complement signed integers, and unsigned
integers are interpreted according to the selected DataType. Omitting
`B.IOR` selects the zero register as the operation-defined default; an
explicit all-zero `B.IOR` remains a distinct encoded descriptor but supplies
the same zero scalar. `RegSrc1`, `RegSrc2`, and `RegDst` are unused and MUST be
zero when a descriptor is present.

TSUBS supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Every other
DataType rejects before effects. Source and destination MUST match physical
and valid shape, row-major layout, and DataType. The selected numeric profile
defines subtraction, exceptional values, overflow, and fixed/default rounding
for that type; no scalar conversion or extension beyond the raw low-width
interpretation occurs.

The closed Local scalar-VEC schema and dimension defaults are identical to
PRD-082. `PadValueOrByteId` is the only applicable `B.DATR` field: omission is
`Null`, and explicit `00`, `01`, `10`, and `11` are `Zero`, `Max`, `Min`, and
`Null`. Every other explicit nondefault data attribute is illegal.

`B.IOS` is illegal. Source and destination bindings use the same `PE_MASK`,
and mask zero is a strict no-op before the private GPR read. The source
persists and MAY alias the destination. Complete preflight precedes source and
scalar snapshots; valid results, numeric status, padding definedness, and the
destination descriptor publish atomically. Rejection has no architectural
effect.

## PRD-084: `TMULS` performs typed elementwise Tile-times-scalar multiplication

`TMULS` is selected by TEPL carrier `Mode=1, Function=2` and executes on the
`VEC` engine. It reads one Local source Tile, multiplies each valid element by
one scalar, and writes one explicit renamed Local destination. Signed and
unsigned integer results are modulo the element width. Floating results and
status follow the selected numeric profile and its fixed/default rounding.

The scalar-binding, low-width raw DataType encoding, per-selected-PE private
GPR lookup, omitted versus explicit-zero `B.IOR`, unused `B.IOR` fields,
16-type set, dimension defaults, Local-only bindings, equal and zero mask
rules, source persistence and aliasing, `PadValue` behavior, prohibited data
attributes, complete preflight, and atomic publication are exactly those in
PRD-082. No additional scalar conversion, saturation, or encoded rounding
control is defined.

## PRD-085: `TDIVS` is ordered SFU Tile-divided-by-scalar division

`TDIVS` retains TEPL carrier `Mode=1, Function=3`, selector `0x023`, but its
semantic engine is `SFU` because division requires complex execution hardware.
Canonical block assembly uses `BSTART.SFU TDIVS, DataType`; the raw carrier
encoding is unchanged. For every valid element it computes `source / scalar`,
never `scalar / source`.

The scalar binding and raw low-width DataType interpretation follow PRD-082.
An integer scalar encoding of zero causes Illegal Block Exception before
source snapshot, destination allocation publication, or any architectural
effect. A floating positive or negative zero scalar is not a block-legality
failure; quotient and numeric status follow the selected floating profile.
The profile also owns signed minimum divided by negative one and all floating
NaN, infinity, overflow, underflow, inexact, and rounding behavior.

TDIVS supports the same exact 16 DataTypes, dimensions/defaults, Local Tile
schema, `PadValue`, prohibited fields, masks, persistence, aliasing, preflight,
and atomic publication as PRD-082. Omitting `B.IOR` supplies zero: therefore an
omitted scalar is illegal for every integer TDIVS type and is floating
division by positive zero for every floating type. This is an architectural
default, not permission to read an absent or uninitialized register.

## PRD-086: `TREMS` is SFU divisor-signed Tile-modulo-scalar

`TREMS` retains TEPL carrier `Mode=1, Function=4`, selector `0x024`, but its
semantic engine is `SFU`. Canonical assembly uses
`BSTART.SFU TREMS, DataType` without changing the raw encoding. It computes
modulo with ordered operands `source mod scalar`, not a truncation-toward-zero
language remainder. For signed integers, `q=floor(source/scalar)` and
`result=source-q*scalar`, so every nonzero result has the scalar divisor's
sign. Unsigned types use ordinary unsigned modulo; floating types use the
profile's divisor-signed modulo definition.

The scalar binding, raw low-width DataType interpretation, per-PE private GPR
lookup, exact 16-type set, dimensions/defaults, padding, Local-only bindings,
masks, persistence, aliases, and transaction rules follow PRD-082. Integer
scalar zero raises Illegal Block Exception before effects. Floating positive
or negative zero is not a block-legality failure; result and numeric status
are profile-defined. Consequently an omitted `B.IOR` supplies an illegal zero
divisor for integer TREMS and a legal positive-zero divisor for floating
TREMS. The profile also owns signed overflow boundaries and floating special
values; no encoded rounding or saturation control is consumed.

## PRD-087: `TANDS` is integer-only raw element-width AND with a scalar

`TANDS` is selected by TEPL carrier `Mode=1, Function=6` and executes on the
`VEC` engine. For each valid element it computes the raw bitwise AND of the
source element and scalar. Signedness does not change the bit operation. The
exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`,
and `U8`; every floating, compact, exponent-only, and packed encoding rejects
before effects.

`B.IOR.RegSrc0` supplies the scalar from each selected PE's private GPR. Only
the selected integer element width participates; upper GPR bits are ignored.
Omitting `B.IOR` supplies zero and therefore makes every valid destination
element zero. An explicit all-zero descriptor is distinct but numerically
identical; its unused fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero masks, persistence, aliasing, complete
preflight, and atomic publication follow PRD-082. `PadValueOrByteId` is the
only applicable `B.DATR` field, with omission `Null` and explicit
`Zero`/`Max`/`Min`/`Null`; `Max` and `Min` use the selected integer type.
TANDS has no rounding, saturation, or numeric-status effect.

## PRD-088: `TORS` is integer-only raw element-width OR with a scalar

`TORS` is selected by TEPL carrier `Mode=1, Function=7` and executes on the
`VEC` engine. For each valid element it computes the raw bitwise OR of the
source element and scalar. Signedness does not change the bit operation. The
exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`,
and `U8`; every floating, compact, exponent-only, and packed encoding rejects
before effects.

`B.IOR.RegSrc0` supplies the scalar from each selected PE's private GPR. Only
the selected integer element width participates; upper GPR bits are ignored.
Omitting `B.IOR` supplies zero and therefore leaves every valid source element
unchanged. An explicit all-zero descriptor is distinct but numerically
identical; its unused fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
complete preflight, and atomic publication follow PRD-082.
`PadValueOrByteId` is the only applicable `B.DATR` field, with omission `Null`
and explicit `Zero`/`Max`/`Min`/`Null`; `Max` and `Min` use the selected integer
type. TORS has no rounding, saturation, or numeric-status effect.

## PRD-089: `TXORS` is integer-only raw element-width XOR with a scalar

`TXORS` is selected by TEPL carrier `Mode=1, Function=8` and executes on the
`VEC` engine. For each valid element it computes the raw bitwise XOR of the
source element and scalar. Signedness does not change the bit operation. The
exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`,
and `U8`; every floating, compact, exponent-only, and packed encoding rejects
before effects.

`B.IOR.RegSrc0` supplies the scalar from each selected PE's private GPR. Only
the selected integer element width participates; upper GPR bits are ignored.
Omitting `B.IOR` supplies zero and therefore leaves every valid source element
unchanged. An explicit all-zero descriptor is distinct but numerically
identical; its unused fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
complete preflight, and atomic publication follow PRD-082.
`PadValueOrByteId` is the only applicable `B.DATR` field, with omission `Null`
and explicit `Zero`/`Max`/`Min`/`Null`; `Max` and `Min` use the selected integer
type. TXORS has no rounding, saturation, or numeric-status effect.

## PRD-090: `TSHLS` uses an element-width-masked scalar shift count

`TSHLS` is selected by TEPL carrier `Mode=1, Function=9` and executes on the
`VEC` engine. It reads one Local integer source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local destination. For an
element width `W` of 8, 16, 32, or 64 bits, the shift count is the unsigned
value of the scalar's low `log2(W)` bits. Each destination element is the low
`W` bits of `source << count`; verification-carrier bits above `W` are zero.
Signedness does not change the raw shift.

The exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; every other DataType rejects before effects. The scalar is
read from each selected PE's private GPR. Omitting `B.IOR` supplies zero and
therefore makes TSHLS an identity operation over the valid region. An explicit
all-zero descriptor is distinct but numerically identical; unused `B.IOR`
fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
`PadValueOrByteId`, complete preflight, and atomic publication follow PRD-082.
TSHLS has no rounding, saturation, or numeric-status effect.

## PRD-091: `TSHRS` follows integer signedness with a masked scalar count

`TSHRS` is selected by TEPL carrier `Mode=1, Function=10` and executes on the
`VEC` engine. It reads one Local integer source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local destination. For an
element width `W` of 8, 16, 32, or 64 bits, the shift count is the unsigned
value of the scalar's low `log2(W)` bits. Signed DataTypes use arithmetic right
shift with sign fill; unsigned DataTypes use logical right shift with zero
fill. The low `W` result bits are stored and verification-carrier bits above
`W` are zero.

The exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; every other DataType rejects before effects. The scalar is
read from each selected PE's private GPR. Omitting `B.IOR` supplies zero and
therefore makes TSHRS an identity operation over the valid region. An explicit
all-zero descriptor is distinct but numerically identical; unused `B.IOR`
fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
`PadValueOrByteId`, complete preflight, and atomic publication follow PRD-082.
TSHRS has no rounding, saturation, or numeric-status effect.

## PRD-092: `TMAXS` is typed maximum between each element and a scalar

`TMAXS` is selected by TEPL carrier `Mode=1, Function=11` and executes on the
`VEC` engine. It reads one Local source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local destination. Signed
integer DataTypes use signed numeric ordering, unsigned integer DataTypes use
unsigned numeric ordering, and floating DataTypes use the selected numeric
profile's maximum operation.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all others reject before effects. The scalar is the raw low element-width
encoding from each selected PE's private GPR; upper bits are ignored. Omitting
`B.IOR` supplies the selected type's all-zero encoding, including positive
zero for floating types. Explicit all-zero is distinct but numerically
identical; unused `B.IOR` fields MUST be zero.

For floating types, one NaN selects the non-NaN operand without changing its
encoding; two NaNs produce the destination canonical NaN; signaling NaN
reports the profile's invalid condition; equal-sign zero preserves that sign;
and a mixed-sign zero tie produces positive zero. Source encodings invalid for
the selected profile reject before effects.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
`PadValueOrByteId`, complete preflight, numeric-status transaction, and atomic
publication follow PRD-082 and PRD-067.

## PRD-093: `TMINS` is typed minimum between each element and a scalar

`TMINS` is selected by TEPL carrier `Mode=1, Function=12` and executes on the
`VEC` engine. It reads one Local source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local destination. Signed
integer DataTypes use signed numeric ordering, unsigned integer DataTypes use
unsigned numeric ordering, and floating DataTypes use the selected numeric
profile's minimum operation.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all others reject before effects. The scalar is the raw low element-width
encoding from each selected PE's private GPR; upper bits are ignored. Omitting
`B.IOR` supplies the selected type's all-zero encoding, including positive
zero for floating types. Explicit all-zero is distinct but numerically
identical; unused `B.IOR` fields MUST be zero.

For floating types, one NaN selects the non-NaN operand without changing its
encoding; two NaNs produce the destination canonical NaN; signaling NaN
reports the profile's invalid condition; equal-sign zero preserves that sign;
and a mixed-sign zero tie produces negative zero. Source encodings invalid for
the selected profile reject before effects.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
`PadValueOrByteId`, complete preflight, numeric-status transaction, and atomic
publication follow PRD-082 and PRD-068.

## PRD-094: `TCMPS` produces a packed predicate Tile from a scalar comparison

`TCMPS` is selected by TEPL carrier `Mode=1, Function=13` and executes on the
`VEC` engine. It reads one Local numeric source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local predicate destination.
`B.DATR.CMode` maps `0=EQ`, `1=NE`, `2=LT`, `3=GT`, `4=LE`, and `5=GE`;
encodings 6 and 7 are reserved. Omission retains encoded zero and selects EQ.

Each logical comparison produces exactly one predicate bit. Logical element
index `i` occupies bit `i mod 8` of byte `floor(i/8)`, with lower logical
indices in lower bit positions. The destination is predicate-kind Tile
storage, not a numeric DataType. It retains the source logical `Row`, `Col`,
`ValidRow`, and `ValidCol`, and its capacity MUST hold at least
`ceil(Row*Col/8)` bytes.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. Signed and unsigned ordered
comparisons use their respective numeric ordering. Floating comparison rules,
including unordered NaN results, signaling-NaN invalid status, and signed-zero
equality, follow PRD-069. The scalar is the raw low source-element-width
encoding from each selected PE's private GPR; upper bits are ignored. Omitted
`B.IOR` supplies the selected source type's all-zero encoding.

Source dimensions/defaults and row-major layout follow PRD-082. `CMode` and
`PadValueOrByteId` are the only applicable `B.DATR` fields. Pad omission is
`Null`; `Zero` and `Min` write zero predicate bits outside the valid rectangle,
`Max` writes one bits, and `Null` leaves those bits undefined. TCMPS rejects
`B.IOS`, uses Local-only bindings with equal masks, and treats mask zero as a
strict no-op before private GPR reads. Complete preflight precedes the source
snapshot; packed payload, padding definedness, numeric status, and destination
descriptor publish atomically.

## PRD-095: `TSELS` selects a Tile element or scalar using packed predicates

`TSELS` is selected by TEPL carrier `Mode=1, Function=26` and executes on the
`VEC` engine. It reads one Local packed-predicate mask Tile, one Local numeric
true-source Tile, and one scalar false alternative from `B.IOR.RegSrc0`, then
writes one explicit renamed Local numeric destination. For logical element
index `i`, bit `i mod 8` of mask byte `floor(i/8)` selects the true-source
element when one and the scalar when zero. Lower logical indices occupy lower
bit positions. An ordinary numeric Tile is not a legal mask.

The true source and destination MUST have identical physical shape, logical
shape, valid shape, row-major layout, and DataType. The mask has the same
logical and valid geometry, predicate-kind storage, capacity of at least
`ceil(Row*Col/8)` bytes, and every valid predicate bit defined. Every valid
true-source element MUST be defined. Selection copies either the source
element encoding or the raw low element-width scalar encoding exactly; upper
GPR bits are ignored and no conversion, rounding, saturation, NaN
canonicalization, or numeric-status update occurs.

The exact supported numeric DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; every other numeric type rejects before effects. Omitting
`B.IOR` supplies the selected type's all-zero encoding. Explicit all-zero is
distinct but numerically identical; unused `B.IOR` fields MUST be zero.

Dimensions/defaults, Local-only bindings, equal and zero mask rules,
source persistence, allowed true-source/destination aliasing,
`PadValueOrByteId`, complete predicate/data/scalar preflight, padding
definedness, and atomic destination publication follow PRD-079 and PRD-082.
The predicate mask cannot alias the numeric destination because their storage
kinds differ.

## PRD-096: `TEXPANDS` broadcasts one typed scalar into a new Local Tile

`TEXPANDS` is selected by TEPL carrier `Mode=1, Function=27` and executes on
the `VEC` engine. It has no Tile source. It reads one scalar from
`B.IOR.RegSrc0` and writes one explicit newly allocated Local destination. For
every element inside `ValidRow x ValidCol`, the destination receives the raw
low element-width encoding from the selected PE's private GPR. GPR bits above
the selected DataType width are ignored; no numeric conversion, rounding,
saturation, canonicalization, or numeric-status update occurs.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all other DataTypes reject before effects. Omitting `B.IOR` supplies the
selected type's all-zero encoding, including positive zero for floating
types. An explicitly present all-zero `B.IOR` is a distinct encoded descriptor
but supplies the same value. `RegSrc1`, `RegSrc2`, and `RegDst` are unused and
MUST be zero when `B.IOR` is present.

The closed Local schema requires nonzero `LB0=ValidCol`; omitted `LB1` gives
`ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows derive from
destination capacity, `Col`, and DataType. The destination is row-major and
MUST satisfy `ValidRow <= Row` and `ValidCol <= Col`.
`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `Zero`, `Max`, and `Min` define every physical destination
element outside the valid rectangle with the selected DataType's corresponding
value, while `Null` leaves those elements undefined. Explicit nondefault
`CMode`, `Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or `Layout` is
illegal.

`B.IOS` is illegal. The destination `B.IOT.PE_MASK` may select any subset of
the four PEs; mask zero is a strict no-op before GPR reads, allocation, or
faults. Complete descriptor, field, type, dimension, capacity, GPR-binding,
mask, and allocation preflight precedes scalar reads. Padding definedness and
the destination descriptor publish atomically; rejection has no architectural
effect.

## PRD-097: `TROWSUM` reduces each valid row in increasing-column order

`TROWSUM` is selected by TEPL carrier `Mode=2, Function=0` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each source row `r` in increasing order, it
forms a left fold over source columns `0` through `ValidCol-1` in increasing
order, beginning with the selected DataType's positive/all-zero value. Each
profile-defined addition step produces the next accumulator, and the final
accumulator is written to destination element `[r,0]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Integer addition follows the selected
element-width result rule; floating addition, intermediate rounding,
exceptional values, and numeric status follow the selected profile at every
fold step.

`LB0=ValidCol` is required and nonzero; omitted `LB1` gives source
`ValidRow=1`; omitted `LB2` gives source `Col=ValidCol`; and source physical
rows derive from source capacity, `Col`, and DataType. The source is row-major,
its complete valid rectangle MUST be defined, and
`ValidRow <= Row`, `ValidCol <= Col`. The destination valid shape is exactly
`source.ValidRow x 1`, its physical column count is exactly one, and its
physical row count derives from destination capacity and DataType and MUST be
at least `source.ValidRow`. The destination is row-major.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `Zero`, `Max`, and `Min` define destination physical elements
outside `source.ValidRow x 1` using the selected DataType, while `Null` leaves
them undefined. Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary
`DataType`, `RMode`, or `Layout` is illegal. `B.IOR` and `B.IOS` are illegal.

The source and destination `B.IOT` bindings use the same `PE_MASK`; any PE
subset is legal and mask zero is a strict no-op before source reads,
allocation, or faults. The source persists. Complete descriptor, field, type,
dimension, capacity, mask, allocation, and source-definedness preflight
precedes the source snapshot. Numeric status, all reduction results, padding
definedness, and the destination descriptor publish atomically; rejection has
no architectural effect.

## PRD-098: `TROWMAX` applies typed maximum across each valid row

`TROWMAX` is selected by TEPL carrier `Mode=2, Function=1` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source row, the accumulator starts
with column zero and folds columns one through `ValidCol-1` in increasing
order using exactly the typed maximum operation defined for `TMAX`. The final
value is written to destination element `[r,0]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Signed and
unsigned integers use their respective numeric order. Floating one-NaN,
two-NaN, signaling-NaN status, canonical-NaN, and signed-zero tie behavior is
identical to PRD-067, including positive zero for a mixed-sign maximum tie.
Invalid source encodings reject before effects.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, matching DataType, and bounds follow
PRD-097. `PadValueOrByteId` is the only applicable `B.DATR` field and follows
PRD-097 for every physical destination element outside the valid one-column
result. `B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Floating
invalid status, results, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## PRD-099: `TROWMIN` applies typed minimum across each valid row

`TROWMIN` is selected by TEPL carrier `Mode=2, Function=2` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source row, the accumulator starts
with column zero and folds columns one through `ValidCol-1` in increasing
order using exactly the typed minimum operation defined for `TMIN`. The final
value is written to destination element `[r,0]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Signed and
unsigned integers use their respective numeric order. Floating one-NaN,
two-NaN, signaling-NaN status, canonical-NaN, and signed-zero tie behavior is
identical to PRD-068, including negative zero for a mixed-sign minimum tie.
Invalid source encodings reject before effects.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, matching DataType, and bounds follow
PRD-097. `PadValueOrByteId` is the only applicable `B.DATR` field and follows
PRD-097 for every physical destination element outside the valid one-column
result. `B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Floating
invalid status, results, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## PRD-100: `TROWPROD` reduces each valid row with typed multiplication

`TROWPROD` is selected by TEPL carrier `Mode=2, Function=3` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source row, it performs an
increasing-column left fold over columns zero through `ValidCol-1`. The
accumulator begins with the selected DataType's exact multiplicative identity
and every fold step uses exactly the typed multiplication operation defined for
`TMUL`; the final value is written to destination element `[r,0]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Integer multiplication follows the selected
element-width overflow rule. Floating multiplication, intermediate rounding,
exceptional values, and numeric status follow the selected profile at every
fold step.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, matching DataType, and bounds follow
PRD-097. `PadValueOrByteId` is the only applicable `B.DATR` field and follows
PRD-097 for every physical destination element outside the valid one-column
result. `B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Numeric
status, results, padding definedness, and the destination descriptor publish
atomically; rejection has no architectural effect.

## PRD-101: `TROWEXPAND` broadcasts one one-column source across destination rows

`TROWEXPAND` is selected by TEPL carrier `Mode=2, Function=4` and executes on
the `SFU` engine. It reads exactly one Local source Tile and writes one explicit
newly allocated Local destination. The source has
`ValidRow == destination.ValidRow`, `ValidCol == 1`, and `Col == 1`. For every
valid destination element `[r,c]`, the operation copies the source element
`[r,0]` exactly. There is no second full-shape source operand and no otherwise
unread source payload.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Expansion copies element encodings without
conversion, rounding, saturation, canonicalization, or numeric-status change.

`LB0=destination.ValidCol` is required and nonzero; omitted `LB1` gives both
source and destination `ValidRow=1`; omitted `LB2` gives destination
`Col=ValidCol`; destination physical rows derive from capacity, `Col`, and
DataType. The destination is row-major and the complete one-column source valid
region MUST be defined. `PadValueOrByteId` is the only applicable `B.DATR`
field and follows PRD-097 over destination elements outside its valid rectangle.
`B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Valid
results, padding definedness, and the destination descriptor publish atomically;
rejection has no architectural effect.

## PRD-102: `TROWEXPANDADD` adds a one-column row broadcast source

`TROWEXPANDADD` is selected by TEPL carrier `Mode=2, Function=5` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. For every valid element `[r,c]`, the result is the selected
DataType's addition of `source0[r,c]` and `source1[r,0]`.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all others reject before effects. All operands use the same DataType.
Integer overflow and floating rounding, exceptional values, and numeric status
are exactly the typed addition rules of `TADD` for each element.

`source0` and the destination have identical physical shape, valid shape, and
row-major layout. `source1.ValidRow` equals their `ValidRow`, while
`source1.ValidCol == source1.Col == 1`; its physical rows derive from capacity.
Dimension defaults and bounds follow PRD-082. Both source valid regions MUST be
defined. `PadValueOrByteId` is the only applicable `B.DATR` field and applies
to every physical destination element outside the valid rectangle. `B.IOR`
and `B.IOS` are illegal.

All three `B.IOT` bindings use the same `PE_MASK`; partial masks are legal and
mask zero is a strict no-op before reads, allocation, or faults. Both sources
persist. Any otherwise legal source/destination alias uses read-old/write-new
behavior, with both source payloads snapshotted after complete preflight.
Numeric status, valid results, padding definedness, and the destination
descriptor publish atomically; rejection has no architectural effect.

## PRD-103: `TROWEXPANDSUB` subtracts a one-column row broadcast source

`TROWEXPANDSUB` is selected by TEPL carrier `Mode=2, Function=6` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. Operand order is fixed: for every valid `[r,c]`, the result is
`source0[r,c] - source1[r,0]` under the selected DataType. The reverse
subtraction is not an alias or alternate form.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-102. Integer overflow and floating rounding, exceptional values, signed
zeros, and numeric status are exactly the typed subtraction rules of `TSUB`
for each element.

## PRD-104: `TROWEXPANDMUL` multiplies by a one-column row broadcast source

`TROWEXPANDMUL` is selected by TEPL carrier `Mode=2, Function=7` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. For every valid `[r,c]`, the result is the selected DataType's
multiplication of `source0[r,c]` and `source1[r,0]`.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-102. Integer overflow and floating rounding, exceptional values, and
numeric status are exactly the typed multiplication rules of `TMUL` for each
element.

## PRD-105: `TROWEXPANDDIV` divides by a one-column row broadcast source

`TROWEXPANDDIV` is selected by TEPL carrier `Mode=2, Function=8` and executes
on the `SFU` engine. It reads one full-shape Local numerator source and one
Local one-column broadcast denominator source, then writes one explicit newly
allocated Local destination. Operand order is fixed: for every valid `[r,c]`,
the result is `source0[r,c] / source1[r,0]` under the selected DataType.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-102. Signed, unsigned, and floating division semantics follow PRD-060.
Any selected row whose integer broadcast denominator is zero causes Illegal
Block Exception before source snapshots, allocation publication, status, or
destination effects. Floating positive or negative zero is processed by the
selected floating profile and is not a block-legality failure.

## PRD-106: `TROWEXPANDMAX` takes typed maximum with a row broadcast source

`TROWEXPANDMAX` is selected by TEPL carrier `Mode=2, Function=9` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. For every valid `[r,c]`, the result is
`max(source0[r,c], source1[r,0])` under the selected DataType.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-102. Signed and unsigned ordering and floating one-NaN, two-NaN,
signaling-NaN, canonical-NaN, and signed-zero tie behavior follow PRD-067;
mixed-sign zero maximum produces positive zero.

## PRD-107: `TROWEXPANDMIN` takes typed minimum with a row broadcast source

`TROWEXPANDMIN` is selected by TEPL carrier `Mode=2, Function=10` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. For every valid `[r,c]`, the result is
`min(source0[r,c], source1[r,0])` under the selected DataType.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-102. Signed and unsigned ordering and floating one-NaN, two-NaN,
signaling-NaN, canonical-NaN, and signed-zero tie behavior follow PRD-068;
mixed-sign zero minimum produces negative zero.

## PRD-108: `TROWEXPANDEXPDIF` exponentiates a typed row-broadcast difference

`TROWEXPANDEXPDIF` is selected by TEPL carrier `Mode=2, Function=11` and
executes on the `SFU` engine. It reads one full-shape Local source and one
Local one-column broadcast source, then writes one explicit newly allocated
Local destination. For every valid `[r,c]`, it first computes the selected
same-type subtraction `difference = source0[r,c] - source1[r,0]` and then
writes the selected same-type natural exponential `exp(difference)`. Publishing
the raw subtraction result without the exponential is not conforming.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, and `E5M2`; every integer, exponent-only, compact, packed, or
reserved DataType encoding rejects before effects. All operands use the same
DataType. The subtraction stage follows the typed `TSUB` rules and the
exponential stage follows the typed `TEXP` rules. Each stage applies the
selected profile's rounding and numeric-status behavior; accumulated status is
part of the single architectural transaction. Signed zeros, infinities, quiet
and signaling NaNs, overflow, underflow, and inexact results follow those two
typed operations in sequence.

Exact source and destination geometry, row-major layout, dimension defaults,
source definedness, `PadValueOrByteId` applicability, prohibited `B.IOR` and
`B.IOS`, equal and zero mask rules, source persistence, legal alias snapshot
behavior, complete preflight, rollback, and atomic publication follow PRD-102.

## PRD-109: `TROWARGMAX` returns the lowest column index of each row maximum

`TROWARGMAX` is selected by TEPL carrier `Mode=2, Function=12` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. Each nonempty valid source row is scanned from
column zero through `ValidCol-1` in increasing order. Values are compared with
the selected DataType's `TMAX` rules. The destination element `[r,0]` is the
`U32` encoding of the winning column index. When multiple elements represent
the same maximum, the lowest column index wins.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. The destination DataType is
always `U32` and is independent of the selected source DataType. Signed,
unsigned, and floating ordering, one-NaN and two-NaN behavior, signaling-NaN
invalid status, canonical NaNs, and signed-zero preference follow `TMAX`.
Selecting a later value because it is the preferred maximum updates the index;
an equal value that does not replace the current maximum preserves the earlier
index.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, and `PadValueOrByteId` application
to U32 destination padding follow PRD-097. `B.IOR` and `B.IOS` are illegal.
Source and destination `B.IOT` bindings use the same `PE_MASK`; any subset is
legal and mask zero is a strict no-op before reads, allocation, or faults. The
source persists. Complete preflight precedes the source snapshot. Numeric
status, U32 indices, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## PRD-110: `TROWARGMIN` returns the lowest column index of each row minimum

`TROWARGMIN` is selected by TEPL carrier `Mode=2, Function=13` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. Each nonempty valid source row is scanned from
column zero through `ValidCol-1` in increasing order. Values are compared with
the selected DataType's `TMIN` rules. The destination element `[r,0]` is the
`U32` encoding of the winning column index. When multiple elements represent
the same minimum, the lowest column index wins.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. The destination DataType is
always `U32` and is independent of the selected source DataType. Signed,
unsigned, and floating ordering, one-NaN and two-NaN behavior, signaling-NaN
invalid status, canonical NaNs, and signed-zero preference follow `TMIN`.
Selecting a later value because it is the preferred minimum updates the index;
an equal value that does not replace the current minimum preserves the earlier
index.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, and `PadValueOrByteId` application
to U32 destination padding follow PRD-097. `B.IOR` and `B.IOS` are illegal.
Source and destination `B.IOT` bindings use the same `PE_MASK`; any subset is
legal and mask zero is a strict no-op before reads, allocation, or faults. The
source persists. Complete preflight precedes the source snapshot. Numeric
status, U32 indices, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## PRD-111: `TCOLSUM` reduces each valid column with typed addition

`TCOLSUM` is selected by TEPL carrier `Mode=2, Function=16` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source column, it performs an
increasing-row left fold over rows zero through `ValidRow-1`. The accumulator
begins with the selected DataType's exact additive identity and every fold step
uses exactly the typed addition operation defined for `TADD`; the final value
is written to destination element `[0,c]`. Tree reduction, scratch storage, and
implementation scheduling do not change this architectural order and are not
instruction operands.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Integer addition follows the selected
element-width overflow rule. Floating addition, intermediate rounding,
exceptional values, and numeric status follow the selected profile at every
fold step.

`LB0=source.ValidCol` is required and nonzero; omitted `LB1` gives
`source.ValidRow=1`; omitted `LB2` gives `source.Col=source.ValidCol`; source
physical rows derive from capacity. The source is row-major and its complete
valid rectangle MUST be defined. The destination has `ValidRow=1`,
`ValidCol=source.ValidCol`, `Col=source.Col`, and capacity-derived physical
rows. `PadValueOrByteId` is the only applicable `B.DATR` field and applies to
every physical destination element outside that one-row valid rectangle.
`B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Numeric
status, results, padding definedness, and the destination descriptor publish
atomically; rejection has no architectural effect.

## PRD-112: `TCOLMAX` reduces each valid column with typed maximum

`TCOLMAX` is selected by TEPL carrier `Mode=2, Function=17` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source column, the accumulator is
initialized from source row zero and rows one through `ValidRow-1` are folded
in increasing order with exactly the typed maximum operation defined for
`TMAX`. The final value is written to destination element `[0,c]`. The first
element is evaluated exactly once.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Signed and unsigned ordering and floating
one-NaN, two-NaN, signaling-NaN, canonical-NaN, and signed-zero behavior
follow `TMAX`; mixed-sign zero maximum produces positive zero.

Source dimensions, defaults, row-major layout, complete source definedness,
destination `1 x source.ValidCol` valid shape, destination physical shape,
`PadValueOrByteId` applicability, prohibited `B.IOR`/`B.IOS`, equal and zero
mask rules, source persistence, snapshot behavior, complete preflight,
numeric-status transaction, rollback, and atomic publication follow PRD-111.

## PRD-129: `TFILLPAD` materializes padding from one private-GPR scalar

`TFILLPAD` is selected by TEPL carrier `Mode=3, Function=5` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. The destination physical `Rows` and `Col` MUST
be at least the source physical `Rows` and `Col`, and its `ValidRow` and
`ValidCol` MUST be at least the source valid dimensions. Equality is the
ordinary form; larger destination dimensions are the expand form. Separate
`TFILLPAD_INPLACE` and `TFILLPAD_EXPAND` encodings are not assigned. A
same-Tile source/result binding is the in-place lowering and retains
read-old/write-new behavior.

For every destination logical coordinate, `TFILLPAD` copies the corresponding
source element when the coordinate lies inside the source valid rectangle.
Every other element of the destination physical Tile is written with one
typed padding scalar. The destination descriptor retains its configured valid
and physical dimensions; the operation makes the complete physical payload
defined.

The padding scalar is supplied exclusively by `B.IOR.RegSrc0`, resolved from
the selected PE's private GPR file. Its low selected-DataType element width is
used as the raw scalar encoding and higher GPR bits do not participate.
Omitting `B.IOR` selects the zero register as the operation-defined default;
an explicitly present all-zero `B.IOR` is a distinct descriptor but supplies
the same zero value. `RegSrc1`, `RegSrc2`, and `RegDst` are unused and MUST be
zero. Standard `Zero`, `Max`, and `Min` constants and arbitrary custom pad
constants are software-selected scalar encodings; they are not selected by
`B.DATR.PadValueOrByteId`. `PadValueOrByteId` is inapplicable to `TFILLPAD`
and every nonzero encoded value is illegal before effects.

The exact supported DataTypes are `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, `E5M2`, `S32`, `S16`, `S8`, `U32`, `U16`, and `U8`. Every other
DataType rejects before effects. Source and destination use the same selected
DataType. Assigned `Layout` values govern physical destination placement
without changing the logical copy-and-fill rule; every other explicit
nondefault data attribute is illegal.

`B.IOS` is illegal. Source and destination `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before GPR or
Tile reads, allocation, or faults. The source persists. Complete descriptor,
schema, type, layout, dimension, capacity, GPR-binding, mask, allocation, and
source-valid-region definedness preflight precedes the source and scalar
snapshots. The full physical payload and destination descriptor publish
atomically; rejection has no architectural effect.

## PRD-130: `TCI` generates one typed single-row integer sequence

`TCI` is selected by TEPL carrier `Mode=3, Function=6` and executes on the
`SFU` engine. It writes one explicit newly allocated Local destination whose
`ValidRow` MUST equal one and whose `ValidCol` MUST be nonzero. Physical `Col`
defaults to `ValidCol` when `LB2` is omitted and MUST be at least
`ValidCol`; physical rows continue to derive from capacity. Only the first
valid row is part of the generated sequence. Other physical elements remain
padding with `Null` definedness.

`B.IOR.RegSrc0` supplies the start value and `RegSrc1` supplies the direction.
Both are read from the selected PE's private GPR file. The low selected
DataType width of `RegSrc0` is the raw start encoding and higher bits do not
participate. `RegSrc1` MUST contain exactly zero for ascending or one for
descending. `RegSrc2` and `RegDst` are unused and MUST be zero. Omitting
`B.IOR` supplies start zero and ascending direction. An explicitly present
all-zero `B.IOR` remains a distinct descriptor but supplies the same values.

For column `k` in `0..ValidCol-1`, ascending TCI writes `start+k` and
descending TCI writes `start-k`. Addition and subtraction wrap modulo the
selected element width. Sequence position is the contiguous logical column
index and does not include physical row-stride gaps.

The exact supported DataTypes are `S32`, `S16`, `U32`, and `U16`; every other
DataType rejects before effects. The destination is row-major. Every explicit
nondefault `B.DATR` field is illegal, including `PadValueOrByteId`, and
`B.IOS` is illegal.

The destination `B.IOT` may use any `PE_MASK`; mask zero is a strict no-op
before GPR reads, allocation, or faults. Complete schema, type, dimension,
capacity, GPR-value, mask, and allocation preflight precedes the GPR
snapshots. The valid sequence and destination descriptor publish atomically;
rejection has no architectural effect.

## PRD-131: `TTRI` generates a typed triangular matrix

`TTRI` is selected by TEPL carrier `Mode=3, Function=7` and executes on the
`SFU` engine. It writes one explicit newly allocated Local destination with
nonzero `ValidRow` and `ValidCol`. Physical `Col` defaults from `LB2` when it
is omitted and MUST be at least `ValidCol`; physical rows derive from the
allocated capacity. The destination uses row-major layout.

`B.IOR.RegSrc0` supplies a signed XLEN diagonal displacement in the inclusive
range `-65535..65535`. `RegSrc1` supplies the orientation and MUST contain
exactly zero for lower-triangular generation or one for upper-triangular
generation. `RegSrc2` and `RegDst` are unused and MUST be zero. Omitting
`B.IOR` supplies diagonal zero and lower orientation. An explicitly present
all-zero `B.IOR` remains a distinct descriptor but supplies the same values.

For every valid logical coordinate `[r,c]`, lower-triangular generation writes
typed one exactly when `c <= r + diagonal` and typed zero otherwise.
Upper-triangular generation writes typed one exactly when
`c >= r + diagonal` and typed zero otherwise. The signed boundary comparison
does not wrap at the Tile edges; extreme diagonal values therefore naturally
produce all-zero or all-one valid regions. Elements outside the valid
rectangle remain padding with `Null` definedness.

The exact supported DataTypes are `FP32`, `FP16`, `S32`, `S16`, `U32`, and
`U16`; every other DataType rejects before effects. Floating destinations use
the selected format's exact positive-zero and positive-one encodings. Every
explicit nondefault `B.DATR` field is illegal, including
`PadValueOrByteId`, and `B.IOS` is illegal.

The destination `B.IOT` may use any `PE_MASK`; mask zero is a strict no-op
before GPR reads, allocation, or faults. Complete schema, type, dimension,
capacity, GPR-value, mask, and allocation preflight precedes generation. The
valid payload and destination descriptor publish atomically; rejection has no
architectural effect.

## PRD-132: `THISTOGRAM` produces U32 cumulative byte histograms

`THISTOGRAM` is selected by TEPL carrier `Mode=3, Function=8` and executes on
the `SFU` engine. It reads one Local source Tile and one Local prefix-filter
Tile and writes one explicit newly allocated Local destination. The source
DataType is selected by `BSTART` and MUST be `U16` or `U32`. The destination
DataType is fixed to `U32`. `B.DATR` is therefore mandatory and MUST encode
destination `U32`; an omitted `B.DATR` retains its reset `FP64` DataType and
is illegal. Its `PadValueOrByteId` field is reinterpreted as `ByteId` values
zero through three. Every other nondefault `B.DATR` field is illegal.

The destination has `ValidRow = source.ValidRow` and `ValidCol = 256`, uses
row-major layout, has physical `Col >= 256`, and has enough capacity for all
valid output rows. For each valid source row, the operation forms 256 exact
counts and writes their inclusive prefix sum: destination `[row,k]` is the
number of accepted source elements in that row whose selected byte is less
than or equal to `k`. Because source `ValidCol` is bounded by the architectural
dimension encoding, each per-row count fits in `U32` without overflow.
Elements outside the destination valid rectangle remain padding with `Null`
definedness.

For a `U16` source, `ByteId=1` selects the high byte without filtering and
`ByteId=0` selects the low byte after requiring the element's high byte to
equal filter element `[row,0]`. Values two and three are illegal. The filter
Tile has DataType `U8`; for `ByteId=0` it has `ValidRow >= source.ValidRow`
and `ValidCol >= 1` and every consumed `[row,0]` element is defined.

For a `U32` source, `ByteId=3` selects the highest byte without filtering.
`ByteId=2`, one, and zero respectively require one, two, and three defined
global prefix bytes from filter elements `[0,0]`, `[1,0]`, and `[2,0]` and
select the next lower source byte only when all required higher bytes match.
The filter Tile has DataType `U8`, `ValidCol >= 1`, and at least the required
number of valid rows. Its physical row stride and unused columns do not add
semantic filter inputs.

The filter binding remains structurally present for the two unfiltered modes,
but its payload and shape are not read in those modes. Source and filter
Tiles persist. Source and destination use row-major layout; filter accesses
use its assigned logical layout. `B.IOS` is illegal. All participating
`B.IOT` bindings use the same `PE_MASK`; any subset is legal and mask zero is
a strict no-op before Tile reads, allocation, or faults. Complete schema,
type, shape, capacity, byte-selector, mask, allocation, and consumed-source
definedness preflight precedes source snapshots. The U32 cumulative payload
and destination descriptor publish atomically; rejection has no architectural
effect.

## PRD-125: `TCONCAT` is fixed horizontal concatenation along columns

`TCONCAT` is selected by TEPL carrier `Mode=3, Function=0` and executes on the
`SFU` engine. It reads two ordered Local source Tiles and writes one explicit
newly allocated Local destination. It has no architectural axis operand. The
left source precedes the right source along the column dimension.

The two sources and destination MUST use the same DataType and row-major
layout. Both sources MUST have the same nonzero `ValidRow`. The destination
has that same `ValidRow` and has `ValidCol = left.ValidCol + right.ValidCol`.
For every valid row, destination columns below `left.ValidCol` are copied from
the left source; following columns are copied from the right source in order.
Vertical row concatenation is not an assigned `TCONCAT` form.

`TCONCAT` supports every assigned Tile DataType except `HiF4X2`. The globally
reserved DataType encodings and `HiF4X2` MUST raise Illegal Block Exception
before source reads, destination allocation, or any other architectural
effect. This is the common `MOVE24` type domain used by representation-
preserving Tile rearrangement operations.

`B.DATR.Layout` retains its physical-layout-transform meaning and MUST NOT be
interpreted as a concatenation-axis selector. No indexed or variable-per-row
concatenation form is part of this instruction. The complete valid regions of
both sources are required defined before effects. Both source payloads are
snapshotted before destination writes, and the destination descriptor and
contents publish atomically after complete preflight. The sources persist;
rejection has no architectural effect.

## PRD-115: `TCOLEXPAND` broadcasts one one-row source down destination columns

`TCOLEXPAND` is selected by TEPL carrier `Mode=2, Function=20` and executes on
the `SFU` engine. It reads exactly one Local source Tile representing one row
and writes one explicit newly allocated Local destination. For every valid
destination element `[r,c]`, the operation copies source element `[0,c]`
bit-for-bit. There is no second full-shape source operand and no numeric
transformation.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Copying does not update numeric status.

`LB0=destination.ValidCol` is required and nonzero; omitted `LB1` gives
`destination.ValidRow=1`; omitted `LB2` gives
`destination.Col=destination.ValidCol`; destination physical rows derive from
capacity. The source has `ValidRow=1`, `ValidCol=destination.ValidCol`, and
`Col=destination.Col`; its physical rows also derive from capacity. Source and
destination are row-major and the complete valid source row MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field and applies to every
physical destination element outside its valid rectangle. `B.IOR` and `B.IOS`
are illegal. Source and destination `B.IOT` bindings use the same `PE_MASK`;
any PE subset is legal and mask zero is a strict no-op before reads,
allocation, or faults. The source persists. Complete preflight precedes the
source snapshot. Results, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## PRD-116: `TCOLEXPANDADD` adds a one-row column broadcast source

`TCOLEXPANDADD` is selected by TEPL carrier `Mode=2, Function=21` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
For every valid element `[r,c]`, the result is the selected DataType's addition
of `source0[r,c]` and `source1[0,c]`.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all others reject before effects. All operands use the same DataType.
Integer overflow and floating rounding, exceptional values, and numeric status
are exactly the typed addition rules of `TADD` for each element.

`source0` and the destination have identical physical shape, valid shape, and
row-major layout. `source1.ValidRow == 1`, while `source1.ValidCol` and
`source1.Col` equal the corresponding destination values; its physical rows
derive from capacity. Dimension defaults and bounds follow PRD-082. Both
source valid regions MUST be defined. `PadValueOrByteId` is the only applicable
`B.DATR` field and applies to every physical destination element outside the
valid rectangle. `B.IOR` and `B.IOS` are illegal.

All three `B.IOT` bindings use the same `PE_MASK`; partial masks are legal and
mask zero is a strict no-op before reads, allocation, or faults. Both sources
persist. Any otherwise legal source/destination alias uses read-old/write-new
behavior, with both source payloads snapshotted after complete preflight.
Numeric status, valid results, padding definedness, and the destination
descriptor publish atomically; rejection has no architectural effect.

## PRD-117: `TCOLEXPANDSUB` subtracts a one-row column broadcast source

`TCOLEXPANDSUB` is selected by TEPL carrier `Mode=2, Function=22` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
Operand order is fixed: for every valid `[r,c]`, the result is
`source0[r,c] - source1[0,c]` under the selected DataType. The reverse
subtraction is not an alias or alternate form.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-116. Integer overflow and floating rounding, exceptional values, signed
zeros, and numeric status are exactly the typed subtraction rules of `TSUB`
for each element.

## PRD-118: `TCOLEXPANDMUL` multiplies by a one-row column broadcast source

`TCOLEXPANDMUL` is selected by TEPL carrier `Mode=2, Function=23` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
For every valid `[r,c]`, it multiplies `source0[r,c]` by `source1[0,c]` under
the selected DataType.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-116. Integer overflow and floating rounding, exceptional values, signed
zeros, and numeric status are exactly the typed multiplication rules of
`TMUL` for each element.

## PRD-119: `TCOLEXPANDDIV` divides by a one-row column broadcast source

`TCOLEXPANDDIV` is selected by TEPL carrier `Mode=2, Function=24` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
Operand order is fixed: for every valid `[r,c]`, the result is
`source0[r,c] / source1[0,c]` under the selected DataType. The reverse quotient
is not an alias or alternate form.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-116. Signed, unsigned, and floating division and numeric status follow
PRD-060. A zero integer broadcast element causes an Illegal Block Exception
before effects; floating positive and negative zero are legal and follow the
selected floating profile.

## PRD-120: `TCOLEXPANDMAX` takes maximum with a one-row broadcast source

`TCOLEXPANDMAX` is selected by TEPL carrier `Mode=2, Function=25` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
For every valid `[r,c]`, the result is exactly the typed maximum of
`source0[r,c]` and `source1[0,c]`.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-116. Signed and unsigned ordering and floating NaN, signaling-NaN,
canonical-NaN, signed-zero, and numeric-status behavior follow `TMAX` exactly;
mixed-sign zero maximum produces positive zero.

## PRD-121: `TCOLEXPANDMIN` takes minimum with a one-row broadcast source

`TCOLEXPANDMIN` is selected by TEPL carrier `Mode=2, Function=26` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
For every valid `[r,c]`, the result is exactly the typed minimum of
`source0[r,c]` and `source1[0,c]`.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
PRD-116. Signed and unsigned ordering and floating NaN, signaling-NaN,
canonical-NaN, signed-zero, and numeric-status behavior follow `TMIN` exactly;
mixed-sign zero minimum produces negative zero.

## PRD-122: `TCOLEXPANDEXPDIF` exponentiates a typed column-broadcast difference

`TCOLEXPANDEXPDIF` is selected by TEPL carrier `Mode=2, Function=27` and
executes on the `SFU` engine. It reads one full-shape Local source and one
Local one-row broadcast source, then writes one explicit newly allocated
Local destination. For every valid `[r,c]`, it first computes the selected
same-type subtraction `difference = source0[r,c] - source1[0,c]` and then
writes the selected same-type natural exponential `exp(difference)`. Publishing
the raw subtraction result without the exponential is not conforming.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, and `E5M2`; every integer, exponent-only, compact, packed, or
reserved DataType encoding rejects before effects. All operands use the same
DataType. The subtraction stage follows the typed `TSUB` rules and the
exponential stage follows the typed `TEXP` rules. Each stage applies the
selected profile's rounding and numeric-status behavior; accumulated status is
part of the single architectural transaction. Signed zeros, infinities, quiet
and signaling NaNs, overflow, underflow, and inexact results follow those two
typed operations in sequence.

Exact source and destination geometry, one-row broadcast geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR` and `B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, complete preflight, rollback, and
atomic publication follow PRD-116.

## PRD-123: `TCOLARGMAX` returns the lowest row index of each column maximum

`TCOLARGMAX` is selected by TEPL carrier `Mode=2, Function=28` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. Each nonempty valid source column is scanned from
row zero through `ValidRow-1` in increasing order. Values are compared with
the selected DataType's `TMAX` rules. Destination element `[0,c]` is the `U32`
encoding of the winning row index. When multiple elements represent the same
maximum, the lowest row index wins.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. The destination DataType is
always `U32` and is independent of the selected source DataType. Signed,
unsigned, and floating ordering, one-NaN and two-NaN behavior, signaling-NaN
invalid status, canonical NaNs, and signed-zero preference follow `TMAX`.
Selecting a later value because it is the preferred maximum updates the index;
an equal value that does not replace the current maximum preserves the earlier
index.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `1 x source.ValidCol` logical shape, destination
physical `Col=source.Col`, capacity-derived destination rows, and
`PadValueOrByteId` application to U32 destination padding follow PRD-111.
`B.IOR` and `B.IOS` are illegal. Source and destination `B.IOT` bindings use
the same `PE_MASK`; any subset is legal and mask zero is a strict no-op before
reads, allocation, or faults. The source persists. Complete preflight precedes
the source snapshot. Numeric status, U32 indices, padding definedness, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## PRD-124: `TCOLARGMIN` returns the lowest row index of each column minimum

`TCOLARGMIN` is selected by TEPL carrier `Mode=2, Function=29` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. Each nonempty valid source column is scanned from
row zero through `ValidRow-1` in increasing order. Values are compared with
the selected DataType's `TMIN` rules. Destination element `[0,c]` is the `U32`
encoding of the winning row index. When multiple elements represent the same
minimum, the lowest row index wins.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. The destination DataType is
always `U32` and is independent of the selected source DataType. Signed,
unsigned, and floating ordering, one-NaN and two-NaN behavior, signaling-NaN
invalid status, canonical NaNs, and signed-zero preference follow `TMIN`.
Selecting a later value because it is the preferred minimum updates the index;
an equal value that does not replace the current minimum preserves the earlier
index.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `1 x source.ValidCol` logical shape, destination
physical `Col=source.Col`, capacity-derived destination rows, and
`PadValueOrByteId` application to U32 destination padding follow PRD-111.
`B.IOR` and `B.IOS` are illegal. Source and destination `B.IOT` bindings use
the same `PE_MASK`; any subset is legal and mask zero is a strict no-op before
reads, allocation, or faults. The source persists. Complete preflight precedes
the source snapshot. Numeric status, U32 indices, padding definedness, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## PRD-113: `TCOLMIN` reduces each valid column with typed minimum

`TCOLMIN` is selected by TEPL carrier `Mode=2, Function=18` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source column, the accumulator is
initialized from source row zero and rows one through `ValidRow-1` are folded
in increasing order with exactly the typed minimum operation defined for
`TMIN`. The final value is written to destination element `[0,c]`. The first
element is evaluated exactly once.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Signed and unsigned ordering and floating
one-NaN, two-NaN, signaling-NaN, canonical-NaN, and signed-zero behavior
follow `TMIN`; mixed-sign zero minimum produces negative zero.

Source dimensions, defaults, row-major layout, complete source definedness,
destination `1 x source.ValidCol` valid shape, destination physical shape,
`PadValueOrByteId` applicability, prohibited `B.IOR`/`B.IOS`, equal and zero
mask rules, source persistence, snapshot behavior, complete preflight,
numeric-status transaction, rollback, and atomic publication follow PRD-111.

## PRD-114: `TCOLPROD` reduces each valid column with typed multiplication

`TCOLPROD` is selected by TEPL carrier `Mode=2, Function=19` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source column, it performs an
increasing-row left fold over rows zero through `ValidRow-1`. The accumulator
begins with the selected DataType's exact multiplicative identity and every
fold step uses exactly the typed multiplication operation defined for `TMUL`;
the final value is written to destination element `[0,c]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Integer multiplication follows the selected
element-width overflow rule. Floating multiplication, intermediate rounding,
exceptional values, and numeric status follow the selected profile at every
fold step.

Source dimensions, defaults, row-major layout, complete source definedness,
destination `1 x source.ValidCol` valid shape, destination physical shape,
`PadValueOrByteId` applicability, prohibited `B.IOR`/`B.IOS`, equal and zero
mask rules, source persistence, snapshot behavior, complete preflight,
numeric-status transaction, rollback, and atomic publication follow PRD-111.

## PRD-133: `TQUANT` is the encoded single-destination affine quantizer

`TQUANT` is selected by TEPL carrier `Mode=3, Function=10` and executes on
the `SFU` engine. The architectural selector has one Local source Tile, one
newly allocated Local destination Tile, and two per-PE scalar inputs. It does
not directly expose parameter Tiles or auxiliary result Tiles. Quantization
interfaces that require row-varying parameters, shared exponents, maxima,
scaling Tiles, or other auxiliary results are compound software lowerings and
do not add operands or results to this selector.

The source DataType is exactly `FP32`. The destination DataType is exactly
`S8` or `U8`. `BSTART` supplies the source DataType and a mandatory `B.DATR`
supplies the destination DataType. Source and destination have the same
nonzero valid shape and use row-major layout. When present, `B.IOR.RegSrc0`
supplies the raw `FP32` quantization multiplier and `B.IOR.RegSrc1` supplies
the zero point in the selected destination integer encoding. `RegSrc2` and
`RegDst` are unused and must select `zero`. Omitting `B.IOR` supplies the
operation defaults multiplier `1.0` and zero point zero. An explicitly encoded
all-zero `B.IOR` instead reads the `zero` register for both inputs and is
illegal because its multiplier is `0.0`. Every nondefault multiplier must be
finite, positive, and nonzero. The zero point must be in `S8` range for an
`S8` destination and in `U8` range for a `U8` destination.

For each valid source element `x`, the unbounded quantized value is
`x * multiplier + zero_point`. `B.DATR.RMode` selects the rounding rule and
defaults to round-to-nearest-even. With `Sat=1`, the rounded value is clamped
to the destination range; with `Sat=0`, conversion uses the selected integer
width's modulo result. Floating exceptional inputs and numeric status follow
the numeric conversion profile before the selected saturation rule.
`Canonicalize` and `PadValueOrByteId` are inapplicable and must be zero.
Elements outside the destination valid region remain Null padding.

`B.IOS` is illegal. Source and destination `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before GPR or
Tile reads, allocation, or faults. The source persists. Complete descriptor,
scalar, type, shape, layout, and capacity preflight precedes the source
snapshot. Numeric status, destination payload, definedness, padding, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## PRD-134: `TDEQUANT` is the encoded single-destination affine dequantizer

`TDEQUANT` is selected by TEPL carrier `Mode=3, Function=11` and executes on
the `SFU` engine. The architectural selector has one Local source Tile, one
newly allocated Local destination Tile, and two per-PE scalar inputs. It does
not directly consume row-varying parameter Tiles. Interfaces that use scale
or zero-point Tiles are compound software lowerings and do not change this
selector's operand arity.

The source DataType is exactly `S8` or `U8`; the destination DataType is
exactly `FP32`. `BSTART` supplies the source DataType and a mandatory
`B.DATR` supplies destination `FP32`. Source and destination have the same
nonzero valid shape and use row-major layout. When present, `B.IOR.RegSrc0`
supplies the raw `FP32` dequantization multiplier and `B.IOR.RegSrc1`
supplies the zero point in the source integer encoding. `RegSrc2` and
`RegDst` are unused and must select `zero`. Omitting `B.IOR` supplies the
operation defaults multiplier `1.0` and zero point zero. An explicitly encoded
all-zero `B.IOR` instead reads the `zero` register and is illegal because its
multiplier is `0.0`. Every nondefault multiplier must be finite, positive, and
nonzero. The zero point must be in the selected source type's range.

For each valid source element `q`, the destination is the `FP32` result of
`(q - zero_point) * multiplier`. `B.DATR.RMode` selects floating rounding and
defaults to round-to-nearest-even. `Sat`, `Canonicalize`, and
`PadValueOrByteId` are inapplicable and must be zero. Numeric status follows
the floating conversion and multiplication profile. Elements outside the
destination valid region remain Null padding.

`B.IOS` is illegal. Source and destination `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before GPR or
Tile reads, allocation, or faults. The source persists. Complete descriptor,
scalar, type, shape, layout, and capacity preflight precedes the source
snapshot. Numeric status, destination payload, definedness, padding, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## PRD-135: `TSORT` stably sorts independent row groups and returns indices

`TSORT` is selected by TEPL carrier `Mode=3, Function=12` and executes on the
`SFU` engine. It reads one Local source Tile and atomically creates two
distinct Local destinations: a value destination with the source DataType and
a `U32` index destination. All three Tiles have the same nonzero valid shape
and use row-major layout.

Each source row is partitioned from column zero into independent consecutive
groups of `sort_width` elements. The final group contains only its remaining
valid elements and never reads padding. Each group is stably sorted by the
selected DataType. The value destination receives the reordered values; the
index destination receives each value's original zero-based column offset
within that group. Equal values preserve source order. `descending=0` sorts
ascending and `descending=1` sorts descending. Numeric values precede NaNs in
both directions; NaNs preserve source order. Signaling-NaN observation sets
the selected numeric invalid status, and signed zeros compare equal so their
source order is preserved.

The exact supported value DataTypes are `FP32` and `FP16`. `B.DATR` is
inapplicable and every field must remain zero. `B.DIM LB0` supplies
`sort_width` in `1..64`; omission and an encoded zero both select the
operation default `32`, while nonzero values outside `1..64` are illegal.
When present, `B.IOR.RegSrc0` supplies `descending` and must contain exactly
zero or one. Omitting `B.IOR` selects ascending order. `RegSrc1`, `RegSrc2`,
and `RegDst` are unused and must select `zero`.

`B.IOS` is illegal. All source and destination `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before reads,
allocation, comparison status, or faults. The source persists. Complete
descriptor, control, type, shape, layout, capacity, distinct-destination, and
definedness preflight precedes the source snapshot. Both destination payloads,
definedness, Null padding, numeric status, and descriptors publish as one
atomic transaction; rejection has no architectural effect.

## PRD-136: `TMRGSORT` stably merges two single-row sorted value streams

`TMRGSORT` is selected by TEPL carrier `Mode=3, Function=13` and executes on
the `SFU` engine. The architectural selector reads exactly two Local source
Tiles and creates one newly allocated Local destination. Interfaces that merge
three or four lists, merge packed records, return per-list consumption counts,
use temporary Tiles, stop on exhaustion, or merge four blocks from one Tile
are compound software lowerings and do not add operands or results to this
selector.

Each source is a nonempty single-row, row-major, already-sorted value stream.
The destination is single-row and row-major, with `ValidCol` equal to the sum
of both source `ValidCol` values. Source and destination share one DataType.
The exact supported DataTypes are `FP32` and `FP16`. `descending=0` requires
ascending sources and produces an ascending merge; `descending=1` requires
descending sources and produces a descending merge. If either source stream
is not sorted in the selected order, the complete block is illegal before any
architectural effect.

Equal values select the left source first. Numeric values precede NaNs in both
directions; NaNs preserve their source order and left-source precedence.
Signaling-NaN observation sets numeric invalid status, and signed zeros compare
equal. Both sources persist.

`B.DATR` is inapplicable and every field must remain zero. When present,
`B.IOR.RegSrc0` supplies `descending` and must contain exactly zero or one.
Omitting `B.IOR` selects ascending order. `RegSrc1`, `RegSrc2`, and `RegDst`
are unused and must select `zero`. `B.IOS` is illegal. All source and
destination `B.IOT` bindings use the same `PE_MASK`; any subset is legal and
mask zero is a strict no-op before source reads, sortedness checks, allocation,
numeric status, or faults.

Complete descriptor, control, type, shape, layout, capacity, definedness, and
input-order preflight precedes source snapshots. Destination payload,
definedness, Null padding, numeric status, and descriptor publish atomically;
rejection has no architectural effect.

## PRD-137: `TTRANS` is a logical two-dimensional transpose

`TTRANS` is selected by TEPL carrier `Mode=3, Function=14` and executes on
the `SFU` engine. It reads one Local source Tile and creates one newly
allocated Local destination. For every source valid coordinate `[r,c]`, the
destination coordinate `[c,r]` receives the same logical element bit-for-bit.
The destination therefore has `ValidRow=source.ValidCol` and
`ValidCol=source.ValidRow`. The complete valid source rectangle must be
defined. The source persists.

Required nonzero `B.DIM LB0` supplies destination `ValidCol`; omitted `LB1`
supplies destination `ValidRow=1`; omitted `LB2` supplies destination physical
`Col=ValidCol`; physical rows derive from destination capacity, physical
columns, and DataType. The resulting destination dimensions must equal the
transposed source dimensions before effects. Source and destination use the
same DataType. Every assigned Tile DataType except `HiF4X2` is supported;
globally reserved encodings and `HiF4X2` reject before effects.

The source is addressed through its architectural layout. An assigned
`B.DATR.Layout` transformation governs destination physical placement without
changing the logical transpose. Every reserved Layout code rejects before
effects. `DataType`, `PadValueOrByteId`, `CMode`, `RMode`, `Sat`, and
`Canonicalize` are inapplicable and must remain at their operation-default
values. Physical destination elements outside the transposed valid rectangle
remain Null padding.

`TTRANS` has no architectural temporary-Tile operand and does not define a
separate convolution-layout conversion. A backend scratch Tile or a compound
format-conversion interface is a lowering detail and does not change the
selector's one-source, one-destination schema. `B.IOR` and `B.IOS` are
illegal. Source and destination `B.IOT` bindings use the same `PE_MASK`; any
subset is legal and mask zero is a strict no-op before reads, allocation, or
faults.

Complete schema, descriptor, type, dimension, layout, capacity, allocation,
mask, and source-definedness preflight precedes the source snapshot.
Destination payload, definedness, Null padding, and descriptor publish
atomically; rejection has no architectural effect.

## PRD-139: `TSCATTER` uses each index as a destination-row selector

`TSCATTER` is selected by TEPL carrier `Mode=3, Function=16` and executes on
the `SFU` engine. It reads one Local value source and one Local index source,
then creates one newly allocated Local destination. The two sources have the
same nonzero valid shape. The destination has the same `ValidCol` and a
nonzero `ValidRow` large enough for every selected row. For every source
coordinate `[r,c]`, the selected index value `k=index[r,c]` names a logical
destination row and the operation writes `destination[k,c]=source[r,c]`.

The index Tile DataType and value DataType pair is restricted by element
width. `FP32`, `S32`, and `U32` values use `S32` or `U32` indices. `FP16`,
`BF16`, `S16`, and `U16` values use `S16` or `U16` indices. `S8` and `U8`
values also use `S16` or `U16` indices. A signed index must be nonnegative,
and every index must be less than `destination.ValidRow`. Two source elements
must not select the same destination coordinate; duplicate destinations make
the complete block illegal before effects.

Required nonzero `B.DIM LB0` supplies destination `ValidCol`; omitted `LB1`
supplies `ValidRow=1`; omitted `LB2` supplies destination physical
`Col=ValidCol`; physical rows derive from capacity. `destination.ValidCol`
must equal both source `ValidCol` values, while both sources have equal
`ValidRow`. The complete valid rectangles of both sources must be defined.

An assigned `B.DATR.Layout` transformation governs destination physical
placement without changing row-index semantics. `DataType`, `CMode`, `RMode`,
`Sat`, and `Canonicalize` are inapplicable. `PadValueOrByteId` is fixed to
encoded zero for this operation: before applying the scatter writes, every
physical destination element is initialized to the selected value DataType's
positive or integer zero. Thus valid positions not selected by an index and
physical padding are defined zero rather than preserved old contents.

`B.IOR` and `B.IOS` are illegal. All three `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before Tile
reads, index and duplicate checks, allocation, or faults. Both sources
persist. The destination is a renamed result and never reads a previous
destination value.

Complete schema, descriptor, type-pair, shape, layout, capacity, index-range,
duplicate-destination, definedness, mask, and allocation preflight precedes
source snapshots. Zero initialization, scattered payload, definedness, and
destination descriptor publish atomically; rejection has no architectural
effect.

## PRD-138: `TGATHER` uses each index as a source-row selector

`TGATHER` is selected by TEPL carrier `Mode=3, Function=15` and executes on
the `SFU` engine. It reads one Local value source and one Local index source,
then creates one newly allocated Local destination. The index source and
destination have the same nonzero valid shape. The value source has at least
the destination `ValidCol` columns. For every destination coordinate `[r,c]`,
the selected index value `k=index[r,c]` names a logical source row and the
result is `destination[r,c]=source[k,c]`.

The index Tile DataType is exactly `S32` or `U32`. A signed index must be
nonnegative, and every index must be less than `source.ValidRow`. An invalid
index makes the complete block illegal before source reads or destination
effects; indices never wrap, clamp, or produce an implementation-defined
value. The complete index valid rectangle and every selected value-source
element must be defined.

The exact value DataTypes are `FP32`, `FP16`, `S32`, `S16`, `U32`, and
`U16`. Source and destination use the same value DataType. Required nonzero
`B.DIM LB0` supplies destination `ValidCol`; omitted `LB1` supplies
`ValidRow=1`; omitted `LB2` supplies destination physical `Col=ValidCol`;
physical rows derive from capacity. The dimensions must match the index Tile
and fit the source column extent before effects.

An assigned `B.DATR.Layout` transformation governs destination physical
placement without changing row-index semantics. `DataType`,
`PadValueOrByteId`, `CMode`, `RMode`, `Sat`, and `Canonicalize` are
inapplicable and must remain at their operation-default values. Destination
physical elements outside the valid rectangle remain Null padding.

The selector has no architectural mask-pattern or temporary-Tile operand.
Mask-pattern gather and scratch-Tile interfaces are compound lowerings and do
not change the encoded three-Tile schema. `B.IOR` and `B.IOS` are illegal.
All three `B.IOT` bindings use the same `PE_MASK`; any subset is legal and
mask zero is a strict no-op before Tile reads, index checks, allocation, or
faults. Both sources persist.

Complete schema, descriptor, type, shape, layout, capacity, index-range,
definedness, mask, and allocation preflight precedes source snapshots.
Destination payload, definedness, Null padding, and descriptor publish
atomically; rejection has no architectural effect.

## PRD-140: `TPARTADD` combines two origin-anchored partial rectangles

`TPARTADD` is selected by TEPL carrier `Mode=3, Function=17` and executes on
the `SFU` engine. It reads two Local sources and creates one newly allocated
Local destination. All three Tiles use one DataType and row-major layout. Each
source valid rectangle is anchored at logical coordinate `[0,0]` and must fit
within the destination valid rectangle. At least one source valid rectangle
must equal the complete destination valid rectangle, so every destination
coordinate is covered by at least one source.

For each destination valid coordinate, if both sources cover that coordinate,
the result is their selected-DataType addition. If exactly one source covers
the coordinate, that source element is copied bit-for-bit. No coordinate may
be uncovered. Integer addition wraps modulo the selected element width;
floating addition, rounding, exceptional values, and numeric status follow the
same typed rules as `TADD`.

The exact supported DataTypes are `FP32`, `FP16`, `BF16`, `S32`, `S16`,
`S8`, `U32`, `U16`, and `U8`. Required nonzero `B.DIM LB0` supplies
destination `ValidCol`; omitted `LB1` supplies `ValidRow=1`; omitted `LB2`
supplies physical `Col=ValidCol`; physical rows derive from capacity. Source
physical shapes may differ, but their row-major descriptors and complete valid
rectangles must be legal and defined.

`B.DATR`, `B.IOR`, and `B.IOS` are illegal. Destination physical elements
outside its valid rectangle remain Null padding. All three `B.IOT` bindings
use the same `PE_MASK`; any subset is legal and mask zero is a strict no-op
before reads, allocation, numeric status, or faults. Both sources persist and
may alias each other or the destination because source payloads are
snapshotted before any result write.

Complete schema, descriptor, type, shape, coverage, capacity, definedness,
mask, and allocation preflight precedes source snapshots. Destination payload,
definedness, Null padding, numeric status, and descriptor publish atomically;
rejection has no architectural effect.

## PRD-148: `HL.PRF` assigns three cache-hint models

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

## PRD-149: `ACRE` is an implicit SYS-block stop

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

## PRD-147: `HL.MADDW` returns two sign-extended word halves

`HL.MADDW` reads the low 32 bits of `SrcL`, `SrcR`, and `SrcD` and interprets
each as a signed two's-complement value. It computes the signed 64-bit result
`signed32(SrcL) * signed32(SrcR) + signed32(SrcD)` modulo 2^64.

`RegDst0` receives the sign extension to `PTO_XLEN` of result bits `31:0`.
`RegDst1` receives the sign extension to `PTO_XLEN` of result bits `63:32`.
All three source values MUST be snapshotted before either destination is
written. Destination writes occur in `RegDst0` then `RegDst1` order and follow
the ordinary Reg5 destination-alias semantics.

## PRD-146: `HL.LUI` places its immediate in the upper 32 bits

`HL.LUI` reconstructs the encoded 32-bit immediate and writes it to result
bits `63:32`. Result bits `31:0` are zero. Equivalently, the materialized
value is `ZeroExtend64(imm32) << 32`.

The immediate is not sign-extended and is not shifted by twelve bits. Encoded
zero materializes zero. This upper-half operation is distinct from `HL.LIS`,
which sign-extends its encoded 32-bit immediate without shifting it.

## PRD-145: indexed TLSU transfers reject packed four-bit data types

`MGATHER`, `MGATHER.MASK`, `MGATHER.CAS`, `MSCATTER`, and
`MSCATTER.MASK` use byte displacements and do not encode an independent
low-versus-high-nibble selector. Their transferred data type MUST therefore
not be `E2M1X2`, `E1M2X2`, `HiF4X2`, `S4X2`, or `U4X2`. Selecting any of
those packed four-bit transfer types MUST raise Illegal Block Exception before
address checks, memory effects, destination allocation, source lifetime
effects, or memory events.

This restriction applies only to the transferred data. An IndexTile MAY still
use `S4X2` or `U4X2`: each logical IndexTile element is independently sign- or
zero-extended from four bits and denotes one byte displacement under PRD-043
and PRD-046.

## PRD-144: an unallocated Shared `TSTORE` source derives minimum capacity

When `TSTORE` or `TSTORE.SPART` reads a completely unallocated Shared register,
the source-form `B.IOS` supplies no `TSize`. The operation MUST therefore derive
the smallest legal per-PE Tile capacity from 128 B through 8 KiB that can
represent the completed `ValidRow`, `ValidCol`, physical `Col`, and `DataType`
schema. Physical Rows are derived from that capacity, `Col`, and `DataType`.

If no legal capacity represents the schema, the block raises Illegal Block
Exception before reading GPRs or writing memory. Otherwise every selected
source element has the ordinary undefined-register value. The temporary
descriptor is read-only and MUST NOT allocate, initialize, or otherwise modify
the Shared register.

## PRD-142: `TPARTMAX` combines two origin-anchored partial rectangles

`TPARTMAX` is selected by TEPL carrier `Mode=3, Function=19` and executes on
the `SFU` engine. It reads two Local sources and creates one newly allocated
Local destination. All three Tiles use one DataType and row-major layout. Each
source valid rectangle is anchored at logical coordinate `[0,0]` and must fit
within the destination valid rectangle. At least one source valid rectangle
must equal the complete destination valid rectangle, so every destination
coordinate is covered by at least one source.

For each destination valid coordinate, if both sources cover that coordinate,
the result is their selected-DataType maximum. If exactly one source covers the
coordinate, that source element is copied bit-for-bit. No coordinate may be
uncovered. Signed integers use signed ordering and unsigned integers use
unsigned ordering. Floating one-NaN, two-NaN, signaling-NaN, canonical-NaN,
and signed-zero behavior follows `TMAX` exactly; a mixed-sign zero maximum is
positive zero.

The exact supported DataTypes are `FP32`, `FP16`, `BF16`, `S32`, `S16`,
`S8`, `U32`, `U16`, and `U8`. Required nonzero `B.DIM LB0` supplies
destination `ValidCol`; omitted `LB1` supplies `ValidRow=1`; omitted `LB2`
supplies physical `Col=ValidCol`; physical rows derive from capacity. Source
physical shapes may differ, but their row-major descriptors and complete valid
rectangles must be legal and defined.

`B.DATR`, `B.IOR`, and `B.IOS` are illegal. Destination physical elements
outside its valid rectangle remain Null padding. All three `B.IOT` bindings
use the same `PE_MASK`; any subset is legal and mask zero is a strict no-op
before reads, allocation, numeric status, or faults. Both sources persist and
may alias each other or the destination because source payloads are
snapshotted before any result write.

Complete schema, descriptor, type, shape, coverage, capacity, source-encoding,
definedness, mask, and allocation preflight precedes source snapshots.
Destination payload, definedness, Null padding, numeric status, and descriptor
publish atomically; rejection has no architectural effect.

## PRD-143: `TPARTMIN` combines two origin-anchored partial rectangles

`TPARTMIN` is selected by TEPL carrier `Mode=3, Function=20` and executes on
the `SFU` engine. It reads two Local sources and creates one newly allocated
Local destination. All three Tiles use one DataType and row-major layout. Each
source valid rectangle is anchored at logical coordinate `[0,0]` and must fit
within the destination valid rectangle. At least one source valid rectangle
must equal the complete destination valid rectangle, so every destination
coordinate is covered by at least one source.

For each destination valid coordinate, if both sources cover that coordinate,
the result is their selected-DataType minimum. If exactly one source covers the
coordinate, that source element is copied bit-for-bit. No coordinate may be
uncovered. Signed integers use signed ordering and unsigned integers use
unsigned ordering. Floating one-NaN, two-NaN, signaling-NaN, canonical-NaN,
and signed-zero behavior follows `TMIN` exactly; a mixed-sign zero minimum is
negative zero.

The exact supported DataTypes are `FP32`, `FP16`, `BF16`, `S32`, `S16`,
`S8`, `U32`, `U16`, and `U8`. Required nonzero `B.DIM LB0` supplies
destination `ValidCol`; omitted `LB1` supplies `ValidRow=1`; omitted `LB2`
supplies physical `Col=ValidCol`; physical rows derive from capacity. Source
physical shapes may differ, but their row-major descriptors and complete valid
rectangles must be legal and defined.

`B.DATR`, `B.IOR`, and `B.IOS` are illegal. Destination physical elements
outside its valid rectangle remain Null padding. All three `B.IOT` bindings
use the same `PE_MASK`; any subset is legal and mask zero is a strict no-op
before reads, allocation, numeric status, or faults. Both sources persist and
may alias each other or the destination because source payloads are
snapshotted before any result write.

Complete schema, descriptor, type, shape, coverage, capacity, source-encoding,
definedness, mask, and allocation preflight precedes source snapshots.
Destination payload, definedness, Null padding, numeric status, and descriptor
publish atomically; rejection has no architectural effect.

## PRD-141: `TPARTMUL` combines two origin-anchored partial rectangles

`TPARTMUL` is selected by TEPL carrier `Mode=3, Function=18` and executes on
the `SFU` engine. It reads two Local sources and creates one newly allocated
Local destination. All three Tiles use one DataType and row-major layout. Each
source valid rectangle is anchored at logical coordinate `[0,0]` and must fit
within the destination valid rectangle. At least one source valid rectangle
must equal the complete destination valid rectangle, so every destination
coordinate is covered by at least one source.

For each destination valid coordinate, if both sources cover that coordinate,
the result is their selected-DataType multiplication. If exactly one source
covers the coordinate, that source element is copied bit-for-bit. No
coordinate may be uncovered. Integer multiplication wraps modulo the selected
element width; floating multiplication, rounding, exceptional values, signed
zeros, and numeric status follow the same typed rules as `TMUL`.

The exact supported DataTypes are `FP32`, `FP16`, `BF16`, `S32`, `S16`,
`S8`, `U32`, `U16`, and `U8`. Required nonzero `B.DIM LB0` supplies
destination `ValidCol`; omitted `LB1` supplies `ValidRow=1`; omitted `LB2`
supplies physical `Col=ValidCol`; physical rows derive from capacity. Source
physical shapes may differ, but their row-major descriptors and complete valid
rectangles must be legal and defined.

`B.DATR`, `B.IOR`, and `B.IOS` are illegal. Destination physical elements
outside its valid rectangle remain Null padding. All three `B.IOT` bindings
use the same `PE_MASK`; any subset is legal and mask zero is a strict no-op
before reads, allocation, numeric status, or faults. Both sources persist and
may alias each other or the destination because source payloads are
snapshotted before any result write.

Complete schema, descriptor, type, shape, coverage, capacity, definedness,
mask, and allocation preflight precedes source snapshots. Destination payload,
definedness, Null padding, numeric status, and descriptor publish atomically;
rejection has no architectural effect.

## PRD-150: software-breakpoint immediates are trap-cause payloads

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

## PRD-151: frame-template instructions are part of PTO

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

## PRD-152: `MCOPY` is a non-overlapping restartable memory template

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

## PRD-153: General Queue Management is part of PTO

General Queue Management is formal PTO architecture. Its three canonical
mnemonics are `HL.QMT`, `HL.QPUSH`, and `HL.QPOP`. These spellings are retained
without aliases to `HL.PUSH` or `HL.POP`.

The three occupied 48-bit encoding families are executable PTO instruction
families rather than externally reserved space. Their complete legality,
queue-state, result, notification, ordering, exception, and restart contracts
MUST be defined in PTO ASL. The earlier PTO profile rule that rejected these
handlers before effects is superseded for these three mnemonics.

## PRD-154: `HL.QMT` flag, capacity, and result contract

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

## PRD-155: GQM operands use the common absolute-or-relative selector domain

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

## PRD-156: `HL.QMT` initialization and missing-queue behavior

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

## PRD-157: `HL.QPOP` removes the unused encoded source

`HL.QPOP` admits the bare form and suffixes `.e`, `.r`, and `.er`. Encoded
bits `[40:36]` are not a source-register field. They are reserved-zero and
MUST be zero; a nonzero value raises Illegal Instruction before reading
`SrcL`, observing or changing a queue, broadcasting an event, or writing
either destination.

The instruction has exactly one source selector, `SrcL`, and two destination
selectors, `RegDst0` and `RegDst1`. All three selectors use the absolute-or-
relative domain defined for GQM operands. No implementation may read a hidden
or placeholder `SrcR` value.

## PRD-158: `HL.QPOP` is an atomic acquire-capable queue pop

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

## PRD-159: `HL.QPUSH` is an atomic release-capable queue push

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

## PRD-160: `ADDTPC` uses a signed page-scaled immediate

`ADDTPC` computes `TPC + (SignExtend(imm20) << 12)` and writes the wrapping
XLEN result to its selected scalar destination. Encoded immediate zero denotes
the current instruction TPC. The instruction is the high-part PC-relative
address materialization operation and may be paired with a low 12-bit add.

## PRD-161: conditional branch forms are reserved in PTO

`B.EQ`, `B.NE`, `B.LT`, `B.GE`, `B.LTU`, `B.GEU`, `B.Z`, and `B.NZ` are not
active PTO instructions. Their complete encoding forms are reserved for the
two-level block-body architecture and MUST remain unavailable to PTO
instructions or aliases.

A PTO decoder MUST reject every one of these reserved forms before reading an
operand or changing architectural, pending-block, queue, memory, descriptor,
trap, or control-flow state. PTO assemblers MUST reject these spellings, and a
canonical PTO disassembler MUST NOT emit them. The reservation may be revised
only by a later architecture decision that assigns an explicit PTO contract.

## PRD-162: `C.SETC.TGT` snapshots its target into `BARG.BPCN`

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

## PRD-163: `C.SETC.TGT` is unique within one block

At most one `C.SETC.TGT` may execute in a block. If the active block already
contains a successful `C.SETC.TGT`, a second occurrence MUST raise Illegal
Block Exception before reading its source or changing `BARG.BPCN`, TPC,
queue state, or any other architectural or pending-block state.

The uniqueness state is private to the active block. It is initialized clear
when the block begins, set only after a successful `C.SETC.TGT` target
snapshot, and cleared with the rest of the retiring block state after a
successful commit. A failed first occurrence does not consume the block's
single permitted occurrence.

## PRD-164: `HL.ADDTPC` uses a signed page-scaled immediate

`HL.ADDTPC` computes `TPC + (SignExtend(imm32) << 12)` and writes the
wrapping XLEN result to its selected scalar destination. Encoded immediate
zero denotes the current instruction TPC. The instruction is the extended
high-part PC-relative address materialization operation and may be paired with
a low 12-bit add.

## PRD-165: one `SETC.*` condition setter resolves an active conditional block

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

## PRD-166: `LSRGET` reads the active block's BARG word view

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

## PRD-167: `SCVTF` assigns four integer sources and four floating destinations

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

## PRD-168: `C.SSRGET` uses direct low system-register addresses

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

## PRD-169: `PRF` is a non-faulting address hint with an ignored encoded destination field

`PRF [SrcL, SrcR<modifier><<shamt>]` snapshots its two scalar sources and
forms `EA = SrcL + (Modify(SrcR, SrcRType) << shamt)` modulo XLEN. `SrcL` and
`SrcR` use the complete Reg5 source namespace. `SrcRType=0` leaves the
full-width right source unchanged, `1` sign-extends its low 32 bits, `2`
zero-extends its low 32 bits, and `3` performs full-width two's-complement
negation. Every five-bit shift value from 0 through 31 is assigned.

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

## PRD-170: `PRFI.U` is an unscaled immediate non-faulting hint with an ignored encoded destination field

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

## PRD-171: the reviewed common encoded-form envelope contains 548 forms

The closed PTO common encoded-form envelope contains exactly 474 scalar forms
and 74 block forms. `BSTART.ICALL` and `L.BSTOP` are active additions.
Two-level-only `B.TEXT`, MPAR/MSEQ, Fixup, and long or high-long BSTART forms
are not active PTO instructions; their complete encodings remain owned by the
extension-reservation catalog and MUST NOT be reassigned to another PTO
mnemonic.

The active forms incorporate the accepted field-domain and canonical-assembly
repairs for `B.DIM`, `B.FPATR`, the common BSTART family, `C.SETRET`,
`FENTRY`/`FEXIT`/`FRET.*`, `HL.QMT`/`HL.QPUSH`/`HL.QPOP`, `MCOPY`, and `MSET`.
They also bind `HL.PRF`, `HL.PRF.A`, `HL.PRFI.U`, and `HL.PRFI.UA` to the
three assigned cache-hint models from PRD-148. These repairs change decoded
legality or canonical spelling without assigning an unreviewed opcode. The
projection also carries ADR 0028's FSU domains directly: every scalar FSU
form assigns `SrcType` values 0 and 1 and reserves 2 and 3, while conversion
forms assign `DstType` values 0 through 14 and reserve 15 through 31.

The canonical projection of each form's ID, mnemonic, assembly, instruction
length, encoding kind, fixed encoding, fields, and constraints has SHA-256
fingerprint
`d7ea59cc80d4165d106ecc6b9b2cd2ec07c78a833c592988958f1fdc2546592c`.
Any later change to that projection MUST be accompanied by a new architecture
decision before the binary-closure gate is updated.

## PRD-172: scalar SYS placement, local BARG reads, and fault ordering are explicit

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
