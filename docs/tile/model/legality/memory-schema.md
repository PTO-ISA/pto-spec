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
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","surface":"tile","classification":["model","legality","memory-schema"],"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT"]}
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
    indices: TileIndex, pad_value: TilePadValue) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(indices) &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[indices]].valid_columns &&
           IndexedTLSUIndexDataTypeLegal(_Tiles[[indices]].data_type) &&
           IndexedTLSUTransferDataTypeLegal(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_MGATHER(
    destination: TileIndex, base_address: Word,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_MGATHER(destination, base_address, indices,
        TilePad_Null);
end;

readonly func TileOperandsLegal_MSCATTER(
    base_address: Word, source: TileIndex, indices: TileIndex) => boolean
begin
    return TileSourceContentsDefined(source) &&
           TileSourceContentsDefined(indices) &&
           IndexedTLSUIndexDataTypeLegal(_Tiles[[indices]].data_type) &&
           IndexedTLSUTransferDataTypeLegal(_Tiles[[source]].data_type) &&
           _Tiles[[source]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[source]].valid_columns ==
               _Tiles[[indices]].valid_columns &&
           _Tiles[[source]].layout == _Tiles[[indices]].layout;
end;

readonly func TileOperandsLegal_MGATHER_MASK(
    destination: TileIndex, base_address: Word,
    indices: TileIndex, mask: TileIndex, pad_value: TilePadValue) => boolean
begin
    return TileDescriptorLegal(destination) &&
           TileSourceContentsDefined(indices) &&
           TilePredicateValuesLegal(mask) &&
           IndexedTLSUIndexDataTypeLegal(_Tiles[[indices]].data_type) &&
           IndexedTLSUTransferDataTypeLegal(
               _Tiles[[destination]].data_type) &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[mask]].valid_rows &&
           _Tiles[[destination]].valid_columns ==
               _Tiles[[mask]].valid_columns &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[mask]].layout;
end;

readonly func TileOperandsLegal_MSCATTER_MASK(
    base_address: Word, source: TileIndex, indices: TileIndex,
    mask: TileIndex) => boolean
begin
    return TileSourceContentsDefined(source) &&
           TileSourceContentsDefined(indices) &&
           TilePredicateValuesLegal(mask) &&
           IndexedTLSUIndexDataTypeLegal(_Tiles[[indices]].data_type) &&
           IndexedTLSUTransferDataTypeLegal(_Tiles[[source]].data_type) &&
           _Tiles[[source]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[source]].valid_columns ==
               _Tiles[[indices]].valid_columns &&
           _Tiles[[source]].valid_rows == _Tiles[[mask]].valid_rows &&
           _Tiles[[source]].valid_columns == _Tiles[[mask]].valid_columns &&
           _Tiles[[source]].layout == _Tiles[[indices]].layout &&
           _Tiles[[source]].layout == _Tiles[[mask]].layout;
end;

readonly func TileOperandsLegal_MGATHER_CAS(
    destination: TileIndex, base_address: Word, indices: TileIndex,
    expected: TileIndex, replacement: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return TileDescriptorLegal(destination) &&
           TileSourceContentsDefined(indices) &&
           TileSourceContentsDefined(expected) &&
           TileSourceContentsDefined(replacement) &&
           IndexedTLSUIndexDataTypeLegal(_Tiles[[indices]].data_type) &&
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
               _Tiles[[replacement]].data_type;
end;

readonly func TileOperandsLegal_MGATHER_CAS(
    destination: TileIndex, base_address: Word, indices: TileIndex,
    expected: TileIndex, replacement: TileIndex) => boolean
begin
    return TileOperandsLegal_MGATHER_CAS(destination, base_address, indices,
        expected, replacement, TilePad_Null);
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
