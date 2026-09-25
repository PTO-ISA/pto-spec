// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","surface":"block","classification":["model","dispatch","expdif-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
readonly func SelectedBundleExponentialDifferenceTypes()
    => (boolean, TileDataType, TileDataType)
begin
    let default_type = TileDataType_FP64;
    if !_BundleOperation.data_type_valid then
        return (FALSE, default_type, default_type);
    end;
    let source_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    var destination_type = source_type;
    if _BundleDataAttributesPresent then
        if _BundleDataAttributes.data_type == DTYPE_NONE then
            destination_type = source_type;
        elsif !BundleDataTypeConcrete(_BundleDataAttributes.data_type) then
            return (FALSE, default_type, default_type);
        else
            destination_type = BundleTileDataType(
                _BundleDataAttributes.data_type);
        end;
    end;
    return (
        TileExpdifTypePairLegal(source_type, destination_type),
        source_type,
        destination_type);
end;
