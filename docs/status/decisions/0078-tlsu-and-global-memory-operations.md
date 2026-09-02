---
{
  "id": "ADR-0078",
  "title": "TLSU and global-memory operations",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "zhoubot"
  ],
  "created": "2026-08-21",
  "accepted": "2026-08-21",
  "rejected": null,
  "superseded": null,
  "baseline": "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f",
  "target_releases": [
    "0.58.1",
    "0.58.2",
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-BSTART-GMOV-COLLECTIVE-001",
    "PTO-BSTART-MGATHER-CAS-SCHEMA-001",
    "PTO-BSTART-MGATHER-MASK-SCHEMA-001",
    "PTO-BSTART-MGATHER-SCHEMA-001",
    "PTO-BSTART-MSCATTER-MASK-SCHEMA-001",
    "PTO-BSTART-MSCATTER-SCHEMA-001",
    "PTO-BSTART-TLOAD-CUBE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TMOV-SHARED-001",
    "PTO-BSTART-TPREFETCH-MEMORY-001",
    "PTO-BSTART-TSTORE-CUBE-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-GMOV-CORE4-PEER-001",
    "PTO-MGATHER-BYTE-DISPLACEMENT-001",
    "PTO-MGATHER-CAS-ATOMIC-001",
    "PTO-MGATHER-CAS-PUBLICATION-001",
    "PTO-MGATHER-MASK-PREDICATE-001",
    "PTO-MGATHER-MASK-PUBLICATION-001",
    "PTO-MGATHER-MASK-TYPE-002",
    "PTO-MSCATTER-BYTE-DISPLACEMENT-001",
    "PTO-MSCATTER-DUPLICATE-ORDER-001",
    "PTO-MSCATTER-MASK-DUPLICATE-001",
    "PTO-MSCATTER-MASK-PREDICATE-001",
    "PTO-MSCATTER-MASK-TYPE-002",
    "PTO-TLOAD-CUBE-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TPREFETCH-FOOTPRINT-001",
    "PTO-TSTORE-CUBE-001",
    "PTO-TSTORE-MEMORY-001",
    "PTO-INDEXED-TLSU-STRIDE-001",
    "PTO-INST-BLOCK-B-IOR",
    "PTO-INST-BLOCK-BSTART-MGATHER",
    "PTO-INST-BLOCK-BSTART-MGATHER-CAS",
    "PTO-INST-BLOCK-BSTART-MGATHER-MASK",
    "PTO-INST-BLOCK-BSTART-MSCATTER",
    "PTO-INST-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-REQ-TILE-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-BSTART-GMOV",
    "PTO-BLOCK-BSTART-MGATHER",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-MGATHER-MASK",
    "PTO-BLOCK-BSTART-MSCATTER",
    "PTO-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-BSTART-TPREFETCH",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-TILE-GMOV",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TPREFETCH",
    "PTO-TILE-TSTORE",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-DECODE",
    "PTO-BLOCK-MODEL-LIFECYCLE-RESET",
    "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-ARCH-PROFILE-RESET",
    "PTO-TILE-MODEL-STATE-ALLOCATION",
    "PTO-TILE-MODEL-STATE-DESCRIPTORS",
    "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS",
    "PTO-TILE-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA",
    "PTO-TILE-MODEL-MEMORY-ADDRESSING",
    "PTO-TILE-MODEL-MEMORY-ATOMICS",
    "PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-0062"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "PRD-040",
    "PRD-041",
    "PRD-042",
    "PRD-043",
    "PRD-044",
    "PRD-045",
    "PRD-046",
    "PRD-047",
    "PRD-048",
    "PRD-144",
    "PRD-145"
  ],
  "amendments": [
    {
      "date": "2026-09-01",
      "baseline": "cbcd6abb2dc4d7f933d4db1124fadd11934d4c56",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/209",
      "affected_ndf": [
        "PTO-BSTART-MGATHER-CAS-SCHEMA-001",
        "PTO-BSTART-MGATHER-MASK-SCHEMA-001",
        "PTO-BSTART-MGATHER-SCHEMA-001",
        "PTO-BSTART-MSCATTER-MASK-SCHEMA-001",
        "PTO-BSTART-MSCATTER-SCHEMA-001",
        "PTO-B-DATR-FIELDS-001",
        "PTO-B-IOT-STREAM-001",
        "PTO-INDEXED-TLSU-STRIDE-001",
        "PTO-INST-BLOCK-B-IOR",
        "PTO-INST-BLOCK-BSTART-MGATHER",
        "PTO-INST-BLOCK-BSTART-MGATHER-CAS",
        "PTO-INST-BLOCK-BSTART-MGATHER-MASK",
        "PTO-INST-BLOCK-BSTART-MSCATTER",
        "PTO-INST-BLOCK-BSTART-MSCATTER-MASK",
        "PTO-MGATHER-BYTE-DISPLACEMENT-001",
        "PTO-MGATHER-CAS-ATOMIC-001",
        "PTO-MGATHER-CAS-PUBLICATION-001",
        "PTO-MGATHER-MASK-PREDICATE-001",
        "PTO-MGATHER-MASK-PUBLICATION-001",
        "PTO-MGATHER-MASK-TYPE-002",
        "PTO-MSCATTER-BYTE-DISPLACEMENT-001",
        "PTO-MSCATTER-DUPLICATE-ORDER-001",
        "PTO-MSCATTER-MASK-DUPLICATE-001",
        "PTO-MSCATTER-MASK-PREDICATE-001",
        "PTO-MSCATTER-MASK-TYPE-002",
        "PTO-REQ-TILE-001"
      ],
      "affected_units": [
        "PTO-BLOCK-B-DATR",
        "PTO-BLOCK-B-IOR",
        "PTO-BLOCK-BSTART-MGATHER",
        "PTO-BLOCK-BSTART-MGATHER-CAS",
        "PTO-BLOCK-BSTART-MGATHER-MASK",
        "PTO-BLOCK-BSTART-MSCATTER",
        "PTO-BLOCK-BSTART-MSCATTER-MASK",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK",
        "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
        "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
        "PTO-BLOCK-B-IOT",
        "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
        "PTO-BLOCK-MODEL-DISPATCH-DECODE",
        "PTO-BLOCK-MODEL-LIFECYCLE-RESET",
        "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION",
        "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
        "PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR",
        "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
        "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
        "PTO-BLOCK-MODEL-STATE-TYPES",
        "PTO-ARCH-PROFILE-RESET",
        "PTO-TILE-MGATHER",
        "PTO-TILE-MGATHER-CAS",
        "PTO-TILE-MGATHER-MASK",
        "PTO-TILE-MODEL-STATE-ALLOCATION",
        "PTO-TILE-MODEL-STATE-DESCRIPTORS",
        "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS",
        "PTO-TILE-MODEL-STATE-TYPES",
        "PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA",
        "PTO-TILE-MODEL-MEMORY-ADDRESSING",
        "PTO-TILE-MODEL-MEMORY-ATOMICS",
        "PTO-TILE-MODEL-MEMORY-GATHER-SCATTER",
        "PTO-TILE-MSCATTER",
        "PTO-TILE-MSCATTER-MASK"
      ]
    }
  ]
}
---
# ADR 0078: TLSU and global-memory operations

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 040: Shared `TMOV` has four distinct movement and publication modes

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

