// PTO-REQ-TILE-LEGALITY-001: decoded tile operands are rejected before effects.

readonly func TileDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    return tile.allocated &&
           tile.layout != TileLayout_ImplementationDefined &&
           tile.valid_rows <= tile.rows &&
           tile.valid_columns <= tile.columns &&
           tile.rows * tile.columns <= PTO_MODEL_TILE_ELEMENTS;
end;

readonly func TileLogicalShapeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    return TileDescriptorLegal(left) && TileDescriptorLegal(right) &&
           _Tiles[[left]].rows == _Tiles[[right]].rows &&
           _Tiles[[left]].columns == _Tiles[[right]].columns &&
           _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows &&
           _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout;
end;

readonly func TileShapeAndTypeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(left, right) &&
           _Tiles[[left]].data_type == _Tiles[[right]].data_type;
end;

readonly func TilePayloadNonzero(index: TileIndex) => boolean
begin
    if !TileDescriptorLegal(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile, row as integer {0..65535},
                column as integer {0..65535});
            if IsZero(tile.payload[[element]]) then return FALSE; end;
        end;
    end;
    return TRUE;
end;

readonly func TileBroadcastPayloadNonzero(axis: TileAxis, source: TileIndex,
                                           broadcast: TileIndex) => boolean
begin
    if !TileDescriptorLegal(source) || !TileDescriptorLegal(broadcast) then
        return FALSE;
    end;
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let broadcast_row = if axis == TileAxis_Row then row else 0;
            let broadcast_column = if axis == TileAxis_Row then 0 else column;
            let element = TileLinearIndex(broadcast_tile,
                broadcast_row as integer {0..65535},
                broadcast_column as integer {0..65535});
            if IsZero(broadcast_tile.payload[[element]]) then return FALSE; end;
        end;
    end;
    return TRUE;
end;

readonly func TileIndexPayloadWithin(index: TileIndex, extent: integer) => boolean
begin
    if !TileDescriptorLegal(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile, row as integer {0..65535},
                column as integer {0..65535});
            if UInt(tile.payload[[element]]) >= extent then return FALSE; end;
        end;
    end;
    return TRUE;
end;

readonly func TileByteOffsetPayloadWithin(offsets: TileIndex,
                                           source: TileIndex) => boolean
