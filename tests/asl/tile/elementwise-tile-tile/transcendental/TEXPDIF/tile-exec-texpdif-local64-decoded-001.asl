// PTO-TEST: {"id":"PTO-AVS-TILE-EXPDIF-LOCAL64-DECODED-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-TEXPDIF-CONTRACT-001","PTO-TROWEXPANDEXPDIF-CONTRACT-001","PTO-TCOLEXPANDEXPDIF-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"The exact FP64 same-type pair decodes for elementwise and both broadcast EXPDIF forms.","pass_condition":"All three decoded M32 FP64 forms compute exp(one minus one) as exact one in a two-CELL destination while preserving source descriptors.","related_sources":["asl/tile/reduce-and-expand/row-expansion/TROWEXPANDEXPDIF.asl","asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDEXPDIF.asl","asl/tile/model/execution/expdif.asl"]}
func ExpdifLocal64Decoded(start: bits(64))
begin
    ResetProfileState();
    let source0_ready = ConfigureCubeTile(1, 256, 1, 1, TileDataType_FP64, TileLayout_CUBE_M32);
    let source1_ready = ConfigureCubeTile(2, 256, 1, 1, TileDataType_FP64, TileLayout_CUBE_M32);
    assert source0_ready && source1_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5} + 29,
        '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(TRUE, 0, 2, '0001', TRUE, TRUE, 1, 2, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_FP64;
    assert _Tiles[[destination]].cube_cell_count == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x3ff0000000000000;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x3ff0000000000000;
end;

func main() => integer
begin
    assert InstructionContractDataTypeLegal_TROWEXPANDEXPDIF(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TCOLEXPANDEXPDIF(TileDataType_FP64);
    ExpdifLocal64Decoded(Zeros{64} + 0x01d19181);
    ExpdifLocal64Decoded(Zeros{64} + 0x04b19181);
    ExpdifLocal64Decoded(Zeros{64} + 0x05b19181);
    return 0;
end;