## Decision 041: destination-free `TPREFETCH` implicitly selects all four PEs

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

## Decision 042: `GMOV` permits partial destination participation within a full Core4 collective

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

## Decision 043: `MGATHER` indexes are signed or unsigned logical element indices

`MGATHER` consumes one scalar base pointer, one scalar row stride in elements,
and one Local IndexTile. Each IndexTile element is a logical linear element
index. `ValidCol` splits index `k` into row `q=floor(k/ValidCol)` and column
`r=k-q*ValidCol`; the element offset is `q*stride+r`, and the byte address is
the base plus that offset scaled by the transfer DataType size.

An IndexTile MAY use a signed `SINT` integer data type or an unsigned integer
data type. A signed index is sign-extended from the IndexTile element width;
an unsigned index is zero-extended from that width. For every valid destination
element, the effective byte address follows the logical-index formula above.
Address validity, translation, permission, alignment, and access-size checks
MUST complete according to the ordinary precise TLSU memory contract before
destination or memory-event effects.

Non-integer IndexTile data types MUST raise Illegal Block Exception before
architectural or pending block effects.

## Decision 044: `MGATHER` pads the physical destination outside its valid rectangle

For `MGATHER`, `ValidRow` MUST NOT exceed `Row`, and `ValidCol` MUST NOT exceed
`Col`. The destination's physical region is `Row x Col`; its gathered valid
rectangle is `ValidRow x ValidCol`.