begin
    if !TileDescriptorLegal(offsets) || !TileDescriptorLegal(source) then
        return FALSE;
    end;
    let offsets_tile = _Tiles[[offsets]];
    let element_bytes = TileElementBytes(_Tiles[[source]].data_type);
    let source_extent: integer =
        _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns;
    for row = 0 to offsets_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to offsets_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(offsets_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let byte_offset = UInt(offsets_tile.payload[[element]]);
            if byte_offset MOD element_bytes != 0 ||
               byte_offset DIV element_bytes >= source_extent then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TilePartialCoverageLegal(destination: TileIndex,
                                        source_left: TileIndex,
                                        source_right: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_left) ||
       !TileDescriptorLegal(source_right) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    if left_tile.valid_rows > destination_tile.valid_rows ||
       left_tile.valid_columns > destination_tile.valid_columns ||
       right_tile.valid_rows > destination_tile.valid_rows ||
       right_tile.valid_columns > destination_tile.valid_columns then
        return FALSE;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let left_valid = row < left_tile.valid_rows &&
                             column < left_tile.valid_columns;
            let right_valid = row < right_tile.valid_rows &&
                              column < right_tile.valid_columns;
            if !left_valid && !right_valid then return FALSE; end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileBinary(
    op: TileBinaryOperation, destination: TileIndex,
    source_left: TileIndex, source_right: TileIndex) => boolean
begin
    if !TileShapeAndTypeMatch(source_left, source_right) ||
       !TileShapeAndTypeMatch(destination, source_left) then return FALSE; end;
    if op == TileBinary_DIV || op == TileBinary_REM then
        return TilePayloadNonzero(source_right);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileAxpy(
    destination: TileIndex, source: TileIndex, scalar: Word) => boolean
begin
    return TileShapeAndTypeMatch(destination, source);
end;

readonly func TileOperandsLegal_ExecuteTileFillScalar(
    destination: TileIndex, scalar: Word) => boolean
begin
    return TileDescriptorLegal(destination);
end;

readonly func TileOperandsLegal_ExecuteTileUnary(
    op: TileUnaryOperation, destination: TileIndex, source: TileIndex) => boolean
begin
    if !TileShapeAndTypeMatch(destination, source) then return FALSE; end;
    if op == TileUnary_RECIP || op == TileUnary_RSQRT then
        return TilePayloadNonzero(source);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileScalar(
    op: TileBinaryOperation, destination: TileIndex,
    source: TileIndex, scalar: Word) => boolean
begin
    if !TileShapeAndTypeMatch(destination, source) then return FALSE; end;
    return (op != TileBinary_DIV && op != TileBinary_REM) || !IsZero(scalar);
end;

readonly func TileOperandsLegal_ExecuteTileCompare(
    destination: TileIndex, source_left: TileIndex, source_right: TileIndex,
    comparison: TileComparison) => boolean
begin
    return TileShapeAndTypeMatch(source_left, source_right) &&
           TileLogicalShapeMatch(destination, source_left);
end;

readonly func TileOperandsLegal_ExecuteTileCompareScalar(
    destination: TileIndex, source: TileIndex, scalar: Word,
    comparison: TileComparison) => boolean
begin
    return TileLogicalShapeMatch(destination, source);
end;

readonly func TileOperandsLegal_ExecuteTileSelect(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, source_false: TileIndex) => boolean
begin
    return TileShapeAndTypeMatch(source_true, source_false) &&
           TileLogicalShapeMatch(mask, source_true) &&
           TileShapeAndTypeMatch(destination, source_true);
end;

readonly func TileOperandsLegal_ExecuteTileSelectScalar(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, scalar_false: Word) => boolean
begin
    return TileLogicalShapeMatch(destination, source_true) &&
           TileLogicalShapeMatch(mask, source_true);
end;

readonly func TileOperandsLegal_ExecuteTileReduction(
    op: TileReductionOperation, axis: TileAxis,
    destination: TileIndex, source: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) || !TileDescriptorLegal(source) ||
       _Tiles[[source]].valid_rows == 0 ||
       _Tiles[[source]].valid_columns == 0 then return FALSE; end;
    if axis == TileAxis_Row then
        return _Tiles[[destination]].valid_rows >= _Tiles[[source]].valid_rows &&
               _Tiles[[destination]].valid_columns >= 1;
    else
        return _Tiles[[destination]].valid_rows >= 1 &&
               _Tiles[[destination]].valid_columns >= _Tiles[[source]].valid_columns;
    end;
end;

readonly func TileOperandsLegal_ExecuteTileExpand(
    op: TileExpandOperation, axis: TileAxis, destination: TileIndex,
    source: TileIndex, broadcast_source: TileIndex) => boolean
begin
    if !TileShapeAndTypeMatch(destination, source) ||
       !TileDescriptorLegal(broadcast_source) ||
       _Tiles[[broadcast_source]].data_type != _Tiles[[source]].data_type then
        return FALSE;
    end;
    let shape_legal = if axis == TileAxis_Row then
        _Tiles[[broadcast_source]].valid_rows >= _Tiles[[source]].valid_rows &&
        _Tiles[[broadcast_source]].valid_columns >= 1
    else
        _Tiles[[broadcast_source]].valid_rows >= 1 &&
        _Tiles[[broadcast_source]].valid_columns >= _Tiles[[source]].valid_columns;
    if !shape_legal then return FALSE; end;
    return op != TileExpand_DIV ||
           TileBroadcastPayloadNonzero(axis, source, broadcast_source);
end;

readonly func TileOperandsLegal_TCI(
    destination: TileIndex, start: Word, descending: boolean) => boolean
begin
    return TileDescriptorLegal(destination);
end;

readonly func TileOperandsLegal_TTRI(
    destination: TileIndex, upper: boolean,
    diagonal: integer {-65535..65535}) => boolean
begin
    return TileDescriptorLegal(destination);
end;

readonly func TileOperandsLegal_TFILLPAD(
    destination: TileIndex, source: TileIndex, padding: Word) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].rows >= _Tiles[[source]].valid_rows &&
           _Tiles[[destination]].columns >= _Tiles[[source]].valid_columns;
