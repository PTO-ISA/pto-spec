// PTO-TEST: {"id":"PTO-AVS-TILE-TMIN-ENCODING-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl","requirements":["PTO-INST-TILE-TMIN"],"kind":"boundary","summary":"TMIN rejects invalid floating source encodings before destination effects","pass_condition":"a TF32 source with nonzero discarded fraction bits makes operand legality false and leaves the destination undefined","related_sources":["asl/arch/features/mx-formats.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_TF32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x40000000);

    assert !InstructionContractOperandsLegal_TMIN(2, 0, 1);
    assert !_Tiles[[2]].contents_defined;
    return 0;
end;
