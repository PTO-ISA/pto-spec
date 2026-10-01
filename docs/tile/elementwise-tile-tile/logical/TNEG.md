<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
# TNEG

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TNEG.asl`

Typed elementwise arithmetic negation over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TNEG}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tneg-purpose role=purpose -->
## What TNEG does

`TNEG` negates every element of one Local Tile and writes the results into a newly allocated Local destination Tile. Integers are negated with wraparound at the element width; floating-point values have their sign bit flipped.

Design point: `TNEG` has no standalone opcode. `BSTART.VEC` Mode 0 Function 17 (TEPL selector `0x011`) selects it, and it shares the closed unary bundle schema with `TABS`, `TNOT`, and `TRELU`.

<!-- PTO-READER-BLOCK: tile-tneg-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileUnary` reads the source and transforms each coordinate of the valid rectangle `ValidRow x ValidCol`.

- Integer types, signed and unsigned: the result is `0 - source` modulo the element width. For `U8`, 1 becomes `0xFF`. For `S8`, -128 (`0x80`) stays `0x80`, because +128 is not representable.
- Floating-point types: only the sign bit is toggled. Positive and negative zero exchange encodings, infinities change sign, and a NaN keeps its class and payload.

Design point: floating `TNEG` is a sign-bit toggle, not a subtraction from zero. It therefore never rounds, never reports an invalid condition (even for a signaling NaN), and maps positive zero to negative zero, which `0 - x` would not do.

Design point: before any effect, every valid-region source element (every active one, when an ExecutionMask is in force) must be a valid encoding of the selected `DataType`. Invalid floating encodings, such as a `TF32` value with nonzero low mantissa bits, are rejected even though the transform only touches the sign bit.

<!-- PTO-READER-BLOCK: tile-tneg-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the negation source. It is an existing, allocated Local Tile.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its physical shape, valid shape, and layout match the source.

One terminating `B.IOT` binds both Tiles under a single `PE_MASK`; `B.IOR` and `B.IOS` are illegal. The source may use a different same-width, non-packed backing type; its bits are then validated and interpreted as the selected `DataType`.

<!-- PTO-READER-BLOCK: tile-tneg-effects role=effects -->
## Publication, definedness, and padding

The source payload is snapshotted before the first destination write, so a source that aliases the destination is read with its old values.

The destination descriptor, the valid-region results, the padding, and every element's definedness publish together. Elements outside `ValidRow x ValidCol` receive the selected `PadValue`: `Zero`, `Max`, and `Min` are defined, and `Null`, the value when `B.DATR` is omitted, leaves them undefined. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value. `TNEG` has no global-memory effect.

<!-- PTO-READER-BLOCK: tile-tneg-constraints role=constraints -->
## Type, layout, and fault boundary

The ASL type predicate `TileTNegDataTypeSupported` accepts `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. Packed four-bit formats are excluded. The layout is `RowMajor` by default, or `CUBE_M16` or `CUBE_M32` when an explicit `Layout` selects it; `CUBE_N8`, Shared Tiles, and mixed layouts are illegal.

`PE_MASK=0000` is a strict no-op. Otherwise, malformed bindings, missing or zero dimensions, undefined or mismatched source state, an unsupported `DataType`, a non-selected layout, a nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, or `RMode`, or an invalid floating source encoding raises `Fault_TileLegality` before any effect. An unrepresentable destination shape or insufficient `TSize` capacity raises `Fault_TileAllocation` before allocation.

<!-- PTO-READER-BLOCK: tile-tneg-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

With `DataType=S8`, valid elements `[5, -3, 0, -128]` become `[-5, 3, 0, -128]`. With `DataType=FP32`, `0x3F800000` (1.0) becomes `0xBF800000` (-1.0), and `0x00000000` (positive zero) becomes `0x80000000` (negative zero).

In macro form, `TNEG <Row=8, Col=64, FP32>, T#1, ->T<2KB>` negates all 8 x 64 elements of an `FP32` Tile into a new 2 KB destination.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TNEG <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TNEG | TEPL | 0x011 | 17 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | negation source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
```asl
readonly func InstructionContractOperation_TNEG() => TileOperation
begin
    return TileOperation_TNEG;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TNEG, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
```asl
pure func InstructionContractDataTypeLegal_TNEG(
    data_type: TileDataType) => boolean
begin
    return TileTNegDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TNEG(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_NEG,
        destination,
        source);
end;

pure func InstructionContractValue_TNEG(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_NEG,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TNEG() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TNEG(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_NEG, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Integer negation is zero minus the source modulo the selected element width, including unsigned types. Floating negation toggles only the sign bit, preserving zeros, infinities, NaN class, and NaN payload without reporting invalid solely for TNEG.

## Legality

- TNEG is BSTART.VEC Mode 0 Function 17 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, S16, S8, FP32, FP16, or BF16.
- Source and destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; the source valid region is fully defined.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For every valid coordinate, negate modulo the selected integer width or toggle only the floating sign bit according to DataType.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.
- Source-to-destination aliasing therefore observes the complete pre-operation source payload.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-selected layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.
- This operation introduces no memory fault and reports no floating invalid condition solely from its value transform.

## Examples

- BSTART.VEC TNEG, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
