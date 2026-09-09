// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-EXACT-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Direct TSEL fallback permits exact backing and operation type identity without changing numeric status","pass_condition":"a selected signaling-NaN payload from a TF32 source is preserved in a TF32 destination and sticky status remains unchanged","related_sources":["asl/tile/model/execution/comparison.asl","asl/arch/state/numeric-status.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(0, 128, 32, 1, 1, 1);
    ConfigureTile(1, 128, 32, 1, 1, 1, TileDataType_TF32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 32, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 32, 1, 1, 1, TileDataType_TF32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTilePredicateBit(0, 0, 0, TRUE);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7f800123);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    _SystemRegisters.core_state[36:32] = '00100';

    ExecuteTileSelect(3, 0, 1, 2);

    assert ReadTileElement(3, 0, 0) ==
        Zeros{PTO_XLEN} + 0x7f800123;
    assert ScalarFPFlags() == '00100';
    return 0;
end;
