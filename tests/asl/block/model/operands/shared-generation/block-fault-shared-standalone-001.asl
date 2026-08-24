// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-STANDALONE-COMPAT-001","source":"asl/block/model/operands/shared-generation.asl","requirements":["PTO-B-ASSEMBLE-SHARED-STANDALONE-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"fault","summary":"Multi-PE Shared destinations require B.ASSEMBLE while single-PE standalone B.IOS remains legal.","pass_condition":"A decoded all-PE standalone TLOAD faults before memory or Shared effects, a single-PE standalone form succeeds, and an all-PE INIT_LAST form publishes atomically.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/operands/B.ASSEMBLE.asl"]}
pure func SharedPolicyStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func SharedPolicyBIOS(shared_tile_id: bits(6), pe_mode: bits(3))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = '0001';
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func SharedPolicyAssemble() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = '0001';
    return instruction;
end;

func PrepareSharedPolicyBlock()
begin
    let started = ExecuteCommandInstruction(SharedPolicyStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
end;

func main() => integer
begin
    ResetProfileState();
    PrepareSharedPolicyBlock();
    let standalone = ExecuteCommandInstruction(
        SharedPolicyBIOS(Zeros{6} + 1, '111'), 32);
    assert standalone == CommandExecution_Executed;
    let rejected = ExecuteBundleTileOperation();
    assert !rejected && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !SharedTileRecord((Zeros{6} + 1) as SharedTileID)
        .descriptor_valid;

    ResetProfileState();
    PrepareSharedPolicyBlock();
    let single = ExecuteCommandInstruction(
        SharedPolicyBIOS(Zeros{6} + 2, '001'), 32);
    assert single == CommandExecution_Executed;
    let single_completed = ExecuteBundleTileOperation();
    assert single_completed && _LastFault == Fault_None;
    assert SharedTileRecord((Zeros{6} + 2) as SharedTileID)
        .descriptor_valid;

    ResetProfileState();
    PrepareSharedPolicyBlock();
    let collective = ExecuteCommandInstruction(
        SharedPolicyBIOS(Zeros{6} + 3, '111'), 32);
    let assemble = ExecuteCommandInstruction(SharedPolicyAssemble(), 32);
    assert collective == CommandExecution_Executed;
    assert assemble == CommandExecution_Executed;
    let collective_completed = ExecuteBundleTileOperation();
    assert collective_completed && _LastFault == Fault_None;
    assert SharedTilePublished((Zeros{6} + 3) as SharedTileID);
    return 0;
end;
