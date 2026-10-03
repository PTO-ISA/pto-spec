<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
# TFMA

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl`

Fused typed elementwise multiply-add over three Local Tile sources.

## Normative identity {#PTO-INST-TILE-TFMA}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tfma-purpose role=purpose -->
## What TFMA does

`TFMA` computes `left * right + addend` element by element over three Local Tiles and writes the results into a newly allocated Local destination Tile. Unlike `TADD`, it reads three sources.

Design point: `TFMA` is selected by `BSTART.VEC` Mode 0 Function 28 (TEPL selector `0x01C`) and has no standalone opcode. A single `B.IOT` carries at most two sources, so `TFMA` uses two `B.IOT` bindings: the first carries the two multiplicands, and the second carries the addend and the destination.

<!-- PTO-READER-BLOCK: tile-tfma-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, all three sources are snapshotted, and each coordinate in the valid rectangle `ValidRow x ValidCol` is computed independently.

For floating types the operation is fused. The exact product `left * right` is added to `addend` without rounding the product first, and only the final sum is rounded, using the profile's fixed default rounding (round to nearest even).

Design point: a fused operation rounds once, whereas `TMUL` followed by `TADD` rounds twice. The two sequences can therefore produce different results; the worked example below shows a case where the separate sequence loses the answer completely.

For integer types the result is `left * right + addend` reduced modulo the element width, and carrier bits above that width are zero. No status flag is produced for integers.

Certain floating inputs produce a quiet NaN and record the invalid flag: any signaling NaN operand, zero times infinity, infinity times zero, and an infinite product added to an infinity of the opposite sign. Status flags from all elements are ORed together and recorded when the result is published; they never cause a synchronous trap.

<!-- PTO-READER-BLOCK: tile-tfma-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the left multiplicand. It is bound as the first source of the first `B.IOT`.
- `source1` is the right multiplicand. It is bound as the second source of the first `B.IOT`.
- `source2` is the addend. It is bound as the source of the second, terminating `B.IOT`.
- `destination0` is a newly allocated Local Tile, bound by the second `B.IOT`.

The first `B.IOT` must have no destination and no last marker; the second must carry the destination and terminate the sequence. All participating `B.IOT` bindings must use the same `PE_MASK`, and `PE_MASK=0000` is a strict no-op.

Design point: all four Tiles must have exactly the same backing `DataType`, shape, and layout. Unlike `TADD`, `TFMA` does not accept a same-width source stored under a different backing type, so no source is reinterpreted.

<!-- PTO-READER-BLOCK: tile-tfma-effects role=effects -->
## Publication, definedness, and padding

The destination descriptor, the valid-region results, the padding, the definedness of every element, and the accumulated numeric status are published as one operation. A rejected bundle has no architectural effect, and all three sources persist unchanged.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the `DataType`; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

Duplicate sources and a source that aliases the destination observe the complete pre-operation values. `TFMA` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value and contribute no status.

<!-- PTO-READER-BLOCK: tile-tfma-constraints role=constraints -->
## Type, layout, and fault boundary

`TFMA` accepts exactly `FP64`, `S64`, `U64`, `FP16`, `FP32`, and `BF16`. The fused floating helper has finite execution for `FP64`, `FP32`, and `FP16`; the pre-existing admitted-`BF16` finite-result gap remains. Integer forms use the fixed-width fused rule.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32`, and all operands must use that same layout; among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. `TFMA` rejects nondefault `RMode`, `Sat`, `CMode`, and `Canonicalize`.

Malformed or surplus bindings, `B.IOR` or `B.IOS`, unequal masks, bad dimensions, an unsupported `DataType`, a layout mismatch, undefined sources, or invalid floating encodings raise `Fault_TileLegality`. An unrepresentable destination shape or insufficient capacity raises `Fault_TileAllocation`. Both faults occur before any destination effect.

<!-- PTO-READER-BLOCK: tile-tfma-example role=example -->
## Non-normative worked example

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

