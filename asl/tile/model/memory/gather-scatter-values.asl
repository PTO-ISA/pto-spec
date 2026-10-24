// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GATHER-SCATTER-VALUES","surface":"tile","classification":["model","memory","gather-scatter-values"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-MEMORY-LOAD-STORE","PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES","PTO-TILE-MODEL-STATE-TYPES"]}
readonly func IndexedGatherInactiveDestinationValueForOutput(
    destination: TileOutputValueTarget,
    row: integer {0..65535}, column: integer {0..65535}) => Word
begin
    if _BundleExecutionMask.zero_inactive then
        return Zeros{PTO_XLEN};
    end;
    assert _BundleExecutionMask.merge_base_valid;
    if _BundleExecutionMask.merge_base == destination.destination then
        let element = TileLogicalLinearIndex(destination.value, row, column);
        return TileReadLogicalElement(destination.value, element);
    end;
    let base = _Tiles[[_BundleExecutionMask.merge_base]];
    let element = TileLogicalLinearIndex(base, row, column);
    return TileReadLogicalElement(base, element);
end;

func MGATHERToValue(destination: TileOutputValueTarget,
                    base_address: Word, indices: TileIndex,
                    pad_value: TilePadValue) => TileInfo
begin
    let destination_tile = destination.value;
    let index_tile = _Tiles[[indices]];
    assert destination_tile.allocated &&
           destination_tile.storage_kind == TileStorage_Numeric &&
           IndexedTLSULayoutSupported(destination_tile.layout) &&
           (if TileLayoutIsCube(destination_tile.layout) then
                TileCubeDescriptorLegal(destination_tile)
            else
                TileDescriptorShapeLegal(destination_tile.capacity_bytes,
                    destination_tile.columns, destination_tile.valid_rows,
                    destination_tile.valid_columns,
                    destination_tile.data_type));
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUDataShapeMatchesIndex(
        destination_tile.valid_rows, destination_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        destination_tile.data_type);
    assert destination_tile.layout == index_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(destination_tile.data_type);
    var translated_addresses: TilePayload;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let index_element = TileStorageIndex(index_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let address = TileMemoryByteDisplacementAddress(base_address,
                    index_tile.payload[[index_element]], index_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    destination_tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then
                    return destination.value;
                end;
                translated_addresses[[index_element]] =
                    probe.translated_address;
            end;
        end;
    end;
    var result = destination_tile;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                let transfer_column = if TileDataTypeIsFourBit(
                    destination_tile.data_type) then column DIVRM 2 else column;
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    transfer_column as integer {0..65535});
            end;
            let value = if inactive then
                IndexedGatherInactiveDestinationValueForOutput(destination,
                    row as integer {0..65535},
                    column as integer {0..65535})
            else TilePadValueForDataType(
                pad_value, destination_tile.data_type);
            result = TileInfoWithLogicalElementAndDefined(
                result, element, value, TRUE);
        end;
    end;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let raw = LoadTranslatedUnsigned(
                translated_addresses[[index_element]],
                TileMemoryElementBytes(destination_tile.data_type));
            RecordLoadEvent(translated_addresses[[index_element]],
                TileMemoryElementBytes(destination_tile.data_type), raw,
                CurrentBundleMemoryOrder());
            let first_column = if TileDataTypeIsFourBit(
                destination_tile.data_type) then 2 * column else column;
            let first = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                first_column as integer {0..65535});
            result = TileInfoWithLogicalElementAndDefined(result, first,
                DecodeTileMemoryElementRaw(
                    raw, destination_tile.data_type, FALSE), TRUE);
            if TileDataTypeIsFourBit(destination_tile.data_type) then
                let second = TileLogicalLinearIndex(result,
                    row as integer {0..65535},
                    (first_column + 1) as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(result, second,
                    DecodeTileMemoryElementRaw(
                        raw, destination_tile.data_type, TRUE), TRUE);
            end;
            end;
        end;
    end;
    return TileWithPhysicalRegionDefined(result);
end;

func MGATHER_MASKToValue(destination: TileOutputValueTarget,
                  base_address: Word,
                  indices: TileIndex, mask: TileIndex,
                  pad_value: TilePadValue) => TileInfo
begin
    let destination_tile = destination.value;
    let index_tile = _Tiles[[indices]];
    let mask_tile = _Tiles[[mask]];
    assert IndexedTLSUNumericValueDescriptorLegal(destination_tile);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUPredicateValuesLegal(mask);
    assert IndexedTLSUDataShapeMatchesIndex(
        destination_tile.valid_rows, destination_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        destination_tile.data_type);
    assert index_tile.valid_rows == mask_tile.valid_rows;
    assert index_tile.valid_columns == mask_tile.valid_columns;
    assert destination_tile.layout == index_tile.layout;
    assert destination_tile.layout == mask_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(destination_tile.data_type);
    var translated_addresses: TilePayload;
    var active_lanes: bits(PTO_MODEL_TILE_ELEMENTS) =
        Zeros{PTO_MODEL_TILE_ELEMENTS};
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               ReadIndexedTLSUPredicate(mask,
                row as integer {0..65535},
                column as integer {0..65535}) then
                let address = TileMemoryByteDisplacementAddress(base_address,
                    index_tile.payload[[index_element]], index_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    destination_tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then
                    return destination.value;
                end;
                translated_addresses[[index_element]] = probe.translated_address;
                active_lanes[index_element] = '1';
            end;
        end;
    end;
    var result = destination_tile;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                let transfer_column = if TileDataTypeIsFourBit(
                    destination_tile.data_type) then column DIVRM 2 else column;
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    transfer_column as integer {0..65535});
            end;
            let value = if inactive then
                IndexedGatherInactiveDestinationValueForOutput(destination,
                    row as integer {0..65535},
                    column as integer {0..65535})
            else TilePadValueForDataType(
                pad_value, destination_tile.data_type);
            result = TileInfoWithLogicalElementAndDefined(
                result, element, value, TRUE);
        end;
    end;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if active_lanes[index_element] == '1' then
                let raw = LoadTranslatedUnsigned(
                    translated_addresses[[index_element]],
                    TileMemoryElementBytes(destination_tile.data_type));
                RecordLoadEvent(translated_addresses[[index_element]],
                    TileMemoryElementBytes(destination_tile.data_type), raw,
                    CurrentBundleMemoryOrder());
                let first_column = if TileDataTypeIsFourBit(
                    destination_tile.data_type) then 2 * column else column;
                let first = TileLogicalLinearIndex(result,
                    row as integer {0..65535},
                    first_column as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(result, first,
                    DecodeTileMemoryElementRaw(
                        raw, destination_tile.data_type, FALSE), TRUE);
                if TileDataTypeIsFourBit(destination_tile.data_type) then
                    let second = TileLogicalLinearIndex(result,
                        row as integer {0..65535},
                        (first_column + 1) as integer {0..65535});
                    result = TileInfoWithLogicalElementAndDefined(result, second,
                        DecodeTileMemoryElementRaw(
                            raw, destination_tile.data_type, TRUE), TRUE);
                end;
            end;
        end;
    end;
    return TileWithPhysicalRegionDefined(result);
end;
