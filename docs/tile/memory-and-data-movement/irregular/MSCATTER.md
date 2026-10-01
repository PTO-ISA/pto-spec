<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
# MSCATTER

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER.asl`

scatter using explicit byte displacements.

## Normative identity {#PTO-INST-TILE-MSCATTER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-purpose role=purpose -->
## What MSCATTER does

`MSCATTER` is TLSU Function 5, written `BSTART.MSCATTER DataType`. It reads one Local data Tile and one Local index Tile and stores one transfer element, or one packed byte, per active valid coordinate of the index Tile, at the per-PE base address named by `B.IOR.RegSrc0` plus that coordinate's index value read as a byte displacement. A coordinate is active when no ExecutionMask is in force or when `BundleExecutionMaskActiveAt` selects it.

The owner declares `InstructionContractUsesByteDisplacements_MSCATTER` TRUE, `InstructionContractUsesMaskTile_MSCATTER` FALSE, `InstructionContractWritesMemory_MSCATTER` TRUE, and `InstructionContractIsAtomicMemoryOperation_MSCATTER` FALSE. The dispatcher `ExecuteBundleMSCATTEROperation` decodes Function 5, checks the binding shape, the dimensions, and the descriptors, then calls `TileOperandsLegal_MSCATTER` and the body `MSCATTER`.

Design point: `InstructionContractUsesMaskTile_MSCATTER` is FALSE and there is no per-lane predicate operand, so every active valid coordinate of the index Tile stores. The only per-coordinate filter this form accepts is the bundle ExecutionMask, whose coordinate source here is the index Tile.

<!-- PTO-READER-BLOCK: tile-mscatter-mechanism role=mechanism -->
## Addressing, preflight, and store commit

Each address is `base + displacement`, where the displacement is the complete index value in bytes. `S32` sign-extends, `U32` zero-extends, and `S64` and `U64` are used unchanged. It is never multiplied by the element size and never divided by `ValidCol` (NDF `PTO-INDEXED-TLSU-STRIDE-001`), so element-scaled addressing must be produced by scaling the indices.

The body runs two passes. Preflight walks the active coordinates, builds each address with `TileMemoryByteDisplacementAddress`, probes it for write access at element-width alignment with `ProbeTileMemoryAccess`, and records the original address, the translated address, and the source element bits; `RaiseDataAccessFault` ends the body at the first failing probe. The commit pass `CommitIndexedScatterTransactions` then stores those recorded values and records one store event per lane. `StoreTileMemoryElement` normalizes the value to the element width; a packed four-bit lane instead writes one assembled byte with `StoreTranslated`, taking the low nibble from the first logical element and the high nibble from the second.

Design point: the commit pass is entered only after preflight completes, so no store and no store event can precede a failing probe. A scatter with one bad active address leaves GM unchanged, and repeating it after the fault is fixed cannot apply a partial update.

Design point: the commit pass visits lanes in an order drawn from `ARBITRARY` choices, so duplicate or overlapping target addresses have an implementation-defined winner. NDF `PTO-MSCATTER-DUPLICATE-ORDER-001` states that `B.CATR.atomic` does not impose an internal lane order; it only makes the complete block effect non-interleavable. Two lanes storing different values to one address therefore leave a result that depends on the chosen order.

<!-- PTO-READER-BLOCK: tile-mscatter-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the executing PE's own register file; `B.IOR` is required and `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero.
- `source0` is the data Tile: bundle `DataType`, `LB1` valid rows, `LB0` valid columns, `LB2` physical columns, and the bundle layout.
- `source1` is the index Tile: `S32`, `U32`, `S64`, or `U64` elements, a valid shape that matches the data Tile, the bundle layout, and physical columns that are not compared with `LB2`.

Without a predicate-Tile ExecutionMask, one terminating `B.IOT` carries the data Tile and the index Tile and has no destination. With one, the first `B.IOT` carries both sources and is not `last`, and a second `B.IOT` carries the mask Tile as its only source and is `last`. All bindings must carry the same `PE_MASK`, and `PE_MASK=0000` on every binding is a strict no-op at the top of the dispatcher, before the decode, schema, GPR, dimension, descriptor, and memory checks.

