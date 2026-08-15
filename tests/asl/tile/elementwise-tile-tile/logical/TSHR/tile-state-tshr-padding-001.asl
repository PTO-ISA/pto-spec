// PTO-TEST: {"id":"PTO-AVS-TILE-TSHR-PADDING-001","source":"asl/tile/elementwise-tile-tile/logical/TSHR.asl","requirements":["PTO-INST-TILE-TSHR"],"kind":"state-transition","summary":"TSHR applies explicit Max padding using the selected unsigned element type","pass_condition":"U8 valid shift result and defined 255 padding publish together","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 16, 8, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 128);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    SetBundleDataAttributeState(Zeros{5} + 14, Zeros{5}, '01',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    assert InstructionContractOperandsLegal_TSHR(2, 0, 1);
    InstructionContractExecute_TSHR(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 64;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 255;
    return 0;
end;
