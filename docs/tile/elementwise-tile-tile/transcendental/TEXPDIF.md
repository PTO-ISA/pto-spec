<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl -->
# TEXPDIF

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl`

Compute natural exp(src0-src1) elementwise over two full-shape Local Tiles.

## Normative identity {#PTO-INST-TILE-TEXPDIF}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-texpdif-purpose role=purpose -->
## What TEXPDIF does

`TEXPDIF` computes `exp(source0 - source1)` element by element over two Local floating Tiles and writes the results into a newly allocated Local destination Tile. Unlike `TADD`, the destination type may be wider than the source type, and the operation runs on the `SFU` engine.

Design point: `TEXPDIF` is selected by TEPL Mode 0 Function 29 (selector `0x01D`) and has no standalone opcode. Its canonical header is `BSTART.SFU TEXPDIF, SrcOperationType`. The header type names the source operation type; the destination type comes from `B.DATR`.

<!-- PTO-READER-BLOCK: tile-texpdif-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, both sources are snapshotted, and each coordinate in the valid rectangle `ValidRow x ValidCol` is computed independently. `source0` is always the minuend and `source1` the subtrahend. Both sources cover the full valid rectangle; `TEXPDIF` does not broadcast a row or a column.

For a same-type pair, the operation performs a typed subtraction in that type, then a typed natural exponential. Both steps use the fixed default rounding, and the exponential applies the same special-input table as `TEXP`.

For a mixed pair, `FP16` or `BF16` sources with an `FP32` destination, both inputs are first widened exactly to `FP32`. The subtraction and the exponential are then performed in `FP32`.

Design point: widening an `FP16` or `BF16` value to `FP32` loses nothing, so it is defined as an interpretation step rather than a `TCVT` conversion and adds no inexact status. The difference is then rounded to `FP32` precision rather than to 16-bit precision before the exponential is applied.

For each element, the status of the subtraction and of the exponential are ORed together. The status of all active elements is ORed again and recorded when the destination is published.

<!-- PTO-READER-BLOCK: tile-texpdif-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the persistent minuend, interpreted as `SrcOperationType`.
- `source1` is the persistent subtrahend, interpreted as `SrcOperationType`.
- `destination0` is a newly allocated Local Tile whose backing type is the destination type `DstDataType`.

One terminating `B.IOT` binds all three Tiles, and they share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before source descriptor reads, destination allocation, numeric status, or payload effects.

`DstDataType` is resolved from `B.DATR`. Omitting `B.DATR`, or encoding the `DataType` field as `DTYPE_NONE` (code 31), makes the destination inherit `SrcOperationType`. An encoded `DataType` of zero selects `FP64`, which is not a legal destination and therefore rejects.

Design point: code 0 already names `FP64`, so inheritance needs a separate sentinel. Using `DTYPE_NONE` keeps "no destination type requested" distinct from a real type request.

Each source backing type may differ independently from `SrcOperationType` when both types are non-packed, have the same element width, and are carrier-compatible. The source bits are validated and interpreted as `SrcOperationType`, and the source descriptors are not retagged.

<!-- PTO-READER-BLOCK: tile-texpdif-effects role=effects -->
## Publication, definedness, and padding

The destination descriptor, the valid-region results, the padding, the definedness of every element, and the accumulated numeric status are published together. A rejected bundle publishes no destination payload, padding, descriptor, or status, and both sources remain unchanged.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the destination type; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

Because both sources are snapshotted before any result is written, a legal alias between a source and the destination reads the old source values. `TEXPDIF` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value and contribute no status.

<!-- PTO-READER-BLOCK: tile-texpdif-constraints role=constraints -->
## Type, layout, and fault boundary

The only legal `(SrcOperationType,DstDataType)` pairs are `(FP16,FP16)`, `(BF16,BF16)`, `(FP32,FP32)`, `(FP16,FP32)`, and `(BF16,FP32)`. Every other pair, including a narrowing pair or an integer type, rejects.

The layout is `RowMajor`, `CUBE_M16`, or `CUBE_M32`, and all three operands must use the selected layout. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. The operands share `ValidRow` and `ValidCol`, but each descriptor's physical geometry is checked with its own type, so an `FP32` destination can have a different physical size from its `FP16` sources. `B.DATR` accepts only `Layout`, `DataType`, and `PadValue`; nondefault `CMode`, `RMode`, `Sat`, or `Canonicalize` is illegal.

Malformed or extra bindings, `B.IOR` or `B.IOS`, an illegal type pair, a packed or width-changing source carrier, invalid or undefined source contents, a layout or shape mismatch, or bad dimensions raise `Fault_TileLegality`. An unrepresentable destination shape or insufficient capacity raises `Fault_TileAllocation`. Both faults occur before any destination effect.

<!-- PTO-READER-BLOCK: tile-texpdif-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For the mixed pair `(FP16,FP32)`, a minuend row `[1.0, 2.0]` and a subtrahend row `[1.0, 1.0]` are widened to `FP32`, giving the differences `[0.0, 1.0]`. The destination row is `[1.0, e]` in `FP32`, where `exp(0)` is exactly `1.0` and `e` is approximately 2.71828.

For an 8 x 64 valid shape in `RowMajor`, each `FP16` source holds 8 x 64 x 2 = 1024 bytes, and the `FP32` destination needs 8 x 64 x 4 = 2048 bytes. The header is `BSTART.SFU TEXPDIF, FP16`, and `B.DATR` selects the destination `DataType` `FP32`. The same-type `FP32` form needs no `B.DATR` and is written in macro form as `TEXPDIF <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TEXPDIF <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TEXPDIF | TEPL | 0x01D | 29 | 0 | ExecuteTileExpdif |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.DataType (`PTO-FIELD-BLOCK-DATATYPE`)

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

