// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-MASK-PRED-001","source":"asl/block/execution/BSTART.MGATHER.MASK.asl","requirements":["PTO-MGATHER-MASK-PREDICATE-001"],"kind":"fault","summary":"MGATHER.MASK requires packed predicate storage for MaskTile.","pass_condition":"A fully defined ordinary numeric Tile containing value one raises TileLegality before destination allocation, address checks, memory events, or payload effects.","related_sources":["asl/tile/model/definedness/elements.asl","asl/block/model/dispatch/tlsu-mgather-mask.asl"]}
pure func PredicateGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00611181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func PredicateGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func PredicateGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x200);
    let started = ExecuteCommandInstruction(PredicateGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(PredicateGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(PredicateGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();
    return 0;
end;
