<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER.asl -->
# MGATHER

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER.asl`

gather using explicit byte displacements.

## Normative identity {#PTO-INST-TILE-MGATHER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-purpose role=purpose -->
## What MGATHER does

`MGATHER` reads global memory (GM) at one address per lane and writes the loaded elements into a new Local destination Tile. It is a selector-encoded Tile operation of engine `TLSU`, selected by TLSU Function 4 and spelled `BSTART.MGATHER DataType`. The block dispatcher `ExecuteBundleMGATHEROperation` checks the bundle and then calls the shared tile model `MGATHER`.

A lane is one coordinate of the index Tile's valid region. Its address is `BaseGPR` plus that lane's index value used as a byte displacement. `MGATHER` has no standalone opcode.

Design point: the number of lanes follows the index Tile's valid rectangle and not a memory layout, so the shape of the result is statically known even though the addresses are not. Four indices always produce a four-element valid region, however scattered those four addresses are.

<!-- PTO-READER-BLOCK: tile-mgather-mechanism role=mechanism -->
## Addressing and two-phase mechanism

The model makes two passes over the index Tile. The preflight pass visits every active coordinate of the valid region, builds the address with `TileMemoryByteDisplacementAddress` as base plus `TileIndexByteDisplacement`, and probes it with `ProbeTileMemoryAccess`. A failing probe raises its own fault through `RaiseDataAccessFault`. The displacement is the full index value in bytes: `S32` sign-extends and `U32` zero-extends, and it is never multiplied by the element width.

The commit pass fills every physical destination element, then loads only the preflighted lanes with `LoadTranslatedUnsigned`, records one load event per load through `RecordLoadEvent`, marks the region with `MarkTilePhysicalRegionDefined`, and installs the completed tile with one assignment.

Design point: the probe is a read probe only and touches neither memory nor the destination. Every lane address is therefore resolved, translated, and alignment-checked before the first load event and before any destination element changes. A faulting request leaves no partial destination, so retrying it cannot double-apply anything.

<!-- PTO-READER-BLOCK: tile-mgather-inputs role=inputs-outputs -->
## Operand roles and bindings

- `destination0` is a new Local Tile with the bundle `DataType` and the `B.DIM` shape. It receives the loaded elements.
- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the current memory agent's register file.
- `source0` is the index Tile: `S32`, `U32`, `S64`, or `U64`, sharing the bundle layout and the `B.DIM` valid rows and valid columns.

`B.IOR` is required, and `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero. Without a predicate-Tile ExecutionMask one terminating `B.IOT` carries the index Tile and the destination. With a predicate-Tile ExecutionMask the same command carries that predicate Tile as an additional Local source, so `ExecuteBundleMGATHEROperation` still sees exactly one tile binding. The index Tile is a Local operand and is never written.

<!-- PTO-READER-BLOCK: tile-mgather-effects role=effects -->
## Publication, definedness, and padding

Before the first load, the model initializes every physical destination element. Elements outside the valid region receive the bundle `PadValue` through `TilePadValueForDataType`. Under an ExecutionMask, a valid-region coordinate that the mask does not activate receives `IndexedGatherInactiveDestinationValue` instead: zero bits when the mask selects zero, otherwise the merge base element at the same coordinate. Preflighted lanes then overwrite their own element with the loaded value.

Design point: `TilePadValueForDataType` returns zero bits for `TilePad_Null`, and an omitted `B.DATR` makes `CurrentBundlePadValue` return `TilePad_Null`. Omitting the command and encoding pad code `00` therefore both write zero bits here, and every physical element is marked defined either way. A later read of a non-valid element returns zero rather than being undefined, so a consumer needs no validity test for the padding region.

On success the complete physical destination region is defined and `contents_defined` is true. If a probe faults, the model returns before its first load and the dispatcher calls `RollBackBundleTileDestinations`, so no destination is published.

<!-- PTO-READER-BLOCK: tile-mgather-constraints role=constraints -->
## Types, shape, and fault boundary

Index Tiles must be `S32`, `U32`, `S64`, or `U64` through `IndexedTLSUMemoryIndexDataTypeLegal`. The transfer `DataType` must pass `IndexedTLSUOrdinaryTransferDataTypeLegal`, which admits every type `TileDataTypeIsFourBit` rejects plus the five four-bit types `E2M1X2`, `E1M2X2`, `HiF4X2`, `S4X2`, and `U4X2`. For one of those five, valid columns must be even and equal twice the index valid columns, and the one indexed byte carries both logical nibbles.

Layouts are `ROWMAJOR`, `CUBE_M16`, and `CUBE_M32`; `IndexedTLSULayoutSupported` rejects `CUBE_N8`. Every `B.DIM` value must lie in `1..65535`, valid rows times valid columns may not exceed `PTO_MODEL_TILE_ELEMENTS`, and `ROWMAJOR` requires valid columns no greater than the physical columns, which must be a nonzero power of two.

A selector code that decodes to nothing raises `Fault_IllegalInstruction`. A wrong number of tile bindings, a Shared binding, a missing `B.IOR`, or a bad dimension, layout, index type, or transfer type raises `Fault_TileLegality`. `PE_MASK=0000` exits at the top of the dispatcher, before all of those checks.

<!-- PTO-READER-BLOCK: tile-mgather-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

Take a 1 by 4 `U32` index Tile holding `8, 0, 8, 4`, a base address `0x1000` in `a0`, and GM holding the `U32` values `1, 2, 3, 4` at `0x1000`, `0x1004`, `0x1008`, and `0x100c`. Each index is a byte displacement, so lanes `0` and `2` both load from `0x1008`, lane `1` loads from `0x1000`, and lane `3` loads from `0x1004`. The valid region of the destination holds `3, 1, 3, 2`.

In macro form this is `MGATHER <Col=4, U32>, [base=a0], T#1, ->T<128B>`, with `T#1` as the index Tile. The 128-byte destination holds 32 `U32` physical elements: the 4 valid ones receive the loaded values and the other 28 receive zero bits from the default pad value.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER | TLSU |  | 4 |  | MGATHER |

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
| destination0 | destination |
| address | base-address |
| source0 | byte-displacement indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER.asl -->
```asl
readonly func InstructionContractOperation_MGATHER() => TileOperation
begin
    return TileOperation_MGATHER;
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER.asl -->
```asl
readonly func InstructionContractHandler_MGATHER() => TileSemanticHandler
begin
    return TileHandler_MGATHER;
end;

pure func InstructionContractUsesByteDisplacements_MGATHER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MGATHER()
    => boolean
begin
    return FALSE;
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

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.
- All valid addresses are preflighted before the first architectural effect.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
