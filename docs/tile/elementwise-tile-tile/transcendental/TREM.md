<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TREM.asl -->
# TREM

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TREM.asl`

Compute divisor-signed modulo for corresponding Local Tile elements.

## Normative identity {#PTO-INST-TILE-TREM}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trem-purpose role=purpose -->
## What TREM does

`TREM` computes an elementwise modulo of two Local Tiles and writes the results into a newly allocated Local destination Tile. It shares the bundle schema, padding, and publication rules of `TDIV`, including the integer division-by-zero check, and runs on the `SFU` engine.

Design point: `TREM` keeps the TEPL carrier Mode 0 Function 4 (selector `0x004`) and has no standalone opcode. Its canonical header is `BSTART.SFU TREM, DataType`; the `SFU` spelling adds no encoding bits.

<!-- PTO-READER-BLOCK: tile-c-trem-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileBinary` computes one modulo result for each coordinate in the valid rectangle `ValidRow x ValidCol`. The rule depends on the kind of `DataType`:

- Signed integers use floor modulo. A nonzero result always has the sign of the divisor, and its magnitude is smaller than the divisor's magnitude.
- Unsigned integers use the ordinary unsigned remainder.
- Floating types use the floating modulo reference: `dividend - q * divisor`, where `q` is `dividend / divisor` truncated toward zero, rounded once with the fixed default rounding.

Design point: floor modulo differs from the truncating remainder of many programming languages. For signed integers, `-7 mod 3` is `2` here, not `-1`, and `7 mod -3` is `-2`, not `1`. For signed integers, keeping the result sign tied to the divisor makes the result a valid index in the range from 0 to `divisor - 1` whenever the divisor is positive.

An integer zero anywhere in the valid divisor rectangle raises `Fault_TileLegality` before any source snapshot or destination effect. Divisor padding is not read. An integer type has no encoding for `x mod 0`, so the bundle is rejected rather than given an invented value.

For floating types, any NaN operand, a zero divisor, or an infinite dividend produces a quiet NaN. Otherwise, an infinite divisor or a zero dividend returns the dividend unchanged.

<!-- PTO-READER-BLOCK: tile-c-trem-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the dividend. It is an existing, allocated Local Tile.
- `source1` is the divisor. It must match `source0` in physical rows, physical columns, valid rows, valid columns, and layout.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape matches the sources.

All three Tiles are bound by one terminating `B.IOT` and share one `PE_MASK`. `PE_MASK=0000` is a strict no-op. A source may be stored with a different same-width, non-packed backing type; its bits are then validated and interpreted as the selected `DataType`.

<!-- PTO-READER-BLOCK: tile-c-trem-effects role=effects -->
## Publication, definedness, and padding

Both sources are snapshotted only after all legality and integer-zero checks pass, so a source that aliases the destination is read before it is overwritten. The destination descriptor, the valid-region results, the padding, and the definedness of every element are published together. A rejected bundle leaves descriptors, payloads, and allocation state unchanged.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the `DataType`; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

`TREM` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value instead of a result.

<!-- PTO-READER-BLOCK: tile-c-trem-constraints role=constraints -->
## Type, layout, and fault boundary

`TREM` accepts exactly `FP64`, `S64`, `U64`, `S32`, `U32`, `FP32`, `S16`, `U16`, `FP16`, and `BF16`. Floating remainder is executable for all four admitted floating types, including `FP64`; integer forms retain their typed remainder rule.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32`, and all operands must use that same layout; among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. `TREM` rejects nondefault `RMode`, `Sat`, and `CMode`.

An integer zero divisor, malformed bindings, missing or zero dimensions, undefined or mismatched sources, an unsupported `DataType`, or an invalid destination capacity raise `Fault_TileLegality` before any destination effect.

<!-- PTO-READER-BLOCK: tile-c-trem-example role=example -->
## Non-normative worked example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

For `S32`, a dividend row `[7, -7, 7, -7]` and a divisor row `[3, 3, -3, -3]` produce the destination row `[1, 2, -2, -1]`. Every nonzero result has the sign of its divisor.

For `U32`, a dividend row `[7, 9]` and a divisor row `[3, 4]` produce `[1, 1]`.

In macro form, an 8 x 64 `S32` modulo is `TREM <Row=8, Col=64, S32>, T#1, T#2, ->T<2KB>`, where `T#1` is the dividend and `T#2` is the divisor.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TREM <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TREM | TEPL | 0x004 | 4 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered dividend |
| source1 | ordered divisor |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TREM.asl -->
```asl
readonly func InstructionContractOperation_TREM() => TileOperation
begin
    return TileOperation_TREM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TREM, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Dividend, Divisor, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TREM.asl -->
```asl
pure func InstructionContractDataTypeLegal_TREM(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TREM(
    destination: TileIndex,
    dividend: TileIndex,
    divisor: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_REM,
        destination,
        dividend,
        divisor);
end;

readonly func InstructionContractHandler_TREM() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TREM(
    destination: TileIndex,
    dividend: TileIndex,
    divisor: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_REM,
        destination,
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and nonzero; omitted LB1 selects ValidRow=1 and omitted LB2 selects Col=ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The numeric profile owns fixed rounding, signed overflow boundaries, floating exceptional values, and floating zero modulo.

## Legality

- TREM retains TEPL carrier Mode 0 Function 4 but is canonically classified as SFU.
- Exactly one terminating Local B.IOT supplies ordered dividend and divisor sources plus one new Local destination; B.IOR and B.IOS are illegal and PE_MASK zero is a strict no-op.
- DataType is exactly FP64, S64, U64, S32, U32, FP32, S16, U16, FP16, or BF16.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Signed integer modulo uses floor division so a nonzero result has the divisor's sign; unsigned integers use ordinary unsigned remainder and floating values use the selected modulo profile.
- The valid modulo result and selected physical padding publish atomically; rejection leaves descriptor, payload, and allocation state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after all legality and integer-zero checks, so aliasing is read-before-write.

## Exceptions

- An integer zero in the valid divisor rectangle raises Fault_TileLegality before snapshots, allocation publication, or destination effects; divisor padding is not read.
- Malformed bindings, unsupported types, undefined inputs, mismatched descriptors, or invalid capacity reject before effects; floating zero is handled by the selected numeric profile.

## Examples

- BSTART.SFU TREM, S64; B.DIM LB0=ValidCol; B.IOT Dividend, Divisor, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
