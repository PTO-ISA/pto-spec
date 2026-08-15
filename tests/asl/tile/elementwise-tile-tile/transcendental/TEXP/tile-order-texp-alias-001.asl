// PTO-TEST: {"id":"PTO-AVS-TILE-TEXP-ALIAS-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXP.asl","requirements":["PTO-INST-TILE-TEXP"],"kind":"ordering","summary":"TEXP snapshots a source that aliases its renamed destination","pass_condition":"an in-place FP32 negative-zero source produces positive one from the old payload","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1,
        TileDataType_FP32, TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x80000000);
    InstructionContractExecute_TEXP(0, 0);
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f800000;
    return 0;
end;
