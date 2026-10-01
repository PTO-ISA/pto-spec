<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl -->
# TMIN

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl`

Minimum corresponding Local Tile elements under typed integer and floating ordering.

## Normative identity {#PTO-INST-TILE-TMIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmin-purpose role=purpose -->
## What TMIN does

`TMIN` compares two Local Tiles element by element and writes the smaller element of each pair into a newly allocated Local destination Tile. It shares the bundle schema, preflight, padding, and publication rules of `TADD`; the element operation is a typed selection instead of arithmetic.

Design point: `TMIN` is selected by `BSTART.VEC` Mode 0 Function 12 (TEPL selector `0x00C`) and has no standalone opcode. The same selection rules apply to its partner `TMAX`, which differs only in direction and in the sign it picks for a zero tie.

<!-- PTO-READER-BLOCK: tile-tmin-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileBinary` computes one result for each coordinate in the valid rectangle `ValidRow x ValidCol`. The result is always one of the two source values or a fixed special value; no rounding occurs.

Integer ordering follows the `DataType`. Signed types compare as signed values and unsigned types compare as unsigned values, so for `U8` the byte `0xFF` is 255 and loses against 1, while for `S8` the same byte is -1 and wins.

Floating ordering applies fixed special-value rules first:

- If exactly one operand is a NaN, the result is the other operand, unchanged.
- If both operands are NaNs, the result is the canonical NaN of the `DataType`.
- If both operands are zeros with different signs, the result is negative zero. Two zeros with the same sign keep that sign.
- Otherwise the numerically smaller operand is selected.

Design point: these rules make the result independent of operand order. Swapping `source0` and `source1` never changes a destination element, even for NaNs and signed zeros. A signaling NaN does not change the selected result either.

<!-- PTO-READER-BLOCK: tile-tmin-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the left comparison source. It is an existing, allocated Local Tile.
- `source1` is the right comparison source. It must match `source0` in physical rows, physical columns, valid rows, valid columns, and layout.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape matches the sources.

All three Tiles are bound by one terminating `B.IOT` and share one `PE_MASK`. `PE_MASK=0000` is a strict no-op. Both sources are read completely before the first destination write, so either source may alias the destination.

Design point: a source may be stored with a different same-width, non-packed backing type. Its bits are then validated and ordered as the selected `DataType`. Because signedness decides the order, reading `U8` data as `S8` can change which element wins.

<!-- PTO-READER-BLOCK: tile-tmin-effects role=effects -->
## Publication, definedness, and padding

The destination descriptor, the valid-region results, the padding, and the definedness of every element are published together. A rejected bundle publishes none of them, and both sources persist unchanged.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the `DataType`; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

`TMIN` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value instead of a selected value.

<!-- PTO-READER-BLOCK: tile-tmin-constraints role=constraints -->
## Type, layout, and fault boundary

The ASL legality predicate `TileVecArithmeticDataTypeSupported` accepts the 16 types `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. The generated legality list below is narrower and names only `S32`, `U32`, `FP32`, `S16`, `U16`, `FP16`, `BF16`, `S8`, and `U8`. Code that must satisfy both should use a type from the narrower list.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32`, and all operands must use that same layout. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal.

Every valid source element must be defined and, for floating types, must be a valid encoding of the selected `DataType`. Malformed bindings, missing or zero dimensions, mismatched sources, an unsupported `DataType`, an invalid encoding, or an invalid destination capacity raise `Fault_TileLegality` before any destination effect.

<!-- PTO-READER-BLOCK: tile-tmin-example role=example -->
## Non-normative worked example

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

For `FP32`, a left source row `[1.5, NaN, -0.0, 2.0]` and a right source row `[-3.0, 4.0, +0.0, NaN]` produce the destination row `[-3.0, 4.0, -0.0, 2.0]`. Each NaN is ignored in favor of the numeric operand, and the mixed-sign zero pair produces negative zero.

In macro form, an 8 x 64 `FP32` minimum is `TMIN <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`. The destination payload is 8 x 64 x 4 = 2048 bytes, exactly the 2KB capacity.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TMIN <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMIN | TEPL | 0x00C | 12 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | left comparison source |
| source1 | right comparison source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl -->
```asl
readonly func InstructionContractOperation_TMIN() => TileOperation
begin
    return TileOperation_TMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TMIN, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl -->
```asl
pure func InstructionContractDataTypeLegal_TMIN(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TMIN(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_MIN,
        destination,
        source_left,
        source_right);
end;

pure func InstructionContractFloatingValue_TMIN(
    data_type: TileDataType,
    source_left: Word,
    source_right: Word) => (Word, boolean)
begin
    assert InstructionContractDataTypeLegal_TMIN(data_type);
    assert TileDataTypeIsFloating(data_type);
    return TileFloatingMinMaxValue(
        TileBinary_MIN,
        data_type,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TMIN(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_MIN,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For floating TMIN, one NaN selects the numeric operand, two NaNs select canonical NaN, signaling NaN reports invalid, and mixed signed zeros select negative zero.

## Legality

- TMIN is BSTART.VEC Mode 0 Function 12 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Floating source encodings invalid for the selected operation reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- Select the typed elementwise minimum for every valid coordinate.
- Signed integers use signed ordering, unsigned integers use unsigned ordering, and supported floating carriers use deterministic NaN and signed-zero rules.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after complete legality and encoding preflight and before destination writes.
- Source aliasing and source-to-destination aliasing therefore observe pre-operation values.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, non-selected layout, invalid source encoding, or invalid destination capacity raises Fault_TileLegality before effects.
- A signaling NaN reports the selected numeric profile invalid condition without changing the deterministic selected result.

## Examples

- BSTART.VEC TMIN, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
