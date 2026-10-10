// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE","surface":"block","classification":["model","dispatch","matrix-scale"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX","PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS","PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}

readonly func BundleMatrixCScaleDestinationIndicesDistinct(
    c_scale_ordinal: integer {0..8}) => boolean
begin
    let c_scale = BundleMatrixArchitecturalSourceAt(c_scale_ordinal);
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           c_scale == UInt(_BundleTileBindings[[binding]].destination_hand) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleMatrixCooperativeInfosMatchDimensions(
    left: TileInfo,
    right: TileInfo,
    m: integer {1..65535},
    n: integer {1..65535},
    k: integer {1..65535},
    left_shared: boolean,
    left_type: TileDataType,
    right_type: TileDataType) => boolean
begin
    let left_legal = if left_shared then
        BundleMatrixPrivateSharedViewLegal(
            left, m, k, left_type, FALSE)
    else
        TileCubeDescriptorLegal(left) && left.contents_defined &&
        left.valid_rows == m && left.valid_columns == k;
    return left_legal && BundleMatrixPrivateSharedViewLegal(
        right, k, n, right_type, TRUE);
end;

readonly func BundleMatrixCooperativeScalesLegal(
    left: TileInfo,
    left_scale: TileInfo,
    left_scale_present: boolean,
    left_scale_shared: boolean,
    right: TileInfo,
    right_scale: TileInfo,
    right_scale_present: boolean,
    left_type: TileDataType,
    right_type: TileDataType) => boolean
begin
    if !TileMXOperandPairLegal(left_type, right_type) ||
       left_scale_present != TileMXInputTypeNeedsScale(left_type) ||
       right_scale_present != TileMXInputTypeNeedsScale(right_type) then
        return FALSE;
    end;
    let left_groups = if left_scale_present then
        TileMXScaleGroupCount(
            left.valid_columns as integer {1..65535}, left_type)
    else 1;
    let right_groups = if right_scale_present then
        TileMXScaleGroupCount(
            left.valid_columns as integer {1..65535}, right_type)
    else 1;
    let left_scale_type = if left_scale_present then
        TileMXScaleCarrierType(left_type) else left_type;
    let right_scale_type = if right_scale_present then
        TileMXScaleCarrierType(right_type) else right_type;
    let left_scale_legal = !left_scale_present ||
        (left_scale_shared && BundleMatrixPrivateSharedViewLegal(
            left_scale, left.valid_rows as integer {1..65535},
            left_groups, left_scale_type, FALSE)) ||
        (!left_scale_shared &&
         ((left_scale.layout == TileLayout_CUBE_M32 &&
           TileCubeDescriptorLegal(left_scale)) ||
          (left_scale.layout == TileLayout_RowMajor &&
           TileInfoDescriptorLegal(left_scale))) &&
         left_scale.data_type == left_scale_type &&
         left_scale.valid_rows == left.valid_rows &&
         left_scale.valid_columns == left_groups);
    let right_scale_legal = !right_scale_present ||
        BundleMatrixPrivateSharedViewLegal(
            right_scale, right_groups,
            right.valid_columns as integer {1..65535},
            right_scale_type, FALSE);
    return left_scale_legal && right_scale_legal;
end;
