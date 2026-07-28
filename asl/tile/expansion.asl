// PTO-REQ-TEPL-EXPAND-001: row/column broadcast operations.

impdef func TileExpDifference(left: Word, right: Word) => Word
begin
    // Raw floating encoding behavior is supplied by a named numeric profile.
    // The default bitvector model makes the operation explicit and stable.
    return left - right;
end;

func TileExpandValue(op: TileExpandOperation, left: Word, broadcast: Word) => Word
begin
    case op of
        when TileExpand_COPY => return broadcast;
        when TileExpand_ADD  => return left + broadcast;
        when TileExpand_SUB  => return left - broadcast;
        when TileExpand_MUL  => return MultiplyWord(left, broadcast);
        when TileExpand_DIV  =>
            assert !IsZero(broadcast);
            return DivideWordUnsigned(left, broadcast);
        when TileExpand_MAX  => if SInt(left) > SInt(broadcast) then return left; else return broadcast; end;
        when TileExpand_MIN  => if SInt(left) < SInt(broadcast) then return left; else return broadcast; end;
        when TileExpand_EXPDIF => return TileExpDifference(left, broadcast);
    end;
end;

func ExecuteTileExpand(op: TileExpandOperation, axis: TileAxis,
                       destination: TileIndex, source: TileIndex,
                       broadcast_source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    let source_payload = source_tile.payload;
    let broadcast_payload = broadcast_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let broadcast_row = if axis == TileAxis_Row then row else 0;
            let broadcast_column = if axis == TileAxis_Row then 0 else column;
            let broadcast_element = TileLinearIndex(broadcast_tile,
                broadcast_row as integer {0..65535},
                broadcast_column as integer {0..65535});
            _Tiles[[destination]].payload[[source_element]] = TileExpandValue(op,
                source_payload[[source_element]], broadcast_payload[[broadcast_element]]);
        end;
    end;
end;
