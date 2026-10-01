<!-- GENERATED FROM: asl/block/execution/BSTART.TMOV.asl -->
# BSTART.TMOV

**Normative ASL source:** `asl/block/execution/BSTART.TMOV.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TMOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tmov-purpose role=purpose -->
## What BSTART.TMOV does

`BSTART.TMOV` opens a Tile memory bundle whose operation is `TMOV`: a copy between Tiles that never touches global memory. It is one 32-bit word (match `0x00211181`, mask `0x07ffffff`) with `DataType` in bits 31 to 27. The form carries the fixed TLSU selector 2 (Function 2).

Three directions are accepted: Local to Local, Local to Shared, and Shared to Local. Function 13 (`GMOV`, the peer-Local move) is a separate operation with its own start. Other former Shared movement function encodings are reserved and raise `Fault_IllegalInstruction`.

Design point: `TMOV` is the only Tile operation whose start may encode `DataType` 31 (`DTYPE_NONE`). [Descriptor legality](../model/dispatch/descriptor-legality.md) accepts that code only when the descriptor selects `TMOV`. At commit, a concrete `B.DATR` type wins, then a concrete start type, and otherwise the type is inferred from the bound source descriptor. `DTYPE_NONE` itself is never installed in a Tile descriptor.

<!-- PTO-READER-BLOCK: block-bstart-tmov-mechanism role=mechanism -->
## Placement and execution mechanism

[Bundle start dispatch](../model/dispatch/start.md) checks the descriptor before it commits any predecessor, so a reserved `DataType` (15, 21 to 23, 29, or 30) leaves the predecessor in place. The copy itself runs when the bundle is committed, for example at `BSTOP`, at a following `BSTART`, at a trace `B.HINT`, or at the architecture enter request.

At commit, [Tile execution](../model/dispatch/tile-execution.md) sends any bundle with a `B.IOS` binding to [Shared TLSU](../model/dispatch/shared-tlsu.md), function 2. A bundle with only `B.IOT` bindings takes the generic path and the Tile-level [TMOV](../../tile/layout-and-rearrangement/layout/TMOV.md) handler.

Design point: a Shared source is gated by publication before any Local destination is allocated. If the Shared Tile is not yet published, the handler returns without a fault and without consuming the bindings. The bundle stays active, so commit can retry after the producer publishes. No undefined Shared payload is ever copied.

<!-- PTO-READER-BLOCK: block-bstart-tmov-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `DataType` is a concrete transfer interpretation, or `DTYPE_NONE` for source-descriptor inference.
- `B.DIM` `LB0`, `LB1`, and `LB2` give ValidCol, ValidRow, and physical Col. Each omitted dimension has effective value one; omission does not copy the source shape.
- Local to Local: one terminating `B.IOT` binds one Local source and one newly allocated Local destination under one `PE_MASK`.
- Local to Shared: one source-only `B.IOT` names the Local source and one destination `B.IOS` names the Shared parent. Both bindings use the same mask, and the source capacity must equal the Shared `SizeCode` capacity.
- Shared to Local: one source `B.IOS` names the Shared parent and one destination-only `B.IOT` allocates the Local result. An optional `B.SUBVIEW` selects a partial source range.

Design point: for Local to Local, the source and destination must agree on capacity, layout, physical Col, and valid shape. A concrete non-packed `DataType` may differ from the source backing type only at the same element width, and the destination keeps the source backing type, so the copy can reinterpret bits without converting them.

<!-- PTO-READER-BLOCK: block-bstart-tmov-effects role=effects -->
## State effects and ordering

Local to Local copies payload and definedness into one renamed Local destination and keeps the Local source.

Local to Shared with a single participating PE publishes the whole parent. With more than one PE, `B.ASSEMBLE` is required, each writer commits its range into an open generation, and the parent publishes atomically at a complete LAST.

Shared to Local reads the Shared source without changing its descriptor, payload, readiness, or lifetime. The Local destination must match the Shared view in rows, columns, valid shape, data type, and layout; a mismatch releases the destination and raises `Fault_TileLegality`.

`TMOV` has no global-memory effect.

<!-- PTO-READER-BLOCK: block-bstart-tmov-constraints role=constraints -->
## Legality, faults, and atomicity

`PE_MASK=0000` is a strict no-op before source reads, allocation, publication checks, faults, or binding consumption.

Role, mask, size, descriptor, shape, type, layout, readiness, and allocation checks run before any payload is copied or published. A failure raises `Fault_TileLegality`, or `Fault_BundleControl` on the generic Local path for an incomplete binding stream, and releases any destination the bundle allocated.

Design point: a failed commit leaves the bundle active with its header intact, as [commit validation](../model/commit/validation.md) describes, so no partial copy is published and a retry reruns the whole move.

<!-- PTO-READER-BLOCK: block-bstart-tmov-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
BSTART.TMOV U8
B.DIM zero, 16, ->LB0
B.DIM zero, 8, ->LB1
B.DIM zero, 16, ->LB2
B.IOT T#1, mask=1111, last, ->U<1>
BSTOP
```

