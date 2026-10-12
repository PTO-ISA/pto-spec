// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-LAST-USE-PUBLICATION-PIN-010","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-B-IOS-SHARED-STATE-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001"],"kind":"state-transition","summary":"An encoded Shared destination waits without effects while an older generation has an incomplete last-use cohort.","pass_condition":"After PE0 completes last-use, a decoded TLOAD replacement returns pending without fault, memory or publication change; after PE1 through PE3 finish the cohort, retry publishes one new live generation with the loaded value.","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/block/model/operands/shared-bindings.asl","asl/tile/model/state/shared-registers.asl"]}
pure func PinStoreStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001'; instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func PinLoadStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[24:20] = '00000'; instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func PinSourceBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 16; instruction[11:9] = '111';
    instruction[26] = '1'; return instruction;
end;

pure func PinDestinationBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 16; instruction[18:15] = '0001';
    instruction[11:9] = '001'; return instruction;
end;

pure func PinAddress() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2; return instruction;
end;

func SetPinDimensions()
begin
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
end;

func RunPinConsumer(pe: MemoryAgentId, address: integer)
begin
    SelectExecutionContext(0, pe); ClearBundleHeaderState();
    WriteGPR(2, Zeros{PTO_XLEN} + address);
    let started = ExecuteCommandInstruction(PinStoreStart(), 32);
    SetPinDimensions();
    let bound = ExecuteCommandInstruction(PinSourceBinding(), 32);
    let addressed = ExecuteCommandInstruction(PinAddress(), 32);
    assert started == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           addressed == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation(); assert completed;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x400);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x61);
    let shared_id = (Zeros{6} + 16) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');
    let old_generation = SharedTileRecord(shared_id).payload_generation;
    RunPinConsumer(0, 8);

    SelectExecutionContext(0, 0); ClearBundleHeaderState();
    _Memory[[64]] = Zeros{8} + 0x72;
    WriteGPR(2, Zeros{PTO_XLEN} + 64);
    let load_started = ExecuteCommandInstruction(PinLoadStart(), 32);
    SetPinDimensions();
    let destination = ExecuteCommandInstruction(PinDestinationBinding(), 32);
    let load_address = ExecuteCommandInstruction(PinAddress(), 32);
    assert load_started == CommandExecution_Executed &&
           destination == CommandExecution_Executed &&
           load_address == CommandExecution_Executed;
    let pending = ExecuteBundleTileOperation();
    assert !pending && _LastFault == Fault_None;
    let pinned = SharedTileRecord(shared_id);
    assert pinned.payload_live && pinned.payload_generation == old_generation &&
           TileReadLogicalElement(pinned.tile, 0) == Zeros{PTO_XLEN} + 0x61;

    for pe = 1 to 3 do RunPinConsumer(pe as MemoryAgentId, 8 + pe * 8); end;
    SelectExecutionContext(0, 0);
    let published = ExecuteBundleTileOperation();
    assert published && _LastFault == Fault_None;
    let replacement = SharedTileRecord(shared_id);
    assert replacement.payload_live &&
           replacement.payload_generation == old_generation + 1 &&
           TileReadLogicalElement(replacement.tile, 0) ==
               Zeros{PTO_XLEN} + 0x72;
    return 0;
end;
