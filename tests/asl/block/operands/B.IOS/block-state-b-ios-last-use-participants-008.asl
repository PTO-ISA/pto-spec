// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-LAST-USE-PARTICIPANTS-008","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-B-IOS-SHARED-STATE-001","PTO-ARCH-SHARED-VTAG-LIFETIME-001"],"kind":"state-transition","summary":"Decoded Shared last-use is completed independently by every declared PE before the common payload is released.","pass_condition":"Each successful PE returns immediately, the first three completions retain the same Shared generation, and the fourth completion releases its payload exactly once.","related_sources":["asl/block/model/operands/shared-bindings.asl","asl/tile/model/state/shared-registers.asl"]}
pure func ParticipantLastUseStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00001';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func ParticipantLastUseBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 11;
    instruction[11:9] = '111';
    instruction[26] = '1';
    return instruction;
end;

pure func ParticipantLastUseAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func ExecuteParticipantLastUse(pe: MemoryAgentId, address: integer)
begin
    SelectExecutionContext(0, pe);
    WriteGPR(2, Zeros{PTO_XLEN} + address);
    let started = ExecuteCommandInstruction(ParticipantLastUseStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(ParticipantLastUseBinding(), 32);
    let addressed = ExecuteCommandInstruction(ParticipantLastUseAddress(), 32);
    assert started == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           addressed == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x100);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x6a);
    let shared_id = (Zeros{6} + 11) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');

    for pe = 0 to 3 do
        ExecuteParticipantLastUse(pe as MemoryAgentId, 8 + pe * 8);
        let shared = SharedTileRecord(shared_id);
        assert shared.descriptor_valid;
        if pe < 3 then
            assert shared.payload_live;
        else
            assert !shared.payload_live;
        end;
        assert _Memory[[8 + pe * 8]] == Zeros{8} + 0x6a;
    end;
    assert SharedTileCapacityInUse() == 0;
    return 0;
end;
