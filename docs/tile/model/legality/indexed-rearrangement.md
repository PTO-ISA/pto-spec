<!-- GENERATED FROM: asl/tile/model/legality/indexed-rearrangement.asl -->
# Indexed Rearrangement

**Normative ASL source:** `asl/tile/model/legality/indexed-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/indexed-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT","surface":"tile","classification":["model","legality","indexed-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

pure func InstructionContractValueDataTypeLegal_TGATHER(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_FP32, TileDataType_FP16,
             TileDataType_S32, TileDataType_S16,
             TileDataType_U32, TileDataType_U16 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func InstructionContractIndexDataTypeLegal_TGATHER(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32;
end;

pure func InstructionContractTypePairLegal_TSCATTER(
    value_type: TileDataType,
    index_type: TileDataType) => boolean
begin
    if value_type == TileDataType_FP32 ||
       value_type == TileDataType_S32 ||
       value_type == TileDataType_U32 then
        return index_type == TileDataType_S32 ||
               index_type == TileDataType_U32;
    end;
    if value_type == TileDataType_FP16 ||
       value_type == TileDataType_BF16 ||
       value_type == TileDataType_S16 ||
       value_type == TileDataType_U16 ||
       value_type == TileDataType_S8 ||
       value_type == TileDataType_U8 then
        return index_type == TileDataType_S16 ||
               index_type == TileDataType_U16;
    end;
    return FALSE;
end;

pure func TileIndexedRowIsNegative(
    value: Word,
    data_type: TileDataType) => boolean
begin
    if data_type == TileDataType_S16 then
        return SInt(value[15:0]) < 0;
    end;
    if data_type == TileDataType_S32 then
        return SInt(value[31:0]) < 0;
    end;
    return FALSE;
end;

pure func TileIndexedRowValue(
    value: Word,
    data_type: TileDataType) => integer
begin
    if data_type == TileDataType_S16 ||
       data_type == TileDataType_U16 then
        return UInt(value[15:0]);
    end;
    assert data_type == TileDataType_S32 ||
           data_type == TileDataType_U32;
    return UInt(value[31:0]);
end;

readonly func TileGatherReferencesLegal(
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let raw_index = index_payload[[index_element]];
            if TileIndexedRowIsNegative(raw_index, index_tile.data_type) then
                return FALSE;
            end;
            let source_row = TileIndexedRowValue(
                raw_index,
                index_tile.data_type);
            if source_row >= source_tile.valid_rows then
                return FALSE;
            end;
            let source_element = TileLinearIndex(
                source_tile,
                source_row as integer {0..65535},
                column as integer {0..65535});
            if source_tile.defined_elements[source_element] == '0' ||
               !TileNumericEncodingValid(
                   source_tile.data_type,
                   source_payload[[source_element]]) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileScatterReferencesLegal(
    destination: TileIndex,
    indices: TileIndex) => boolean
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let index_payload = index_tile.payload;
    var selected = Zeros{PTO_MODEL_TILE_ELEMENTS};
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let raw_index = index_payload[[index_element]];
            if TileIndexedRowIsNegative(raw_index, index_tile.data_type) then
                return FALSE;
            end;
            let destination_row = TileIndexedRowValue(
                raw_index,
                index_tile.data_type);
            if destination_row >= destination_tile.valid_rows then
                return FALSE;
            end;
            let destination_element = TileLinearIndex(
                destination_tile,
                destination_row as integer {0..65535},
                column as integer {0..65535});
            if selected[destination_element] == '1' then
                return FALSE;
            end;
            selected[destination_element] = '1';
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       !TileDescriptorLegal(indices) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       index_tile.storage_kind != TileStorage_Numeric ||
       !InstructionContractValueDataTypeLegal_TGATHER(
           source_tile.data_type) ||
       !InstructionContractIndexDataTypeLegal_TGATHER(
           index_tile.data_type) ||
       destination_tile.data_type != source_tile.data_type ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       destination_tile.valid_rows != index_tile.valid_rows ||
       destination_tile.valid_columns != index_tile.valid_columns ||
       source_tile.valid_columns < destination_tile.valid_columns ||
       !TileSourceContentsDefined(indices) ||
       !TileSourceEncodingsValid(indices) then
        return FALSE;
    end;
    return TileGatherReferencesLegal(source, indices);
end;

readonly func TileOperandsLegal_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       !TileDescriptorLegal(indices) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       index_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.data_type != source_tile.data_type ||
       !InstructionContractTypePairLegal_TSCATTER(
           source_tile.data_type,
           index_tile.data_type) ||
       source_tile.valid_rows == 0 ||
       source_tile.valid_columns == 0 ||
       source_tile.valid_rows != index_tile.valid_rows ||
       source_tile.valid_columns != index_tile.valid_columns ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns != source_tile.valid_columns ||
       !TileSourceContentsDefined(source) ||
       !TileSourceContentsDefined(indices) ||
       !TileSourceEncodingsValid(source) ||
       !TileSourceEncodingsValid(indices) then
        return FALSE;
    end;
    return TileScatterReferencesLegal(destination, indices);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
