# ADR-0009: Define the PTO ISA 0.57.1 tile encoding and execution contract

- Status: accepted
- Decision date: 2026-07-30
- Requirements: PTO-REQ-ENCODING-001, PTO-REQ-BLOCK-STATE-001,
  PTO-REQ-BLOCK-DISPATCH-001, PTO-REQ-TILE-001, PTO-REQ-TILE-LEGALITY-001,
  PTO-REQ-TEPL-001, PTO-REQ-TMA-001, PTO-REQ-CUBE-001,
  PTO-REQ-MEMORY-COMPLETION-001, PTO-REQ-MEMORY-TSO-001,
  PTO-REQ-RELEASE-ISA-001

## Context

PTO v0 already defines 98 TEPL, 9 TMA, and 13 CUBE direct operations, but the
existing ten-bit TEPL selector and block-attribute encodings do not provide the
field structure selected for the PTO ISA 0.57.1 release. Reusing the same raw
word under both layouts is unsafe: some words select different accepted
operations. Decoder priority cannot recover the producer's intended encoding.

The release also needs one portable contract for Tile capacity and lifetime,
implicit accumulator state, layout capabilities, masked access, multi-access
fault completion, numeric conformance, and object-level encoding identity.

## Decision

### Release identity and compatibility

The architecture release identity is **PTO ISA 0.57.1**. The active profile ID
remains `pto-v0`; release identity and profile identity are separate fields.

PTO ISA 0.57.1 is an encoding-ABI break. It has no untagged legacy decoder.
Objects and executables identify both the PTO release and the canonical
encoding-manifest hash. A linker rejects mixed or mismatched identities. A
loader rejects an absent or mismatched identity. A bare-metal image provides
the same identity in its platform manifest.

ELF objects and images carry that identity in `.note.pto.isa`. The note owner
is the four-byte name `PTO\0`; `PTO_NT_ISA_IDENTITY` has owner-local numeric
type `1`. Header fields, name, and descriptor are aligned to four bytes. The
descriptor is the canonical UTF-8 JSON object named by the release manifest,
without a trailing NUL byte. These wire details are normative so independent
producers, linkers, and loaders cannot choose incompatible note encodings.

### Direct-operation inventory

PTO ISA 0.57.1 contains exactly 120 base direct operations and no optional
direct operation: 98 TEPL, 9 TMA, and 13 CUBE.

The TEPL names `TFMA`, `TFMOD`, `TFMODS`, `TADDC`, `TSUBC`, `TADDSC`,
`TSUBSC`, `TLRELU`, and `TRANDOM` are rejected. Their selected Mode/Function
positions are reserved and do not name aliases or review-only executable
operations.

`TTRANS` and `TSORT` are canonical identities. `TTRANSPOSE` and `TSORT32` may
be accepted only by source migration tooling and never appear as canonical
decode identities. TMA function 8 is `MGATHER.CAS`. All thirteen cataloged
CUBE functions are base operations.

### TEPL encoding

The 32-bit TEPL block start encodes:

```text
DataType[31:27] | Mode[26:25] | Function[24:20] |
00011[19:15] | Func=001[14:12] | 00011[11:7] |
Opc1=000[6:4] | Opcode=000[3:1] | W=1[0]
```

The logical selector is `(Mode << 5) | Function`. The accepted Function sets
are:

| Mode | Accepted | Reserved |
| ---: | --- | --- |
| 0 | 0-4, 6-23, 26-27 | 5, 24-25, 28-31 |
| 1 | 0-4, 6-13, 15, 26-27 | 5, 14, 16-25, 28-31 |
| 2 | 0-13, 16-29 | 14-15, 30-31 |
| 3 | 0-8, 10-29 | 9, 30-31 |

Mode 3 functions 21 through 29 are, in order, `TPARTARGMAX`,
`TPARTARGMIN`, `TRESHAPE`, `TDEINTERLEAVE`, `TINTERLEAVE`, `TPUSH`,
`TPOP`, `TALLOC`, and `TFREE`.

The raw command decoder must resolve Mode and Function to a cataloged direct
operation before block execution begins. It must not maintain a separate
logical-selector execution path that can accept a raw word without this
resolution step.

### B.IOT encoding and lifetime

`B.IOT` encodes `SrcTile1[31:26]`, `SrcTile0[25:20]`, `L[19]`,
`imm4[18:15]`, `Func[14:12]`, `S1R[11]`, `S0R[10]`, and
`DstTile[9:7]`, with the fixed tail `Opc1=001`, `Opcode=001`, `W=1`.

`Func=4`, `5`, and `6` mean two, one, and zero active sources. Other values
are illegal. Active ordinary destinations use `DstTile=0..3` for T/U/M/N;
4..6 are reserved and 7 is illegal. Destination-free operations zero the
inapplicable destination and size fields and do not allocate or publish a Tile.
An operation with no Tile source or destination emits no B.IOT only to carry
zero fields.

An active destination uses `imm4=3..9`, corresponding to 128 B, 256 B,
512 B, 1 KiB, 2 KiB, 4 KiB, and 8 KiB. Architectural CELL size is 128 B.
Each PE has 2048 CELL, or 256 KiB, of architectural Tile capacity. A failed
allocation raises a precise Tile-allocation fault before effects. Eviction,
overwriting live state, and architecture-transparent spill are forbidden.

The reuse bits are architectural lifetime controls. A zero bit marks the
source as last-use and releases it only after the consumer commits
successfully. A one bit keeps the source live. Fault, retry, and squash do not
release a source.

### B.DATR and layout capability

