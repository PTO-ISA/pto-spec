// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-LIFETIME-COHORT-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-TMOV-SHARED-ND-TO-CUBE-001"],"kind":"state-transition","summary":"reverse last-use cohorts pin one generation through a later PE allocation fault and retry","pass_condition":"a decoded four-PE last-use cohort commits earlier Local outputs, captures the same Shared generation across PEs, survives a later selected-PE allocation fault and unchanged-bundle retry, preserves earlier outputs, and retires the source only after the final participant","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/operands/local-generation.asl","asl/block/model/state/source-lifetime.asl","asl/tile/model/state/shared-registers.asl"]}
pure func SharedNDToCubeCohortGolden(row: integer {0..127},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 1 + row * 71 + column * 29 +
        ((row * column) MOD 113);
end;

pure func SharedNDToCubeCohortStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = DTYPE_NONE;
    return instruction;
end;

pure func SharedNDToCubeCohortDATR(selector: integer {21,24})
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + selector;
    return instruction;
end;

pure func SharedNDToCubeCohortSharedSource(shared_id: bits(6),
    pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = pe_mode;
    instruction[26] = '1';
    return instruction;
end;

pure func SharedNDToCubeCohortSharedDestination(shared_id: bits(6),
    parent_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = parent_size;
    instruction[11:9] = '101';
    return instruction;
end;

pure func SharedNDToCubeCohortAssemble(writer_size: bits(4))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = writer_size;
    return instruction;
end;

pure func SharedNDToCubeCohortLocalSource(pe_mode: bits(3))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeCohortSubview() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000053;
    instruction[19:15] = Zeros{5} + 2;
    instruction[10:7] = Zeros{4} + 5;
    return instruction;
end;

pure func SharedNDToCubeCohortLocalDestination(size_code: bits(4),
    pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = '10';
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

func SharedNDToCubeCohortLastUse(shared_id: bits(6)) => bits(64)
begin
    return SharedNDToCubeCohortSharedSource(shared_id, '111');
end;

func SharedNDToCubeCohortCapacityPoolFull() => boolean
begin
    for tile = 0 to 31 looplimit 32 do
        ConfigureTileForMask(tile as TileIndex, 8192, 32, 256,
            32, 256, TileDataType_U8, TileLayout_RowMajor, '0001');
    end;
    return TileCapacityInUseForPE(3) == TileCapacityLimitBytes();
end;

readonly func SharedNDToCubeCohortLifetimeSlot(shared_id: SharedTileID)
    => integer {-1..63}
begin
    let generation = SharedTileRecord(shared_id).payload_generation;
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].resource ==
               (UInt(shared_id) as TileIndex) &&
           _BundleSourceLifetimes[[slot]].shared_epoch == generation then
            return slot as integer {-1..63};
        end;
    end;
    return -1;
end;

func SubmitSharedNDToCubeCohortLastUsePE(pe: integer {0..3})
begin
    let agent = pe as MemoryAgentId;
    SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
    WriteTPC(Zeros{PTO_XLEN} + 0x900);
    if pe == 3 then
        assert TileCapacityInUseForPE(3) == TileCapacityLimitBytes();
    end;
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortDATR(21), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortLastUse(Zeros{6} + 55), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeCohortLocalDestination(Zeros{4} + 6, '111'), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    if pe == 3 then
        let shared_id = (Zeros{6} + 55) as SharedTileID;
        let slot = SharedNDToCubeCohortLifetimeSlot(shared_id);
        assert stop_status == CommandExecution_Rejected &&
               _LastFault == Fault_TileAllocation &&
               _TrapContexts[[0]].valid &&
               !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
               TileCapacityInUseForPE(3) == TileCapacityLimitBytes() &&
               SharedSourceLifetimePinned(shared_id) && slot >= 0 &&
               _BundleSourceLifetimes[[slot]].participant_mask == '1111' &&
               _BundleSourceLifetimes[[slot]].captured_mask == '1011' &&
               _BundleSourceLifetimes[[slot]].completed_mask == '1010' &&
               _BundleSourceLifetimes[[slot]].shared_epoch ==
                   SharedTileRecord(shared_id).payload_generation &&
               SharedTileRecord(shared_id).payload_live &&
               SharedTileRecord(shared_id).published;
    else
        assert stop_status == CommandExecution_Executed &&
               _LastFault == Fault_None && !_BundleActive;
    end;
end;

func RunSharedNDToCubeCohortLastUseFaultRetry()
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x900);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x900);
    ConfigureTileForMask(10, 4096, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_RowMajor, '1111');
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeCohortGolden(
                    row as integer {0..127}, column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 55) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1111');
    let source_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);

    SubmitSharedNDToCubeCohortLastUsePE(2);
    let slot_after_pe2 = SharedNDToCubeCohortLifetimeSlot(shared_id);
    assert slot_after_pe2 >= 0 &&
           _BundleSourceLifetimes[[slot_after_pe2]].participant_mask == '1111' &&
           _BundleSourceLifetimes[[slot_after_pe2]].captured_mask == '0010' &&
           _BundleSourceLifetimes[[slot_after_pe2]].completed_mask == '0010' &&
           SharedSourceLifetimePinned(shared_id) &&
           SharedTileRecord(shared_id).payload_live;
    SubmitSharedNDToCubeCohortLastUsePE(0);
    let slot_after_pe0 = SharedNDToCubeCohortLifetimeSlot(shared_id);
    assert slot_after_pe0 == slot_after_pe2 &&
           _BundleSourceLifetimes[[slot_after_pe0]].captured_mask == '1010' &&
           _BundleSourceLifetimes[[slot_after_pe0]].completed_mask == '1010' &&
           SharedSourceLifetimePinned(shared_id);

    SelectExecutionContext(0 as PTOModelCoreIdentity, 3 as MemoryAgentId);
    let pool_full = SharedNDToCubeCohortCapacityPoolFull();
    assert pool_full;
    let local_destination_before = TileCapacityInUseForPE(3);
    SubmitSharedNDToCubeCohortLastUsePE(3);
    SelectExecutionContext(0 as PTOModelCoreIdentity, 3 as MemoryAgentId);
    for tile = 32 to 47 do
        assert !_Tiles[[tile]].allocated ||
               _Tiles[[tile]].layout != TileLayout_CUBE_M32 ||
               _Tiles[[tile]].capacity_bytes != 4096;
    end;
    let failed_slot = SharedNDToCubeCohortLifetimeSlot(shared_id);
    assert failed_slot == slot_after_pe2;
    assert TileCapacityInUseForPE(3) == local_destination_before;
    assert SharedTileRecord(shared_id).payload_generation ==
           source_before.payload_generation;
    assert SharedTileRecord(shared_id).payload_live;
    assert SharedTileRecord(shared_id).published;
    assert SharedSourceLifetimePinned(shared_id);
    for pe = 0 to 2 do
        if pe != 1 then
            SelectExecutionContext(0 as PTOModelCoreIdentity,
                pe as MemoryAgentId);
            var prior_found = FALSE;
            for tile = 32 to 47 do
                if !prior_found && _Tiles[[tile]].allocated &&
                   _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
                   _Tiles[[tile]].capacity_bytes == 4096 &&
                   _Tiles[[tile]].contents_defined then
                    prior_found = TRUE;
                    assert ReadTileElement(tile as TileIndex, 0, 0) ==
                           SharedNDToCubeCohortGolden(0, 0);
                end;
            end;
            assert prior_found;
        end;
    end;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 3 as MemoryAgentId);
    ReleaseTile(0);
    assert TileCapacityInUseForPE(3) == TileCapacityLimitBytes() - 8192;
    let recovered = RecoverTrapContext(0);
    assert recovered && !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    ClearFault();
    assert _LastFault == Fault_None && _BundleActive && BundleTMOVSelected();
    let retry = ExecuteCommandInstruction(Zeros{64}, 16);
    let slot_after_retry = SharedNDToCubeCohortLifetimeSlot(shared_id);
    assert retry == CommandExecution_Executed && _LastFault == Fault_None &&
           !_BundleActive &&
           TileCapacityInUseForPE(3) == TileCapacityLimitBytes() - 4096 &&
           slot_after_retry == slot_after_pe2 &&
           _BundleSourceLifetimes[[slot_after_retry]].captured_mask == '1011' &&
           _BundleSourceLifetimes[[slot_after_retry]].completed_mask == '1011' &&
           SharedSourceLifetimePinned(shared_id) &&
           SharedTileRecord(shared_id).payload_live;
    var pe3_output = FALSE;
    for tile = 32 to 47 do
        if _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].capacity_bytes == 4096 &&
           _Tiles[[tile]].contents_defined then
            pe3_output = TRUE;
        end;
    end;
    assert pe3_output;
    SubmitSharedNDToCubeCohortLastUsePE(1);
    assert !SharedSourceLifetimePinned(shared_id) &&
           SharedTileRecord(shared_id).payload_generation ==
               source_before.payload_generation &&
           SharedTileRecord(shared_id).published &&
           !SharedTileRecord(shared_id).payload_live &&
           SharedNDToCubeCohortLifetimeSlot(shared_id) == -1;
    for pe = 0 to 3 do
        SelectExecutionContext(0 as PTOModelCoreIdentity,
            pe as MemoryAgentId);
        var found = FALSE;
        for tile = 32 to 47 do
            if !found && _Tiles[[tile]].allocated &&
               _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
               _Tiles[[tile]].capacity_bytes == 4096 &&
               _Tiles[[tile]].contents_defined then
                found = TRUE;
                for row = 0 to 31 looplimit 32 do
                    for column = 0 to 127 looplimit 128 do
                        assert ReadTileElement(tile as TileIndex,
                                   row as integer {0..65535},
                                   column as integer {0..65535}) ==
                               SharedNDToCubeCohortGolden(
                                   row as integer {0..127},
                                   column as integer {0..127});
                    end;
                end;
            end;
        end;
        assert found;
    end;
end;

func main() => integer
begin
    RunSharedNDToCubeCohortLastUseFaultRetry();
    return 0;
end;
