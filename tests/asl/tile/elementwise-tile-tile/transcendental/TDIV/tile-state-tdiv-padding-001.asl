// PTO-TEST: {"id":"PTO-AVS-TILE-TDIV-PADDING-001","source":"asl/tile/elementwise-tile-tile/transcendental/TDIV.asl","requirements":["PTO-INST-TILE-TDIV"],"kind":"state-transition","summary":"TDIV publishes the valid quotient and selected padding together","pass_condition":"Max padding is defined with the U64 maximum while omitted B.DATR leaves padding undefined","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func ConfigurePaddedTDIVTiles()
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 8, 2, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 15);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigurePaddedTDIVTiles();
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5}, '01',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    assert InstructionContractOperandsLegal_TDIV(2, 0, 1);
    InstructionContractExecute_TDIV(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Ones{PTO_XLEN};

    ResetProfileState();
    ConfigurePaddedTDIVTiles();
    assert InstructionContractOperandsLegal_TDIV(2, 0, 1);
    InstructionContractExecute_TDIV(2, 0, 1);
    assert !TileElementDefined(2, 0, 1);
    return 0;
end;
