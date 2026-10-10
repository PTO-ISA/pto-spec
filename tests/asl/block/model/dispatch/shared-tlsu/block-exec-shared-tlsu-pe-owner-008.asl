// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-PE-OWNER-008","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-B-ASSEMBLE-SHARED-STANDALONE-001"],"kind":"execution","summary":"A singleton direct TMOV publishes its eligible PE's private source; nonparticipants cannot contribute and a later operation updates the whole parent.","pass_condition":"PE0's encoded singleton publishes all 16 of its source words immediately, nonselected PE1..PE3 instances do not fault or alter Shared, and a repeated site publishes PE0's distinct later payload.","related_sources":["asl/tile/model/state/shared-registers.asl","asl/block/model/operands/shared-generation.asl"]}
pure func BundleTestTLSUOwnerStart(function: bits(5), data_type: bits(5))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestTLSUOwnerTileBinding(source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '001';
    instruction[25:20] = source;
    instruction[19] = '1';
    return instruction;
end;

pure func BundleTestTLSUOwnerSharedBinding(
    shared_tile_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

func PrepareTLSUOwnerPE(pe: MemoryAgentId, generation: integer)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    if ReadTPC() == Zeros{PTO_XLEN} then
        WriteTPC(Zeros{PTO_XLEN} + 0x100);
    end;
    ConfigureTile(0, 128, 16, 1, 16, 1, TileDataType_U64,
        TileLayout_RowMajor);
    for element = 0 to 15 do
        WriteTileElement(0, element as integer {0..65535}, 0,
            Zeros{PTO_XLEN} + (generation * 100 +
                (pe as integer {0..3}) * 10 + element + 1));
    end;
    let start_result = ExecuteCommandInstruction(BundleTestTLSUOwnerStart(
        '00010', Zeros{5} + 24), 32);
    let shared_result = ExecuteCommandInstruction(
        BundleTestTLSUOwnerSharedBinding(Zeros{6} + 19), 32);
    let tile_result = ExecuteCommandInstruction(
        BundleTestTLSUOwnerTileBinding(Zeros{6}), 32);
    assert start_result == CommandExecution_Executed;
    assert shared_result == CommandExecution_Executed;
    assert tile_result == CommandExecution_Executed;
    assert _BundleActive && _BundleSharedBindings[[0]].valid &&
           !_BundleSharedBindings[[0]].consumed &&
           _BundleTileBindings[[0]].valid;
end;

func TestTLSUActualPEOwnerPublication()
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;

    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        PrepareTLSUOwnerPE(pe as MemoryAgentId, 1);
    end;

    // The first eligible singleton direct TMOV publishes the complete parent
    // from the real PE0 source, without asking nonselected PEs to execute this
    // operation or contribute their private payload.
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    assert _BundleActive && _BundleSharedBindings[[0]].valid &&
           !_BundleSharedBindings[[0]].consumed;
    assert BundleSharedBindingId(0) == ((Zeros{6} + 19) as SharedTileID);
    let pe0_first_result = ExecuteCommandInstruction(
        Zeros{64}, 16);
    assert pe0_first_result == CommandExecution_Executed;
    let shared_id = (Zeros{6} + 19) as SharedTileID;
    assert SharedTilePublished(shared_id);
    for element = 0 to 15 do
        assert ReadSharedTileWord(shared_id,
            element as PackedTileElementIndex) ==
            Zeros{PTO_XLEN} + (100 + element + 1);
    end;
    // PE0 starts a second operation at the same static site before PE1..PE3
    // have reached their first instance. The new ordinal and payload remain
    // distinct from the older completed candidate.
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    PrepareTLSUOwnerPE(0 as MemoryAgentId, 2);
    assert _BundleActive && _BundleSharedBindings[[0]].valid &&
           !_BundleSharedBindings[[0]].consumed;
    let pe0_second_result = ExecuteCommandInstruction(
        Zeros{64}, 16);
    assert pe0_second_result == CommandExecution_Executed;
    for element = 0 to 15 do
        assert ReadSharedTileWord(shared_id,
            element as PackedTileElementIndex) ==
            Zeros{PTO_XLEN} + (200 + element + 1);
    end;
    for pe = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        SelectExecutionContext(0 as PTOModelCoreIdentity,
            pe as MemoryAgentId);
        assert _BundleActive && _BundleSharedBindings[[0]].valid &&
               !_BundleSharedBindings[[0]].consumed;
        let stale_first_result = ExecuteCommandInstruction(
            Zeros{64}, 16);
        assert stale_first_result == CommandExecution_Executed;
        for element = 0 to 15 do
            assert ReadSharedTileWord(shared_id,
                element as PackedTileElementIndex) ==
                Zeros{PTO_XLEN} + (200 + element + 1);
        end;
        PrepareTLSUOwnerPE(pe as MemoryAgentId, 2);
        assert _BundleActive && _BundleSharedBindings[[0]].valid &&
               !_BundleSharedBindings[[0]].consumed;
        let second_peer_result = ExecuteCommandInstruction(
            Zeros{64}, 16);
        assert second_peer_result == CommandExecution_Executed;
    end;
    for element = 0 to 15 do
        assert ReadSharedTileWord(shared_id,
            element as PackedTileElementIndex) ==
            Zeros{PTO_XLEN} + (200 + element + 1);
    end;
end;

func main() => integer
begin
    TestTLSUActualPEOwnerPublication();
    return 0;
end;
