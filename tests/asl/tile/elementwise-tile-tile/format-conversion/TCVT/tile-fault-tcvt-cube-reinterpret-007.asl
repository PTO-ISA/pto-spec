// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CUBE-REINTERPRET-007","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"fault","summary":"TCVT does not broaden Matrix/CUBE source reinterpretation","pass_condition":"a BF16 source operation type rejects an FP16-backed CUBE_M16 source even though both types have the same element width","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/tile/model/legality/operand-schema.asl"]}
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
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let destination_ready = ConfigureCubeTile(
        1, 128, 16, 1, TileDataType_BF16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source_ready && destination_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    MarkTileValidRegionDefined(0);

    let started = ExecuteCommandInstruction(TCVTCubeReinterpretStart(), 32);
    assert started == CommandExecution_Executed;
    assert !TileOperandsLegal_TCVT(
        1, 0, DefaultNumericExecutionControl());
    return 0;
end;
