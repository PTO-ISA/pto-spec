// PTO-TEST: {"id":"PTO-AVS-TILE-TSQRT-ALIAS-001","source":"asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl","requirements":["PTO-INST-TILE-TSQRT"],"kind":"ordering","summary":"TSQRT snapshots a source that aliases its renamed destination","pass_condition":"an in-place FP32 negative zero preserves the old signed-zero payload","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1,
        TileDataType_FP32, TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x80000000);
    InstructionContractExecute_TSQRT(0, 0);
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0x80000000;
    return 0;
end;
