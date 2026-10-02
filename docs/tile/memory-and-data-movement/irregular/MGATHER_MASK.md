<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
# MGATHER_MASK

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl`

Masked gather using explicit logical element indices.

## Normative identity {#PTO-INST-TILE-MGATHER-MASK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-mask-purpose role=purpose -->
## What MGATHER_MASK does

`MGATHER_MASK` is a masked gather. It reads global memory (GM) at one address per enabled lane and writes the result into a new Local destination Tile; a lane whose predicate is `0` is not read at all. It is a selector-encoded Tile operation of engine `TLSU`, selected by TLSU Function 6 and spelled `BSTART.MGATHER.MASK DataType`. The block dispatcher `ExecuteBundleMGATHERMASKOperation` checks the bundle and then calls the shared tile model `MGATHER_MASK`.

A lane is one coordinate of the index Tile's valid region, and its predicate is the `U8` element of the second source at the same coordinate. `MGATHER_MASK` has no standalone opcode.

Design point: the per-lane predicate is data, not encoding. It lives in an ordinary Local `U8` Tile whose values are read while the operation runs, so one instruction encoding can gather a different lane subset on each execution.

<!-- PTO-READER-BLOCK: tile-mgather-mask-mechanism role=mechanism -->
## Predicate mechanism and two-phase execution

The model asserts that the index elements are defined, that the predicate values are legal through `IndexedTLSUPredicateValuesLegal`, and that the mask Tile's valid rows and valid columns equal the index Tile's. It then makes two passes over the index Tile.

The preflight pass visits every coordinate of the valid region. When the coordinate is active in the ExecutionMask and `ReadIndexedTLSUPredicate` reports `1` for it, the pass builds the address with `TileMemoryByteDisplacementAddress`, probes it with `ProbeTileMemoryAccess`, raises the probe's fault through `RaiseDataAccessFault` if the probe failed, and records the translated address and one active lane.

The commit pass fills every physical destination element, then loads and records one load event for each active lane only.

Design point: every enabled address is translated and checked before the first load, so all `MGATHER_MASK` faults that come from addresses are known before any data movement. A faulting request has performed no load, which is what lets a masked gather be restarted as a whole.

<!-- PTO-READER-BLOCK: tile-mgather-mask-inputs role=inputs-outputs -->
## Operand roles and the two predicate sources

- `destination0` is a new Local Tile with the bundle `DataType` and the `B.DIM` shape. It receives the enabled loaded elements.
- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the current memory agent's register file.
- `source0` is the index Tile: `S32`, `U32`, `S64`, or `U64` logical element indices.
- `source1` is the predicate Tile: an ordinary Local `U8` carrier with one element per indexed transaction.

`B.IOR` is required, and `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero. `ExecuteBundleMGATHERMASKOperation` requires exactly one tile binding when no ExecutionMask is in force, so the form then terminates in one `B.IOT` that carries the index Tile, the predicate Tile, and the destination. A predicate-Tile ExecutionMask instead forces two bindings, where the first carries the two sources with no destination and no `last` and the second carries the predicate Tile as its only source together with the destination and `last`; unlike the `TGATHER` and `MSCATTER` families, whose mask domain comes from source ordinal `1`, `BundleExecutionMaskCoordinateSourceOrdinal` names ordinal `0` for `MGATHER_MASK`, so the index Tile supplies the coordinate domain of the mask.

<!-- PTO-READER-BLOCK: tile-mgather-mask-effects role=effects -->
## Publication, definedness, and padding

Every physical destination element is initialized before the first load. Elements outside the valid region receive the bundle `PadValue` through `TilePadValueForDataType`, which maps the default `TilePad_Null` to zero bits. Under an ExecutionMask, a valid-region coordinate that the mask does not activate receives `IndexedGatherInactiveDestinationValue` instead. A lane with predicate `0` keeps the pad value it was initialized with, so a disabled lane and a non-valid element end up with the same content.

