<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.asl -->
# BSTART.MSCATTER

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.asl`

scatter using explicit logical element indices.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-purpose role=purpose -->
## What BSTART.MSCATTER contributes

`BSTART.MSCATTER` opens a Tile memory bundle whose operation is `MSCATTER`: an indexed store. Each element of a Local data Tile is written to global memory (GM) at a base address plus a logical element index taken from a Local index Tile. The command is one 32-bit word (match `0x00511181`, mask `0x07ffffff`) with `DataType` in bits 31 to 27. It carries the fixed TLSU selector 5.

A scatter produces no Tile. Neither source is consumed or modified.

Design point: the start command writes no memory. [Bundle start dispatch](../model/dispatch/start.md) validates the descriptor and commits any active predecessor first; the scatter runs when the bundle is committed, for example at `BSTOP`, at a following `BSTART`, at a trace `B.HINT`, or at the architecture enter request. A reserved `DataType` code raises `Fault_IllegalInstruction` at the `BSTART`, before the predecessor commits.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mechanism role=mechanism -->
## Placement and mechanism

At commit, [Tile execution](../model/dispatch/tile-execution.md) reaches the [MSCATTER handler](../model/dispatch/tlsu-mscatter.md) after the earlier specialized selectors, including plain `MGATHER`, decline. The handler validates the complete bundle and calls the Tile-level [MSCATTER](../../tile/memory-and-data-movement/irregular/MSCATTER.md).

For each active lane, the address is `BaseGPR` plus the index value. The index is a logical element index: an S32, U32, S64, or U64 value that is scaled by the transfer element size or decomposed.

Design point: the Tile-level `MSCATTER` probes every active lane for write permission before it commits any store. A translation or permission fault found while probing therefore leaves no store of this scatter in GM. Only after every probe succeeds are the stores committed and their store events recorded.

Design point: when two lanes name the same address, the lane that wins is implementation-defined. The commit order of lanes is chosen arbitrarily in the ASL, and a `B.CATR` atomic attribute does not select one. A program that needs a defined result must avoid duplicate indices.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` is the transfer element type. The data Tile must have exactly this type.
- `B.DIM` `LB0`, `LB1`, and `LB2` must equal the data Tile's ValidCol, ValidRow, and physical Col.
- The first `B.IOT` has no destination and a `SizeCode` of zero. It carries the data Tile in `source0` and the index Tile in `source1`. Without a predicate-Tile ExecutionMask it is the only binding and carries `last`.
- `B.IOR` is required. `RegSrc0` selects the per-PE `BaseGPR`; `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero. `RegSrc0` equal to `zero` supplies base address zero.
- The optional `B.DATR` selects the layout: `ROWMAJOR`, `CUBE_M16`, or `CUBE_M32`; `CUBE_N8` is rejected. Both Tiles must use the bundle layout.

Design point: `B.DIM` restates the shape of an existing Tile instead of describing a new destination. The handler compares the data Tile's valid rows, valid columns, and physical columns with the dimension values, so the bundle must describe that Tile exactly.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-effects role=effects -->
## Pending state and completion

Each active lane stores one transfer element. For a packed four-bit `DataType`, each index names one byte, which receives the low nibble from data column `2 * c` and the high nibble from column `2 * c + 1`. The data ValidCol must then be exactly twice the index ValidCol, so no pair is incomplete.

On success the handler finalizes the attempt; no Tile is published. PTO memory ordering is unchanged, apart from the implementation-defined order among duplicate addresses.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-constraints role=constraints -->
## Legality and fault boundary

`PE_MASK=0000` is a strict no-op before schema, source, GPR, dimension, address, or memory checks. Otherwise all bindings must use one `PE_MASK`.

An unknown TLSU operation code raises `Fault_IllegalInstruction`. A `B.IOS` binding, a missing or nonzero-field `B.IOR`, a malformed binding schema, an undefined source element, a wrong type or layout, a shape mismatch, or a dimension outside `BundleMGATHERDimensionsLegal` raises `Fault_TileLegality` before the first probe. For `ROWMAJOR`, that check requires ValidCol not above Col and Col a nonzero power of two.

A memory fault keeps its own kind. There is no destination to roll back, and the bundle stays active for a retry, as [commit validation](../model/commit/validation.md) describes.

<!-- PTO-READER-BLOCK: block-bstart-mscatter-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.MSCATTER FP32
B.DIM zero, 16, ->LB0
B.DIM zero, 2, ->LB1
B.DIM zero, 16, ->LB2
B.IOT T#2, T#1, mask=1111, last
B.IOR a0, zero, zero, ->zero
BSTOP
```

The data Tile `T#2` is a 2 x 16 `FP32` row-major Tile with 16 physical columns, and the index Tile `T#1` is a 2 x 16 `S32` Tile. On each PE, 32 lanes are probed and then 32 stores are committed. A lane whose index is 40 writes 4 bytes at `a0 + 40`; the index is not multiplied by 4.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_32_0f0ba08bd798 | L32 | 32 | 0x00511181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_32_0f0ba08bd798 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_mscatter_32_0f0ba08bd798 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | memory transfer element type selector | Encoded zero supplies numeric zero for the memory transfer element type selector. |

- `bstart_mscatter_32_0f0ba08bd798.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | memory transfer element type selector |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_32_0f0ba08bd798);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER()
    => TileOperation
begin
    return TileOperation_MSCATTER;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies DataTile or destination physical Col; omitted LB1 and LB2 default to one and LB0 respectively.
- IndexTile entries are S32, U32, S64, or U64 logical element indices; each index is scaled by the transfer element width and is not decomposed.

## Legality

- Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 5 with the encoded transfer DataType.
- No Tile is allocated and no source is consumed by the start instruction.

## Memory effects and ordering

### Memory effects

- Each indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the logical element index scaled by the transfer element width.
- All valid addresses are preflighted before the first architectural effect.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
