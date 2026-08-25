<!-- GENERATED FROM: asl/tile/model/legality/indexed-rearrangement.asl -->
# Indexed Rearrangement

**Normative ASL source:** `asl/tile/model/legality/indexed-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/indexed-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT","surface":"tile","classification":["model","legality","indexed-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

pure func InstructionContractValueDataTypeLegal_TGATHER(
    data_type: TileDataType) => boolean
begin
    return IndexedTLSUTransferDataTypeLegal(data_type);
end;

pure func InstructionContractIndexDataTypeLegal_TGATHER(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func InstructionContractTypePairLegal_TSCATTER(
    value_type: TileDataType,
    index_type: TileDataType) => boolean
begin
    return IndexedTLSUTransferDataTypeLegal(value_type) &&
           (index_type == TileDataType_S16 ||
            index_type == TileDataType_U16 ||
            index_type == TileDataType_S32 ||
            index_type == TileDataType_U32 ||
            index_type == TileDataType_S64 ||
            index_type == TileDataType_U64);
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
    if data_type == TileDataType_S64 then
        return SInt(value[63:0]) < 0;
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
    if data_type == TileDataType_S32 ||
       data_type == TileDataType_U32 then
        return UInt(value[31:0]);
    end;
    assert data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
    return UInt(value[63:0]);
end;

readonly func TileGatherReferencesLegal(
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileLogicalLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let raw_index = TileReadLogicalElement(index_tile, index_element);
            if TileIndexedRowIsNegative(raw_index, index_tile.data_type) then
                return FALSE;
            end;
            let source_row = TileIndexedRowValue(
                raw_index,
                index_tile.data_type);
            if source_row >= source_tile.valid_rows then
                return FALSE;
            end;
            let source_element = TileLogicalLinearIndex(
                source_tile,
                source_row as integer {0..65535},
                column as integer {0..65535});
            if !TileLogicalElementDefined(source_tile, source_element) then
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
    var selected = Zeros{524288};
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileLogicalLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let raw_index = TileReadLogicalElement(index_tile, index_element);
            if TileIndexedRowIsNegative(raw_index, index_tile.data_type) then
                return FALSE;
            end;
            let destination_row = TileIndexedRowValue(
                raw_index,
                index_tile.data_type);
            if destination_row >= destination_tile.valid_rows then
                return FALSE;
            end;
            let destination_element = TileLogicalLinearIndex(
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
       !TileSourceEncodingsValid(indices) then
        return FALSE;
    end;
    return TileScatterReferencesLegal(destination, indices);
end;
```
<!-- GENERATED-ASL-END: unit -->
