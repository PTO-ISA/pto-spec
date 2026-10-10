<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
# TSUB

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl`

Subtract corresponding right-source elements from left-source elements.

## Normative identity {#PTO-INST-TILE-TSUB}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsub-purpose role=purpose -->
## What TSUB does

`TSUB` subtracts one Local Tile from another element by element and writes the differences into a newly allocated Local destination Tile. It shares the bundle schema, preflight, padding, and publication rules of `TADD`; only the element operation and the operand order differ.

Design point: `TSUB` is selected by `BSTART.VEC` Mode 0 Function 1 (TEPL selector `0x001`) and has no standalone opcode. Subtraction is not commutative, so the binding order carries meaning: the first source of the terminating `B.IOT` is always the minuend.

<!-- PTO-READER-BLOCK: tile-c-tsub-mechanism role=mechanism -->
## Element and Tile mechanism

Preflight checks the complete bundle first: the selected `DataType`, the layout, both source descriptors, source definedness and encodings, the destination capacity, and the operand schema. Only after every check passes does `ExecuteTileBinary` compute `left - right` for each coordinate in the valid rectangle `ValidRow x ValidCol`.

Integer subtraction wraps. Both operands are first sign-extended or zero-extended according to the `DataType`, and the difference is truncated back to the element width. For example, with `U8`, `3 - 5` produces `254`.

Floating-point subtraction uses the numeric profile of the selected `DataType` with its fixed default rounding. `TSUB` rejects any nondefault `RMode`, `Sat`, or `CMode`, so there is no per-instruction rounding or saturation control.

Design point: both sources are read completely before the first destination element is written. A destination that aliases either source therefore still receives `old left - old right`.

<!-- PTO-READER-BLOCK: tile-c-tsub-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the minuend, the left operand. It is an existing, allocated Local Tile.
- `source1` is the subtrahend, the right operand. It must match `source0` in physical rows, physical columns, valid rows, valid columns, and layout.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape matches the sources.

All three Tiles are bound by one terminating `B.IOT` and share one `PE_MASK`. `PE_MASK=0000` is a strict no-op: no descriptor, allocation, or payload is produced.

Design point: a source may be stored with a different same-width, non-packed backing type. Its bits are then validated and interpreted as the selected `DataType`, which allows a reinterpreting read without a separate copy.

<!-- PTO-READER-BLOCK: tile-c-tsub-effects role=effects -->
## Publication, definedness, and padding

The destination descriptor, the valid-region differences, the padding, and the definedness of every element are published together. A rejected bundle publishes none of them, and both sources persist unchanged.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the `DataType`; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

`TSUB` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value instead of a difference.

<!-- PTO-READER-BLOCK: tile-c-tsub-constraints role=constraints -->
## Type, layout, and fault boundary

`TSUB` accepts exactly `FP64`, `S64`, `U64`, `S32`, `U32`, `FP32`, `S16`, `U16`, `FP16`, `BF16`, `S8`, and `U8`. Floating subtraction has an executable profile for each admitted floating type; the remaining floating formats and every packed type reject before effects.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32`, and all operands must use that same layout; among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal.

Malformed bindings, missing or zero dimensions, undefined or mismatched sources, an unsupported `DataType`, or an invalid destination capacity raise `Fault_TileLegality` before any destination effect.

<!-- PTO-READER-BLOCK: tile-c-tsub-example role=example -->
## Non-normative worked example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

For `S32`, a left source row `[10, -4]` and a right source row `[3, 6]` produce the destination row `[7, -10]`. Swapping the two sources produces `[-7, 10]`.

In macro form, an 8 x 64 `S32` subtraction is `TSUB <Row=8, Col=64, S32>, T#1, T#2, ->T<2KB>`, where `T#1` is the minuend and `T#2` is the subtrahend. The destination payload is 8 x 64 x 4 = 2048 bytes, exactly the 2KB capacity.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TSUB <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSUB | TEPL | 0x001 | 1 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | minuend |
| source1 | subtrahend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
```asl
readonly func InstructionContractOperation_TSUB() => TileOperation
begin
    return TileOperation_TSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSUB, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSUB(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSUB(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_SUB,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TSUB() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TSUB(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_SUB,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TSUB is BSTART.VEC Mode 0 Function 1 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of FP64, S64, U64, S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Publish source-left minus source-right for each valid coordinate after complete preflight.
- Pad the remaining physical region using the selected PadValue; Null padding is undefined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both sources are snapshotted before destination writes.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.

## Examples

- BSTART.VEC TSUB, U64; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
