<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
# MSCATTER_MASK

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl`

Masked scatter using explicit byte displacements.

## Normative identity {#PTO-INST-TILE-MSCATTER-MASK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-mask-purpose role=purpose -->
## What MSCATTER_MASK does

`MSCATTER_MASK` is TLSU Function 7, written `BSTART.MSCATTER.MASK DataType`. Its addressing is the byte-displacement rule of `MSCATTER`: the per-PE base address named by `B.IOR.RegSrc0` plus the index value, and the stored value is the raw source element. The difference is a Local `U8` predicate Tile that decides which indexed transactions store. NDF `PTO-MSCATTER-MASK-PREDICATE-001` allows only `0x00` and `0x01` per transaction and states that a zero suppresses address generation, translation, permission checks, stores, and events.

The owner declares `InstructionContractUsesMaskTile_MSCATTER_MASK` TRUE and `InstructionContractWritesMemory_MSCATTER_MASK` TRUE. The dispatcher `ExecuteBundleMSCATTERMASKOperation` decodes Function 7, checks two `B.IOT` bindings and the descriptors, then calls `TileOperandsLegal_MSCATTER_MASK` and the body `MSCATTER_MASK`.

Design point: the lane test is `BundleExecutionMaskActiveAt(...) && ReadIndexedTLSUPredicate(mask, ...)`, and the address computation and the probe sit inside it. A lane whose predicate element is zero is therefore not translated and cannot fault, so an out-of-range or misaligned displacement is harmless while its predicate element is zero.

<!-- PTO-READER-BLOCK: tile-mscatter-mask-mechanism role=mechanism -->
## Two masks: ExecutionMask and predicate Tile

Two different masks can gate a lane, and they are not interchangeable.

The ExecutionMask is block-wide state. It is carried either by a GPR pair, which `BundleExecutionMaskGPRCarrierShapeLegal` accepts only for the `CUBE_M16` and `CUBE_M32` coordinate layouts, or by a predicate Tile whose storage kind is `TileStorage_PredicateCell`. Here its coordinate source is the index Tile, so its layout and valid shape follow that Tile. `CaptureBundleExecutionMaskPredicateTile` copies bit 0 of every element into a snapshot, and only that snapshot is consulted afterwards.

The `MaskTile` operand belongs to this instruction alone. It is a Local `U8` Tile with one element per indexed transaction, its valid rows and valid columns must equal the index Tile's, and its layout must equal the bundle layout. `IndexedTLSUPredicateValuesLegal` scans every element that the ExecutionMask leaves active and rejects the bundle unless each one is defined and is `0x00` or `0x01`.

Design point: that predicate scan belongs to legality, so it runs before any address exists. One element holding `0x02` rejects the whole bundle with `Fault_TileLegality`, and no lane stores, not merely the offending lane.

Design point: for a packed four-bit transfer the index Tile has half as many columns as the data Tile, so one predicate element covers both nibbles of one byte and they are enabled or suppressed together (NDF `PTO-MSCATTER-MASK-TYPE-002`).

<!-- PTO-READER-BLOCK: tile-mscatter-mask-inputs role=inputs-outputs -->
## Operand roles and bindings

- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the executing PE's own register file; `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero.
- `source0` is the data Tile: bundle `DataType`, `LB1` valid rows, `LB0` valid columns, `LB2` physical columns, and the bundle layout.
- `source1` is the index Tile: `S32`, `U32`, `S64`, or `U64` elements, the bundle layout, and a valid shape that matches the data Tile.
- `source2` is the mask Tile: a Local `U8` Tile whose valid shape equals the index Tile's and whose layout equals the bundle layout.

This form always binds exactly two `B.IOT` commands. The first carries the data Tile and the index Tile, has no destination, and is not `last`. The second carries the mask Tile as its source and is `last`; when a predicate-Tile ExecutionMask is in force, that same second `B.IOT` also carries the mask's predicate Tile as its second source. All bindings must carry the same `PE_MASK`.

`PE_MASK=0000` on every binding is a strict no-op at the top of the dispatcher, before the decode, schema, GPR, dimension, descriptor, and memory checks.

