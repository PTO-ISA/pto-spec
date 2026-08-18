// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-MASK-PACKED-001","source":"asl/block/execution/BSTART.MGATHER.MASK.asl","requirements":["PTO-BSTART-MGATHER-MASK-SCHEMA-001"],"kind":"boundary","summary":"MGATHER.MASK reserves packed four-bit transfer types.","pass_condition":"A complete U4X2 masked gather raises TileLegality before destination allocation, events, or memory effects because no nibble selector is encoded.","related_sources":["asl/tile/model/legality/memory-schema.asl"]}
pure func PackedMaskGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00611181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;

pure func PackedMaskGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func PackedMaskGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(1, 128, 1, 2, 1, 2);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTilePredicateBit(1, 0, 0, TRUE);
    WriteTilePredicateBit(1, 0, 1, TRUE);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x200);
    let started = ExecuteCommandInstruction(PackedMaskGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    let bound = ExecuteCommandInstruction(PackedMaskGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(PackedMaskGatherIOR(), 32);
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
