// PTO-TEST: {"id":"PTO-AVS-TILE-TABS-PADDING-001","source":"asl/tile/elementwise-tile-tile/logical/TABS.asl","requirements":["PTO-TABS-CONTRACT-001"],"kind":"state-transition","summary":"TABS applies explicit padding and preserves omitted Null padding.","pass_condition":"Explicit Max defines the physical padding while omitted PadValue leaves it undefined after TABS.","related_sources":["asl/tile/model/definedness/elements.asl","asl/tile/model/execution/unary.asl"]}
func ConfigureTabsPaddingTiles()
begin
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 8, 2, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTabsPaddingTiles();
    SetBundleDataAttributeState(
        Zeros{5} + 24, Zeros{5}, '01',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    InstructionContractExecute_TABS(1, 0);
    assert TileElementDefined(1, 0, 1);
    assert ReadTileElement(1, 0, 1) == Ones{PTO_XLEN};

    ResetProfileState();
    ConfigureTabsPaddingTiles();
    InstructionContractExecute_TABS(1, 0);
    assert !TileElementDefined(1, 0, 1);
    return 0;
end;
