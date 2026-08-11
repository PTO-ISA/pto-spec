// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-PRESENCE-FAULT-001","source":"asl/block/model/dispatch/shared-cube.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"fault","summary":"missing, duplicate, and non-CUBE B.FPATR presence faults are bundle-control errors","pass_condition":"each invalid presence case faults before operand consumption or destination allocation","related_sources":[]}
pure func BundleTestPresenceCUBEStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestPresenceTEPLStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestPresenceFPATR() => bits(64)
begin
    return Zeros{64} + 0x00002023;
end;

pure func BundleTestPresenceSharedBinding(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '1111';
    instruction[11:9] = '000';
    return instruction;
end;

pure func BundleTestPresenceLocalBinding(tile_size: bits(3),
                                         destination: bits(2),
                                         source0: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = tile_size;
    instruction[8:7] = destination;
    instruction[18:15] = '1111';
    instruction[25:20] = source0;
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 6);
    InstallSharedTile(Zeros{8} + 31, _Tiles[[0]], '1111');
    let start = ExecuteCommandInstruction(
        BundleTestPresenceCUBEStart('00000', Zeros{5} + 24), 32);
    let shared = ExecuteCommandInstruction(
        BundleTestPresenceSharedBinding(Zeros{8} + 31), 32);
    let local = ExecuteCommandInstruction(
        BundleTestPresenceLocalBinding('001', '00', Zeros{6}), 32);
    assert start == CommandExecution_Executed;
    assert shared == CommandExecution_Executed;
    assert local == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    // Duplicate B.FPATR is rejected before any CUBE operand can consume.
    ResetProfileState();
    let duplicate_start = ExecuteCommandInstruction(
        BundleTestPresenceCUBEStart('00000', Zeros{5} + 24), 32);
    let first_fpatr = ExecuteCommandInstruction(BundleTestPresenceFPATR(), 32);
    let duplicate_fpatr = ExecuteCommandInstruction(BundleTestPresenceFPATR(), 32);
    assert duplicate_start == CommandExecution_Executed;
    assert first_fpatr == CommandExecution_Executed;
    assert duplicate_fpatr == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    // A non-CUBE operation cannot carry B.FPATR.
    ResetProfileState();
    let noncube_start = ExecuteCommandInstruction(
        BundleTestPresenceTEPLStart(Zeros{5} + 24), 32);
    let noncube_fpatr = ExecuteCommandInstruction(
        BundleTestPresenceFPATR(), 32);
    assert noncube_start == CommandExecution_Executed;
    assert noncube_fpatr == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    return 0;
end;
