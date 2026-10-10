<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
# TRELU

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TRELU.asl`

Same-type elementwise rectifier over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TRELU}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trelu-purpose role=purpose -->
## What TRELU does

`TRELU` applies the rectifier `max(x, 0)` to every element of one Local Tile and writes the results into a newly allocated Local destination Tile of the same `DataType`. Negative values and zeros become zero, positive values pass through, and floating NaNs are replaced as described below.

Design point: `TRELU` has no standalone opcode. `BSTART.VEC` Mode 0 Function 23 (TEPL selector `0x017`) selects it, and it shares the closed unary bundle schema with `TABS`, `TNOT`, and `TNEG`.

<!-- PTO-READER-BLOCK: tile-c-trelu-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileUnary` reads the source and transforms each coordinate of the valid rectangle `ValidRow x ValidCol`. The rule depends on the selected `DataType`.

- Signed integer types: a negative element becomes zero, and a nonnegative element is unchanged.
- Unsigned integer types: `TRELU` is the identity, because no element is negative.
- Floating-point types: negative finite values, negative infinity, negative zero, and positive zero all become positive zero. Positive finite values and positive infinity are unchanged.
- Floating-point NaN: a quiet or signaling NaN becomes the numeric profile's quiet NaN. A signaling NaN also records the invalid condition.

Design point: unlike `TABS` and `TNEG`, which only edit the sign bit, `TRELU` classifies each floating value with `TileNumericValueClass`. Both NaN classes map to the profile quiet NaN, so a NaN payload is not preserved, and a signaling NaN reports invalid. The invalid status is recorded only after complete legality preflight, together with the published result.

Design point: both signed zeros map to the positive-zero encoding, so a computed `TRELU` element is never a negative zero.

<!-- PTO-READER-BLOCK: tile-c-trelu-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the rectifier source. It is an existing, allocated Local Tile.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its physical shape, valid shape, and layout match the source.

One terminating `B.IOT` binds both Tiles under a single `PE_MASK`; `B.IOR` and `B.IOS` are illegal. Once the `B.IOT` encoding itself is well formed, `PE_MASK=0000` is a strict no-op.

The source may use a different same-width, non-packed backing type. Its bits are then validated and interpreted as the selected `DataType`. Every valid-region element (every active one, when an ExecutionMask is in force) must be defined and a valid encoding of that type.

<!-- PTO-READER-BLOCK: tile-c-trelu-effects role=effects -->
## Publication, definedness, and padding

The source payload is snapshotted before the first destination write, so a source that aliases the destination is read with its old values.

The destination descriptor, the valid-region results, the padding, the definedness of every element, and any invalid status publish together. A rejected `TRELU` has no architectural effect.

Elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero`, `Max`, and `Min` are defined; `Null`, selected when `B.DATR` is omitted, leaves them undefined.

When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value and contribute no status. `TRELU` has no global-memory effect.

<!-- PTO-READER-BLOCK: tile-c-trelu-constraints role=constraints -->
## Type, layout, and fault boundary

`TRELU` accepts exactly `FP64`, `S64`, `U64`, `FP16`, `BF16`, `FP32`, and `S32`. Every admitted type has an executable ReLU result.

The layout is `RowMajor` by default, or `CUBE_M16` or `CUBE_M32` when an explicit `Layout` selects it. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. Nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, or `RMode` is illegal. Among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it.

Malformed bindings, missing or zero dimensions, undefined or mismatched source state, an unsupported `DataType`, a non-selected layout, or an invalid floating source encoding raises `Fault_TileLegality` before any effect. An unrepresentable destination shape or insufficient `TSize` capacity raises `Fault_TileAllocation` before allocation.

<!-- PTO-READER-BLOCK: tile-c-trelu-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

With `DataType=S32`, valid elements `[-7, 0, 9]` become `[0, 0, 9]`. With `DataType=FP16`, `0xC000` (-2.0) and `0x8000` (negative zero) both become `0x0000`, while `0x3C00` (1.0) is unchanged.

In macro form, `TRELU <Row=8, Col=64, FP16>, T#1, ->T<1KB>` rectifies all 8 x 64 elements of an `FP16` Tile into a new 1 KB destination.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TRELU <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TRELU | TEPL | 0x017 | 23 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | rectifier source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
```asl
readonly func InstructionContractOperation_TRELU() => TileOperation
begin
    return TileOperation_TRELU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TRELU, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
```asl
pure func InstructionContractDataTypeLegal_TRELU(
    data_type: TileDataType) => boolean
begin
    return TileTReluDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TRELU(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_RELU,
        destination,
        source);
end;

pure func InstructionContractValue_TRELU(
    data_type: TileDataType,
    source: Word) => (Word, boolean)
begin
    return TileFixedUnaryValue(
        TileUnary_RELU,
        data_type,
        source);
end;

readonly func InstructionContractHandler_TRELU() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TRELU(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_RELU, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Signed negative integers become zero and unsigned integers are unchanged. Floating negative finite values, negative infinity, and both signed zeros become positive zero; positive values and positive infinity are preserved; NaNs become the profile quiet NaN and signaling NaN reports invalid.

## Legality

- TRELU is BSTART.VEC Mode 0 Function 23 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of FP64, S64, U64, FP16, BF16, FP32, or S32.
- Source and destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; the source valid region is fully defined.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For every valid coordinate, apply the same-type integer or floating rectifier selected by DataType.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.
- Source-to-destination aliasing therefore observes the complete pre-operation source payload.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-selected layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.
- For TRELU, a signaling NaN publishes the profile quiet NaN and records the selected numeric-profile invalid condition only after complete legality preflight.

## Examples

- BSTART.VEC TRELU, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