Design point: a `0` predicate suppresses the whole memory path of that lane, not just the store. `ProbeTileMemoryAccess` is never called for it, so it generates no translated address, no permission or alignment check, no event, and no data-access fault. A program can therefore use the predicate Tile to keep an unmapped address out of the transaction set.

The region is marked defined with `MarkTilePhysicalRegionDefined`, which also sets `contents_defined`. If an enabled lane's probe faults, the model returns before its first load and the dispatcher calls `RollBackBundleTileDestinations`, so no destination is published.

<!-- PTO-READER-BLOCK: tile-mgather-mask-constraints role=constraints -->
## Types, shape, and fault boundary

The predicate Tile must be a Local `U8` carrier whose elements are each `0x00` or `0x01`. `IndexedTLSUPredicateValuesLegal` requires a `U8` descriptor in a supported layout, requires the tile to be defined where the check applies, and rejects the whole request for any other element value before effects. Its valid rows and valid columns must equal the index Tile's.

The index Tile must be `S32`, `U32`, `S64`, or `U64`. The transfer `DataType` must pass `IndexedTLSUOrdinaryTransferDataTypeLegal`, which admits every type `TileDataTypeIsFourBit` rejects plus the five four-bit types `E2M1X2`, `E1M2X2`, `HiF4X2`, `S4X2`, and `U4X2`. For a packed transfer the valid columns must be even and equal twice the index valid columns, and one predicate value then controls the complete byte pair.

Layouts are `ROWMAJOR`, `CUBE_M16`, and `CUBE_M32`; `IndexedTLSULayoutSupported` rejects `CUBE_N8`. A decoded selector code of nothing raises `Fault_IllegalInstruction`, and a binding, type, shape, or layout violation raises `Fault_TileLegality`. `PE_MASK=0000` exits at the top of the dispatcher, before all of those checks.

<!-- PTO-READER-BLOCK: tile-mgather-mask-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

Take a 1 by 4 `U32` index Tile holding `8, 0, 8, 4`, a 1 by 4 predicate Tile holding `1, 0, 1, 0`, a base address `0x1000` in `a0`, and GM holding the `U32` values `1, 2, 3, 4` at `0x1000`, `0x1004`, `0x1008`, and `0x100c`.

- Lane `0` has predicate `1`, so it reads `0x1008` and the destination element becomes `3`.
- Lane `1` has predicate `0`, so `0x1000` is never read and the destination element keeps the pad value, which is zero bits by default.
- Lane `2` has predicate `1`, so it reads `0x1008` as well and the destination element becomes `3`.
- Lane `3` has predicate `0`, so `0x1004` is never read and the destination element keeps the pad value.

In macro form this is `MGATHER_MASK <Col=4, U32>, [base=a0], T#1, T#2, ->T<128B>`, with `T#1` as the index Tile and `T#2` as the predicate Tile bound in the predicate-tile-source role. The valid region of the destination holds `3, 0, 3, 0`: the two enabled lanes carry loaded values and the two disabled lanes carry the pad value, which is zero bits because `B.DATR` was omitted.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_MASK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_MASK | TLSU |  | 6 |  | MGATHER_MASK |

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
| source0 | logical element indices |
| source1 | U8 PredicateTile |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
```asl
readonly func InstructionContractOperation_MGATHER_MASK() => TileOperation
begin
    return TileOperation_MGATHER_MASK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.MASK DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_MASK() => TileSemanticHandler
begin
    return TileHandler_MGATHER_MASK;
end;

pure func InstructionContractUsesLogicalElementIndices_MGATHER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER_MASK()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MGATHER_MASK()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- IndexTile entries are S32, U32, S64, or U64 logical element indices; each index is scaled by the transfer element width and is not decomposed.

## Legality

- PredicateTile is an ordinary Local U8 predicate carrier with one 0x00 or 0x01 element per indexed transaction; every other value rejects before effects.
- PredicateTile valid shape equals IndexTile valid shape and its producer DataType does not constrain the transfer DataType.
- Packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and one predicate controls the complete byte pair.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each enabled indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the logical element index scaled by the transfer element width.
- A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault and leaves the corresponding destination value(s) at PadValue.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
