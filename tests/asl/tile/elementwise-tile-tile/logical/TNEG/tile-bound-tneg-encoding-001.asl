// PTO-TEST: {"id":"PTO-AVS-TILE-TNEG-ENCODING-001","source":"asl/tile/elementwise-tile-tile/logical/TNEG.asl","requirements":["PTO-TNEG-CONTRACT-001"],"kind":"boundary","summary":"TNEG rejects invalid floating source encodings.","pass_condition":"A TF32 source with discarded fraction bits makes TNEG operand legality false before effects.","related_sources":["asl/arch/features/mx-formats.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_TF32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);

    assert !InstructionContractOperandsLegal_TNEG(1, 0);
    assert !_Tiles[[1]].contents_defined;
    return 0;
end;
