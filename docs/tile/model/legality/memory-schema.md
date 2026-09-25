<!-- GENERATED FROM: asl/tile/model/legality/memory-schema.asl -->
# Memory Schema

**Normative ASL source:** `asl/tile/model/legality/memory-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/memory-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","surface":"tile","classification":["model","legality","memory-schema"],"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
readonly func IndexedTLSUExecutionMaskContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !IndexedTLSUNumericDescriptorLegal(index) then return FALSE; end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows then
        return FALSE;
    end;
    if TileDataTypeIsFourBit(tile.data_type) then
        if tile.valid_columns !=
           2 * _BundleExecutionMask.valid_columns then return FALSE; end;
    elsif tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to _BundleExecutionMask.valid_rows - 1 looplimit 65536 do
        for column = 0 to _BundleExecutionMask.valid_columns - 1
            looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let first_column = if TileDataTypeIsFourBit(tile.data_type)
                    then 2 * column else column;
                let first = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    first_column as integer {0..65535});
                if !TileLogicalElementDefined(tile, first) then
                    return FALSE;
                end;
                if TileDataTypeIsFourBit(tile.data_type) then
                    let second = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        (first_column + 1) as integer {0..65535});
                    if !TileLogicalElementDefined(tile, second) then
                        return FALSE;
                    end;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TMOV(destination: TileIndex,
                                     source: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    return operation_type_valid &&
           TileLogicalShapeMatch(destination, source) &&
           _Tiles[[destination]].storage_kind ==
               _Tiles[[source]].storage_kind &&
           TileCarrierWidthCompatible(
               _Tiles[[source]].data_type, operation_type) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;

readonly func TileOperandsLegal_TLOAD(destination: TileIndex,
                                      base_address: Word,
                                      row_stride_bytes: Word) => boolean
begin
    return TileDescriptorLegal(destination) &&
           TileRegularTLSUDataTypeSupported(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_TSTORE(base_address: Word,
                                       row_stride_bytes: Word,
                                       source: TileIndex) => boolean
begin
    return TileDescriptorLegal(source) &&
           TileRegularTLSUDataTypeSupported(
               _Tiles[[source]].data_type);
end;

readonly func TileOperandsLegal_MGATHER(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[destination]].valid_rows,
               _Tiles[[destination]].valid_columns,
               _Tiles[[indices]].valid_rows,
               _Tiles[[indices]].valid_columns,
               _Tiles[[destination]].data_type) &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_MGATHER(
    destination: TileIndex, base_address: Word,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_MGATHER(
        destination, base_address, indices, TilePad_Null);
end;

readonly func TileOperandsLegal_MSCATTER(
    base_address: Word, source: TileIndex, indices: TileIndex) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(source) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[source]].data_type) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
               _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
               _Tiles[[source]].data_type) &&
           _Tiles[[source]].layout == _Tiles[[indices]].layout;
end;

readonly func TileOperandsLegal_MGATHER_MASK(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    mask: TileIndex, pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUPredicateValuesLegal(mask) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[destination]].data_type) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[destination]].valid_rows,
               _Tiles[[destination]].valid_columns,
               _Tiles[[indices]].valid_rows,
               _Tiles[[indices]].valid_columns,
               _Tiles[[destination]].data_type) &&
           _Tiles[[indices]].valid_rows == _Tiles[[mask]].valid_rows &&
           _Tiles[[indices]].valid_columns == _Tiles[[mask]].valid_columns &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[mask]].layout;
end;

readonly func TileOperandsLegal_MSCATTER_MASK(
    base_address: Word, source: TileIndex, indices: TileIndex,
    mask: TileIndex) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(source) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUPredicateValuesLegal(mask) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           IndexedTLSUOrdinaryTransferDataTypeLegal(
               _Tiles[[source]].data_type) &&
           IndexedTLSUDataShapeMatchesIndex(
               _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
               _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
               _Tiles[[source]].data_type) &&
           _Tiles[[indices]].valid_rows == _Tiles[[mask]].valid_rows &&
           _Tiles[[indices]].valid_columns == _Tiles[[mask]].valid_columns &&
           _Tiles[[source]].layout == _Tiles[[indices]].layout &&
           _Tiles[[source]].layout == _Tiles[[mask]].layout;
end;

readonly func TileOperandsLegal_MGATHER_CAS(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    expected: TileIndex, replacement: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(expected) &&
           IndexedTLSUExecutionMaskContentsDefined(replacement) &&
           IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) &&
           IndexedTLSUTransferDataTypeLegal(
               _Tiles[[destination]].data_type) &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[expected]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[expected]].valid_columns &&
           _Tiles[[destination]].valid_rows ==
               _Tiles[[replacement]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[replacement]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[expected]].data_type &&
           _Tiles[[destination]].data_type ==
               _Tiles[[replacement]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[expected]].layout &&
           _Tiles[[destination]].layout == _Tiles[[replacement]].layout;
end;

readonly func TileOperandsLegal_MGATHER_CAS(
    destination: TileIndex, base_address: Word,
    indices: TileIndex,
    expected: TileIndex, replacement: TileIndex) => boolean
begin
    return TileOperandsLegal_MGATHER_CAS(destination, base_address,
        indices, expected, replacement, TilePad_Null);
end;

readonly func TileOperandsLegal_TPREFETCH(
    base_address: Word, row_stride_elements: Word,
    valid_columns: integer {1..65535},
    valid_rows: integer {1..65535},
    columns: integer {1..65535}) => boolean
begin
    return valid_columns <= columns && IsNonzeroPowerOfTwo(columns) &&
           valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

readonly func TileOperandsLegal_TPREFETCH(
    base_address: Word, row_stride_elements: Word,
    valid_columns: integer {1..65535},
    valid_rows: integer {1..65535},
    columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    return TileOperandsLegal_TPREFETCH(
               base_address, row_stride_elements, valid_columns,
               valid_rows, columns) &&
           TileCarrierOrPackedBaselineDataTypeSupported(data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
