<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
# TDIV

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TDIV.asl`

Divide corresponding Local Tile elements under the selected numeric profile.

## Normative identity {#PTO-INST-TILE-TDIV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tdiv-purpose role=purpose -->
## What TDIV does

`TDIV` divides one Local Tile by another element by element and writes the quotients into a newly allocated Local destination Tile. It shares the bundle schema, padding, and publication rules of `TADD`, but it adds a division-by-zero check and runs on the `SFU` engine.

Design point: `TDIV` keeps the TEPL carrier Mode 0 Function 3 (selector `0x003`) and has no standalone opcode. Its canonical header is `BSTART.SFU TDIV, DataType`. `BSTART.SFU` is an alias of `BSTART.TEPL` that adds no encoding bits, so the engine name changes only the assembly spelling, not the binary encoding.

<!-- PTO-READER-BLOCK: tile-tdiv-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileBinary` computes `numerator / denominator` for each coordinate in the valid rectangle `ValidRow x ValidCol`. The rule depends on the kind of `DataType`:

- Signed integers use signed division, and the quotient is truncated toward zero. For example, `-7 / 2` produces `-3`.
- Unsigned integers use unsigned division. For example, `7 / 2` produces `3`.
- Floating types use the floating division profile with its fixed default rounding.

An integer zero anywhere in the valid denominator rectangle is a legality error. Preflight checks every valid denominator element, or every active one when an ExecutionMask is in force, and raises `Fault_TileLegality` before any source snapshot or destination effect. Denominator padding is not read.

Design point: an integer `DataType` has no infinity or NaN encoding that could represent `x / 0`. Instead of inventing a value, `TDIV` rejects the whole bundle, so a program never receives a silently wrong integer quotient. A program that may divide by zero must replace those divisors or exclude them with an ExecutionMask before issuing `TDIV`.

A floating zero divisor is not a legality error. The floating profile defines the result: a nonzero value divided by zero gives an infinity with the combined sign, `0 / 0` and `inf / inf` give a quiet NaN, and a finite value divided by infinity gives a signed zero.

<!-- PTO-READER-BLOCK: tile-tdiv-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the numerator. It is an existing, allocated Local Tile.
- `source1` is the denominator. It must match `source0` in physical rows, physical columns, valid rows, valid columns, and layout.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape matches the sources.

All three Tiles are bound by one terminating `B.IOT` and share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before any read, check, or allocation. A source may be stored with a different same-width, non-packed backing type; its bits are then validated and interpreted as the selected `DataType`.

<!-- PTO-READER-BLOCK: tile-tdiv-effects role=effects -->
## Publication, definedness, and padding

Both sources are snapshotted only after all legality and integer-zero checks pass, so a source that aliases the destination is read before it is overwritten. The destination descriptor, the valid-region quotients, the padding, and the definedness of every element are published together. A rejected bundle leaves descriptors, payloads, and allocation state unchanged.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the `DataType`; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

`TDIV` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value instead of a quotient.

<!-- PTO-READER-BLOCK: tile-tdiv-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is the same as for `TADD`: `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Packed four-bit formats are excluded. The floating element arithmetic that `TDIV` reaches, `ScalarFPBinaryProfile`, is defined only for `FP64`, `FP32`, `FP16`, and `BF16`, so the ASL gives no element result for `TF32`, `HF32`, `E4M3`, or `E5M2`.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32`, and all operands must use that same layout; among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. `TDIV` rejects nondefault `RMode`, `Sat`, and `CMode`.

An integer zero divisor, malformed bindings, missing or zero dimensions, undefined or mismatched sources, an unsupported `DataType`, or an invalid destination capacity raise `Fault_TileLegality` before any destination effect.

<!-- PTO-READER-BLOCK: tile-tdiv-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For `S32`, a numerator row `[7, -7, 9]` and a denominator row `[2, 2, -3]` produce the destination row `[3, -3, -3]`. If any valid denominator element were `0`, the bundle would fault instead and no destination would be produced.

For `FP32`, a numerator row `[1.0, -1.0, 0.0]` and a denominator row `[0.0, 0.0, 0.0]` produce `[+inf, -inf, NaN]` without a fault.

In macro form, an 8 x 64 `FP32` division is `TDIV <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`, where `T#1` is the numerator and `T#2` is the denominator.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TDIV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TDIV | TEPL | 0x003 | 3 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered numerator |
| source1 | ordered denominator |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
```asl
readonly func InstructionContractOperation_TDIV() => TileOperation
begin
    return TileOperation_TDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TDIV, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
```asl
pure func InstructionContractDataTypeLegal_TDIV(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;

readonly func InstructionContractHandler_TDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and nonzero; omitted LB1 selects ValidRow=1 and omitted LB2 selects Col=ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The numeric profile owns fixed rounding, floating exceptional values, and floating positive or negative zero division.

## Legality

- TDIV retains TEPL carrier Mode 0 Function 3 but is canonically classified as SFU.
- Exactly one terminating Local B.IOT supplies ordered numerator and denominator sources plus one new Local destination; B.IOR and B.IOS are illegal and PE_MASK zero is a strict no-op.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Signed integers use signed division, unsigned integers use unsigned division, and floating values use the selected floating division profile.
- The valid quotient and selected physical padding publish atomically; rejection leaves descriptor, payload, and allocation state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after all legality and integer-zero checks, so aliasing is read-before-write.

## Exceptions

- An integer zero in the valid denominator rectangle raises Fault_TileLegality before source snapshots, allocation publication, or destination effects; denominator padding is not read.
- Malformed bindings, unsupported types, undefined inputs, mismatched descriptors, or invalid capacity reject before effects; floating zero is handled by the selected numeric profile.

## Examples

- BSTART.SFU TDIV, S64; B.DIM LB0=ValidCol; B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
