// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-S4-INDEX-002","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-INDEXED-TLSU-STRIDE-001","PTO-MGATHER-BYTE-DISPLACEMENT-001"],"kind":"fault","summary":"MGATHER rejects a packed S4 IndexTile outside the S32/U32 common subset.","pass_condition":"The block rejects before memory events or destination allocation.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/definedness/elements.asl"]}

pure func PackedSignedGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func PackedSignedGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func PackedSignedGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S4X2,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xd);
    Store(Zeros{PTO_XLEN} + 0x100, 1, Zeros{PTO_XLEN} + 0x5a);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x103);

    let started = ExecuteCommandInstruction(PackedSignedGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(PackedSignedGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(PackedSignedGatherIOR(), 32);
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
