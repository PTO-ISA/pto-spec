// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-MASK-SCHEMA-001","source":"asl/block/execution/BSTART.MGATHER.MASK.asl","requirements":["PTO-BSTART-MGATHER-MASK-SCHEMA-001"],"kind":"fault","summary":"MGATHER.MASK requires an explicit scalar base binding.","pass_condition":"A block with its Local sources, destination, and LB0 but no B.IOR raises TileLegality before allocation, events, or memory effects.","related_sources":["asl/block/model/dispatch/tlsu-mgather-mask.asl"]}
pure func SchemaMaskGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00611181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func SchemaMaskGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(1, 128, 1, 1, 1, 1);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTilePredicateBit(1, 0, 0, TRUE);
    let started = ExecuteCommandInstruction(SchemaMaskGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(SchemaMaskGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return 0;
end;