<!-- PTO-READER-BLOCK: tile-mscatter-mask-effects role=effects -->
## Memory effects, definedness, and padding

Each enabled transaction stores one transfer element at `base + displacement`, or one packed byte holding the low then the high logical nibble for a four-bit transfer. A disabled transaction performs no address generation, no translation, no permission check, no probe, no access, and no event, so it also cannot raise a data-access fault.

As in the unmasked form, both source Tiles must be defined over the whole valid region when no ExecutionMask is in force, and only at the mask's active coordinates when one is. The mask Tile is read and never modified, and no destination Tile is allocated.

`B.DATR` may set only `Layout`: an explicit nonzero `PadValue` field is rejected because this form's pad union is `must-zero`. A merge-mode ExecutionMask also has no destination to fill, so `PrepareSelectedBundleExecutionMaskMerge` finds no destination binding in this block.

<!-- PTO-READER-BLOCK: tile-mscatter-mask-constraints role=constraints -->
## Type, layout, and fault boundary

The bundle `DataType` must equal the data Tile's type, and the index Tile is `S32`, `U32`, `S64`, or `U64`. NDF `PTO-MSCATTER-MASK-TYPE-002` requires packed four-bit transfer data to use two adjacent logical nibbles per indexed byte with one predicate per pair, and NDF `PTO-MSCATTER-MASK-DUPLICATE-001` gives duplicate enabled addresses an implementation-defined winner without imposing an internal enabled-lane order.

Layouts are `RowMajor`, `CUBE_M16`, and `CUBE_M32`, with `CUBE_N8` rejected, and `RowMajor` needs `ValidCol <= Col` with `Col` a nonzero power of two. The data, index, and mask Tiles must all carry the bundle layout.

`Fault_IllegalInstruction` covers an unknown TLSU code. `Fault_TileLegality` covers a missing `B.IOR`, a wrong `B.IOT` binding shape, an out-of-range dimension, a layout, type, or shape mismatch, a missing or undefined predicate element, and a predicate value other than `0x00` or `0x01`. A failing probe raises `Fault_DataAlignment` or `Fault_DataPage` before the first store.

<!-- PTO-READER-BLOCK: tile-mscatter-mask-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

Take `U32`, `ValidRow=1`, `ValidCol=2`, `Col=4`, base `0x1000` in `a0`, a data Tile holding `7, 9`, an index Tile holding `4, 0`, and a mask Tile holding `0, 1`.

- Coordinate (0, 0) is disabled, so displacement `4` generates no address and `0x1004` keeps its previous content.
- Coordinate (0, 1) is enabled, so displacement `0` stores `9` at `0x1000`.
- A mask Tile holding `2, 1` instead would fail `IndexedTLSUPredicateValuesLegal`, so neither store would happen.

The macro spelling is `MSCATTER_MASK <Col=4, ValidCol=2, U32>, [base=a0], T#1, T#2, PredicateTile2`, where `T#1` is the data Tile, `T#2` is the index Tile, and `PredicateTile2` is the mask Tile.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_MASK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_MASK | TLSU |  | 7 |  | MSCATTER_MASK |

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
| source2 | U8 PredicateTile |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER_MASK() => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MASK DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK
B.IOT MaskTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_MASK() => TileSemanticHandler
begin
    return TileHandler_MSCATTER_MASK;
end;

pure func InstructionContractUsesByteDisplacements_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER_MASK()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER_MASK()
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

- PredicateTile is an ordinary Local U8 predicate carrier with one 0x00 or 0x01 element per indexed transaction; every other value rejects before effects.
- PredicateTile valid shape equals IndexTile valid shape and its producer DataType does not constrain the transfer DataType.
- Packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and one predicate controls the complete byte pair.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- All three source descriptors and payloads persist unchanged after success or rejection.
- On success only enabled-lane memory and event state changes; MSCATTER_MASK allocates no destination Tile.

## Memory effects and ordering

### Memory effects

- Each enabled indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.
- A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