`B.DATR` encodes `CMode[31:29]`, `PadValueOrByteId[28:27]`, `Sat[26]`,
`Canonicalize[25]`, `DataType[24:20]`, zero bits 19:18, `RMode[17:15]`,
`Func=001[14:12]`, `Layout[11:7]`, and the fixed tail `Opc1=010`,
`Opcode=001`, `W=1`.

Compare modes EQ, NE, LT, GT, LE, and GE use 0 through 5; 6 and 7 are
reserved. Round modes NONE, RNE, RTZ, RDN, RUP, RNA, RTO, and RHB use 0
through 7. For ordinary and padding operations bits 28:27 encode Zero, Max,
Min, or Null. For `THISTOGRAM` only, those bits encode ByteId 0 through 3.
Every inapplicable union member or attribute encodes zero.

The accepted DataType codes are 0 through 14, 16 through 20, and 24 through
28. Codes 15, 21 through 23, and 29 through 30 are reserved; code 31 is
illegal. Command-form constraints enforce the accepted DataType and Layout
sets rather than deferring them to an implementation profile.

NORM is mandatory. Historical ND, DN, ZN, and NZ conversions retain these
codes: 1, 3, 4, 6, 8, 9, 17, 18, 20, 27, 28, and 30. They require an
advertised capability. Unsupported accepted layouts raise a precise fault
before effects and never execute as NORM. Codes involving ZZ or NN are
reserved in PTO ISA 0.57.1.

### B.CATR and ordering

`B.CATR` encodes `DR[26]`, `trap[19]`, `far[18]`, `atom[17]`, `aq[16]`,
and `rl[15]`; all other dynamic high fields are zero and the fixed tail is
`Func=000`, `Opc1=010`, `Opcode=001`, `W=1`.

Only B.CATR and the PTO memory model define architectural ordering. Dependency
metadata is scheduling metadata, not a fence. `B.IOD` remains rejected and
reserved.

### TMA descriptors and completion

Canonical assembly names each operation directly:
`BSTART.TLOAD/TSTORE/TMOV/TPREFETCH/MGATHER/MSCATTER/MGATHER.MASK/
MSCATTER.MASK/MGATHER.CAS DataType`. Address, stride, data attributes, and
dimensions are supplied by B.IOR, B.DATR, and applicable B.DIM fields according
to each operation's descriptor schema.

The six legacy TMA-oriented `B.ARG` descriptor forms are removed. Generic
`BSTART.CUBE Function, DataType` and `BSTART.FIXP TileOp, DataType` forms are
also removed because they expose unallocated functions outside the exact
120-operation inventory. Reserved CUBE functions have no generic escape
form.

`TPREFETCH` is destination-free but performs the same address, translation,
permission, and ordering preflight as TLOAD. It faults precisely and restarts
by full reissue.

A false mask lane performs no source or memory read, no destination or memory
write, and no fault check for the suppressed access. Masked gather fills an
inactive destination using B.DATR PadValue. Null is unspecified but may not
expose data from another protection domain. Inactive store or scatter lanes
perform no memory access.

Every multi-access operation preflights its complete ordered access set. A
failure reports the first failing original address and commits no memory,
Tile, queue, accumulator, or partial progress effect. Restart is a full
instruction reissue. A non-atomic scatter with duplicate active addresses has
an unspecified winning lane after all active lanes pass preflight. Atomic
forms obey PTO-TSO.

### Accumulator state

ACC is implicit architectural state and has no B.IOT source or destination
code. B.IOT destination 4 remains reserved. CUBE function identity declares
ACC access:

- ordinary and BIAS MATMUL/GEMV/MX functions initialize and write ACC;
- `.ACC` functions read and write ACC;
- ACCCVT reads ACC, publishes an ordinary Tile, and releases ACC only after a
  successful commit.

Fault, retry, and squash preserve the pre-attempt ACC state. Trap context save
and restore include ACC.

### Numeric and sort conformance

The PTO ISA 0.57.1 hardware-conformance profile uses IEEE-754 behavior,
canonical quiet NaN, and IEEE signed zero. Operation legality and B.DATR select
rounding and saturation. The deterministic raw-carrier profile remains a
separately identified reference-test profile and cannot claim hardware
conformance.

TSORT processes stable 32-element groups and produces each value with its U32
original index. Equal values retain original-index order. NaNs follow numeric
values and retain their original order. Ascending and descending are supported.

## Consequences

- All catalog, ASL, assembler, linker, loader, emulator, RTL, and model
  projections must move atomically to the 0.57.1 manifest or reject the input.
- Every one of the 120 base operations must have selector/function, operands,
  legality, effects, faults, restart, semantic handler, and executable evidence.
- The release manifest publishes the exact normative content hash and owned
  conformance-vector set.
- A 0.57.1 release requires positive and negative raw vectors, complete
  accepted/reserved/illegal classification, ASL totality, object-identity
  rejection tests, and independent downstream byte/effect parity.
- The two intentional raw-pattern containments among B.IOT grammar forms
  (one-source and two-source destination-free forms within their
  destination-bearing masks) are legal-set disjoint: fixed zero destination
  and size fields cannot satisfy the destination-bearing constraints. Every
  other command-form overlap is rejected.

## Rejected alternatives

- Retaining the previous ten-bit TEPL raw layout would contradict the selected
  0.57.1 field contract.
- An untagged dual decoder can silently execute the wrong accepted operation.
- Treating reuse, dependency metadata, or TPREFETCH as ignorable hints changes
  architecture-visible lifetime, ordering, or fault behavior.
- Encoding ACC as an ordinary Tile destination conflates distinct
  architectural state.
- Silently mapping an unsupported layout to NORM hides a required capability
  fault.
