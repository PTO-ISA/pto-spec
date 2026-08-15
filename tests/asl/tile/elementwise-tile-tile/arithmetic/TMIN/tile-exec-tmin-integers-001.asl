// PTO-TEST: {"id":"PTO-AVS-TILE-TMIN-INTEGERS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl","requirements":["PTO-INST-TILE-TMIN"],"kind":"execution","summary":"TMIN compares signed and unsigned integers at their element width","pass_condition":"S8 selects negative one over positive one while U8 selects one over 255","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func ConfigureTminIntegerTiles(data_type: TileDataType)
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            data_type, TileLayout_RowMajor, TileLocation_Any);
    end;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTminIntegerTiles(TileDataType_S8);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    assert InstructionContractOperandsLegal_TMIN(2, 0, 1);
    InstructionContractExecute_TMIN(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Ones{PTO_XLEN};

    ResetProfileState();
    ConfigureTminIntegerTiles(TileDataType_U8);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    assert InstructionContractOperandsLegal_TMIN(2, 0, 1);
    InstructionContractExecute_TMIN(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
