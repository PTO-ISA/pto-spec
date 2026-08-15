// PTO-TEST: {"id":"PTO-AVS-TILE-TREM-PADDING-001","source":"asl/tile/elementwise-tile-tile/transcendental/TREM.asl","requirements":["PTO-INST-TILE-TREM"],"kind":"state-transition","summary":"TREM applies PadValue only outside the valid destination rectangle","pass_condition":"Zero padding becomes defined without participating in valid divisor checks","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 8, 2, 1, 1,
            TileDataType_S64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} - 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5}, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;

    assert InstructionContractOperandsLegal_TREM(2, 0, 1);
    InstructionContractExecute_TREM(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
