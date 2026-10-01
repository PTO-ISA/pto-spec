<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
# TADD

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TADD.asl`

Add corresponding elements of two Local Tiles.

## Normative identity {#PTO-INST-TILE-TADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tadd-purpose role=purpose -->
## What TADD does

`TADD` adds two Local Tiles element by element and writes the sums into a newly allocated Local destination Tile. It is the reference member of the VEC elementwise arithmetic family: `TSUB`, `TMUL`, `TMAX`, and `TMIN` reuse the same bundle schema and differ only in the element operation.

Design point: `TADD` has no standalone opcode. It is selected by `BSTART.VEC` Mode 0 Function 0 (TEPL selector `0x000`), and the surrounding `B.DIM`, `B.DATR`, and `B.IOT` commands supply shape, attributes, and operands. Keeping the operation identity in one selector and the configuration in shared bundle commands lets every elementwise operation share one decoder and one operand model.

<!-- PTO-READER-BLOCK: tile-tadd-mechanism role=mechanism -->
## Element and Tile mechanism

Execution has two phases. Preflight checks the complete bundle first: the selected `DataType`, the layout, both source descriptors, source definedness, the destination capacity, and the operand schema. Only after every check passes does `ExecuteTileBinary` read the sources and compute `left + right` for each coordinate in the valid rectangle `ValidRow x ValidCol`.

Design point: both sources are read completely before the first destination element is written. This makes aliasing well defined: if a source and the destination name the same Tile, the result is computed from the old source values, exactly as if the destination were a separate Tile.

The addition itself is defined by the numeric profile for the selected `DataType`, including rounding, overflow, and special values. Integer addition wraps; floating-point addition uses the profile's fixed default rounding. `TADD` rejects any nondefault `RMode`, `Sat`, or `CMode`, so there is no per-instruction rounding or saturation control.

<!-- PTO-READER-BLOCK: tile-tadd-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the left addend. It is an existing, allocated Local Tile.
- `source1` is the right addend. It must have the same physical rows, physical columns, valid rows, valid columns, and layout as `source0`.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape matches the sources.

Without an ExecutionMask carrier, all three Tiles are bound by one terminating `B.IOT`, and all share one `PE_MASK`. Each selected PE executes independently on its own fragment.

Design point: `PE_MASK=0000` is a strict no-op. Once the `B.IOT` encoding itself is well formed, zero participation skips schema, allocation, and descriptor checks, and no descriptor, allocation, payload, or numeric status is produced. A bundle can therefore be encoded with no participating PE without being rejected by the operation's schema checks.

Design point: a source may be stored with a different same-width, non-packed backing type, for example `U16` data read as `FP16`. The bits are then validated and interpreted as the selected `DataType`. This allows a reinterpreting read without a separate copy, while a width mismatch or a packed four-bit carrier remains illegal.

<!-- PTO-READER-BLOCK: tile-tadd-effects role=effects -->
## Publication, definedness, and padding

The destination becomes visible as a single unit. Its descriptor, the valid-region sums, the padding outside the valid rectangle, and the definedness of every element are published together. No observer can see a partially written `TADD` result.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero; `Max` and `Min` write the largest and smallest finite value of the `DataType`; `Null` leaves those elements undefined.

Design point: omitting `B.DATR` selects `Null`, while an explicit code `00` selects `Zero`. Omission and encoded zero are architecturally distinct: by default the elements outside the valid rectangle are left undefined, so a program that later needs those physical elements to hold defined values must request `Zero`, `Max`, or `Min` explicitly.

`TADD` has no global-memory effect. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value instead of the sum.

<!-- PTO-READER-BLOCK: tile-tadd-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. Packed four-bit formats are excluded. The floating element arithmetic that `TADD` reaches, `ScalarFPBinaryProfile`, is defined only for `FP64`, `FP32`, `FP16`, and `BF16`, so the ASL gives no element result for `TF32`, `HF32`, `E4M3`, or `E5M2`.

The layout is `RowMajor` by default. An explicit `Layout` may select `CUBE_M16` or `CUBE_M32` so that `TADD` can operate directly on Tiles already arranged for the CUBE engine, without a layout conversion. All operands must use the same layout; `CUBE_N8`, Shared Tiles, and mixed layouts are illegal.

Every source element in the valid rectangle (every active one, when an ExecutionMask is in force) must be defined. A missing `LB0`, a malformed `B.IOT`, any `B.IOR` or `B.IOS`, a shape or width mismatch, an undefined source element, an unsupported `DataType`, or an invalid destination capacity raises `Fault_TileLegality` before any destination effect. The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: tile-tadd-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TADD` example, a left source row `[1, 2]` and a right source row `[3, 4]` produce the destination row `[4, 6]`.

A partial Tile with an 8 x 64 `FP32` physical shape, a 7 x 60 valid region, and `Zero` padding is written in macro form as `TADD <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, T#2, ->T<2KB>`. The 7 x 60 sums are computed, and the other 92 physical elements of the 8 x 64 destination (all of row 7, plus columns 60 to 63 of rows 0 to 6) are defined as zero.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TADD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TADD | TEPL | 0x000 | 0 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered left Local source |
| source1 | ordered right Local source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
```asl
readonly func InstructionContractOperation_TADD() => TileOperation
begin
    return TileOperation_TADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TADD, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
```asl
pure func InstructionContractDataTypeLegal_TADD(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TADD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_ADD,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol; an explicitly present zero dimension is illegal.
- Omitted B.DATR selects PadValue=Null and Layout=NORM (RowMajor). Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null respectively.
- The destination physical Rows are derived from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol.

## Legality

- TADD is selected only by BSTART.VEC Mode 0 Function 0 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one newly allocated Local destination. B.IOR and B.IOS are not accepted; all participating Tiles use one PE_MASK and zero mask is a strict no-op.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- After complete preflight, add corresponding source elements and atomically publish the valid destination region.
- Physical destination elements outside ValidRow x ValidCol receive the selected PadValue; Null padding remains undefined while Zero, Max, and Min padding are defined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted before the first destination write, so source/destination aliasing is read-before-write.

## Exceptions

- A missing LB0, malformed Local B.IOT, B.IOR or B.IOS presence, source shape or carrier-width mismatch, undefined source element, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before destination effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.VEC TADD, U64; B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
