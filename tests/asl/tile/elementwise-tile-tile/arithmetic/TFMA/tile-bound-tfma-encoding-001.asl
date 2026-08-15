// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-ENCODING-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"boundary","summary":"TFMA rejects invalid source encodings before execution.","pass_condition":"A TF32 source with nonzero truncated fraction bits makes operand preflight fail.","related_sources":["asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 3 looplimit 4 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_TF32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN});
    assert !InstructionContractOperandsLegal_TFMA(0, 1, 2, 3);
    return 0;
end;
