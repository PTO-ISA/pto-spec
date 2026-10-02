<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
# MGATHER_CAS

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl`

atomic compare-and-swap gather using explicit logical element indices.

## Normative identity {#PTO-INST-TILE-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-cas-purpose role=purpose -->
## What MGATHER_CAS does

`MGATHER_CAS` performs one atomic compare-and-swap in global memory (GM) per lane and returns the value each lane observed in a new Local destination Tile. It is a selector-encoded Tile operation of engine `TLSU`, selected by TLSU Function 8 and spelled `BSTART.MGATHER.CAS DataType`. The block dispatcher `ExecuteBundleMGATHERCASOperation` resolves the bundle and then calls the body `MGATHER_CAS`.

A lane is one coordinate of the index Tile's valid region. The compared address is `BaseGPR` plus that lane's index value used as a logical element index. `MGATHER_CAS` has no standalone opcode.

Design point: the destination carries the observed old value, not the value written. A lane whose compare fails still reports what GM then held, so software can tell a successful swap from a failed one without a second read.

<!-- PTO-READER-BLOCK: tile-mgather-cas-mechanism role=mechanism -->
## Two-command schema and the atomic mechanism

`ExecuteBundleMGATHERCASOperation` calls `MGATHER_CAS`, a body of its own that makes two passes. Function 8 never reaches the shared atom body `GMRunAtomic`: `BundleMGATHERCASSelected` claims the block before `BundleGMAtomRedSelected`, so the atom/red dispatcher and its `GM_ATOM_CAS` wrapper do not run for this function.

The preflight pass visits every active coordinate and builds the address with `TileMemoryByteDisplacementAddress`. It probes that address with `ProbeTileMemoryAccess` once for read and once for write, raises the probe's own fault through `RaiseDataAccessFault`, and raises `Fault_DataPage` when the two probes translate to different addresses. It also snapshots the index, expected, and replacement elements.

The commit pass initializes every physical destination element, then visits the lanes in an order chosen by `ARBITRARY` choices. Each lane loads the old value, compares it with the expected element at the element width, stores the replacement only when the two are equal, writes the old value into its destination element, and records one atomic event whose write flag reports whether that store happened.

Design point: the two probes must agree on the translated address. If they do not, the request raises `Fault_DataPage` during preflight, so it can never store through an address whose write-side translation was not checked. Both probes and all snapshotting finish before the first load or store of the commit pass.

<!-- PTO-READER-BLOCK: tile-mgather-cas-inputs role=inputs-outputs -->
## Operand roles and bindings

- `destination0` is a new Local Tile with the bundle `DataType`. It receives the observed old values.
- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the current memory agent's register file.
- `source0` is the index Tile: `S32`, `U32`, `S64`, or `U64` logical element indices.
- `source1` is the expected Tile, compared against the old value of the addressed element.
- `source2` is the replacement Tile, stored when the comparison matches.

`B.IOR` is required, and `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero. This is a two-command form: `BundleMGATHERCASBindingsLegal` requires exactly two tile bindings, the first carrying the index and expected Tiles with no destination and no `last`, and the second carrying the replacement Tile, the destination, and `last`. With a predicate-Tile ExecutionMask the predicate Tile becomes the first source of the first binding, which moves the index Tile to that binding's second source and the replacement Tile to the second binding's second source.

<!-- PTO-READER-BLOCK: tile-mgather-cas-effects role=effects -->
## GM, destination, and fault effects

`B.DATR` is optional and absent from the block composition of this form. When it is omitted, `_BundleDataAttributesPresent` is false, so `CurrentBundlePadValue` returns `TilePad_Null` and `TilePadValueForDataType` maps that to zero bits. Every physical destination element outside the valid region is set to that pad value, and the region is marked defined.

A lane whose comparison matches stores the replacement. A lane whose comparison fails stores nothing and still publishes its observed old value. In both cases the destination element receives the old value.

On a successful attempt the destination is published. On a preflight fault the dispatcher calls `RollBackBundleTileDestinations` and no destination is published, and the body has by then performed no store.

