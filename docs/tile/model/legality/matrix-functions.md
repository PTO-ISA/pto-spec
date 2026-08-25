<!-- GENERATED FROM: asl/tile/model/legality/matrix-functions.asl -->
# Matrix Functions

**Normative ASL source:** `asl/tile/model/legality/matrix-functions.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-functions.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS","surface":"tile","classification":["model","legality","matrix-functions"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}
// The CUBE Matrix selector and MX side-type rules are kept in one small unit
// so schema and execution code cannot grow separate function tables.

// NDF-BEGIN: PTO-CUBE-MATRIX-SCALE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Each Matrix-MX primary side MUST independently select group-32 E8M0 scale
// for MX FP8/FP4 carriers or group-64 raw U32 scale for HiF4X2. HiF4X2 MUST
// be accepted only by Matrix-MX input roles; ordinary Matrix MUST not gain it.
// Each Local scale MUST use CUBE_M32 and each Shared scale MUST remain an
// independently bound ordinary Tile with the corresponding primary location.
// NDF-END: PTO-CUBE-MATRIX-SCALE-001

pure func TileMXInputTypeSupported(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_E5M2 ||
           data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2 ||
           data_type == TileDataType_HiF4X2;
end;

pure func TileMXScaleGroupSize(data_type: TileDataType)
    => integer {32,64}
begin
    assert TileMXInputTypeNeedsScale(data_type);
    if data_type == TileDataType_HiF4X2 then return 64; end;
    return 32;
end;

pure func TileMXScaleCarrierType(data_type: TileDataType) => TileDataType
begin
    assert TileMXInputTypeNeedsScale(data_type);
    if data_type == TileDataType_HiF4X2 then return TileDataType_U32; end;
    return TileDataType_E8M0;
end;

pure func TileMXScaleGroupCount(
    k: integer {1..65535}, data_type: TileDataType)
    => integer {1..2048}
begin
    let group_size = TileMXScaleGroupSize(data_type);
    return ((k + (group_size - 1)) DIVRM group_size)
        as integer {1..2048};
end;

pure func TileMXInputTypeNeedsScale(data_type: TileDataType) => boolean
begin
    assert TileMXInputTypeSupported(data_type);
    return data_type != TileDataType_FP16 &&
           data_type != TileDataType_BF16;
end;

pure func TileMXOperandPairLegal(left_type: TileDataType,
                                right_type: TileDataType) => boolean
begin
    return TileMXInputTypeSupported(left_type) &&
           TileMXInputTypeSupported(right_type);
end;

pure func TileMatrixFunctionAssigned(function: integer {0..31}) => boolean
begin
    return function == 0 || function == 1 || function == 2 ||
           function == 4 || function == 5 || function == 6 ||
           function == 16 || function == 17 || function == 18 ||
           function == 20 || function == 21 || function == 22;
end;

pure func TileMatrixFunctionUsesBias(function: integer {0..31}) => boolean
begin
    return function == 1 || function == 5 ||
           function == 17 || function == 21;
end;

pure func TileMatrixFunctionUsesAccumulator(
    function: integer {0..31}) => boolean
begin
    return function == 2 || function == 6 ||
           function == 18 || function == 22;
end;

pure func TileMatrixFunctionUsesMX(function: integer {0..31}) => boolean
begin
    return function == 4 || function == 5 || function == 6 ||
           function == 20 || function == 21 || function == 22;
end;

pure func TileMatrixFunctionIsGEMV(function: integer {0..31}) => boolean
begin
    return function == 16 || function == 17 || function == 18 ||
           function == 20 || function == 21 || function == 22;
end;

pure func TileMatrixFunctionAllowsCScale(
    function: integer {0..31}) => boolean
begin
    return function == 2 || function == 6;
end;

pure func TileMatrixLeftGroupSourceCount(
    function: integer {0..31}, left_type: TileDataType) => integer {1..2}
begin
    if TileMatrixFunctionUsesMX(function) &&
       TileMXInputTypeNeedsScale(left_type) then
        return 2;
    end;
    return 1;
end;

pure func TileMatrixRightGroupSourceCount(
    function: integer {0..31}, right_type: TileDataType) => integer {1..2}
begin
    if TileMatrixFunctionUsesMX(function) &&
       TileMXInputTypeNeedsScale(right_type) then
        return 2;
    end;
    return 1;
end;

pure func TileMatrixMathematicalSourceCount(
    function: integer {0..31}, left_type: TileDataType,
    right_type: TileDataType) => integer {2..5}
begin
    assert TileMatrixFunctionAssigned(function);
    let matrix_sources = TileMatrixLeftGroupSourceCount(
        function, left_type) + TileMatrixRightGroupSourceCount(
        function, right_type);
    let supplementary_source =
        TileMatrixFunctionUsesBias(function) ||
        TileMatrixFunctionUsesAccumulator(function);
    return (matrix_sources + (if supplementary_source then 1 else 0))
        as integer {2..5};
end;

// Shared Matrix inputs are carried in complete operand groups.  A right-only
// stream contains the right matrix and its optional scale.  A both-sides
// stream contains the complete left group followed by the complete right
// group.  TGEMV remains Local-only.
pure func TileMatrixSharedSourceCountLegal(
    function: integer {0..31}, left_type: TileDataType,
    right_type: TileDataType, shared_count: integer {0..4}) => boolean
begin
    assert TileMatrixFunctionAssigned(function);
    if TileMatrixFunctionIsGEMV(function) then
        return shared_count == 0;
    end;
    if shared_count == 0 then
        return TRUE;
    end;
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let both_groups = TileMatrixLeftGroupSourceCount(
        function, left_type) + right_group;
    return shared_count == right_group ||
           shared_count == both_groups;
end;

// Local mathematical operands preserve their architectural order after the
// Shared groups are removed.  ACC contributes C first; bias contributes the
// final Local source.  Post-processing sources are not counted here.
pure func TileMatrixLocalMathematicalSourceCount(
    function: integer {0..31}, left_type: TileDataType,
    right_type: TileDataType, shared_count: integer {0..4})
    => integer {0..5}
begin
    assert TileMatrixSharedSourceCountLegal(
        function, left_type, right_type, shared_count);
    let supplementary = if
        TileMatrixFunctionUsesBias(function) ||
        TileMatrixFunctionUsesAccumulator(function)
    then 1 else 0;
    if shared_count == 0 then
        return TileMatrixMathematicalSourceCount(
            function, left_type, right_type) as integer {0..5};
    end;
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    if shared_count == right_group then
        return (TileMatrixLeftGroupSourceCount(function, left_type) +
                supplementary) as integer {0..5};
    end;
    return supplementary as integer {0..5};
end;
```
<!-- GENERATED-ASL-END: unit -->
