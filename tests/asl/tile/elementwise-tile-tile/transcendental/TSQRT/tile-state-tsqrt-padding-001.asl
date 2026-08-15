// PTO-TEST: {"id":"PTO-AVS-TILE-TSQRT-PADDING-001","source":"asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl","requirements":["PTO-INST-TILE-TSQRT"],"kind":"state-transition","summary":"TSQRT applies explicit padding and preserves omitted Null padding","pass_condition":"explicit Max defines physical padding while omitted PadValue leaves it undefined","related_sources":["asl/tile/model/execution/unary.asl"]}
func ConfigureSquareRootPaddingTiles()
begin
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(
            index as TileIndex,
            128,
            8,
            2,
            1,
            1,
            TileDataType_FP32,
            TileLayout_RowMajor,
            TileLocation_Any);
    end;
    WriteTileElement(
        0,
        0,
        0,
        Zeros{PTO_XLEN} + 0x3f800000);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureSquareRootPaddingTiles();
    SetBundleDataAttributeState(
        Zeros{5} + 4,
        Zeros{5},
        '01',
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    InstructionContractExecute_TSQRT(
        1,
        0);
    assert TileElementDefined(
        1,
        0,
        1);

    ResetProfileState();
    ConfigureSquareRootPaddingTiles();
    InstructionContractExecute_TSQRT(
        1,
        0);
    assert !TileElementDefined(
        1,
        0,
        1);
    return 0;
end;
