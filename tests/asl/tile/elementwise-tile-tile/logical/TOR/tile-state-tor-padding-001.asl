// PTO-TEST: {"id":"PTO-AVS-TILE-TOR-PADDING-001","source":"asl/tile/elementwise-tile-tile/logical/TOR.asl","requirements":["PTO-INST-TILE-TOR"],"kind":"state-transition","summary":"TOR applies explicit Max padding using the selected integer type","pass_condition":"U8 physical padding becomes defined 255 while the valid OR result remains unchanged","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 16, 8, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 8);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    SetBundleDataAttributeState(Zeros{5} + 14, Zeros{5}, '01',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    assert InstructionContractOperandsLegal_TOR(2, 0, 1);
    InstructionContractExecute_TOR(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 255;
    return 0;
end;
