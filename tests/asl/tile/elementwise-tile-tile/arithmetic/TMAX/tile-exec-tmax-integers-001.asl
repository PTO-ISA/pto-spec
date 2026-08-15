// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-INTEGERS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-INST-TILE-TMAX"],"kind":"execution","summary":"TMAX compares signed and unsigned integers at their element width","pass_condition":"S8 selects positive one over negative one while U8 selects 255 over one","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func ConfigureTmaxIntegerTiles(data_type: TileDataType)
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            data_type, TileLayout_RowMajor, TileLocation_Any);
    end;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTmaxIntegerTiles(TileDataType_S8);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    assert InstructionContractOperandsLegal_TMAX(2, 0, 1);
    InstructionContractExecute_TMAX(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;

    ResetProfileState();
    ConfigureTmaxIntegerTiles(TileDataType_U8);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    assert InstructionContractOperandsLegal_TMAX(2, 0, 1);
    InstructionContractExecute_TMAX(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0xff;
    return 0;
end;