The base register is read from the executing PE's own register file (`ReadPEAbsoluteGPROperand`), so PEs selected by one `PE_MASK` can use one index Tile to reach different GM regions.

<!-- PTO-READER-BLOCK: tile-mscatter-effects role=effects -->
## Effects, definedness, and padding

On success only GM and memory-event state change. No destination Tile is allocated, and the data Tile and the index Tile keep their descriptors and payloads after success or rejection.

Without an ExecutionMask, `IndexedTLSUExecutionMaskContentsDefined` requires the whole valid region of both Tiles to be defined. With one, it requires the same layout and valid shape as the mask and checks definedness only at the mask's active coordinates, so an undefined element that the mask excludes is tolerated.

`B.DATR` may set only `Layout` here: an explicit nonzero `PadValue` field is rejected because this form's pad union is `must-zero`, and there is no destination whose physical padding could receive a pad value. For the same reason a merge-mode ExecutionMask has nothing to write, and `PrepareSelectedBundleExecutionMaskMerge` finds no destination binding in this block.

<!-- PTO-READER-BLOCK: tile-mscatter-constraints role=constraints -->
## Type, layout, and fault boundary

The bundle `DataType` is carried by `BSTART.MSCATTER` and must equal the data Tile's type. NDF `PTO-MSCATTER-BYTE-DISPLACEMENT-001` requires `B8-NP`, `B16`, `B32`, `B64`, and packed four-bit transfer data with `S32`, `U32`, `S64`, or `U64` index elements, and requires raw carrier bits to move without numeric-validity rejection. The index Tile is never a four-bit carrier.

A packed four-bit transfer needs the data Tile's valid columns to be exactly twice the index Tile's, so `Data.ValidCol == 2 * Index.ValidCol` and an incomplete nibble pair is rejected. Layouts are `RowMajor`, `CUBE_M16`, and `CUBE_M32`; `CUBE_N8` is rejected, and `RowMajor` needs `ValidCol <= Col` with `Col` a nonzero power of two. Every `B.DIM` value must be in `1..65535`.

An unknown TLSU code raises `Fault_IllegalInstruction`. A missing `B.IOR`, a wrong `B.IOT` binding shape, an out-of-range dimension, a type, layout, or shape mismatch, or an undefined active source element raises `Fault_TileLegality`, the fault `ExecuteBundleMSCATTEROperation` uses for all of its schema checks. A failing probe raises `Fault_DataAlignment` or `Fault_DataPage` before the first store.

<!-- PTO-READER-BLOCK: tile-mscatter-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

Take `U32`, `ValidRow=1`, `ValidCol=2`, `Col=4`, base `0x1000` in `a0`, a 1 by 2 data Tile holding `7, 9`, and a 1 by 2 `U32` index Tile holding `4, 0`.

- Coordinate (0, 0) has displacement `4`, so `0x1004` receives `7`.
- Coordinate (0, 1) has displacement `0`, so `0x1000` receives `9`.
- Both probes must succeed first: `0x1000` and `0x1004` are 4-byte aligned and writable here, and one failing probe would suppress both stores.
- If both coordinates carried displacement `0`, both would store to `0x1000`, and the final content there would be `7` or `9` according to the implementation-defined commit order.

The macro spelling is `MSCATTER <Col=4, ValidCol=2, U32>, [base=a0], T#1, T#2`, where `T#1` is the data Tile and `T#2` is the index Tile.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER | TLSU |  | 5 |  | MSCATTER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | source data |
| source1 | byte-displacement indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER() => TileOperation
begin
    return TileOperation_MSCATTER;
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER() => TileSemanticHandler
begin
    return TileHandler_MSCATTER;
end;

pure func InstructionContractUsesByteDisplacements_MSCATTER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed.

## Legality

- Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Source Tile descriptors and payloads persist unchanged after success or rejection.
- On success only memory and memory-event state change; MSCATTER allocates no destination Tile.

## Memory effects and ordering

### Memory effects

- Each indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.
- All valid addresses are preflighted before the first architectural effect.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