For `FP16`, take `left = right = 1.0009765625` and `addend = -1.001953125`. The exact product is `1.001953125 + 2^-20`, so `TFMA` returns `2^-20`, which is exactly representable in `FP16`. `TMUL` alone would round the product to `1.001953125`, and a following `TADD` would return `0`.

In macro form, an 8 x 64 `FP16` fused multiply-add is `TFMA <Row=8, Col=64, FP16>, T#1, T#2, T#3, ->T<1KB>`, where `T#1` and `T#2` are the multiplicands and `T#3` is the addend. The destination payload is 8 x 64 x 2 = 1024 bytes.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TFMA <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TFMA | TEPL | 0x01C | 28 | 0 | TFMA |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new renamed Local destination |
| source0 | left multiplicand Local source |
| source1 | right multiplicand Local source |
| source2 | fused addend Local source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
```asl
readonly func InstructionContractOperation_TFMA() => TileOperation
begin
    return TileOperation_TFMA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TFMA, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK
B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
```asl
pure func InstructionContractDataTypeLegal_TFMA(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex) => boolean
begin
    return TileOperandsLegal_TFMA(
        destination,
        source_left,
        source_right,
        addend);
end;

func InstructionContractValue_TFMA(
    data_type: TileDataType,
    left: Word,
    right: Word,
    addend: Word) => (Word, bits(5))
begin
    return TileFixedFusedMultiplyAddValue(
        data_type,
        left,
        right,
        addend);
end;

readonly func InstructionContractHandler_TFMA() => TileSemanticHandler
begin
    return TileHandler_TFMA;
end;

func InstructionContractExecute_TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex)
begin
    TFMA(
        destination,
        source_left,
        source_right,
        addend);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol. Physical rows derive exactly from TSize, Col, and DataType.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TFMA uses the selected numeric profile's fixed/default arithmetic rounding. It does not consume encoded RMode, Sat, or Canonicalize fields.

## Legality

- TFMA is selected by the TEPL encoding carrier Mode 0 Function 28, canonically assembled with BSTART.VEC, and has no standalone opcode.
- Exactly two ordered Local B.IOT bindings are required: the first supplies two multiplicands without a destination or last marker; the second supplies the addend and one new destination and terminates the sequence.
- DataType is exactly one of FP64, S64, U64, FP16, FP32, or BF16.
- All three sources and the destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; every valid source element is defined.
- Only B.DATR PadValueOrByteId is applicable. Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- B.IOR and B.IOS are illegal. All participating B.IOT masks are equal; PE_MASK zero is a strict no-op before source reads, allocation, arithmetic, flags, padding, or descriptor effects.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For floating DataTypes, each valid destination element is one fused left multiplied by right plus addend operation with no rounded intermediate product and one final profile rounding.
- For signed and unsigned integer DataTypes, each valid destination element is left multiplied by right plus addend modulo the element width; carrier bits above that width are zero.
- The selected PadValue defines or leaves undefined the physical destination region outside ValidRow by ValidCol without changing any source descriptor or source payload.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimension, DataType, layout, source-definedness, source-encoding, PE_MASK, destination-name, and capacity preflight precedes all three source snapshots.
- Duplicate sources and any source-to-destination alias observe complete pre-operation source payloads. Sources persist after both successful and rejected blocks.
- The complete result payload, selected padding definedness, sticky numeric flags, and renamed destination descriptor publish as one architectural operation; rejection has no architectural effect.

## Exceptions

- Malformed or surplus bindings, B.IOR or B.IOS, unequal masks, missing or invalid dimensions, unsupported DataType, non-selected layout, undefined source elements, mismatched descriptors, or invalid floating encodings raise Fault_TileLegality before effects.
- An unrepresentable destination shape, unavailable renamed destination, insufficient per-PE TSize, or exhausted architectural Tile capacity raises Fault_TileAllocation before allocation.
- A signaling NaN, zero multiplied by infinity, infinity multiplied by zero, or an infinite product added to an opposite-signed infinity produces a quiet NaN and records floating invalid without a synchronous trap.

## Examples

- BSTART.VEC TFMA, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK; B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