Every physical destination element outside the valid rectangle MUST be written
with the padding value selected by `B.DATR.PadValueOrByteId`. An omitted
`B.DATR` selects `Null` as defined by the architectural padding-default rule.
The complete valid payload and padded physical remainder become visible as one
destination result; a fault or legality failure MUST expose neither a partial
gathered rectangle nor a partial padding update.

## Decision 045: `MGATHER` requires an explicit scalar base binding

`MGATHER` consumes `RegSrc0` as its scalar base pointer. Its complete block
MUST contain a `B.IOR` binding for `RegSrc0`; omission is illegal and does not
supply an implicit address-zero default.

Software MAY explicitly bind the architectural `zero` register when address
zero is intended. An explicitly encoded `zero` selector therefore supplies a
base pointer value of zero, while omission remains a distinct illegal schema.
Unused `B.IOR` fields MUST remain zero according to the complete block schema.

## Decision 046: indexed TLSU operations use explicit bases, row strides, and logical indices

Every indexed TLSU operation consumes an explicit `B.IOR.RegSrc0` scalar base,
an explicit nonzero `B.IOR.RegSrc1` row stride in elements, and one Local
IndexTile. `RegSrc2` and `RegDst` remain zero. This rule applies to `MGATHER`,
`MGATHER.MASK`, `MGATHER.CAS`, `MSCATTER`, and `MSCATTER.MASK`.

Each IndexTile element is sign- or zero-extended from its integer element type
and interpreted by Decision 043. The stride MUST be at least `ValidCol` and is
validated before address probes or effects. Non-integer IndexTile data types
MUST raise Illegal Block Exception before effects. Disabled mask lanes do not
evaluate their index or address.

Omitting `B.IOR.RegSrc0` is illegal and does not select address zero. Software
MAY explicitly bind the architectural `zero` register to request a zero base.
Unused `B.IOR` fields MUST remain zero according to the complete block schema.

## Decision 047: `MSCATTER` source typing, effects, and duplicate addresses

`MSCATTER` consumes one Local data source Tile and one Local IndexTile with the
same logical shape. The data source Tile MUST use the `BSTART.MSCATTER`
DataType. The IndexTile uses the independent signed-or-unsigned logical-index
rule from Decision 046 in ADR-0078 and is not required to share the data source
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
all-or-nothing transaction as specified by Decision 004 in ADR-0075, but it does not define an
internal lane order or a duplicate-address winner.

## Decision 048: masked indexed TLSU operations use exact per-element predicates

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

## Decision 145: indexed TLSU transfers reject packed four-bit data types

`MGATHER`, `MGATHER.MASK`, `MGATHER.CAS`, `MSCATTER`, and
`MSCATTER.MASK` use logical element indices and do not encode an independent
low-versus-high-nibble selector. Their transferred data type MUST therefore
not be `E2M1X2`, `E1M2X2`, `HiF4X2`, `S4X2`, or `U4X2`. Selecting any of
those packed four-bit transfer types MUST raise Illegal Block Exception before
address checks, memory effects, destination allocation, source lifetime
effects, or memory events.

This restriction applies only to the transferred data. An IndexTile MAY still
use `S4X2` or `U4X2`: each logical IndexTile element is independently sign- or
zero-extended from four bits and denotes one logical element index under Decision 043 in ADR-0078
and Decision 046 in ADR-0078.

## Decision 144: an unallocated Shared `TSTORE` source derives minimum capacity

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

Issue [#209](https://github.com/PTO-ISA/pto-spec/issues/209) records the row
stride and logical-index interface closure plus compiler-generated golden
evidence. Because indexed TLSU was already owned by this decision family, the
accepted interface amendment is folded here rather than assigned a new ADR.
