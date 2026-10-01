<!-- GENERATED FROM: asl/block/execution/BSTART.GMOV.asl -->
# BSTART.GMOV

**Normative ASL source:** `asl/block/execution/BSTART.GMOV.asl`

Collectively copies peer-PE Local fragments to selected Local destinations.

## Normative identity {#PTO-INST-BLOCK-BSTART-GMOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-gmov-purpose role=purpose -->
## What BSTART.GMOV contributes

`BSTART.GMOV` opens a Tile-memory-class block whose operation is `GMOV`: a collective copy of Local fragments between the four PEs of one Core. Each PE resolves a source fragment with its own `peer_tid`, and each selected PE publishes a destination that receives that fragment payload and definedness byte for byte. The command performs no global-memory access and no Shared-register effect.

The single form is `BSTART.GMOV DataType`, one 32-bit word with match `0x00d11181` under mask `0x07ffffff`, so `DataType` sits in bits 31 to 27 and the fixed low bits carry TLSU selector 13, which `BundleGMOVSelected` matches. The operation is `TileOperation_GMOV` and `InstructionContractStartsTileBundle_BSTART_GMOV` returns TRUE.

Design point: `GMOV` has no index Tile and no base address, unlike `MGATHER`, which also publishes a Local destination. The source it copies is a peer-resolved snapshot, so the destination takes the source's own valid shape, physical columns, and capacity instead of the `B.DIM` shape.

<!-- PTO-READER-BLOCK: block-bstart-gmov-mechanism role=mechanism -->
## Placement and mechanism

Tile execution tests `BundleGMOVSelected` before the CAS, atom, gather, and scatter selectors, so selector 13 always reaches `ExecuteBundleGMOVOperation`. That handler requires exactly one Local binding with a destination, a `source0`, no `source1`, and `last`; a Shared binding, an incomplete binding, or a nonzero unused `B.IOR` field raises `Fault_TileLegality`.

The handler then reads `peer_tid` for each of the four PEs from the private GPR named by `B.IOR.RegSrc0` and requires every value to be below 4. Repeated peer identifiers are legal, so two PEs may read the same fragment. All three `B.DIM` lanes must equal 1, because the destination shape comes from the source rather than from dimensions.

Design point: readiness is one collective witness. `BundleGMOVCore4SourceReady` requires the source contents to be defined and its allocation mask to be `1111`, so the copy runs only when all four PEs have allocated the fragment. The copy itself is read-old and write-new from that snapshot, so no PE can observe a half-updated fragment.

Design point: `ExecuteBundleGMOVOperation` has no `PE_MASK=0000` early exit, unlike the gather, scatter, and atom handlers. Its schema, readiness, peer-range, dimension, type, and capacity checks therefore run for every encoding that reaches the handler, whatever the nonzero mask is. `PE_MASK=0000` never reaches it: `B.IOT` records no binding for a zero mask, and `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` then returns true at `asl/block/model/dispatch/tile-execution.asl:143`.

<!-- PTO-READER-BLOCK: block-bstart-gmov-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` in bits 31 to 27 selects the element type of the copied fragment; the constraint accepts codes 0 to 14, 16 to 20, and 24 to 28, and every other code is reserved. The handler also requires `TileCarrierOrPackedBaselineDataTypeSupported` for that type, and both Tiles must use it.
- One terminating `B.IOT` must carry the source fragment and a destination, and must not carry a second source. Its `PE_MASK` selects the destination participants and its size code must describe exactly the source capacity in bytes.
- `B.IOR` is optional. When present, `RegSrc0` selects the per-PE GPR that holds that PE's `peer_tid`, and `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero. Omitting `B.IOR` supplies `peer_tid` zero in all four PEs.
- `B.DATR` selects the layout. The source must already use that layout, and the destination is resolved with it.

<!-- PTO-READER-BLOCK: block-bstart-gmov-effects role=effects -->
## Pending state and completion

For each PE that the mask selects, the bundle allocates a Local destination with the source shape and copies the peer-resolved payload, definedness, and physical region into it. PEs outside the mask still take part in the peer selection, rendezvous, and readiness preflight but request, allocate, write, and complete no destination. Shared state is unchanged.

The copy publishes no memory event because it never touches global memory. A failure after allocation calls `RollBackBundleTileDestinations`, so a rejected attempt exposes no partial destination.

