// PTO-TEST: {"id":"PTO-AVS-TILE-TADD-SIGNED-ZERO-002","source":"asl/tile/elementwise-tile-tile/arithmetic/TADD.asl","requirements":["PTO-TADD-CONTRACT-001"],"kind":"execution","summary":"TADD preserves equal negative-zero signs and uses positive zero for RNE cancellation","pass_condition":"FP32 negative zero plus negative zero produces negative zero while positive one plus negative one produces positive zero without numeric flags","related_sources":["asl/tile/model/execution/elementwise.asl","asl/scalar/model/fsu/scalar-fp.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 4, 4, 1, 2,
            TileDataType_FP32, TileLayout_RowMajor);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x80000000);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x80000000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0xbf800000);

    InstructionContractExecute_TADD(2, 0, 1);
    assert ReadTileElement(2, 0, 0) ==
        Zeros{PTO_XLEN} + 0x80000000;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
