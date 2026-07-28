// PTO-REQ-SCALAR-OPERAND-001: one-level Reg5 source and destination behavior.

pure func DirectTBridgeIndex() => TileIndex
begin
    return 0;
end;

pure func DirectUBridgeIndex() => TileIndex
begin
    return 16;
end;

readonly func ScalarTileBridgeLegal(index: TileIndex) => boolean
begin
    return _Tiles[[index]].allocated &&
           _Tiles[[index]].valid_rows > 0 &&
           _Tiles[[index]].valid_columns > 0 &&
           _Tiles[[index]].layout != TileLayout_ImplementationDefined;
end;

readonly func ScalarSourceSelectorLegal(selector: Reg5Selector) => boolean
begin
    if selector < PTO_SCALAR_REGISTER_COUNT then return TRUE; end;
    let tile_index: TileIndex = if selector < 28 then
        (selector - 24) as TileIndex
    else
        ((16 + selector) - 28) as TileIndex;
    return ScalarTileBridgeLegal(tile_index);
end;

readonly func ScalarDestinationSelectorLegal(selector: Reg5Selector) => boolean
begin
    if selector < 30 then return TRUE; end;
    let tile_index = if selector == 30 then DirectUBridgeIndex()
                     else DirectTBridgeIndex();
    return ScalarTileBridgeLegal(tile_index);
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
    if !ScalarTileBridgeLegal(tile_index) then
        return Zeros{PTO_XLEN};
    end;
    return ReadTileElement(tile_index, 0, 0);
end;

func WriteScalarDestination(selector: Reg5Selector, value: Word)
begin
    if selector < PTO_SCALAR_REGISTER_COUNT then
        WriteGPR(selector as GPRIndex, value);
    elsif selector == 30 then
        let destination = DirectUBridgeIndex();
        if !ScalarTileBridgeLegal(destination) then
            SetFault(Fault_TileLegality, ReadPC());
            return;
        end;
        WriteTileElement(destination, 0, 0, value);
    elsif selector == 31 then
        let destination = DirectTBridgeIndex();
        if !ScalarTileBridgeLegal(destination) then
            SetFault(Fault_TileLegality, ReadPC());
            return;
        end;
        WriteTileElement(destination, 0, 0, value);
    end;
    // Selectors 24..29 intentionally discard destination values.
end;

func WriteCompressedTResult(value: Word)
begin
    WriteScalarDestination(31, value);
end;
