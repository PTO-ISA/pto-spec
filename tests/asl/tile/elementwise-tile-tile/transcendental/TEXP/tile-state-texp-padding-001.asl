// PTO-TEST: {"id":"PTO-AVS-TILE-TEXP-PADDING-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXP.asl","requirements":["PTO-INST-TILE-TEXP"],"kind":"state-transition","summary":"TEXP applies explicit padding and preserves omitted Null padding","pass_condition":"explicit Max defines physical padding while omitted PadValue leaves it undefined","related_sources":["asl/tile/model/execution/unary.asl"]}
func ConfigureExponentialPaddingTiles()
begin
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 8, 2, 1, 1,
            TileDataType_FP32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureExponentialPaddingTiles();
    SetBundleDataAttributeState(Zeros{5} + 4, Zeros{5}, '01',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    InstructionContractExecute_TEXP(1, 0);
    assert TileElementDefined(1, 0, 1);

    ResetProfileState();
    ConfigureExponentialPaddingTiles();
    InstructionContractExecute_TEXP(1, 0);
    assert !TileElementDefined(1, 0, 1);
    return 0;
end;