end;

readonly func TileOperandsLegal_TCVT(destination: TileIndex,
                                     source: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(destination, source);
end;

readonly func TileOperandsLegal_TQUANT(destination: TileIndex,
                                       source: TileIndex, scale: Word,
                                       zero_point: Word) => boolean
begin
    return TileOperandsLegal_TCVT(destination, source) && !IsZero(scale);
end;

readonly func TileOperandsLegal_TDEQUANT(destination: TileIndex,
                                         source: TileIndex, scale: Word,
                                         zero_point: Word) => boolean
begin
    return TileOperandsLegal_TCVT(destination, source);
end;

readonly func TileOperandsLegal_TEXTRACT(
    destination: TileIndex, source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           row_offset + _Tiles[[destination]].valid_rows <=
               _Tiles[[source]].valid_rows &&
           column_offset + _Tiles[[destination]].valid_columns <=
               _Tiles[[source]].valid_columns;
end;

readonly func TileOperandsLegal_TINSERT(
    destination: TileIndex, source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           row_offset + _Tiles[[source]].valid_rows <=
               _Tiles[[destination]].valid_rows &&
           column_offset + _Tiles[[source]].valid_columns <=
               _Tiles[[destination]].valid_columns;
end;

readonly func TileOperandsLegal_TTRANS(destination: TileIndex,
                                       source: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].valid_rows == _Tiles[[source]].valid_columns &&
           _Tiles[[destination]].valid_columns == _Tiles[[source]].valid_rows &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;

readonly func TileOperandsLegal_TRESHAPE(destination: TileIndex,
                                         source: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].rows * _Tiles[[destination]].columns ==
               _Tiles[[source]].rows * _Tiles[[source]].columns &&
           _Tiles[[destination]].valid_rows * _Tiles[[destination]].valid_columns ==
               _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;

readonly func TileOperandsLegal_TCONCAT(
    destination: TileIndex, source_left: TileIndex,
    source_right: TileIndex, axis: TileAxis) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_left) ||
       !TileDescriptorLegal(source_right) ||
       _Tiles[[destination]].data_type != _Tiles[[source_left]].data_type ||
       _Tiles[[destination]].data_type != _Tiles[[source_right]].data_type then
        return FALSE;
    end;
    if axis == TileAxis_Row then
        return _Tiles[[source_left]].valid_columns ==
                   _Tiles[[source_right]].valid_columns &&
               _Tiles[[destination]].valid_rows ==
                   _Tiles[[source_left]].valid_rows +
                   _Tiles[[source_right]].valid_rows &&
               _Tiles[[destination]].valid_columns ==
                   _Tiles[[source_left]].valid_columns;
    else
        return _Tiles[[source_left]].valid_rows ==
                   _Tiles[[source_right]].valid_rows &&
               _Tiles[[destination]].valid_rows ==
                   _Tiles[[source_left]].valid_rows &&
               _Tiles[[destination]].valid_columns ==
                   _Tiles[[source_left]].valid_columns +
                   _Tiles[[source_right]].valid_columns;
    end;
end;

readonly func TileOperandsLegal_TGATHER(destination: TileIndex,
                                        source: TileIndex,
                                        indices: TileIndex) => boolean
begin
    if !TileLogicalShapeMatch(destination, indices) ||
       !TileDescriptorLegal(source) then return FALSE; end;
    let source_extent: integer =
        _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns;
    return TileIndexPayloadWithin(indices, source_extent);
end;

readonly func TileOperandsLegal_TGATHERB(destination: TileIndex,
                                         source: TileIndex,
                                         byte_offsets: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(destination, byte_offsets) &&
           TileDescriptorLegal(source) &&
           TileByteOffsetPayloadWithin(byte_offsets, source);
end;

readonly func TileOperandsLegal_TSCATTER(destination: TileIndex,
                                         source: TileIndex,
                                         indices: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileShapeAndTypeMatch(source, indices) then return FALSE; end;
    let destination_extent: integer =
        _Tiles[[destination]].valid_rows * _Tiles[[destination]].valid_columns;
    return TileIndexPayloadWithin(indices, destination_extent);
end;

readonly func TileOperandsLegal_TINTERLEAVE(
    destination: TileIndex, source_even: TileIndex,
    source_odd: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_even) ||
       !TileDescriptorLegal(source_odd) then return FALSE; end;
    let extent: integer =
        _Tiles[[source_even]].valid_rows * _Tiles[[source_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 &&
           extent == _Tiles[[source_odd]].valid_rows *
                     _Tiles[[source_odd]].valid_columns &&
           _Tiles[[destination]].valid_rows *
               _Tiles[[destination]].valid_columns == extent * 2;
end;

readonly func TileOperandsLegal_TDEINTERLEAVE(
    destination_even: TileIndex, destination_odd: TileIndex,
    source: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination_even) ||
       !TileDescriptorLegal(destination_odd) ||
       !TileDescriptorLegal(source) then return FALSE; end;
    let extent: integer = _Tiles[[destination_even]].valid_rows *
                          _Tiles[[destination_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 &&
           extent == _Tiles[[destination_odd]].valid_rows *
                     _Tiles[[destination_odd]].valid_columns &&
           _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns ==
               extent * 2;
end;

readonly func TileOperandsLegal_TIMG2COL(
    destination: TileIndex, source: TileIndex,
    kernel_rows: integer {1..65535},
    kernel_columns: integer {1..65535},
    stride_rows: integer {1..65535},
    stride_columns: integer {1..65535},
    pad_rows: integer {0..65535},
    pad_columns: integer {0..65535}, padding: Word) => boolean
begin
    if !TileDescriptorLegal(destination) || !TileDescriptorLegal(source) ||
       _Tiles[[source]].valid_rows + 2 * pad_rows < kernel_rows ||
       _Tiles[[source]].valid_columns + 2 * pad_columns < kernel_columns then
        return FALSE;
    end;
    let output_rows: integer =
        (((_Tiles[[source]].valid_rows + 2 * pad_rows) - kernel_rows)
            DIVRM stride_rows) + 1;
    let output_columns: integer =
        (((_Tiles[[source]].valid_columns + 2 * pad_columns) - kernel_columns)
            DIVRM stride_columns) + 1;
    let patch_count: integer = output_rows * output_columns;
    let patch_elements: integer = kernel_rows * kernel_columns;
    return patch_count <= 65535 && patch_elements <= 65535 &&
           _Tiles[[destination]].valid_rows == patch_count &&
           _Tiles[[destination]].valid_columns == patch_elements;
end;

readonly func TileOperandsLegal_ExecuteTilePartial(
    op: TilePartialOperation, destination: TileIndex,
    source_left: TileIndex, source_right: TileIndex) => boolean
begin
    return TilePartialCoverageLegal(destination, source_left, source_right) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type;
end;

readonly func TileOperandsLegal_ExecuteTilePartialArg(
    maximum: boolean, destination: TileIndex, destination_indices: TileIndex,
    source_left: TileIndex, source_right: TileIndex,
    left_indices: TileIndex, right_indices: TileIndex) => boolean
begin
    return TilePartialCoverageLegal(destination, source_left, source_right) &&
           TileDescriptorLegal(destination_indices) &&
           TileLogicalShapeMatch(destination_indices, destination) &&
           TileLogicalShapeMatch(left_indices, source_left) &&
           TileLogicalShapeMatch(right_indices, source_right) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type;
end;

readonly func TileOperandsLegal_TSORT(destination: TileIndex,
                                      source: TileIndex,
                                      descending: boolean) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].valid_rows *
               _Tiles[[destination]].valid_columns ==
               _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;

readonly func TileOperandsLegal_TMRGSORT(
    destination: TileIndex, source_left: TileIndex,
    source_right: TileIndex, descending: boolean) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_left) ||
       !TileDescriptorLegal(source_right) then return FALSE; end;
    let left_extent: integer =
        _Tiles[[source_left]].valid_rows * _Tiles[[source_left]].valid_columns;
    let right_extent: integer =
        _Tiles[[source_right]].valid_rows * _Tiles[[source_right]].valid_columns;
    return _Tiles[[destination]].valid_rows *
               _Tiles[[destination]].valid_columns == left_extent + right_extent &&
           _Tiles[[source_left]].data_type == _Tiles[[source_right]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type;
end;

readonly func TileOperandsLegal_THISTOGRAM(
    destination: TileIndex, source: TileIndex, indices: TileIndex,
    selected_byte: integer {0..3}) => boolean
begin
    if !TileDescriptorLegal(destination) || !TileDescriptorLegal(source) ||
       !TileDescriptorLegal(indices) ||
       _Tiles[[destination]].valid_rows != _Tiles[[source]].valid_rows ||
       _Tiles[[destination]].valid_columns < 256 ||
       !(_Tiles[[source]].data_type == TileDataType_U16 ||
         _Tiles[[source]].data_type == TileDataType_U32) then return FALSE; end;
    if _Tiles[[source]].data_type == TileDataType_U16 then
        if selected_byte > 1 then return FALSE; end;
        return selected_byte == 1 ||
               (_Tiles[[indices]].valid_rows >= _Tiles[[source]].valid_rows &&
                _Tiles[[indices]].valid_columns >= 1);
    else
        let required_rows: integer = if selected_byte == 0 then 3 else
                                     if selected_byte == 1 then 2 else
                                     if selected_byte == 2 then 1 else 0;
        return _Tiles[[indices]].valid_rows >= required_rows &&
               (required_rows == 0 || _Tiles[[indices]].valid_columns >= 1);
    end;
end;

readonly func TileOperandsLegal_TMOV(destination: TileIndex,
                                     source: TileIndex) => boolean
begin
    return TileShapeAndTypeMatch(destination, source);
end;

readonly func TileOperandsLegal_TLOAD(destination: TileIndex,
                                      base_address: Word) => boolean
begin
    return TileDescriptorLegal(destination);
end;

readonly func TileOperandsLegal_TSTORE(base_address: Word,
                                       source: TileIndex) => boolean
begin
    return TileDescriptorLegal(source);
end;

readonly func TileOperandsLegal_MGATHER(
    destination: TileIndex, base_address: Word,
    indices: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(destination, indices);
end;

readonly func TileOperandsLegal_MSCATTER(
    base_address: Word, source: TileIndex, indices: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(source, indices);
end;

readonly func TileOperandsLegal_TPREFETCH(
    base_address: Word, byte_count: integer {0..262144}) => boolean
begin
    return TRUE;
end;

readonly func TileMatrixOperandsLegal(destination: TileIndex,
                                      left: TileIndex,
                                      right: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(left) &&
           TileDescriptorLegal(right) &&
           _Tiles[[left]].valid_columns == _Tiles[[right]].valid_rows &&
           _Tiles[[destination]].valid_rows == _Tiles[[left]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[right]].valid_columns;
end;

readonly func TileMatrixBiasLegal(destination: TileIndex,
                                  bias: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(bias) &&
           (_Tiles[[bias]].valid_rows == 1 ||
            _Tiles[[bias]].valid_rows == _Tiles[[destination]].valid_rows) &&
           (_Tiles[[bias]].valid_columns == 1 ||
            _Tiles[[bias]].valid_columns == _Tiles[[destination]].valid_columns);
end;

readonly func TileMatrixScaleLegal(destination: TileIndex,
                                   row_scale: TileIndex,
                                   column_scale: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) &&
           TileDescriptorLegal(row_scale) &&
           TileDescriptorLegal(column_scale) &&
           _Tiles[[row_scale]].valid_rows == _Tiles[[destination]].valid_rows &&
           _Tiles[[row_scale]].valid_columns == 1 &&
           _Tiles[[column_scale]].valid_rows == 1 &&
           _Tiles[[column_scale]].valid_columns ==
               _Tiles[[destination]].valid_columns;
end;

readonly func TileOperandsLegal_TMATMUL(
    destination: TileIndex, left: TileIndex, right: TileIndex,
    accumulate: boolean) => boolean
begin
    return TileMatrixOperandsLegal(destination, left, right);
end;

readonly func TileOperandsLegal_TMATMUL_BIAS(
    destination: TileIndex, left: TileIndex, right: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileMatrixOperandsLegal(destination, left, right) &&
           TileMatrixBiasLegal(destination, bias);
end;

readonly func TileOperandsLegal_TMATMUL_ACC(
    destination: TileIndex, left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixOperandsLegal(destination, left, right);
end;

readonly func TileOperandsLegal_TMATMUL_MX(
    destination: TileIndex, left: TileIndex, right: TileIndex,
    row_scale: TileIndex, column_scale: TileIndex) => boolean
begin
    return TileMatrixOperandsLegal(destination, left, right) &&
           TileMatrixScaleLegal(destination, row_scale, column_scale);
end;

readonly func TileOperandsLegal_TGEMV(
    destination: TileIndex, matrix: TileIndex, vector: TileIndex) => boolean
begin
    return TileMatrixOperandsLegal(destination, matrix, vector) &&
           _Tiles[[vector]].valid_columns == 1;
end;

readonly func TileOperandsLegal_TGEMV_BIAS(
    destination: TileIndex, matrix: TileIndex, vector: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV(destination, matrix, vector) &&
           TileMatrixBiasLegal(destination, bias);
end;

readonly func TileOperandsLegal_TGEMV_ACC(
    destination: TileIndex, matrix: TileIndex, vector: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV(destination, matrix, vector);
end;

readonly func TileOperandsLegal_TGEMV_MX(
    destination: TileIndex, matrix: TileIndex, vector: TileIndex,
    row_scale: TileIndex, column_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV(destination, matrix, vector) &&
           TileMatrixScaleLegal(destination, row_scale, column_scale);
end;

readonly func TileOperandsLegal_TPUSH(pipe: PipeIndex,
                                      source: TileIndex) => boolean
begin
    return _Pipes[[pipe]].configured && TileDescriptorLegal(source) &&
           !_Pipes[[pipe]].producer_claimed &&
           _Pipes[[pipe]].count < _Pipes[[pipe]].slot_count;
end;

readonly func TileOperandsLegal_TPOP(destination: TileIndex,
                                     pipe: PipeIndex) => boolean
begin
    if !_Pipes[[pipe]].configured || _Pipes[[pipe]].consumer_claimed ||
       _Pipes[[pipe]].count == 0 then return FALSE; end;
    let popped = _Pipes[[pipe]].slots[[_Pipes[[pipe]].head]];
    return TileCapacityInUseExcept(destination) + popped.capacity_bytes <= 524288;
end;

readonly func TileOperandsLegal_TALLOC(pipe: PipeIndex) => boolean
begin
    return _Pipes[[pipe]].configured && !_Pipes[[pipe]].producer_claimed &&
           _Pipes[[pipe]].count < _Pipes[[pipe]].slot_count;
end;

readonly func TileOperandsLegal_TFREE(pipe: PipeIndex) => boolean
begin
    return _Pipes[[pipe]].configured;
end;