<!-- PTO-READER-BLOCK: tile-mgather-cas-constraints role=constraints -->
## Types, shape, and fault boundary

Only `U16`, `U32`, and `U64` transfer `DataType` values are accepted. `GMAtomicOperationDataTypeLegal` admits exactly those three for `GMAtomic_CAS`, and the dispatcher independently re-checks the same three. The index Tile must still be `S32`, `U32`, `S64`, or `U64` through `IndexedTLSUMemoryIndexDataTypeLegal`.

The destination, index, expected, and replacement Tiles must all use the bundle layout, and the index, expected, and replacement Tiles must each have the same valid rows and valid columns as the destination. Layouts are `ROWMAJOR`, `CUBE_M16`, and `CUBE_M32`; `IndexedTLSULayoutSupported` rejects `CUBE_N8`, and each `B.DIM` value must lie in `1..65535`.

A decoded selector code of nothing raises `Fault_IllegalInstruction`. A wrong number of tile bindings, a missing `B.IOR`, an undefined active index, expected, or replacement element, or a wrong type, shape, or layout raises `Fault_TileLegality`. A misaligned lane address raises `Fault_DataAlignment` and a read and write translation mismatch raises `Fault_DataPage`, both during preflight.

Design point: an atom form may not be used as a producer. `BundleProducerEffectClassOfHandler` classifies `TileHandler_GM_ATOM_CAS` as `BundleProducerEffect_NonRollbackAuxiliary`, and `BundleProducerEffectEligible` rejects that class when the bundle carries an assemble modifier, because the GM updates an atom performs are not rolled back.

<!-- PTO-READER-BLOCK: tile-mgather-cas-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

Take a 1 by 4 `U64` index Tile holding `0, 8, 0, 16`, a base address `0x2000` in `a0`, an expected Tile holding `7, 3, 5, 9`, and a replacement Tile holding `70, 30, 50, 90`. GM holds the `U64` values `7` at `0x2000`, `3` at `0x2008`, and `9` at `0x2010`.

- Lanes `0` and `2` both address `0x2000`. Lane `0` expects `7` and matches, so it stores `70`; lane `2` expects `5`, so it never matches. GM ends at `70` whichever of the two runs first.
- Lane `1` addresses `0x2008` and matches the stored `3`, so it stores `30`.
- Lane `3` addresses `0x2010` and matches the stored `9`, so it stores `90`.

Every destination element receives the old value its own lane observed: lane `0` reports `7`, lane `1` reports `3`, lane `3` reports `9`, and lane `2` reports `7` if it ran first or `70` if lane `0` ran first.

In macro form this is `MGATHER_CAS <Col=4, U64>, [base=a0], T#1, T#2, T#3, ->T<128B>`, with `T#1` as the index Tile, `T#2` as the expected Tile, and `T#3` as the replacement Tile. The 128-byte destination holds 16 `U64` physical elements: the 4 valid ones receive the observed values and the other 12 receive zero bits from the default pad value.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_CAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_CAS | TLSU |  | 8 |  | GM_ATOM_CAS |

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
| source1 | expected |
| source2 | replacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractMatches_MGATHER_CAS(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_CAS() => TileSemanticHandler
begin
    return TileHandler_GM_ATOM_CAS;
end;
readonly func InstructionContractOperation_MGATHER_CAS() => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- IndexTile entries are S32, U32, S64, or U64 logical element indices; each index is scaled by the transfer element width and is not decomposed.

## Legality

- Only U16, U32, and U64 transfer DataTypes are accepted; packed four-bit and every other existing unsupported atomic DataType remain illegal.
- Index, Expected, Replacement, and destination have equal logical valid shape and layout class.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each valid coordinate performs one atomic compare-and-swap at BaseGPR plus the sign- or zero-extended logical element index scaled by the transfer element width.
- All read/write probes complete before the first atomic effect; observed old values publish in the destination and non-valid physical elements contain PadValue.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER.CAS DataType; B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
