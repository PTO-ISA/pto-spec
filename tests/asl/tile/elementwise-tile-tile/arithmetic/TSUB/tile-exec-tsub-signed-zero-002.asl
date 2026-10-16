// PTO-TEST: {"id":"PTO-AVS-TILE-TSUB-SIGNED-ZERO-002","source":"asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl","requirements":["PTO-TSUB-CONTRACT-001"],"kind":"execution","summary":"TSUB applies subtraction's effective right sign to exact-zero results","pass_condition":"FP32 negative zero minus positive zero produces negative zero and positive zero minus negative zero produces positive zero without numeric flags","related_sources":["asl/tile/model/execution/elementwise.asl","asl/scalar/model/fsu/scalar-fp.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 4, 4, 1, 2,
            TileDataType_FP32, TileLayout_RowMajor);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x80000000);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x80000000);

    InstructionContractExecute_TSUB(2, 0, 1);
    assert ReadTileElement(2, 0, 0) ==
        Zeros{PTO_XLEN} + 0x80000000;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
