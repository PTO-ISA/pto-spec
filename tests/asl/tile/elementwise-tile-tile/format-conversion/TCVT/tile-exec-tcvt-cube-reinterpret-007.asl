// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CUBE-REINTERPRET-007","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"TCVT accepts a same-width non-packed CUBE source operation view without retagging the backing descriptor","pass_condition":"a BF16 source operation view accepts an FP16-backed CUBE_M16 source, produces the independent BF16 golden for 1.0, and leaves the source descriptor unchanged","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/numeric/formats.asl"]}
pure func TCVTCubeReinterpretStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x09b19181;
    instruction[31:27] = Zeros{5} + 5;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 128, 16, 1, TileDataType_FP16,
        TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        1, 128, 16, 1, TileDataType_BF16,
        TileLayout_CUBE_M16);
    assert source_ready && destination_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    MarkTileValidRegionDefined(0);

    let started = ExecuteCommandInstruction(TCVTCubeReinterpretStart(), 32);
    assert started == CommandExecution_Executed;
    let source_before = _Tiles[[0]];
    assert TileOperandsLegal_TCVT(
        1, 0, DefaultNumericExecutionControl());
    InstructionContractExecute_TCVT(
        1, 0, DefaultNumericExecutionControl());
    assert _LastFault == Fault_None;
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f80;
    assert _Tiles[[0]].data_type == source_before.data_type;
    assert _Tiles[[0]].layout == source_before.layout;
    assert _Tiles[[0]].capacity_bytes == source_before.capacity_bytes;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x3f80;
    return 0;
end;
