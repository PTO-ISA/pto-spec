<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.asl -->
# BSTART.MGATHER

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.asl`

gather using explicit logical element indices.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-purpose role=purpose -->
## What BSTART.MGATHER contributes

`BSTART.MGATHER` opens a Tile memory block whose operation is `MGATHER`: an indexed load. Each active lane reads one transfer element from global memory (GM) at a base address plus that lane's logical element index and writes it into a new Local destination Tile. The block returns the destination and writes no memory.

The command is one 32-bit word with match `0x00411181` under mask `0x07ffffff`, so `DataType` occupies bits 31 to 27 and the fixed low bits carry TLSU selector 4. `BundleMGATHERSelected` matches that selector and `ExecuteBundleMGATHEROperation` runs the operation, whose decoded identity is `TileOperation_MGATHER`.

Design point: an index is a logical element index and is never scaled by the element size. A program that wants element-strided addresses multiplies its own indices, so the same index Tile can serve several transfer types without changing.

<!-- PTO-READER-BLOCK: block-bstart-mgather-mechanism role=mechanism -->
## Placement and mechanism

`ExecuteBundleMGATHEROperation` first declines a `PE_MASK=0000` block as a strict no-op, then decodes the TLSU selector and validates the schema: no Shared binding, exactly one Local binding, a valid `B.IOR`, complete bindings, legal GPR values, legal tile masks, and legal dimensions. It then checks the transfer data type, the index data type, the shape relation between the dimensions and the index Tile, the physical shape rule of the layout, and the bundle layout of every participating Tile.

The Tile-level body `MGATHER` probes every active lane address for read. Only after all probes succeed does it define the whole physical destination and load the active lanes, recording one load event per lane.

Design point: all probes run before the first load and before the destination is filled. A disabled or faulting address therefore stops the attempt with no partial destination: the dispatcher calls `RollBackBundleTileDestinations` and the block publishes nothing.

<!-- PTO-READER-BLOCK: block-bstart-mgather-inputs role=inputs-outputs -->
## Operands and header roles

- `DataType` is the transfer element type; it also fixes the width of each load.
- `B.DIM` `LB0` is ValidCol, `LB1` is ValidRow (default 1), and `LB2` is the physical Col (default `LB0`). The valid rows and valid columns must equal the index Tile's own valid shape.
- One terminating `B.IOT` carries the index Tile in `source0`, the `PE_MASK`, `last`, and a destination with a size code. A predicate-Tile ExecutionMask instead moves the destination into a second `B.IOT`, and the first record then carries the index Tile without a destination and without `last`.
- The index Tile is `S32`, `U32`, `S64`, or `U64`, uses the bundle layout, and holds logical element indices.
- `B.IOR BaseGPR, zero, zero, ->zero` is required: `RegSrc0` selects the per-PE base address GPR, `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero, and a `RegSrc0` of `zero` supplies base address zero.

<!-- PTO-READER-BLOCK: block-bstart-mgather-effects role=effects -->
## Pending state and completion

For each active lane, the destination element at the same row and column receives the loaded element. For a packed four-bit type, one indexed byte supplies two adjacent logical nibbles, so the destination valid columns are exactly twice the index valid columns and no nibble pair is incomplete.

Before the loads, the complete physical destination region is defined: coordinates the ExecutionMask deactivates take the mask's zero or merge value, and every other element outside the active lanes takes the bundle `PadValue`. On success the full physical destination region is defined; a failing attempt publishes no destination.

Design point: because the destination is a new allocation rather than an existing Tile, the padding rule is what makes the result deterministic outside the valid region. A caller that reads the whole physical Tile never sees undefined bits, even where no lane wrote.

<!-- PTO-READER-BLOCK: block-bstart-mgather-constraints role=constraints -->
## Legality and fault boundary

- `PE_MASK=0000` is a strict no-op before every schema, source, GPR, dimension, allocation, and memory check.
- A reserved `DataType` code or an unknown TLSU selector raises `Fault_IllegalInstruction`.
- A `B.IOS` binding, a missing `B.IOR`, a nonzero unused `B.IOR` selector, a malformed binding schema, an index type other than `S32`, `U32`, `S64`, or `U64`, an undefined source, or a shape, layout, or dimension mismatch raises `Fault_TileLegality` before the first probe.
- The layout is `ROWMAJOR`, `CUBE_M16`, or `CUBE_M32`; `CUBE_N8` is rejected. For `ROWMAJOR` the physical columns must be a nonzero power of two and may not be smaller than the valid columns.
- If no free Local destination exists, resolution raises `Fault_TileAllocation`. A memory fault keeps its own kind, and no memory is modified by a gather.

<!-- PTO-READER-BLOCK: block-bstart-mgather-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.MGATHER U32
B.DIM zero, 4, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 4, ->LB2
B.IOT T#1, mask=1111, last, ->T<16B>
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` is a 1 by 4 `S32` index Tile holding the logical element indices `0`, `4`, `8`, and `12`, and `a0` holds `0x1000`. The four active lanes load from `0x1000`, `0x1004`, `0x1008`, and `0x100C`. The destination is a 1 by 4 `U32` Tile of 16 bytes, so all four elements receive a loaded value and the padding rule has no visible effect.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_32_c9defbf18276 | L32 | 32 | 0x00411181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_32_c9defbf18276 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mgather_32_c9defbf18276 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | tile element data type selector | Encoded zero supplies numeric zero for the tile element data type selector. |

- `bstart_mgather_32_c9defbf18276.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_32_c9defbf18276);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER()
    => TileOperation
begin
    return TileOperation_MGATHER;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER()
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

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the logical element index scaled by the transfer element width.
- All valid addresses are preflighted before the first architectural effect.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
