<!-- GENERATED FROM: asl/tile/model/legality/execution-mask-source-schema.asl -->
# Execution Mask Source Schema

**Normative ASL source:** `asl/tile/model/legality/execution-mask-source-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the source-side checks that elementwise and related Tile operations use when an ExecutionMask may be present. An ExecutionMask is a per-bundle carrier that marks each coordinate of the valid region as active or inactive.

- `TileElementwiseSourceContentsDefined` checks the source descriptor and its definedness.
- `TileElementwiseSourceEncodingsValidAs` also checks element encodings under a chosen operation type.
- `TileElementwiseSourceEncodingsValid` checks encodings under the source's own stored type.

The unit also holds NDF clause `PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001`, which limits where an ExecutionMask may apply.

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-concepts role=concepts-state -->
## Concepts and visible state

The predicates read `_Tiles`, per-element definedness, and `_BundleExecutionMask`. They write nothing and raise no fault themselves.

An encoding is valid when `TileNumericEncodingValid` accepts its bits. That helper has real checks only for TF32, HF32, E3M2, and E2M3, where some low or high bits must be zero. For every other type it returns TRUE.

The NDF clause states that an ExecutionMask applies only to an operation's already-legal Local CUBE_M16 or CUBE_M32 forms and does not add layout support. Of the 92 classified mnemonics, 89 have such a form. TGATHER, TSCATTER, and TTRI have none, and an ExecutionMask carrier on them must reject before effects.

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-rules role=rules-interactions -->
## Rules and interactions

`TileElementwiseSourceContentsDefined` first checks the descriptor. A CUBE-layout source must pass `TileCubeDescriptorLegal`; any other source must pass `TileDescriptorLegal`. Then:

- Without an ExecutionMask, it returns the whole-Tile `contents_defined` flag.
- With an ExecutionMask, the source layout, `valid_rows`, and `valid_columns` must equal the mask's. Every active coordinate must then be defined.

Design point: under an ExecutionMask only active coordinates must be defined. A source whose inactive coordinates were never written is still legal, because those coordinates are not read for the result. The whole-Tile flag is not required in this case.

Design point: the mask and the source must agree exactly on layout and valid region. The mask lookup `BundleExecutionMaskCoordinateBit` asserts that the layout equals the mask's layout and that the row and column lie inside the mask's valid region; the exact-match check guarantees those conditions for every coordinate this unit visits and rejects any other shape instead of reinterpreting it.

`TileElementwiseSourceEncodingsValidAs` requires `TileElementwiseSourceContentsDefined` and `TileCarrierWidthCompatible` between the stored type and the operation type. It then checks the encoding of each active valid element (every valid element when no mask is present) under the operation type. `TileElementwiseSourceEncodingsValid` does the same under the stored type and has no width check.

Legality predicates call these helpers before the operation reads source snapshots or writes the destination payload. When such a predicate returns FALSE the operation is rejected and any destination the bundle had already allocated is rolled back. Some execution functions, such as TMOV and TSTORE, also assert these helpers.

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-boundaries role=boundaries -->
## Architectural boundaries

Callers include, for example, `TileOperandsLegal_ExecuteTileBinary` and the other checks in the operand schema, `TileOperandsLegal_TFMA`, the comparison and Tile-scalar dispatch schemas, the EXPDIF operand checks, and the load-store and Shared movement units.

An encoding check is not a numeric-support check. `TileNumericEncodingValid` returns TRUE for FP32, FP16, integers, and most other types. Whether the numeric helper that later computes the result supports the type is decided by separate type predicates and by the helper itself.

`TileCubeDescriptorLegal` accepts CUBE_N8 as a CUBE layout, but the NDF clause limits ExecutionMask use to CUBE_M16 and CUBE_M32 forms. The applicability of a mask to a given operation, including the Local CUBE_M16 or CUBE_M32 requirement, is enforced by `BundleExecutionMaskDataAttributesLegal` in bundle dispatch, not by this unit.

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-example role=example-usage -->
## Non-normative reading example

Take an FP32 CUBE_M16 source with valid region 16 by 8, and an ExecutionMask with the same layout and valid region that activates 100 of the 128 coordinates.

- The descriptor passes `TileCubeDescriptorLegal`.
- The layout and valid region match the mask.
- Only the 100 active elements must be defined; the other 28 may be undefined.
- `TileElementwiseSourceEncodingsValidAs` with FP32 checks 100 encodings, and each passes because FP32 has no encoding restriction.

If the source had valid region 16 by 4, the shape comparison would fail and the operation would be rejected.

<!-- PTO-READER-BLOCK: tile-model-legality-execution-mask-source-schema-related role=related-owners-navigation -->
## Related owners

- [ExecutionMask state](../execution/execution-mask-state.md) owns the active-coordinate lookup.
- [Descriptor shape](descriptor-shape.md) owns the descriptor predicates used first.
- [Data type and layout](dtype-layout.md) owns `TileCarrierWidthCompatible`.
- [Operand schema](operand-schema.md) is the main caller for elementwise operations.
- [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md) decodes the bundle ExecutionMask carrier.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/execution-mask-source-schema.asl -->
```asl
// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// ExecutionMask MUST apply only to an operation's already-legal Local CUBE_M16 or CUBE_M32 forms and MUST NOT add layout support. Of the 92 semantically classified mnemonics, 89 have an applicable baseline CUBE form; TGATHER and TSCATTER have none under their indexed-operation schemas, and TTRI is RowMajor-only. Any ExecutionMask carrier on those forms MUST reject before operation effects. These three names remain classified with zero applicable forms and retain their existing unpredicated behavior. TEXPDIF is included in the applicable intersection.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","surface":"tile","classification":["model","legality","execution-mask-source-schema"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-SHAPE-CUBE-CELL"]}
readonly func TileElementwiseSourceContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if TileLayoutIsCube(tile.layout) then
        if !TileCubeDescriptorLegal(tile) then return FALSE; end;
    elsif !TileDescriptorLegal(index) then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows ||
       tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               !TileElementDefined(index, row as integer {0..65535},
                   column as integer {0..65535}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileElementwiseSourceEncodingsValidAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    if !TileElementwiseSourceContentsDefined(index) ||
       !TileCarrierWidthCompatible(
           _Tiles[[index]].data_type, operation_type) then
        return FALSE;
    end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileElementwiseSourceEncodingsValid(index: TileIndex)
    => boolean
begin
    if !TileElementwiseSourceContentsDefined(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       tile.data_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
