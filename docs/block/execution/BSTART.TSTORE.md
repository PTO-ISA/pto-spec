<!-- GENERATED FROM: asl/block/execution/BSTART.TSTORE.asl -->
# BSTART.TSTORE

**Normative ASL source:** `asl/block/execution/BSTART.TSTORE.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TSTORE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tstore-purpose role=purpose -->
## What BSTART.TSTORE does

`BSTART.TSTORE` opens a Tile memory bundle whose operation is `TSTORE`: a strided write of a Tile's valid rectangle to global memory (GM). It is one 32-bit word (match `0x00111181`, mask `0x07ffffff`) with `DataType` in bits 31 to 27. The form carries the fixed TLSU selector 1, so the bundle always runs `TSTORE`.

The source is one of three kinds: an ordinary Local Tile, a published Shared Tile, or a Local CUBE Tile converted back to an ordinary GM layout. The source Tile is only read; it is never modified or released.

Design point: the start command writes no memory. [Bundle start dispatch](../model/dispatch/start.md) validates the descriptor and commits any active predecessor first, and the store runs when this bundle is committed, for example at `BSTOP`, at a following `BSTART`, at a trace `B.HINT`, or at the architecture enter request. A reserved `DataType` code raises `Fault_IllegalInstruction` at the `BSTART`, before the predecessor commits.

<!-- PTO-READER-BLOCK: block-bstart-tstore-mechanism role=mechanism -->
## Placement and execution mechanism

At commit, [Tile execution](../model/dispatch/tile-execution.md) routes the bundle:

- A `B.DATR` layout of `M322ND` (24), `M162ND` (25), or `N82ND` (26) selects [CUBE transport](../model/dispatch/tlsu-layout-conversion.md), function 1.
- A `B.IOS` source selects [Shared TLSU](../model/dispatch/shared-tlsu.md), function 1.
- Otherwise the generic path calls the Tile-level [TSTORE](../../tile/memory-and-data-movement/regular/TSTORE.md) on the `B.IOT` source.

Each selected PE writes element (row, column) to `base + row * row_stride_bytes + column * element_size`, where `B.IOR` `RegSrc0` is the base and `RegSrc1` is the byte row stride, both read from that PE's own GPRs. A packed four-bit column adds `floor(column / 2)` bytes and writes the low or high nibble by column parity.

Design point: `TSTORE` probes and writes one element at a time and stops at the first fault. Stores completed before the fault stay in GM, and the source is unchanged. The NDF clause `PTO-BSTART-TSTORE-MEMORY-001` states this first-fault rule.

Design point: a Shared source is gated by publication. If the Shared Tile is not yet published, the handler returns without a fault and without reading payload, consuming the binding, or writing GM. The bundle stays active, so commit can be retried after the producer publishes.

<!-- PTO-READER-BLOCK: block-bstart-tstore-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `DataType` is the source element type; codes 0 to 14, 16 to 20, and 24 to 28 are accepted.
- `B.DIM` `LB0`, `LB1`, and `LB2` give ValidCol, ValidRow, and physical Col. Each omitted dimension has effective value one; omission does not copy the source descriptor shape.
- The optional `B.IOR` gives the base and byte row stride. Omitted, the base is zero and the stride is the dense row size `ceil(columns * element_bits / 8)`; an explicit `zero` selector gives a real zero.
- The source is exactly one terminating source-only `B.IOT`, or exactly one source `B.IOS` (`SizeCode` 0). An optional `B.SUBVIEW` after the `B.IOS` selects an explicit per-PE range.
- The CUBE form needs `B.DATR` `DataType` equal to `DTYPE_NONE`, `LB0` and `LB1` as the valid columns and rows, no `LB2`, and one `B.IOT`.

Design point: a Shared `PE_MASK` selects consumer PEs and nothing else. Any nonzero mask is legal for function 1, and the mask does not imply quarters or ranges; `B.SUBVIEW` carries explicit geometry when each PE should store a different part.

<!-- PTO-READER-BLOCK: block-bstart-tstore-effects role=effects -->
## State effects and ordering

On success only GM and memory-event state change, and the source binding is consumed by normal bundle completion. A Local or Shared source keeps its payload, descriptor, producer mask, readiness, and lifetime.

The selected Shared-store PEs have no architecture-defined relative issue or commit order. Programs that let two PEs store overlapping GM ranges must establish ordering separately.

<!-- PTO-READER-BLOCK: block-bstart-tstore-constraints role=constraints -->
## Legality, faults, and atomicity

`PE_MASK=0000` is a strict no-op before schema, descriptor, GPR, memory, or fault effects. Otherwise ValidCol and ValidRow must be nonzero, ValidCol may not exceed physical Col, and the valid rectangle must fit the source descriptor.

Schema, shape, type, and descriptor errors raise `Fault_TileLegality` before the first GM write. The Shared path raises `Fault_BundleControl` for an illegal `B.IOR` schema. A GM translation, permission, or alignment fault stops the store at that element with its own fault kind.

Design point: after a fault, [commit validation](../model/commit/validation.md) leaves the bundle active with its header intact. A retry runs the store handler again from the first element, so elements written before the fault may be written a second time.

<!-- PTO-READER-BLOCK: block-bstart-tstore-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
BSTART.TSTORE U8
B.DIM zero, 64, ->LB0
B.DIM zero, 8, ->LB1
B.DIM zero, 64, ->LB2
B.IOR a0, a1
B.IOT T#1, mask=1111, last
BSTOP
```

