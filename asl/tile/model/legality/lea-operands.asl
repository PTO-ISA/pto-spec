// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS","surface":"tile","classification":["model","legality","lea-operands"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","PTO-TILE-MODEL-STATE-TYPES"]}

pure func TileLEAIndexDataTypeLegal(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func TileLEADestinationDataType(data_type: TileDataType) => TileDataType
begin
    assert TileLEAIndexDataTypeLegal(data_type);
    if data_type == TileDataType_S32 || data_type == TileDataType_S64 then
        return TileDataType_S64;
    end;
    return TileDataType_U64;
end;

pure func TileLEAElementBitsLegal(element_bits: Word) => boolean
begin
    return element_bits == Zeros{PTO_XLEN} + 8 ||
           element_bits == Zeros{PTO_XLEN} + 16 ||
           element_bits == Zeros{PTO_XLEN} + 32 ||
           element_bits == Zeros{PTO_XLEN} + 64;
end;

readonly func TileLEASourceOperationType(source: TileIndex)
    => (boolean, TileDataType)
begin
    return ResolveTileSelectedOperationType(_Tiles[[source]].data_type);
end;

readonly func TileLEABundleLogicalShapeMatches(index: TileIndex) => boolean
begin
    if !BundleTileOperationSelected() then return TRUE; end;
    let valid_columns_raw = UInt(_BundleDimensions[[0]]);
    let valid_rows_raw = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    if valid_columns_raw < 1 || valid_columns_raw > 65535 ||
       valid_rows_raw < 1 || valid_rows_raw > 65535 then
        return FALSE;
    end;
    let tile = _Tiles[[index]];
    return tile.valid_columns == valid_columns_raw &&
           tile.valid_rows == valid_rows_raw &&
           tile.layout == CurrentBundleTileLayout();
end;

readonly func TileOperandsLegal_TLEA(
    destination: TileIndex, source: TileIndex, element_bits: Word) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileLEASourceOperationType(source);
    let source_tile = _Tiles[[source]];
    let destination_tile = _Tiles[[destination]];
    if !operation_type_valid ||
       operation_type != source_tile.data_type ||
       !TileLEAIndexDataTypeLegal(operation_type) ||
       !TileLEAElementBitsLegal(element_bits) ||
       !TileElementwiseLayoutSupported(source_tile.layout) ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.layout != destination_tile.layout ||
       source_tile.valid_rows != destination_tile.valid_rows ||
       source_tile.valid_columns != destination_tile.valid_columns ||
       destination_tile.data_type != TileLEADestinationDataType(operation_type) ||
       !TileElementwiseDescriptorLegal(source) ||
       !TileElementwiseDescriptorLegal(destination) ||
       !TileElementwiseSourceContentsDefined(source) ||
       !TileLEABundleLogicalShapeMatches(source) ||
       !TileLEABundleLogicalShapeMatches(destination) then
        return FALSE;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TLEAToValue(
    destination: TileOutputValueTarget, source: TileIndex,
    element_bits: Word) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileLEASourceOperationType(source);
    let source_tile = _Tiles[[source]];
    let output = destination.value;
    if !operation_type_valid || operation_type != source_tile.data_type ||
       !TileLEAIndexDataTypeLegal(operation_type) ||
       !TileLEAElementBitsLegal(element_bits) ||
       !TileElementwiseLayoutSupported(source_tile.layout) ||
       source_tile.storage_kind != TileStorage_Numeric ||
       output.storage_kind != TileStorage_Numeric ||
       source_tile.layout != output.layout ||
       source_tile.valid_rows != output.valid_rows ||
       source_tile.valid_columns != output.valid_columns ||
       output.data_type != TileLEADestinationDataType(operation_type) ||
       !TileElementwiseDescriptorLegal(source) ||
       (if TileLayoutIsCube(output.layout) then
            !TileCubeDescriptorLegal(output)
        else !TileDescriptorPhysicalShapeLegal(output.capacity_bytes,
            output.rows, output.columns, output.valid_rows,
            output.valid_columns, output.data_type)) ||
       !TileElementwiseSourceContentsDefined(source) then
        return FALSE;
    end;
    if BundleTileOperationSelected() then
        let valid_columns = UInt(_BundleDimensions[[0]]);
        let valid_rows = if _BundleDimensionPresent[[1]] then
            UInt(_BundleDimensions[[1]]) else 1;
        if valid_columns < 1 || valid_columns > 65535 ||
           valid_rows < 1 || valid_rows > 65535 ||
           source_tile.valid_columns != valid_columns ||
           output.valid_columns != valid_columns ||
           source_tile.valid_rows != valid_rows ||
           output.valid_rows != valid_rows ||
           source_tile.layout != CurrentBundleTileLayout() ||
           output.layout != CurrentBundleTileLayout() then
            return FALSE;
        end;
    end;
    return TRUE;
end;
