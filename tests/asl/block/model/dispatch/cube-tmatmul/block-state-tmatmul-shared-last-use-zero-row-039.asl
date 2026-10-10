// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-LAST-USE-ZERO-ROW-039","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-GROUP-M-DISTRIBUTION-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-ARCH-SHARED-VTAG-LIFETIME-001"],"kind":"state-transition","summary":"A selected zero-row cooperative TMATMUL PE completes Shared last-use without creating Local effects.","pass_condition":"For group_M 65 the 32,32,1 active-row PEs retain the bare Shared source, PE3 joins the same occurrence and retires it while leaving its Local allocation, payload, memory, and numeric status unchanged, and the Shared descriptor remains.","related_sources":["asl/block/model/state/source-lifetime.asl","asl/block/operands/B.IOS.asl","asl/arch/state/pe-execution-context.asl"]}
pure func ZeroRowLastUseStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 26; return instruction;
end;

pure func ZeroRowLastUseFPATR() => bits(64)
begin return Zeros{64} + 0x00002023; end;

pure func ZeroRowLastUseDimension(lb: integer {0..2}, value: integer {0..65535})
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00000043;
    if lb == 1 then instruction = Zeros{64} + 0x00001043;
    elsif lb == 2 then instruction = Zeros{64} + 0x00002043; end;
    instruction[31:20] = Zeros{12} + value;
    instruction[11:7] = Zeros{5} + (value DIVRM 4096);
    return instruction;
end;

pure func ZeroRowLastUseShared() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 44; instruction[11:9] = '111';
    instruction[26] = '1'; return instruction;
end;

pure func ZeroRowLastUseTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = '0110'; instruction[11:9] = '111';
    instruction[8:7] = '10'; instruction[19] = '1'; return instruction;
end;

func PrepareZeroRowLastUsePE(pe: MemoryAgentId)
begin
    SelectExecutionContext(0, pe);
    if pe < 3 then
        let configured = ConfigureCubeTile(0, 1024, 32, 16,
            TileDataType_U16, TileLayout_CUBE_M32);
        assert configured;
        _Tiles[[0]].valid_rows = if pe == 2 then 1 else 32;
        for row = 0 to _Tiles[[0]].valid_rows - 1 looplimit 32 do
            for column = 0 to 15 looplimit 16 do
                WriteTileElement(0, row as integer {0..65535}, column,
                    Zeros{PTO_XLEN} + 1 + (pe as integer {0..3}));
            end;
        end;
    end;
end;

func ExecuteZeroRowLastUsePE(pe: MemoryAgentId) => integer
begin
    SelectExecutionContext(0, pe); ClearBundleHeaderState();
    WriteBPC(Zeros{PTO_XLEN} + 0x500); WriteTPC(Zeros{PTO_XLEN} + 0x500);
    let started = ExecuteCommandInstruction(ZeroRowLastUseStart(), 32);
    let fpatr = ExecuteCommandInstruction(ZeroRowLastUseFPATR(), 32);
    let dim_m = ExecuteCommandInstruction(ZeroRowLastUseDimension(0, 65), 32);
    let dim_n = ExecuteCommandInstruction(ZeroRowLastUseDimension(1, 1), 32);
    let dim_k = ExecuteCommandInstruction(ZeroRowLastUseDimension(2, 16), 32);
    let shared = ExecuteCommandInstruction(ZeroRowLastUseShared(), 32);
    let local = ExecuteCommandInstruction(ZeroRowLastUseTileBinding(), 32);
    assert started == CommandExecution_Executed &&
           fpatr == CommandExecution_Executed &&
           dim_m == CommandExecution_Executed &&
           dim_n == CommandExecution_Executed &&
           dim_k == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           local == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation(); assert completed;
    return _BundleSharedBindings[[0]].source_lifetime_ordinal;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x500);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(10, 128, 1, 16, 1, 16, TileDataType_U16,
        TileLayout_RowMajor);
    for column = 0 to 15 looplimit 16 do
        WriteTileElement(10, 0, column, Zeros{PTO_XLEN} + 2);
    end;
    let shared_id = (Zeros{6} + 44) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1111');
    for pe = 0 to 3 do PrepareZeroRowLastUsePE(pe as MemoryAgentId); end;

    var ordinal: integer = 0;
    for pe = 0 to 2 do
        let joined = ExecuteZeroRowLastUsePE(pe as MemoryAgentId);
        if pe == 0 then ordinal = joined; else assert joined == ordinal; end;
        let shared = SharedTileRecord(shared_id); assert shared.payload_live;
    end;
    SelectExecutionContext(0, 3);
    let allocation_before = _TileAllocationMasks;
    let payload_before = _TilePayloadLiveMasks;
    let numeric_before = NumericStatusFlags();
    StartMemoryEventCapture(0);
    let joined_zero = ExecuteZeroRowLastUsePE(3);
    assert joined_zero == ordinal && _LastFault == Fault_None;
    let retired = SharedTileRecord(shared_id);
    assert retired.descriptor_valid && !retired.payload_live;
    for tile = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        assert _TileAllocationMasks[[tile]] == allocation_before[[tile]] &&
               _TilePayloadLiveMasks[[tile]] == payload_before[[tile]];
    end;
    assert _MemoryEventCount == 0 &&
           NumericStatusFlags() == numeric_before;
    StopMemoryEventCapture();
    return 0;
end;
