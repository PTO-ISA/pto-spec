// PTO-TEST: {"id":"PTO-AVS-TILE-TSHL-PADDING-001","source":"asl/tile/elementwise-tile-tile/logical/TSHL.asl","requirements":["PTO-INST-TILE-TSHL"],"kind":"state-transition","summary":"TSHL applies explicit Zero padding outside the valid rectangle","pass_condition":"the shifted valid element and defined zero padding publish together","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 16, 8, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    SetBundleDataAttributeState(Zeros{5} + 14, Zeros{5}, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    assert InstructionContractOperandsLegal_TSHL(2, 0, 1);
    InstructionContractExecute_TSHL(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 6;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
