# ADR 0045: Define the PTO ISA 0.57.1 tile and bundle contract

- Status: accepted
- Decision date: 2026-07-30
- Approval: [formal-model issue 18](https://github.com/PTO-ISA/pto-spec/issues/18)
- Requirements: PTO-REQ-ENCODING-001, PTO-REQ-BUNDLE-STATE-001,
  PTO-REQ-BUNDLE-DISPATCH-001, PTO-REQ-BUNDLE-OPERATION-001,
  PTO-REQ-TILE-001, PTO-REQ-TILE-LEGALITY-001, PTO-REQ-TEPL-001,
  PTO-REQ-TLSU-001, PTO-REQ-CUBE-001, PTO-REQ-MEMORY-COMPLETION-001,
  PTO-REQ-MEMORY-TSO-001, PTO-REQ-RELEASE-ISA-001,
  PTO-REQ-HARDWARE-NUMERIC-001

## Context

The M4 model closes PTO reference semantics for 474 scalar forms, 99
bundle/command forms, and 120 direct tile operations. Release 0.57.1 adds the
public encoding identity and exact bundle attributes needed by independent
producers and consumers. It also fixes the architectural boundary for tile
allocation, source lifetime, accumulator state, and the named hardware numeric
contract.

This decision does not promote the repository beyond M4. Target numeric
conformance remains open under `S5-T2`; immutable release-candidate evidence and
review remain open under Stage 6.

## Decision

### Release and profile identities

The architecture release identity is **PTO ISA 0.57.1**. The active executable
reference profile remains `pto-v0`. Release identity, encoding ABI, and profile
identity are separate machine-readable fields.

Release 0.57.1 is an encoding-ABI break. There is no untagged legacy decoder.
Objects and images identify both the release and the canonical encoding-manifest
hash. Linkers reject mixed or missing identities; loaders reject an absent or
mismatched identity.

The accepted command inventory is 99 forms. The six legacy `B.ARG` forms and
the generic `BSTART.CUBE` and `BSTART.FIXP` forms are not 0.57.1 decode
identities; named Mode/Function starts and explicit bundle attributes replace
those ambiguous surfaces.

ELF objects and images carry the identity in `.note.pto.isa`. The four-byte note
name is `PTO\0`; the owner-local numeric value of `PTO_NT_ISA_IDENTITY` is 1.
Header fields, name, and descriptor use four-byte alignment. The descriptor is
the canonical UTF-8 JSON object named by the release manifest, without a
trailing NUL.

### Terminology and accepted surface

Bundle is the architecture term for grouped execution. `BSTART`, `BSTOP`,
`C.BSTART`, `C.BSTOP`, `B.*`, and BPC retain their encoded spellings. Separately,
`BLOCKNUM`, `BLOCKID`, and `CROSS_BID` identify virtual core blocks.

Release 0.57.1 contains 474 scalar forms, 99 bundle/command forms, and exactly
120 direct tile operations: 98 TEPL, 9 TMA, and 13 CUBE. Vector-only forms
remain outside PTO.

### TEPL Mode/Function encoding

A 32-bit TEPL bundle start encodes:

```text
DataType[31:27] | Mode[26:25] | Function[24:20] |
00011[19:15] | Func=001[14:12] | 00011[11:7] |
Opc1=000[6:4] | Opcode=000[3:1] | W=1[0]
```

The logical selector is `(Mode << 5) | Function`.

| Mode | Accepted functions | Reserved functions |
| ---: | --- | --- |
| 0 | 0–4, 6–23, 26–27 | 5, 24–25, 28–31 |
| 1 | 0–4, 6–13, 15, 26–27 | 5, 14, 16–25, 28–31 |
| 2 | 0–13, 16–29 | 14–15, 30–31 |
| 3 | 0–8, 10–29 | 9, 30–31 |

The raw command decoder resolves Mode and Function to one cataloged operation
before bundle execution. It cannot fall back to the pre-0.57.1 ten-bit layout.
`TTRANS` and `TSORT` are canonical names; migration-only aliases never become
decode identities.

### B.IOT allocation and lifetime

`B.IOT` encodes `SrcTile1[31:26]`, `SrcTile0[25:20]`, `L[19]`,
`imm4[18:15]`, `Func[14:12]`, `S1R[11]`, `S0R[10]`, and
`DstTile[9:7]`, followed by `Opc1=001`, `Opcode=001`, and `W=1`.

`Func=4`, `5`, and `6` select two, one, and zero active sources. Active ordinary
destinations select the T, U, M, or N hand with `DstTile=0..3`. Values 4..6 are
reserved and 7 is illegal. Destination-free operations zero destination and
size fields and allocate no tile.

Architectural CELL size is 128 bytes. Active destination size codes 3..9
allocate 128 bytes, 256 bytes, 512 bytes, 1 KiB, 2 KiB, 4 KiB, or 8 KiB.
Aggregate allocation cannot exceed the read-only `TILE_CAPACITY` system
register. Allocation failure is precise: it neither evicts live state nor
partially claims a destination.

A newly allocated or reconfigured tile has undefined element contents. Each
element write defines only that element; whole-region consumers require every
element of the valid region to be defined. This rule is independent of the
allocation size code.

The `S0R` and `S1R` reuse bits control source lifetime. Zero releases the source
only after successful bundle commit; one preserves it. Rejection, fault, retry,
and squash preserve every source and the destination-allocation state.

### B.DATR and layout

`B.DATR` encodes `CMode[31:29]`, `PadValueOrByteId[28:27]`, `Sat[26]`,
`Canonicalize[25]`, `DataType[24:20]`, zero bits 19:18, `RMode[17:15]`,
`Func=001[14:12]`, `Layout[11:7]`, `Opc1=010`, `Opcode=001`, and `W=1`.

Compare modes EQ, NE, LT, GT, LE, and GE use values 0..5; 6 and 7 are reserved.
Round modes NONE, RNE, RTZ, RDN, RUP, RNA, RTO, and RHB use values 0..7.
`PadValueOrByteId` means Zero, Max, Min, or Null for ordinary padding, and byte
ID 0..3 for `THISTOGRAM`. Every inapplicable attribute must be zero.

NORM is mandatory. Accepted non-NORM layouts require a named implementation
capability. Generic row/column indexing rejects an implementation-defined
layout, and an unsupported accepted layout rejects before effects; neither path
silently interprets the tile as NORM.

### B.CATR and ordering

`B.CATR` encodes `DR[26]`, `trap[19]`, `far[18]`, `atom[17]`, `aq[16]`, and
`rl[15]`; other dynamic high fields are zero. Its fixed tail is `Func=000`,
`Opc1=010`, `Opcode=001`, and `W=1`.

The `aq` and `rl` bits select relaxed, acquire, release, or acquire-release
ordering for bundle-launched tile memory effects. `atom` requests the cataloged
atomic behavior. Dependency metadata remains scheduling metadata and never
creates a PTO-TSO fence.

### TMA completion

TMA address, data, stride, and dimension fields come from the cataloged bundle
descriptor. `TPREFETCH` performs translation, permission, and footprint
preflight and restarts by full reissue. An inactive mask lane performs no source
or memory read, no destination or memory write, and no fault check.

Every multi-access operation preflights its ordered access set. The first
failing original address is reported and no memory, tile, queue, accumulator,
or source-lifetime effect commits.

### Implicit ACC state

ACC is architectural state and has no B.IOT source or destination code. Ordinary
and BIAS MATMUL/GEMV/MX functions initialize and write ACC. `.ACC` functions
read and update ACC. `ACCCVT` reads ACC, publishes an ordinary tile, and releases
ACC only after successful commit.

ACC records its logical data type separately from its physical accumulation
type. Fault, rejection, retry, and squash preserve the pre-attempt ACC value.
Trap-context save and recovery include ACC.

### Named hardware numeric contract

`pto-hardware-numeric-0.57.1-ieee-v1` names the 0.57.1 hardware numeric contract.
Its machine-readable record fixes low-precision format identities, packed-lane
order, canonical NaNs, signed zero, invalid integer results, RHB tie behavior,
matrix operand classes, physical ACC classes, and MX scale shape and order.

The repository defines this contract and its boundary-vector schema; it does
not claim that hardware, RTL, an emulator, or the `pto-v0` raw-carrier model
conforms to it. Independent oracle results, implementation parity, and accepted
review evidence remain required by `S5-T2`. Release-candidate evidence remains
required by Stage 6.

## Consequences

- Catalog, ASL, assembler, linker, loader, emulator, RTL, and model projections
  must use the 0.57.1 identity or reject the input.
- Every accepted Mode/Function and bundle form needs positive decode evidence;
  every reserved or illegal value needs rejection evidence.
- Allocation, DATR/CATR, ACC, lifetime, fault, and restart rules require
  executable state-transition tests.
- A release manifest may describe the draft contract, but its content hashes
  become candidate evidence only after regeneration from one immutable,
  post-`S5-T2` commit.

## Rejected alternatives

- An untagged dual decoder can execute a valid word under the wrong ABI.
- Treating source reuse, dependency metadata, or `TPREFETCH` as ignorable hints
  changes visible lifetime, ordering, or fault behavior.
- Encoding ACC as an ordinary tile conflates accumulator lifetime and physical
  accumulation type with the flat tile register file.
- Silently mapping an unsupported or implementation-defined layout to NORM
  hides a required legality boundary.