`T#1` is an 8 x 64 `U8` Local source. Each of the four PEs stores 8 * 64 = 512 bytes. On a PE whose `a1` is 128, element (7, 63) goes to `a0 + 7 * 128 + 63`, which is `a0 + 959`, and the 64 unused bytes at the end of each row are not written.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TSTORE DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tstore_32_4048b6e8b0f4 | L32 | 32 | 0x00111181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tstore_32_4048b6e8b0f4 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tstore_32_4048b6e8b0f4 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | source element data type | Encoded zero selects FP64. |

- `bstart_tstore_32_4048b6e8b0f4.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | source element data type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR byte row stride |
| B.DIM.LB0 | ordinary ValidCol or CUBE valid columns |
| B.DIM.LB1 | ordinary ValidRow or CUBE valid rows |
| B.DIM.LB2 | ordinary physical Col; forbidden for CUBE conversion |
| B.IOT/B.IOS | Local or Shared source and participation mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TSTORE.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TSTORE(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tstore_32_4048b6e8b0f4);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local source: BSTART.TSTORE DataType; optional B.DATR Layout; optional B.DIM; optional B.IOR; exactly one terminating source B.IOT; BSTOP commits.
Shared source: BSTART.TSTORE DataType; optional B.DATR/B.DIM/B.IOR; exactly one source B.IOS with any nonzero consumer PE_MASK; optional B.SUBVIEW selects an explicit per-PE source range; BSTOP commits.
Local CUBE source: Function 1 encodes B.DATR Layout M322ND, M162ND, or N82ND with DataType=DTYPE_NONE; requires LB0=valid columns and LB1=valid rows, omits LB2, and uses one terminating source B.IOT.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TSTORE.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TSTORE() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TSTORE()
    => TileOperation
begin
    return TileOperation_TSTORE;
end;

pure func InstructionContractStartsTileBundle_BSTART_TSTORE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCubeLayoutLegal_BSTART_TSTORE(
    data_layout: bits(5)) => boolean
begin
    return TileDataLayoutConversionIsStore(data_layout);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit. Optional B.DATR omission retains the default NORM layout.
- Omitted LB0, LB1, and LB2 each have effective value one. The resolved dimensions are checked against the source descriptor; omission does not inherit its shape.
- An unallocated, pending, or incomplete Shared source remains waiting and produces no GM, binding-consumption, or descriptor effect.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An explicitly encoded zero selector reads the zero GPR value and therefore supplies a real zero base or zero stride.

## Legality

- TSTORE is selected only by TLSU Function 1 and has no standalone opcode. Former independent Shared movement encodings are reserved.
- DataType accepts 0..14, 16..20, and 24..28; codes 15, 21..23, and 29..31 are reserved and reject before effects.
- The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS. Shared PE_MASK selects participating consumer PEs and does not infer quarters or ranges; B.SUBVIEW carries explicit source geometry.
- PE_MASK=0000 is a strict no-op before schema, descriptor, GPR, memory, fault, or source-consumption effects.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the valid rectangle fits the persistent source descriptor.

## State effects

- Reads one Local or published, whole-parent-ready Shared source without modifying its payload, descriptor, producer mask, readiness, or lifetime.
- On success only GM and memory-event state change; the source binding is consumed by normal block completion.
- A Shared source that is pending or incomplete causes no payload read and no GM effect.

## Memory effects and ordering

### Memory effects

- For every selected PE and every selected element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size, with packed four-bit columns adding floor(column / 2) to the byte-strided row base and selecting low/high by column parity.
- The selected-PE footprint is accessed element by element until the first fault; prior GM writes and memory events may remain visible. Individual store beats need not be atomic or ordered to observers.

### Ordering

- Resolve and validate the complete schema, source descriptor or temporary descriptor, dimensions, masks, and per-PE GPR inputs before accessing each element until the first fault.
- Selected Shared-store PEs have no architecture-defined relative issue or commit order; software avoids overlapping GM regions or establishes ordering separately.

## Exceptions

- Reserved DataType, unsupported Layout, invalid dimensions, source descriptor mismatch, malformed bindings, illegal PE mask, or GM translation, permission, or alignment fault raises the applicable fault before the first GM write.
- A Shared source is hardware-waiting/no-effect until whole-parent readiness and publication are true; undefined Shared payload is not a legal source path.

## Examples

- BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=1111; BSTOP