<!-- PTO-READER-BLOCK: block-bstart-gmov-constraints role=constraints -->
## Legality and fault boundary

- An unknown TLSU code raises `Fault_IllegalInstruction`; a Shared binding, a malformed binding, an illegal `B.IOR` value, a dimension lane other than 1, an undefined or not-fully-allocated source, a type or layout mismatch, or a destination size that is not the source capacity raises `Fault_TileLegality` before the copy.
- A `peer_tid` of 4 or more in any PE raises `Fault_TileLegality` before allocation and before any request.
- If no free Local destination exists, the resolution raises `Fault_TileAllocation`.
- Any nonzero `PE_MASK` is legal and controls only destination request, allocation, write, and completion participation.

<!-- PTO-READER-BLOCK: block-bstart-gmov-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.GMOV U8
B.IOT T#1, mask=0011, size=1, ->T
B.IOR a1, zero, zero, ->zero
BSTOP
```

`T#1` is the peer-resolved source fragment, `mask=0011` selects two of the four PEs for the destination, and `a1` holds `peer_tid`. If `a1` holds 1 in every PE, all four PEs rendezvous on the fragment published by PE 1 and every selected PE publishes a copy of it; a PE whose `a1` holds 2 instead resolves PE 2's fragment. The two unselected PEs still prove readiness for their own resolution but publish nothing.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.GMOV DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_gmov_32_6c21e223eaa7 | L32 | 32 | 0x00d11181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_gmov_32_6c21e223eaa7 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_gmov_32_6c21e223eaa7 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | byte-preserved Local fragment element type | Encoded zero selects FP64. |

- `bstart_gmov_32_6c21e223eaa7.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | byte-preserved Local fragment element type |
| B.IOT source | Core4 peer-resolved Local source snapshot |
| B.IOT destination | renamed Local destination and per-PE TSize |
| B.IOT PE_MASK | selected destination request/write participants |
| B.IOR.RegSrc0 | each PE's private-GPR absolute peer_tid |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.GMOV.asl -->
```asl
readonly func InstructionContractMatches_BSTART_GMOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_gmov_32_6c21e223eaa7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.GMOV DataType; optional B.DATR Layout; one terminating B.IOT with one Local source and one Local destination; optional B.IOR peer_tid; BSTOP
B.IOS and B.DIM are not members of a GMOV schema.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.GMOV.asl -->
```asl
readonly func InstructionContractHandler_BSTART_GMOV() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_GMOV()
    => TileOperation
begin
    return TileOperation_GMOV;
end;

pure func InstructionContractStartsTileBundle_BSTART_GMOV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit; omitted B.DATR selects NORM.
- Omitted B.IOR supplies peer_tid zero independently in all four PEs. An explicit zero selector reads the architectural zero GPR and supplies the same value without invoking an omission default.

## Legality

- bstart_gmov_32_6c21e223eaa7.DataType accepts only 0..14, 16..20, 24..28; all other encodings are reserved.
- All four PEs rendezvous and all four peer-resolved source fragments must be allocated and ready, independent of PE_MASK.
- Any nonzero PE_MASK is legal and controls only destination request/allocation/write participation; PE_MASK=0000 is a strict no-op before source access or faults.
- Each PE's absolute peer_tid is 0..3; repeated peer identifiers are legal.

## State effects

- For each selected PE, allocate a new Local destination fragment and copy the byte-preserving peer-resolved source payload and definedness.
- Unselected PEs participate in rendezvous and readiness preflight but do not request, allocate, write, or complete a destination. Shared state is unchanged.

## Memory effects and ordering

### Memory effects

- none; GMOV performs no GM access and emits no PTO memory event

### Ordering

- Snapshot every source fragment and validate all descriptors, readiness, peer selectors, and participant agreement before allocating or writing any selected destination.
- Read-old/write-new behavior preserves a source snapshot when architectural aliases resolve to the same prior value.

## Exceptions

- Reserved DataType, malformed bindings, any Shared binding or B.DIM, incompatible descriptors, non-ready Core4 source, or any PE peer_tid outside 0..3 raises an Illegal Block exception before requests, allocation, destination writes, or events.
- Core4 convergence and source readiness are one combined preflight; a failed attempt exposes no partial destination.

## Examples

- BSTART.GMOV U8; B.IOT T#1, mask=0011, size=1, ->T; B.IOR zero, a0; BSTOP
