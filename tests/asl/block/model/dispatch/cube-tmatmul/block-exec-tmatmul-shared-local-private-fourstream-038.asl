// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-LOCAL-PRIVATE-FOURSTREAM-038","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001","PTO-B-SHARED-WHOLE-PARENT-READY-001"],"kind":"execution","summary":"encoded cooperative TMATMUL reads each PE's private Local A with a Core Shared B","pass_condition":"four encoded streams use a common published Shared B and their own distinct Local A fragments; each emits the correct 16-row private result, preserves Shared, and leaves other PE Local results isolated","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/block/model/dispatch/shared-cube-matrix.asl","asl/arch/state/pe-execution-context.asl"]}
pure func PrivateFourStreamTMATMULStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func PrivateFourStreamTMATMULFPATR() => bits(64)
begin
    return Zeros{64} + 0x00002023;
end;

pure func PrivateFourStreamTMATMULDimension(
    lb: integer {0..2}, value: integer {0..65535}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000043;
    if lb == 1 then
        instruction = Zeros{64} + 0x00001043;
    elsif lb == 2 then
        instruction = Zeros{64} + 0x00002043;
    end;
    instruction[19:15] = Zeros{5};
    instruction[31:20] = Zeros{12} + value;
    instruction[11:7] = Zeros{5} + (value DIVRM 4096);
    return instruction;
end;

pure func PrivateFourStreamTMATMULShared(shared_id: bits(6))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    return instruction;
end;

pure func PrivateFourStreamTMATMULBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = '0101';
    instruction[11:9] = '111';
    instruction[8:7] = '10';
    instruction[19] = '1';
    return instruction;
end;

func PreparePrivateFourStreamTMATMULPE(pe: MemoryAgentId)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    let configured = ConfigureCubeTile(0, 512, 16, 16,
        TileDataType_U16, TileLayout_CUBE_M16);
    assert configured;
    let value = Zeros{PTO_XLEN} +
        (1 + (pe as integer {0..3}));
    for row = 0 to 15 looplimit 16 do
        for column = 0 to 15 looplimit 16 do
            WriteTileElement(0 as TileIndex, row, column, value);
        end;
    end;
end;

func ExecutePrivateFourStreamTMATMULPE(pe: MemoryAgentId)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    let start = ExecuteCommandInstruction(
        PrivateFourStreamTMATMULStart(), 32);
    let fpatr = ExecuteCommandInstruction(
        PrivateFourStreamTMATMULFPATR(), 32);
    let dim_m = ExecuteCommandInstruction(
        PrivateFourStreamTMATMULDimension(0, 64), 32);
    let dim_n = ExecuteCommandInstruction(
        PrivateFourStreamTMATMULDimension(1, 1), 32);
    let dim_k = ExecuteCommandInstruction(
        PrivateFourStreamTMATMULDimension(2, 16), 32);
    let shared = ExecuteCommandInstruction(
        PrivateFourStreamTMATMULShared(Zeros{6} + 43), 32);
    let binding = ExecuteCommandInstruction(
        PrivateFourStreamTMATMULBinding(), 32);
    assert start == CommandExecution_Executed &&
           fpatr == CommandExecution_Executed &&
           dim_m == CommandExecution_Executed &&
           dim_n == CommandExecution_Executed &&
           dim_k == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           binding == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].pe_mask == '1111';
    assert _BundleTileBindings[[0]].pe_mask == '1111';
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed && _LastFault == Fault_None;
    assert !_BundleActive;
    // Hand 2 is empty in every private bank, so B.IOT publishes register 32.
    let destination = 32 as TileIndex;
    let expected = Zeros{PTO_XLEN} +
        (32 * (1 + (pe as integer {0..3})));
    assert _Tiles[[destination]].contents_defined;
    assert _Tiles[[destination]].valid_rows == 16;
    assert _Tiles[[destination]].valid_columns == 1;
    for row = 0 to 15 looplimit 16 do
        assert ReadTileElement(destination, row, 0) == expected;
    end;
    assert _Tiles[[0]].contents_defined;
    assert ReadTileElement(0 as TileIndex, 0, 0) ==
        Zeros{PTO_XLEN} + (1 + (pe as integer {0..3}));
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x200);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    ConfigureTile(10, 128, 1, 16, 1, 16, TileDataType_U16,
        TileLayout_RowMajor);
    for column = 0 to 15 looplimit 16 do
        WriteTileElement(10 as TileIndex, 0, column,
            Zeros{PTO_XLEN} + 2);
    end;
    InstallSharedTile((Zeros{6} + 43) as SharedTileID,
        _Tiles[[10]], '1111');
    assert SharedTilePublished((Zeros{6} + 43) as SharedTileID);
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        PreparePrivateFourStreamTMATMULPE(
            pe_number as MemoryAgentId);
    end;
    let shared_before = SharedTileRecord((Zeros{6} + 43) as SharedTileID);
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        ExecutePrivateFourStreamTMATMULPE(
            pe_number as MemoryAgentId);
    end;
    let shared_after = SharedTileRecord((Zeros{6} + 43) as SharedTileID);
    assert shared_after.descriptor_valid == shared_before.descriptor_valid;
    assert shared_after.allocation_mask == shared_before.allocation_mask;
    assert shared_after.initialized_mask == shared_before.initialized_mask;
    assert shared_after.whole_parent_ready == shared_before.whole_parent_ready;
    assert shared_after.published == shared_before.published;
    assert shared_after.tile.payload[[0]] == shared_before.tile.payload[[0]];
    return 0;
end;