### B.DATR.PadValueOrByteId (`PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID`)

Carries the operation-selected PadValue or ByteId union field.

**Encoded zero:** For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | Zero-or-ByteId0 |
| 1 | assigned | Max-or-ByteId1 |
| 2 | assigned | Min-or-ByteId2 |
| 3 | assigned | Null-or-ByteId3 |

**Reserved-value behavior:** All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local DstDataType numeric destination |
| source0 | persistent Local SrcOperationType minuend |
| source1 | persistent Local SrcOperationType subtrahend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl -->
```asl
readonly func InstructionContractOperation_TEXPDIF() => TileOperation
begin
    return TileOperation_TEXPDIF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TEXPDIF, SrcOperationType
B.DATR Layout, DataType, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl -->
```asl
pure func InstructionContractDataTypeLegal_TEXPDIF(
    source_operation_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return TileExpdifTypePairLegal(
        source_operation_type, destination_type);
end;

readonly func InstructionContractOperandsLegal_TEXPDIF(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpdif(
        destination, source0, source1);
end;

readonly func InstructionContractHandler_TEXPDIF() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpdif;
end;

func InstructionContractExecute_TEXPDIF(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex)
begin
    ExecuteTileExpdif(destination, source0, source1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero and legal under the selected descriptor geometry.
- Omitted B.DATR selects Layout=NORM (RowMajor), DstDataType=SrcOperationType, and PadValue=Null. When B.DATR is present, DataType=DTYPE_NONE inherits SrcOperationType and a concrete DataType selects DstDataType; encoded DataType zero selects FP64 and is not absence.

## Legality

- TEXPDIF is TEPL Mode 0 Function 29 (selector 0x01D) on SFU; 0x01C remains TFMA and 0x01E..0x01F remain reserved.
- Exactly one terminating Local B.IOT supplies two ordered persistent Local numeric sources and one newly allocated Local numeric destination. B.IOR, B.IOS, additional bindings, and shared operands are illegal.
- The exact legal (SrcOperationType,DstDataType) pairs are (FP16,FP16), (BF16,BF16), (FP32,FP32), (FP16,FP32), and (BF16,FP32). All other pairs reject.
- Each source backing type may differ independently from SrcOperationType only when both types are non-packed, have equal element width, and TileCarrierWidthCompatible is true. Source payloads are validated and interpreted as SrcOperationType without retagging the source descriptors.
- The result for every valid coordinate is natural exp(src0-src1), with source0 as minuend and source1 as subtrahend. TEXPDIF does not broadcast.
- Same-type pairs perform typed SUB followed by typed natural EXP. Mixed FP16/BF16-to-FP32 pairs exactly widen both inputs to FP32 before FP32 SUB and FP32 natural EXP; widening is not TCVT and adds no conversion-inexact status.
- Only RowMajor, CUBE_M16, and CUBE_M32 are legal. CUBE_N8, Shared, unsupported layouts, and mixed operand layouts reject. Sources and destination share the selected layout and logical ValidRow x ValidCol; each descriptor's physical geometry is checked using its own backing/destination type.
- B.DATR Layout, DataType, and PadValueOrByteId are the only applicable nonzero fields. CMode, RMode, Sat, Canonicalize, and unrelated fields are illegal.
- PE_MASK=0000 is a strict no-op before source descriptor reads, destination allocation, numeric status, or payload effects.

## State effects

- For every valid logical coordinate compute exp(src0-src1) using the shared typed EXPDIF numeric owner and the selected natural-EXP profile.
- Mixed FP16/BF16-to-FP32 results use exact widening before FP32 subtraction; the destination has independently derived FP32 geometry and capacity.
- Apply the selected PadValue outside the valid result rectangle, then atomically publish destination state and accumulated numeric status.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- For nonzero participation, decode and validate commands, dimensions, type pair, source descriptors/carriers/definedness/encodings, destination size/capacity/name allocation, and destination geometry before result publication.
- Snapshot both complete sources before computing results. Legal same-width source/destination aliasing observes read-old/write-new behavior; source Tiles remain unchanged.
- For each valid element, OR SUB and EXP status; OR status across elements. Apply destination padding and publish the full destination descriptor, payload, definedness, and accumulated status atomically.

## Exceptions

- Malformed Local bindings, B.IOR or B.IOS presence, extra bindings, unsupported or reserved type pairs, packed or width-changing source carriers, invalid source encodings, undefined source contents, layout or logical-shape mismatch, invalid dimensions, or illegal source descriptors raise Fault_TileLegality before effects.
- An unrepresentable destination shape, insufficient TSize/capacity, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before publication.
- Rejection publishes no destination payload, padding, descriptor, or numeric status.

## Examples

- BSTART.SFU TEXPDIF, SrcOperationType; B.DATR Layout, DataType, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
