<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl -->
# TMUL

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl`

Multiply corresponding elements of two Local Tiles.

## Normative identity {#PTO-INST-TILE-TMUL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmul-purpose role=purpose -->
## What TMUL does

`TMUL` multiplies two Local Tiles element by element and writes the products into a newly allocated Local destination Tile. It shares the bundle schema, preflight, padding, and publication rules of `TADD`; only the element operation differs.

Design point: `TMUL` is selected by `BSTART.VEC` Mode 0 Function 2 (TEPL selector `0x002`) and has no standalone opcode. Because the operation identity lives in the selector, `TMUL` reuses the same `B.DIM`, `B.DATR`, and `B.IOT` commands as every other closed binary elementwise operation.

<!-- PTO-READER-BLOCK: tile-tmul-mechanism role=mechanism -->
## Element and Tile mechanism

Preflight checks the complete bundle first: the selected `DataType`, the layout, both source descriptors, source definedness and encodings, the destination capacity, and the operand schema. Only after every check passes does `ExecuteTileBinary` compute `left * right` for each coordinate in the valid rectangle `ValidRow x ValidCol`.

Integer multiplication keeps only the low bits of the product. Both operands are first sign-extended or zero-extended according to the `DataType`, and the product is truncated back to the element width. For example, with `U16`, `300 * 300 = 90000` produces `24464`.

Design point: the destination has the same `DataType` as the operation, so `TMUL` never widens. A program that needs the full integer product must select a wider `DataType` for the operands before multiplying.

Floating-point multiplication uses the numeric profile of the selected `DataType` with its fixed default rounding. `TMUL` rejects any nondefault `RMode`, `Sat`, or `CMode`. Both sources are read completely before the first destination element is written, so aliasing a source with the destination is well defined.

<!-- PTO-READER-BLOCK: tile-tmul-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the left factor. It is an existing, allocated Local Tile.
- `source1` is the right factor. It must match `source0` in physical rows, physical columns, valid rows, valid columns, and layout.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape matches the sources.

All three Tiles are bound by one terminating `B.IOT` and share one `PE_MASK`. `PE_MASK=0000` is a strict no-op: no descriptor, allocation, or payload is produced.

A source may be stored with a different same-width, non-packed backing type. Its bits are then validated and interpreted as the selected `DataType`.

<!-- PTO-READER-BLOCK: tile-tmul-effects role=effects -->
## Publication, definedness, and padding

The destination descriptor, the valid-region products, the padding, and the definedness of every element are published together. A rejected bundle publishes none of them, and both sources persist unchanged.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the `DataType`; `Null` leaves those elements undefined. Omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`.

`TMUL` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value instead of a product.

<!-- PTO-READER-BLOCK: tile-tmul-constraints role=constraints -->
## Type, layout, and fault boundary

The ASL legality predicate `TileVecArithmeticDataTypeSupported` accepts the same 16 types as `TADD`: `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Packed four-bit formats are excluded. The floating element arithmetic that `TMUL` reaches, `ScalarFPBinaryProfile`, is defined only for `FP64`, `FP32`, `FP16`, and `BF16`, so the ASL gives no element result for `TF32`, `HF32`, `E4M3`, or `E5M2`. The generated legality list below is narrower and names only `S32`, `U32`, `FP32`, `S16`, `U16`, `FP16`, and `BF16`. Code that must satisfy both should use a type from the narrower list.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32`, and all operands must use that same layout. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal.

Malformed bindings, missing or zero dimensions, undefined or mismatched sources, an unsupported `DataType`, or an invalid destination capacity raise `Fault_TileLegality` before any destination effect.

<!-- PTO-READER-BLOCK: tile-tmul-example role=example -->
## Non-normative worked example

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

For `U16`, a left source row `[3, 300]` and a right source row `[5, 300]` produce the destination row `[15, 24464]`. The second product, 90000, keeps only its low 16 bits.

In macro form, an 8 x 64 `FP32` multiplication is `TMUL <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`. The destination payload is 8 x 64 x 4 = 2048 bytes, exactly the 2KB capacity.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TMUL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMUL | TEPL | 0x002 | 2 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | left factor |
| source1 | right factor |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl -->
```asl
readonly func InstructionContractOperation_TMUL() => TileOperation
begin
    return TileOperation_TMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TMUL, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl -->
```asl
pure func InstructionContractDataTypeLegal_TMUL(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_MUL,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TMUL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_MUL,
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

- TMUL is BSTART.VEC Mode 0 Function 2 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, U32, FP32, S16, U16, FP16, or BF16.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- Publish the elementwise products after complete preflight.
- Pad the remaining physical region using the selected PadValue; Null padding is undefined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both sources are snapshotted before destination writes.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.

## Examples

- BSTART.VEC TMUL, U64; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
