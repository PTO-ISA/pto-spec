<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TABS.asl -->
# TABS

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TABS.asl`

Typed elementwise absolute value over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TABS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tabs-purpose role=purpose -->
## What TABS does

`TABS` takes the absolute value of every element of one Local Tile and writes the results into a newly allocated Local destination Tile. What "absolute value" means depends on the selected `DataType`: signed integers, unsigned integers, and floating-point types each follow their own rule.

Design point: `TABS` has no standalone opcode. It is selected by `BSTART.VEC` Mode 0 Function 15 (TEPL selector `0x00F`). It shares the closed unary bundle schema with `TNOT`, `TNEG`, and `TRELU`: one terminating `B.IOT`, one source, and one new destination. The four operations still differ in their accepted `DataType` sets and per-element transforms, and `TNOT` additionally requires an exact source backing type.

<!-- PTO-READER-BLOCK: tile-tabs-mechanism role=mechanism -->
## Element and Tile mechanism

Preflight checks the complete bundle first: operand schema, dimensions, `DataType`, layout, source definedness, source encodings, and destination capacity. Only then does `ExecuteTileUnary` read the source and transform each coordinate of the valid rectangle `ValidRow x ValidCol`.

- Signed integer types: a negative element is negated modulo the element width, and other elements are unchanged. The most negative value has no positive counterpart, so it keeps its bit pattern: `S8` `0x80` (-128) stays `0x80`.
- Unsigned integer types: `TABS` is the identity.
- Floating-point types: `TABS` clears only the sign bit. Negative zero becomes positive zero, negative infinity becomes positive infinity, and a NaN keeps its class and payload.

Design point: floating `TABS` is a sign-bit operation, not an arithmetic one. It therefore never reports an invalid condition, even for a signaling NaN, and it never changes exponent or mantissa bits.

Design point: the source is still validated as a number before execution. Every valid-region element (every active one, when an ExecutionMask is in force) must be a valid encoding of the selected `DataType`. For example, a `TF32` element whose low 13 mantissa bits are not zero is rejected. Raw-carrier operations such as `TAND` do not perform this check.

<!-- PTO-READER-BLOCK: tile-tabs-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the absolute-value source. It is an existing, allocated Local Tile.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its physical shape, valid shape, and layout match the source.

One terminating `B.IOT` binds both Tiles under a single `PE_MASK`; `B.IOR` and `B.IOS` are illegal. Once the `B.IOT` encoding itself is well formed, `PE_MASK=0000` is a strict no-op: no source is read and no destination is allocated.

Design point: the source may be stored with a different same-width, non-packed backing type, for example `U16` data processed as `FP16`. The bits are validated and interpreted as the selected `DataType`, so a reinterpreting absolute value needs no separate copy.

<!-- PTO-READER-BLOCK: tile-tabs-effects role=effects -->
## Publication, definedness, and padding

The source payload is snapshotted after preflight and before the first destination write. If the source and destination alias, the result is computed from the old source values.

The destination descriptor, the valid-region results, the padding, and the definedness of every element publish together. A rejected `TABS` has no architectural effect.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero`, `Max`, and `Min` write defined values; `Null`, selected when `B.DATR` is omitted, leaves them undefined.

`TABS` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value instead of an absolute value.

<!-- PTO-READER-BLOCK: tile-tabs-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. Packed four-bit formats are excluded.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32`; `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. Nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, or `RMode` is illegal.

Malformed bindings, missing or zero dimensions, undefined or mismatched source state, an unsupported `DataType`, a non-selected layout, or an invalid floating source encoding raises `Fault_TileLegality` before any effect. An unrepresentable destination shape or insufficient `TSize` capacity raises `Fault_TileAllocation` before allocation. The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: tile-tabs-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `DataType=S8`, valid elements `[-2, 3, -128]` become `[2, 3, -128]`. With `DataType=FP16`, the encoding `0x8000` (negative zero) becomes `0x0000`, and `0xFC00` (negative infinity) becomes `0x7C00`.

In macro form, `TABS <Row=8, Col=64, S8>, T#1, ->T<512B>` computes all 8 x 64 results of an `S8` Tile into a new 512-byte destination.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TABS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TABS | TEPL | 0x00F | 15 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | absolute-value source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TABS.asl -->
```asl
readonly func InstructionContractOperation_TABS() => TileOperation
begin
    return TileOperation_TABS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TABS, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TABS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TABS(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TABS(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_ABS,
        destination,
        source);
end;

pure func InstructionContractValue_TABS(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_ABS,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TABS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TABS(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_ABS, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Signed integers use modulo-width absolute value, including retaining the minimum signed bit pattern; unsigned integers are unchanged. Floating values clear only the sign bit, including zeros, infinities, and NaN payloads, without reporting invalid solely for TABS.

## Legality

- TABS is BSTART.VEC Mode 0 Function 15 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- Source and destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; the source valid region is fully defined.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For every valid coordinate, compute signed modulo-width absolute value, unsigned identity, or floating sign-bit clearing according to DataType.
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

- BSTART.VEC TABS, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
