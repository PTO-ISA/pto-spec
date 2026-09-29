<!-- GENERATED FROM: asl/tile/model/legality/matrix-postprocess.asl -->
# Matrix Postprocess

**Normative ASL source:** `asl/tile/model/legality/matrix-postprocess.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-purpose role=purpose-scope -->
## Purpose and scope

This unit checks the auxiliary Local sources that CUBE Matrix post-processing needs. Post-processing is the optional work that `B.FPATR` selects after the product: output quantization (`PreQuantMode`), activation (`ReluMode`), and row or group maximum reductions (`RowMaxEn`, `GroupMaxEn`).

The entry point is `BundleMatrixPostProcessSourcesLegal`. `ExecuteBundleTMATMULOperation` calls it for every `TMATMUL` and `TGEMV` form, after the mathematical sources pass. The unit also defines:

- `TileMatrixLocalRowMaxSchemaLegal` for the RowMaxIn source.
- `TileMatrixLocalVectorParameterSchemaLegal` for per-column quantization and PReLU parameter Tiles.
- `TileMatrixVectorQuantContentsLegal` and `TileMatrixVectorReluContentsLegal`, which check parameter payload words.
- Three stream accessors: `BundleMatrixSourceAt`, `BundleMatrixArchitecturalSourceAt`, and `BundleMatrixDestinationAt`.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-concepts role=concepts-state -->
## Concepts and visible state

The accessors count bundle Tile bindings in order. `BundleMatrixSourceAt(n)` returns the n-th valid source, `source0` before `source1`, and prefers a materialized subview Tile. `BundleMatrixArchitecturalSourceAt(n)` returns the parent Tile of a derived subview instead; block dispatch uses it to compare the CScale source with destination hands. `BundleMatrixDestinationAt(n)` returns the n-th valid destination, so D is ordinal 0 and RowMaxOut and GroupMaxOut follow.

The effective type is the type that post-processing sees. With `PreQuantMode` 0 it is the accumulator type itself (FP32, S32, or U32). With a nonzero mode it is that mode's output type from `BundleFPATROutputType`.

A vector parameter Tile has valid shape [1, N], type `U64`, and layout `CUBE_N8`. This is the one Matrix role that accepts `U64` CUBE storage, as NDF clause `PTO-CUBE-AUX-CELLREG-001` states.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-rules role=rules-interactions -->
## Rules and interactions

`BundleMatrixPostProcessSourcesLegal` checks, in order:

1. The accumulator type must suit `PreQuantMode`: mode 0 accepts FP32, S32, or U32; the modes listed by `BundleFPATRModeUsesS32Accumulator` need S32; the other legal nonzero modes need FP32.
2. If `RowMaxEn` or `GroupMaxEn` is set, the effective type must be FP32, FP16, or BF16.
3. If `RowMaxEn` and `RowMaxInit` are set, the next source is RowMaxIn: valid shape [M, 1], the effective type, and the resolved primary M layout (`CUBE_M16` or `CUBE_M32`).
4. If the mode uses a vector parameter, the next source is the quantization Tile. Every one of its N words must pass `BundleFPATRQuantParameterWordLegal` for that mode.
5. If `ReluMode` is 3 (vector PReLU), the next source is the PReLU Tile. Every word must have bits 63 to 19 zero and hold a positive-zero or positive-normal FP19 value.

The ordinal starts at the number of Local mathematical sources, including CScale when present, so these sources always follow the operands of the product.

Design point: parameter payloads are checked in preflight, not only descriptors. Reserved bits and illegal FP19 values are therefore rejected as `Fault_TileLegality` before any source is snapshotted or D is allocated, rather than being discovered while results are written.

Design point: reductions accept only an FP32, FP16, or BF16 effective type. A U32 or S32 accumulator with mode 0, an integer output mode such as S8, or an 8-bit floating output mode such as HiF8 or E4M3 cannot enable `RowMaxEn` or `GroupMaxEn`.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-boundaries role=boundaries -->
## Architectural boundaries

This check is the last source check in `ExecuteBundleTMATMULOperation`. It runs after the Local mathematical sources, the alias checks, and M layout resolution, and before `ResolveBundleTMATMULDestination` allocates D. A FALSE result raises `Fault_TileLegality`.

This unit does not check the `B.FPATR` field encodings, scalar parameters carried in GPRs, or the destinations RowMaxOut and GroupMaxOut. Those are owned by the `B.FPATR` unit, operand binding, and the CUBE destination resolver. The post-process execution unit reads the same source ordinals later.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-example role=example-usage -->
## Non-normative reading example

Consider an all-Local `TMATMUL` with FP16 A and B, M = 16, N = 24, `PreQuantMode` 0, `ReluMode` 3, and `RowMaxEn` and `RowMaxInit` set. Assume the `B.FPATR` field checks accept this combination.

- The accumulator type is FP32, which mode 0 accepts. The effective type is FP32, which reductions accept.
- There are 2 mathematical sources, so ordinal 2 is RowMaxIn: [16, 1], FP32, in A's M layout.
- Ordinal 3 is the PReLU Tile: [1, 24], `U64`, `CUBE_N8`. All 24 words are checked; a word with any bit set above bit 18 fails.

With S8 inputs and `PreQuantMode` 2 instead, the accumulator is S32, which mode 2 accepts, but the effective type is S8. Setting `RowMaxEn` then fails rule 2 before the quantization Tile that mode 2 also requires is examined.

This example illustrates the current ASL owner and does not replace the normative operation.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-postprocess-related role=related-owners-navigation -->
## Related owners

- [B.FPATR](../../../block/attributes/B.FPATR.md) owns the mode tables and the parameter word checks.
- [FP19](../../../arch/data-types/fp19.md) defines the parameter value classes.
- [Matrix operands](matrix-operands.md) checks the sources that come before these.
- [Post-process execution](../execution/postprocess.md) applies quantization, activation, and reductions.
- [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) calls this check.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-postprocess.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS","surface":"tile","classification":["model","legality","matrix-postprocess"],"depends_on":["PTO-BLOCK-B-FPATR","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE"]}
// PTO-REQ-CUBE-POSTPROCESS-001: auxiliary Matrix operands are completely
// descriptor- and payload-preflighted before source snapshots or allocation.
// NDF-BEGIN: PTO-CUBE-AUX-CELLREG-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local Matrix auxiliary Tiles are orientation-specific CellReg data:
// RowMaxIn/Out and GroupMaxOut use EffectiveDType and the resolved primary
// M16/M32 layout, with their physical geometry and capacity derived from that
// effective type;
// Bias and vector quant/PReLU parameters use CUBE_N8 with logical [1,N].
// Vector parameters retain U64 carriers, whose only CellReg geometry is
// CUBE_N8 K2 x N8; only vector parameter sources and ND2N8 U64 TLOAD may use
// it. All other U64 CUBE producers and consumers remain illegal.
// NDF-END: PTO-CUBE-AUX-CELLREG-001

readonly func BundleMatrixDestinationAt(
    ordinal: integer {0..2}) => TileIndex
begin
    var seen: integer {0..3} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            if seen == ordinal then
                return _BundleTileBindings[[binding]].destination;
            end;
            seen = (seen + 1) as integer {0..3};
        end;
    end;
    return 0;
end;

readonly func BundleMatrixSourceAt(ordinal: integer {0..8}) => TileIndex
begin
    var seen: integer {0..9} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(
                        binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(
                        binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
        end;
    end;
    return 0;
end;

readonly func BundleMatrixArchitecturalSourceAt(
    ordinal: integer {0..8}) => TileIndex
begin
    var seen: integer {0..9} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileArchitecturalSourceIndex(
                        binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileArchitecturalSourceIndex(
                        binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..9};
            end;
        end;
    end;
    return 0;
end;

readonly func TileMatrixLocalRowMaxSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    effective_type: TileDataType,
    expected_layout: TileLayout) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == 1 &&
           tile.data_type == effective_type &&
           tile.layout == expected_layout &&
           (expected_layout == TileLayout_CUBE_M16 ||
            expected_layout == TileLayout_CUBE_M32);
end;

readonly func TileMatrixLocalVectorParameterSchemaLegal(
    source: TileIndex,
    n: integer {1..65535}) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == 1 &&
           tile.valid_columns == n &&
           tile.data_type == TileDataType_U64 &&
           tile.layout == TileLayout_CUBE_N8;
end;

readonly func TileMatrixVectorQuantContentsLegal(
    source: TileIndex, mode: bits(6)) => boolean
begin
    let tile = _Tiles[[source]];
    for column = 0 to tile.valid_columns - 1 looplimit 65536 do
        let element = TileLogicalLinearIndex(
            tile, 0, column as integer {0..65535});
        if !BundleFPATRQuantParameterWordLegal(
               mode, TileReadLogicalElement(tile, element)) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileMatrixVectorReluContentsLegal(
    source: TileIndex) => boolean
begin
    let tile = _Tiles[[source]];
    for column = 0 to tile.valid_columns - 1 looplimit 65536 do
        let element = TileLogicalLinearIndex(
            tile, 0, column as integer {0..65535});
        if !BundleFPATRReluParameterWordLegal(
               TileReadLogicalElement(tile, element)) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleMatrixPostProcessSourcesLegal(
    mathematical_sources: integer {0..6},
    m: integer {1..65535},
    n: integer {1..65535},
    accumulator_type: TileDataType,
    primary_layout: TileLayout) => boolean
begin
    if !BundleFPATRAccumulatorTypeLegal(
           _BundleFixedPointAttributes.pre_quant_mode,
           accumulator_type) then
        return FALSE;
    end;
    let effective_type = BundleFPATREffectiveDataType(
        _BundleFixedPointAttributes.pre_quant_mode, accumulator_type);
    if (_BundleFixedPointAttributes.row_max_en ||
        _BundleFixedPointAttributes.group_max_en) &&
       !BundleFPATRReductionDataTypeLegal(effective_type) then
        return FALSE;
    end;
    var ordinal = mathematical_sources as integer {0..8};
    if _BundleFixedPointAttributes.row_max_en &&
       _BundleFixedPointAttributes.row_max_init then
        let row_max = BundleMatrixSourceAt(ordinal);
        if !TileMatrixLocalRowMaxSchemaLegal(
               row_max, m, effective_type, primary_layout) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..8};
    end;

    if BundleFPATRModeUsesVectorParameter(
           _BundleFixedPointAttributes.pre_quant_mode) then
        let quant = BundleMatrixSourceAt(ordinal);
        if !TileMatrixLocalVectorParameterSchemaLegal(
               quant, n) ||
           !TileMatrixVectorQuantContentsLegal(
               quant, _BundleFixedPointAttributes.pre_quant_mode) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..8};
    end;

    if BundleFPATRReluModeUsesVectorParameter(
           _BundleFixedPointAttributes.relu_mode) then
        let relu = BundleMatrixSourceAt(ordinal);
        if !TileMatrixLocalVectorParameterSchemaLegal(
               relu, n) ||
           !TileMatrixVectorReluContentsLegal(relu) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
