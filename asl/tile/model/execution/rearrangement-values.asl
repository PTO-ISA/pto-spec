// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-REARRANGEMENT-VALUES","surface":"tile","classification":["model","execution","rearrangement-values"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","PTO-TILE-MODEL-STATE-TYPES"]}
func TPERMUTEToValue(destination: TileOutputValueTarget,
                     source0: TileIndex, source1: TileIndex,
                     indices: TileIndex) => TileInfo
begin
    let destination_tile = destination.value;
    let source0_tile = _Tiles[[source0]];
    let source1_tile = _Tiles[[source1]];
    let index_tile = _Tiles[[indices]];
    let row_bytes = TileCellRearrangementRowBytes(destination_tile.layout);
    let valid_bytes = TileCellRearrangementValidBytes(destination_tile);
    var result = destination_tile;
    // Validate all indices before the first destination write.
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 65536 do
            if TileCellRearrangementByteHasActiveCoordinate(
                   destination_tile, row as integer {0..65535}, byte_index) then
                let index_value = UInt(TileReadCellByte(
                    index_tile, row as integer {0..65535}, byte_index));
                assert index_value < row_bytes * 2;
            end;
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 65536 do
            if TileCellRearrangementByteHasActiveCoordinate(
                   destination_tile, row as integer {0..65535}, byte_index) then
                let index_value = UInt(TileReadCellByte(
                    index_tile, row as integer {0..65535}, byte_index));
                let selected_source = if index_value < row_bytes then
                    source0_tile else source1_tile;
                let cell_base = (byte_index DIVRM row_bytes) * row_bytes;
                let selected_byte = if index_value < row_bytes then
                    index_value else index_value - row_bytes;
                result = TileInfoWithCellByte(
                    result,
                    row as integer {0..65535},
                    byte_index,
                    TileReadCellByte(
                        selected_source,
                        row as integer {0..65535},
                        (cell_base + selected_byte)
                            as integer {0..262143}));
            end;
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1
            looplimit 65536 do
            if !BundleExecutionMaskActiveAt(
                   destination_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(
                    result, row as integer {0..65535},
                    column as integer {0..65535});
                let value = BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result = TileInfoWithLogicalElement(result, element, value);
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    return result;
end;

func TSHUFToValue(destination: TileOutputValueTarget,
                  source: TileIndex, controls: TileIndex,
                  control: Word) => TileInfo
begin
    let destination_tile = destination.value;
    let source_tile = _Tiles[[source]];
    let controls_tile = _Tiles[[controls]];
    let mode = UInt(control[7:0]);
    let segment_code = UInt(control[15:8]);
    let boundary = UInt(control[23:16]);
    let segment_width = if segment_code == 0 then 2
        else if segment_code == 1 then 4
        else if segment_code == 2 then 8
        else if segment_code == 3 then 16
        else 32;
    var result = destination_tile;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let first_word = TileCellRearrangementElementWordIndex(
                    source_tile.data_type,
                    column as integer {0..65535});
                let raw_words = if TileElementBits(source_tile.data_type) == 64
                    then 2 else 1;
                for raw_word = 0 to raw_words - 1 looplimit 2 do
                    let word_index = (first_word + raw_word)
                        as integer {0..65535};
                    let control_element = TileLogicalLinearIndex(
                        controls_tile, row as integer {0..65535}, word_index);
                    let control_word = TileReadLogicalElement(
                        controls_tile, control_element);
                    let (source_required, source_row) = TileShuffleSelectedRow(
                        control_word, row as integer {0..65535},
                        source_tile.valid_rows as integer {1..65535},
                        source_tile.layout,
                        segment_width, mode as integer {0..3},
                        boundary as integer {0..1});
                    if source_required then
                        let source_element = TileLogicalLinearIndex(
                            source_tile, source_row,
                            column as integer {0..65535});
                        let source_value = TileReadLogicalElement(
                            source_tile, source_element);
                        if raw_words == 2 then
                            value = TileCubeM32B64WithRawPlaneWord(
                                value,
                                TileCubeM32B64RawPlaneWord(
                                    source_value, raw_word == 1),
                                raw_word == 1);
                        else value = source_value;
                        end;
                    end;
                end;
            else
                value = BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            let destination_element = TileLogicalLinearIndex(
                result, row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(
                result, destination_element, value);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    return result;
end;

func TPACKToValue(destination: TileOutputValueTarget,
                  source0: TileIndex, source1: TileIndex,
                  control: Word) => TileInfo
begin
    let destination_tile = destination.value;
    let source0_tile = _Tiles[[source0]];
    let source1_tile = _Tiles[[source1]];
    let source0_bytes = UInt(control[7:0]);
    let source1_bytes = UInt(control[15:8]);
    let words = TileCellRearrangementWordsPerRow(source0_tile);
    var result = destination_tile;
    if destination_tile.data_type == TileDataType_U64 then
        for row = 0 to source0_tile.valid_rows - 1 looplimit 65536 do
            for pair = 0 to (words DIVRM 2) - 1 looplimit 32768 do
                let column = pair as integer {0..65535};
                let destination_element = TileLogicalLinearIndex(
                    result, row as integer {0..65535}, column);
                var joined = Zeros{PTO_XLEN};
                if _BundleExecutionMask.valid &&
                   !_BundleExecutionMask.zero_inactive then
                    let base = _Tiles[[_BundleExecutionMask.merge_base]];
                    let base_element = TileLogicalLinearIndex(
                        base, row as integer {0..65535}, column);
                    joined = TileReadLogicalElement(base, base_element);
                end;
                for raw_word = 0 to 1 looplimit 2 do
                    let word_index = (pair * 2 + raw_word)
                        as integer {0..65535};
                    if BundleExecutionMaskActiveAt(
                           source0_tile.layout, row as integer {0..65535},
                           word_index) then
                        let word_start = (word_index * 4)
                            as integer {0..262143};
                        var packed = Zeros{32};
                        for byte_index = 0 to source0_bytes - 1 looplimit 3 do
                            packed[(byte_index * 8) +: 8] = TileReadCellByte(
                                source0_tile, row as integer {0..65535},
                                (word_start + byte_index)
                                    as integer {0..262143});
                        end;
                        for byte_index = 0 to source1_bytes - 1 looplimit 3 do
                            packed[((source0_bytes + byte_index) * 8) +: 8] =
                                TileReadCellByte(source1_tile,
                                    row as integer {0..65535},
                                    (word_start + byte_index)
                                        as integer {0..262143});
                        end;
                        joined = TileCubeM32B64WithRawPlaneWord(
                            joined, packed, raw_word == 1);
                    end;
                end;
                result = TileInfoWithLogicalElementAndDefined(
                    result, destination_element, joined, TRUE);
            end;
        end;
        result = TileWithValidRegionDefined(result);
        result = TileWithPadding(result, TilePad_Null);
        return result;
    end;
    for row = 0 to source0_tile.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            if BundleExecutionMaskActiveAt(
                   source0_tile.layout, row as integer {0..65535},
                   word_index as integer {0..65535}) then
                var packed = Zeros{PTO_XLEN};
                for byte_index = 0 to source0_bytes - 1 looplimit 3 do
                    packed[(byte_index * 8) +: 8] = TileReadCellByte(
                        source0_tile, row as integer {0..65535},
                        (word_start + byte_index) as integer {0..262143});
                end;
                for byte_index = 0 to source1_bytes - 1 looplimit 3 do
                    packed[((source0_bytes + byte_index) * 8) +: 8] =
                        TileReadCellByte(source1_tile,
                            row as integer {0..65535},
                            (word_start + byte_index) as integer {0..262143});
                end;
                result = TileInfoWithCellWord(result,
                    row as integer {0..65535},
                    word_index as integer {0..65535}, packed);
            else
                let group_width = if destination_tile.data_type == TileDataType_U8 then 4
                    else if destination_tile.data_type == TileDataType_U16 then 2
                    else 1;
                for group_element = 0 to group_width - 1 looplimit 4 do
                    let column = (word_index * group_width + group_element)
                        as integer {0..65535};
                    let destination_element = TileLogicalLinearIndex(
                        result, row as integer {0..65535}, column);
                    var value = Zeros{PTO_XLEN};
                    if !_BundleExecutionMask.zero_inactive then
                        let base = _Tiles[[_BundleExecutionMask.merge_base]];
                        let base_element = TileLogicalLinearIndex(
                            base, row as integer {0..65535}, column);
                        value = TileReadLogicalElement(base, base_element);
                    end;
                    result = TileInfoWithLogicalElementAndDefined(
                        result, destination_element, value, TRUE);
                end;
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    return result;
end;

func TUNPACKToValue(destination: TileOutputValueTarget,
                    source: TileIndex, control: Word) => TileInfo
begin
    let destination_tile = destination.value;
    let source_tile = _Tiles[[source]];
    let byte_offset = UInt(control[7:0]);
    let byte_count = UInt(control[15:8]);
    let words = TileCellRearrangementWordsPerRow(source_tile);
    var result = destination_tile;
    if destination_tile.data_type == TileDataType_U64 then
        for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
            for pair = 0 to (words DIVRM 2) - 1 looplimit 32768 do
                let column = pair as integer {0..65535};
                let destination_element = TileLogicalLinearIndex(
                    result, row as integer {0..65535}, column);
                var joined = Zeros{PTO_XLEN};
                if _BundleExecutionMask.valid &&
                   !_BundleExecutionMask.zero_inactive then
                    let base = _Tiles[[_BundleExecutionMask.merge_base]];
                    let base_element = TileLogicalLinearIndex(
                        base, row as integer {0..65535}, column);
                    joined = TileReadLogicalElement(base, base_element);
                end;
                for raw_word = 0 to 1 looplimit 2 do
                    let word_index = (pair * 2 + raw_word)
                        as integer {0..65535};
                    if BundleExecutionMaskActiveAt(
                           source_tile.layout, row as integer {0..65535},
                           word_index) then
                        let word_start = (word_index * 4)
                            as integer {0..262143};
                        var unpacked = Zeros{32};
                        for byte_index = 0 to byte_count - 1 looplimit 4 do
                            unpacked[(byte_index * 8) +: 8] =
                                TileReadCellByte(source_tile,
                                    row as integer {0..65535},
                                    (word_start + byte_offset + byte_index)
                                        as integer {0..262143});
                        end;
                        joined = TileCubeM32B64WithRawPlaneWord(
                            joined, unpacked, raw_word == 1);
                    end;
                end;
                result = TileInfoWithLogicalElementAndDefined(
                    result, destination_element, joined, TRUE);
            end;
        end;
        result = TileWithValidRegionDefined(result);
        result = TileWithPadding(result, TilePad_Null);
        return result;
    end;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   word_index as integer {0..65535}) then
                var unpacked = Zeros{PTO_XLEN};
                for byte_index = 0 to byte_count - 1 looplimit 4 do
                    unpacked[(byte_index * 8) +: 8] =
                        TileReadCellByte(source_tile,
                            row as integer {0..65535},
                            (word_start + byte_offset + byte_index)
                                as integer {0..262143});
                end;
                result = TileInfoWithCellWord(result,
                    row as integer {0..65535},
                    word_index as integer {0..65535}, unpacked);
            else
                let group_width = if destination_tile.data_type == TileDataType_U8 then 4
                    else if destination_tile.data_type == TileDataType_U16 then 2
                    else 1;
                for group_element = 0 to group_width - 1 looplimit 4 do
                    let column = (word_index * group_width + group_element)
                        as integer {0..65535};
                    let destination_element = TileLogicalLinearIndex(
                        result, row as integer {0..65535}, column);
                    var value = Zeros{PTO_XLEN};
                    if !_BundleExecutionMask.zero_inactive then
                        let base = _Tiles[[_BundleExecutionMask.merge_base]];
                        let base_element = TileLogicalLinearIndex(
                            base, row as integer {0..65535}, column);
                        value = TileReadLogicalElement(base, base_element);
                    end;
                    result = TileInfoWithLogicalElementAndDefined(
                        result, destination_element, value, TRUE);
                end;
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    return result;
end;
