// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA","surface":"block","classification":["model","dispatch","tgpr2t-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS"]}
// NDF-BEGIN: PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// TGPR2T MUST consume exactly two contiguous source-only B.IOR records (3+1),
// one terminating destination B.IOT, and one exact shape pair: LB1/LB0 is
// 32/4 for CUBE_M32 or 16/8 for CUBE_M16. LB2 MUST be absent. Missing,
// reordered, wrong-split, surplus, or destination-bearing forms reject before
// allocation, source reads, or publication.
// NDF-END: PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001

readonly func SelectedBundleClosedTGPR2TSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if TileOperationOfIndex(operation) != TileOperation_TGPR2T then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       !_BundleDimensionPresent[[0]] ||
       !_BundleDimensionPresent[[1]] ||
       _BundleDimensionPresent[[2]] then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    let rows = UInt(_BundleDimensions[[1]]);
    let columns = UInt(_BundleDimensions[[0]]);
    let shape_legal = (rows == 32 && columns == 4) ||
        (rows == 16 && columns == 8);
    return shape_legal && binding.destination_valid &&
           !binding.destination_allocated_by_bundle &&
           BundleTileDestinationSizeLegal(0) &&
           !binding.source0_valid && !binding.source1_valid &&
           binding.last &&
           TileDataTypeFromEncoding(
               CurrentBundleTileOperationDataTypeCode()
                   as TileDataTypeEncoding) == TileDataType_U8 &&
           BundleOperationGPRBindingValuesLegal(operation) &&
           TileTGPR2TRModeLegal(_BundleDataAttributes.rounding_mode) &&
           TileTGPR2TPadLegal();
end;
