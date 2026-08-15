// PTO-TEST: {"id":"PTO-AVS-TILE-TAND-PADDING-001","source":"asl/tile/elementwise-tile-tile/logical/TAND.asl","requirements":["PTO-INST-TILE-TAND"],"kind":"state-transition","summary":"TAND applies explicit Zero padding outside the valid rectangle","pass_condition":"the valid result is preserved and the physical padding becomes defined zero","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 16, 8, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 15);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 6);
    SetBundleDataAttributeState(Zeros{5} + 14, Zeros{5}, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    assert InstructionContractOperandsLegal_TAND(2, 0, 1);
    InstructionContractExecute_TAND(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 6;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
