// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-CUBE-CROSS-CARRIER-001","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-TCMPS-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"CUBE_M16 TCMPS uses operation-typed S16 GPR geometry with BF16 backing","pass_condition":"a BF16-backed source compares against an S16 scalar and produces the operation-typed four-field M16 mask","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/predicate-carriers.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(10, 128, 1, 4, TileDataType_BF16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source_ready;
    for column = 0 to 3 looplimit 4 do
        WriteTileElement(10, 0, column,
            Zeros{PTO_XLEN} + column + 1);
    end;
    MarkTileValidRegionDefined(10);
    WriteGPR(4, Zeros{PTO_XLEN} + 2);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x92d19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(FALSE, 0, 0, '1111', TRUE, FALSE, 10, 0, TRUE);
    SetBundleScalarBinding(0, 5, 4, 0, 0, 1);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let result = ReadGPR(5);
    assert result[0] == '0';
    assert result[16] == '1';
    assert result[32] == '0';
    assert result[48] == '0';
    return 0;
end;
