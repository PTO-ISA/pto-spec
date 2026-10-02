<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.POPC.asl -->
# BSTART.MSCATTER.POPC

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.POPC.asl`

Starts GM indexed mscatter.popc operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER-POPC}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-popc-purpose role=purpose -->
## Purpose and scope

`BSTART.MSCATTER.POPC` opens a Tile memory block whose operation is `MSCATTER_POPC`: one indexed atomic increment per lane that adds one to a `U32` global memory (GM) element. The block publishes no Tile, and its only source is the index Tile.

The command is one 32-bit word with match `0x01b11181` under mask `0x07ffffff`, so `DataType` occupies bits 31 to 27 and the fixed low bits carry TLSU selector 27. `ExecuteBundleGMAtomRedOperation` decodes selector 27 into `GMReduction_POPC` and calls `GM_RED_POPC(...)`. A reserved `DataType` code raises `Fault_IllegalInstruction` at the `BSTART`, before the block commits.

Design point: the increment amount is fixed by the operation instead of coming from a value Tile, so this reduction binds one fewer source than its siblings. The count an element reaches is therefore exactly the number of active lanes that name it, including lanes that repeat an address.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-popc-mechanism role=mechanism -->
## How to read the operation

At commit the block runs the Tile-level body `GM_RED_POPC`, which first visits every active lane address and probes it for read and then for write. Two probes whose translations differ raise `Fault_DataPage`. Only after all lanes pass does it add one to each element in an `ARBITRARY` order and record one atomic event per lane.

Design point: every lane stores, even when two lanes name the same element, so the operation counts occurrences rather than distinct addresses. The lane order is arbitrary but the final count is not, because the update is a repeated addition of one.

Design point: all probes run before the first increment, so a faulting address leaves every element unchanged and records no event. A retry therefore counts each active lane exactly once instead of double-counting the lanes that already passed their probe.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-popc-inputs role=inputs-outputs -->
## Inputs and outputs

- `DataType` must be `U32`; every other code, including `S32` and the floating types, is rejected for this operation.
- `B.DIM` `LB0` is ValidCol, `LB1` is ValidRow (default 1), and `LB2` is the physical Col. The values must equal the index Tile's valid columns and valid rows, and `LB2` is the physical column count the layout rule uses.
- One terminating `B.IOT` carries the index Tile in `source0`, the `PE_MASK`, and `last`. It carries no destination and no second source, and no value Tile exists for this operation.
- `B.IOR BaseGPR, zero, zero, ->zero` is required: `RegSrc0` selects the per-PE base GPR, the other three selectors encode zero, and a `RegSrc0` of `zero` supplies base address zero.
- The index Tile is `S32`, `U32`, `S64`, or `U64` with logical element indices and the bundle layout.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-popc-effects role=effects -->
## Effects and state

Every active lane adds one to one GM element and records one atomic event. No Tile is published, no Local allocation is created, and the index Tile keeps its contents. The GM results stay visible: a reduction does not roll memory back.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-popc-constraints role=constraints -->
## Boundaries and failures

`PE_MASK=0000` exits at the start of the atom/red dispatcher, before its schema, GPR, descriptor, type, and memory checks.

An unknown TLSU code raises `Fault_IllegalInstruction`. A binding count other than one record raises `Fault_BundleControl`. A missing `B.IOR`, a Shared binding, a nonzero unused `B.IOR` selector, a dimension outside `1..65535`, a `DataType` other than `U32`, a wrong layout or shape, or an undefined active index element raises `Fault_TileLegality` before the first probe. A memory fault keeps its own kind.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-popc-example role=example -->
## Non-normative usage example

Treat the generated `BSTART.MSCATTER.POPC` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.

```asm
BSTART.MSCATTER.POPC U32
B.DIM zero, 3, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 3, ->LB2
B.IOT T#1, mask=1111, last
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` is a 1 by 3 `S32` index Tile holding `0`, `4`, and `4`, and `a0` holds `0x1000`. If GM holds `10` at `0x1000` and `20` at `0x1004`, the block counts the two lanes that name `0x1004` separately, so memory ends at `11` and `22`. The block returns no Tile, and the two duplicate lanes cannot be distinguished from two distinct addresses afterwards.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER.POPC DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_popc_32_gm27 | L32 | 32 | 0x01b11181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_popc_32_gm27 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mscatter_popc_32_gm27 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | GM operation type | Encoded zero is interpreted by the selected operation. |

- `bstart_mscatter_popc_32_gm27.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | GM operation type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.POPC.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER_POPC(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_popc_32_gm27);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.POPC DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.POPC.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER_POPC() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER_POPC()
    => TileOperation
begin
    return TileOperation_MSCATTER_POPC;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER_POPC()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- PE_MASK=0000 is a strict no-effect case; B.IOR and valid dimensions are required otherwise.
- LB0 supplies ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.

## Legality

- GM-only operation; Shared and vector forms are excluded.
- The body binds one terminating Local B.IOT carrying only IndexTile; ValueTile and destination fields are forbidden.

## State effects

- Opens a complete GM indexed block.

## Memory effects and ordering

### Memory effects

- Complete preflight precedes atomic effects.

### Ordering

- Duplicate effective addresses serialize in implementation-defined order.

## Exceptions

- Reserved DataTypes fault IllegalInstruction; unsupported operation/type tuples fault TileLegality; access faults are preflighted.

## Examples

- BSTART.MSCATTER.POPC DataType
