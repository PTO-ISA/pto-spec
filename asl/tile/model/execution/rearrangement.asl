// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// For TPACK/TUNPACK, ExecutionMask coordinates are (source row, source CELL word index), with word_index below the source words-per-row. PredicateCell shape is source ValidRow by source words-per-row; GPR mapping uses word_index as the column. One bit gates one 32-bit result word (4 U8, 2 U16, or 1 U32 elements); an M32 U64 destination joins each complete pair of independently gated result words and publishes the combined logical element once. Active groups perform the selected-byte reads; inactive groups do not read selected source bytes and apply the common MERGE/ZERO destination rule to their result plane. Source/destination shape, type, control, complete-pair, capacity, and allocation checks remain in force for every mask value.
// For TPERMUTE and TSHUF, ExecutionMask coordinates are destination logical
// element coordinates. Inactive elements MUST NOT read index, control, or
// mapped source payload and MUST apply the common MERGE/ZERO destination rule;
// descriptor, shape, type, scalar-control, capacity, and allocation checks
// remain unconditional.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","surface":"tile","classification":["model","execution","rearrangement"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-NUMERIC-EXCEPTIONS","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL"]}
// PTO-REQ-TEPL-REARRANGE-001: direct tile layout and indexing operations.

readonly func TileInfoWithCellByte(tile: TileInfo,
                                   row: integer {0..65535},
                                   byte_index: integer {0..262143},
                                   value: Byte) => TileInfo
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        assert byte_index <= 32767;
        let first_byte_index = byte_index as integer {0..32767};
        let first_nibble = (first_byte_index * 2) as integer {0..65535};
        let first_element = TileLogicalLinearIndex(tile, row,
            first_nibble as integer {0..65535});
        var first_word = TileReadLogicalElement(tile, first_element);
        first_word[3:0] = value[3:0];
        var result = TileInfoWithLogicalElement(tile, first_element,
            first_word);
        if first_nibble + 1 < tile.valid_columns then
            let second_element = TileLogicalLinearIndex(tile, row,
                (first_nibble + 1) as integer {0..65535});
            var second_word = TileReadLogicalElement(result, second_element);
            second_word[3:0] = value[7:4];
            result = TileInfoWithLogicalElement(result, second_element,
                second_word);
        end;
        return result;
    end;
    let element_bytes = TileElementBytes(tile.data_type);
    let element_column = (byte_index DIVRM element_bytes)
        as integer {0..65535};
    let byte_in_element = (byte_index MOD element_bytes) as integer {0..7};
    let element = TileLogicalLinearIndex(tile, row, element_column);
    var word = TileReadLogicalElement(tile, element);
    word[(byte_in_element * 8) +: 8] = value;
    return TileInfoWithLogicalElement(tile, element, word);
end;

readonly func TileReadCellWord(tile: TileInfo,
                               row: integer {0..65535},
                               word_index: integer {0..65535}) => Word
begin
    let valid_bytes = TileCellRearrangementValidBytes(tile);
    let byte_base = (word_index * 4) as integer {0..262143};
    var result = Zeros{PTO_XLEN};
    for byte_index = 0 to 3 looplimit 4 do
        if byte_base + byte_index < valid_bytes then
            result[(byte_index * 8) +: 8] = TileReadCellByte(tile, row,
                (byte_base + byte_index) as integer {0..262143});
        end;
    end;
    return result;
end;

readonly func TileInfoWithCellWord(tile: TileInfo,
                                   row: integer {0..65535},
                                   word_index: integer {0..65535},
                                   value: Word) => TileInfo
begin
    let valid_bytes = TileCellRearrangementValidBytes(tile);
    let byte_base = (word_index * 4) as integer {0..262143};
    var result = tile;
    for byte_index = 0 to 3 looplimit 4 do
        if byte_base + byte_index < valid_bytes then
            result = TileInfoWithCellByte(result, row,
                (byte_base + byte_index) as integer {0..262143},
                value[(byte_index * 8) +: 8]);
        end;
    end;
    return result;
end;

func TPERMUTE(destination: TileIndex, source0: TileIndex,
              source1: TileIndex, indices: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let source0_tile = _Tiles[[source0]];
    let source1_tile = _Tiles[[source1]];
    let index_tile = _Tiles[[indices]];
    assert TileOperandsLegal_TPERMUTE(
        destination, source0, source1, indices);
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
    _Tiles[[destination]] = result;
end;

func TSHUF(destination: TileIndex, source: TileIndex,
           controls: TileIndex, control: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let controls_tile = _Tiles[[controls]];
    assert TileOperandsLegal_TSHUF(destination, source, controls, control);
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
    _Tiles[[destination]] = result;
end;

func TPACK(destination: TileIndex, source0: TileIndex,
           source1: TileIndex, control: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source0_tile = _Tiles[[source0]];
    let source1_tile = _Tiles[[source1]];
    assert TileOperandsLegal_TPACK(destination, source0, source1, control);
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
        _Tiles[[destination]] = result;
        return;
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
    _Tiles[[destination]] = result;
end;

func TUNPACK(destination: TileIndex, source: TileIndex, control: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert TileOperandsLegal_TUNPACK(destination, source, control);
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
        _Tiles[[destination]] = result;
        return;
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
    _Tiles[[destination]] = result;
end;
