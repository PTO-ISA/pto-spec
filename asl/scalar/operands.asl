// PTO-REQ-SCALAR-OPERAND-001: one-level Reg5 source and destination behavior.

pure func DirectTBridgeIndex() => TileIndex
begin
    return 0;
end;

pure func DirectUBridgeIndex() => TileIndex
begin
    return 16;
end;

readonly func ReadScalarRegisterOperand(selector: Reg5Selector) => Word
begin
    if selector < PTO_SCALAR_REGISTER_COUNT then
        return ReadGPR(selector as GPRIndex);
    end;

    let tile_index: TileIndex = if selector < 28 then
        (selector - 24) as TileIndex
    else
        ((16 + selector) - 28) as TileIndex;
    assert _Tiles[[tile_index]].allocated;
    assert _Tiles[[tile_index]].valid_rows > 0;
    assert _Tiles[[tile_index]].valid_columns > 0;
    return ReadTileElement(tile_index, 0, 0);
end;

func WriteScalarDestination(selector: Reg5Selector, value: Word)
begin
    if selector < PTO_SCALAR_REGISTER_COUNT then
        WriteGPR(selector as GPRIndex, value);
    elsif selector == 30 then
        let destination = DirectUBridgeIndex();
        assert _Tiles[[destination]].allocated;
        assert _Tiles[[destination]].valid_rows > 0;
        assert _Tiles[[destination]].valid_columns > 0;
        WriteTileElement(destination, 0, 0, value);
    elsif selector == 31 then
        let destination = DirectTBridgeIndex();
        assert _Tiles[[destination]].allocated;
        assert _Tiles[[destination]].valid_rows > 0;
        assert _Tiles[[destination]].valid_columns > 0;
        WriteTileElement(destination, 0, 0, value);
    end;
    // Selectors 24..29 intentionally discard destination values.
end;

func WriteCompressedTResult(value: Word)
begin
    WriteScalarDestination(31, value);
end;
