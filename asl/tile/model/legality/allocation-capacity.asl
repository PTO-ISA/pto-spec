// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY","surface":"tile","classification":["model","legality","allocation-capacity"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
readonly func TilePayloadNonzero(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !_BundleExecutionMask.valid then
        if !TileSourceContentsDefined(index) then return FALSE; end;
    elsif !TileCubeDescriptorLegal(tile) ||
          tile.layout != _BundleExecutionMask.layout ||
          tile.valid_rows != _BundleExecutionMask.valid_rows ||
          tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                if !TileElementDefined(index, row as integer {0..65535},
                       column as integer {0..65535}) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if IsZero(TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileBroadcastPayloadNonzero(axis: TileAxis, source: TileIndex,
                                           broadcast: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(source) ||
       !TileSourceContentsDefined(broadcast) then
        return FALSE;
    end;
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let broadcast_row = if axis == TileAxis_Row then row else 0;
            let broadcast_column = if axis == TileAxis_Row then 0 else column;
            let element = TileLogicalLinearIndex(broadcast_tile,
                broadcast_row as integer {0..65535},
                broadcast_column as integer {0..65535});
            if IsZero(TileReadLogicalElement(broadcast_tile, element)) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileIndexPayloadWithin(index: TileIndex, extent: integer) => boolean
begin
    if !TileSourceContentsDefined(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if UInt(TileReadLogicalElement(tile, element)) >= extent then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileByteOffsetPayloadWithin(offsets: TileIndex,
                                           source: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(offsets) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let offsets_tile = _Tiles[[offsets]];
    let element_bytes = TileElementBytes(_Tiles[[source]].data_type);
    let source_extent: integer =
        _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns;
    for row = 0 to offsets_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to offsets_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(offsets_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let byte_offset = UInt(TileReadLogicalElement(
                offsets_tile, element));
            if byte_offset MOD element_bytes != 0 ||
               byte_offset DIV element_bytes >= source_extent then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