`T#1` is an 8 x 16 `U8` Local Tile in 128 bytes. `SizeCode` 1 is also 128 bytes, so the new `U#1` has 128 / 16 = 8 rows, and all 8 * 16 = 128 bytes are copied on each PE. The bundle has no `B.IOS`, so it takes the generic Local path.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TMOV DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tmov_32_211446509efb | L32 | 32 | 0x00211181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28,31]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tmov_32_211446509efb | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_tmov_32_211446509efb | DataType | 5 | 0–14, 16–20, 24–28, 31 | none | 15, 21–23, 29–30 | concrete transfer carrier interpretation or DTYPE_NONE source-descriptor inference | Encoded zero selects FP64. |

- `bstart_tmov_32_211446509efb.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | concrete transfer carrier interpretation or DTYPE_NONE source-descriptor inference |
| B.DATR.Layout | Local or Shared Tile layout selection |
| B.DIM.LB0/LB1/LB2 | ValidCol, ValidRow, and physical Col |
| B.IOT | Local source and/or renamed Local destination |
| B.IOS | absolute Shared source or atomic Shared destination |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMOV.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tmov_32_211446509efb);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local copy: BSTART.TMOV DataType; optional B.DATR Layout; optional B.DIM shape; one terminating B.IOT binds one Local source and one newly allocated Local destination with one common PE_MASK; BSTOP commits.
Canonical Shared TMOV: Function 2 uses one Local source B.IOT and one Shared destination B.IOS, or one Shared source B.IOS and one Local destination B.IOT; B.SUBVIEW and B.ASSEMBLE provide the explicit source/destination ranges.
Function 13 GMOV remains the distinct peer-Local operation.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMOV.asl -->
```asl
// BSTART.TMOV accepts DTYPE_NONE (encoded 31). When neither B.DATR nor BSTART
// contributes a concrete type, Local/Shared TMOV inherits the bound source
// descriptor type. DTYPE_NONE is never installed in a tile descriptor.
readonly func InstructionContractHandler_BSTART_TMOV() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TMOV()
    => TileOperation
begin
    return TileOperation_TMOV;
end;

pure func InstructionContractStartsTileBundle_BSTART_TMOV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Concrete DataType codes explicitly select the transfer carrier interpretation. DTYPE_NONE infers the type from the bound source descriptor; failure to resolve a concrete source type rejects before destination effects. Optional B.DATR omission retains NORM layout.
- Omitted LB0, LB1, and LB2 each have effective value one; omission does not inherit the source descriptor shape. An unallocated, pending, or incomplete Shared source remains waiting and produces no destination effect.
- PE_MASK=0000 is a strict no-op before source reads, destination allocation, publication checks, faults, or binding consumption.

## Legality

- DataType accepts the 25 concrete TileDataType codes and code 31 DTYPE_NONE for source-descriptor inference; codes 15, 21..23, and 29..30 are reserved.
- Function 2 accepts Local-to-Local and canonical Local/Shared or Shared/Local TMOV schemas. A Shared destination with multiple participating PEs requires B.ASSEMBLE; a single-PE no-assemble writer publishes the whole parent.
- B.SUBVIEW is the source-range modifier and B.ASSEMBLE is the destination-generation modifier. Shared source legality requires hardware-maintained whole-parent readiness and publication.
- Function 13 GMOV remains accepted and unchanged. Other Shared movement function encodings are reserved and raise Fault_IllegalInstruction.
- For Local-to-Local TMOV, source and destination descriptors agree on capacity, Layout, physical Col, and completed valid shape. A concrete non-packed DataType may differ from the source backing type only at the same element width, and the destination preserves the source backing DataType.

## State effects

- Function 2 Local-to-Local copies Local payload and definedness into one renamed Local destination while preserving the Local source.
- A canonical Shared destination performs one whole-parent publication for a single-PE writer or an atomic B.ASSEMBLE generation at LAST. Shared source operations never modify Shared state.
- Shared source operations wait/no-op before payload access when whole-parent readiness or publication is absent.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete role, mask, size, descriptor, shape, data-type, layout, readiness, and allocation preflight precedes every payload, publication, or destination effect.
- A singleton Local-to-Shared writer publishes the complete parent atomically. A multi-PE writer publishes only through complete B.ASSEMBLE.LAST; a Shared source read is read-only.

## Exceptions

- Reserved DataType, unsupported Layout, malformed or unterminated binding schema, role/size/mask mismatch, incompatible descriptor, incomplete B.ASSEMBLE.LAST, unpublished Shared source, allocation failure, or shape mismatch rejects before destination effects.
- A Shared source is hardware-waiting/no-effect until the complete parent is ready and published; no undefined Shared payload is consumed.

## Examples

- BSTART.TMOV U8; B.IOT T#1, mask=1111, ->U<1>, last; BSTOP
- BSTART.TMOV U8; B.IOT T#1, mask=0001, last; B.IOS mask=0001, ->S7<9>; BSTOP
- BSTART.TMOV U8; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; B.IOT mask=0011, ->T<7>, last; BSTOP
