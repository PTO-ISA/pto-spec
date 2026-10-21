// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-MIXED-GENERATION-007","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-BSTART-TMOV-SHARED-001","PTO-TMOV-CUBE-TO-SHARED-ND-001"],"kind":"execution","summary":"Actual PE Shared generations reject M16/M32 and converted/NORM mode mixing without losing accepted arrivals","pass_condition":"An actual PE cohort accepts two 2 KiB M162ND writers then rejects a 4 KiB M322ND writer in the 2+2+4 KiB mixed example, retaining the two accepted arrivals unpublished; a second cohort accepts M162ND then rejects a complete-parent NORM TMOV candidate with the same atomic preservation","related_sources":["asl/block/model/operands/shared-generation-pe-requests.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/dispatch/shared-tlsu.asl"]}

pure func SharedMixedTMOVStart() => bits(64)
begin
    return Zeros{64} + 0x38211181;
end;

pure func SharedMixedTMOVDATR(layout: integer {24,25}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + layout;
    return instruction;
end;

pure func SharedMixedTMOVIOS(shared_id: bits(6), parent_size: bits(4),
    pemode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = parent_size;
    instruction[11:9] = pemode;
    return instruction;
end;

pure func SharedMixedTMOVAssemble(writer_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = writer_size;
    return instruction;
end;

pure func SharedMixedTMOVSource(pemode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = pemode;
    instruction[19] = '1';
    return instruction;
end;

func ConfigureSharedMixedSource(capacity: integer {2048,4096,16384},
    rows: integer {16,32}, valid_columns: integer {128},
    layout: TileLayout, allocation_mask: bits(4))
begin
    let configured = ConfigureCubeTileForMask(0, capacity, rows,
        valid_columns, TileDataType_E4M3, layout, allocation_mask);
    assert configured;
    InstallRelativeTileFixture(0, 0);
    for row = 0 to rows - 1 looplimit 65536 do
        for column = 0 to valid_columns - 1 looplimit 65536 do
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + 1 + row * 17 + column * 3);
        end;
    end;
    assert _Tiles[[0]].contents_defined && TileCubeDescriptorLegal(
        _Tiles[[0]]);
end;

func SubmitSharedMixedTMOV(pe: integer {0..2},
    layout: TileLayout, layout_code: integer {0,24,25},
    source_capacity: integer {2048,4096,16384}, writer_size: integer {5,6,8},
    parent_size: integer {7,8}, offset: integer {0,16,32},
    shared_id: SharedTileID, pemode: bits(3), expect_fault: boolean)
begin
    let agent = pe as MemoryAgentId;
    SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
    if ReadTPC() == Zeros{PTO_XLEN} then WriteTPC(Zeros{PTO_XLEN} + 0x100); end;
    let rows = if layout == TileLayout_CUBE_M32 then 32 else 16;
    let source_columns = 128;
    let allocation_mask = PEMaskOfPEMode(pemode);
    ConfigureSharedMixedSource(source_capacity, rows, source_columns,
        layout, allocation_mask);
    WriteGPR(1, Zeros{PTO_XLEN} + offset);
    let started = ExecuteCommandInstruction(SharedMixedTMOVStart(), 32);
    var datr_status = CommandExecution_Executed;
    if layout_code != 0 then
        datr_status = ExecuteCommandInstruction(
            SharedMixedTMOVDATR(layout_code as integer {24,25}), 32);
    end;
    let shared = ExecuteCommandInstruction(SharedMixedTMOVIOS(
        shared_id as bits(6), (Zeros{4} + parent_size) as bits(4), pemode), 32);
    let assemble = ExecuteCommandInstruction(SharedMixedTMOVAssemble(
        (Zeros{4} + writer_size) as bits(4)), 32);
    let source = ExecuteCommandInstruction(SharedMixedTMOVSource(pemode), 32);
    assert started == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           assemble == CommandExecution_Executed &&
           source == CommandExecution_Executed;
    let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
    if expect_fault then
        assert _LastFault == Fault_TileLegality;
    else
        assert stopped == CommandExecution_Executed &&
               _LastFault == Fault_None &&
               BundleSharedGenerationOpen(shared_id) &&
               BundleSharedGenerationRequestWaiting(0);
    end;
end;

func InstallPriorSharedGeneration(shared_id: SharedTileID)
begin
    ConfigureTileForMask(10, 128, 1, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor, '1111');
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    InstallSharedTile(shared_id, _Tiles[[10]], '1111');
    assert SharedTilePublished(shared_id) &&
           SharedTileRecord(shared_id).tile.data_type == TileDataType_U8 &&
           TileReadLogicalElement(SharedTileRecord(shared_id).tile, 0) ==
               Zeros{PTO_XLEN} + 0x5a;
end;

func RunM16M32MixedGeneration()
begin
    ResetProfileState();
    InstallPriorSharedGeneration((Zeros{6} + 58) as SharedTileID);
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    StartMemoryEventCapture(0);
    SubmitSharedMixedTMOV(0, TileLayout_CUBE_M16, 25, 2048, 5, 7, 0,
        (Zeros{6} + 58) as SharedTileID, '110', FALSE);
    SubmitSharedMixedTMOV(1, TileLayout_CUBE_M16, 25, 2048, 5, 7, 16,
        (Zeros{6} + 58) as SharedTileID, '110', FALSE);
    let generation_index = SharedTileArrayIndex(
        (Zeros{6} + 58) as SharedTileID);
    assert _SharedGenerations[[generation_index]].working_initialized_mask ==
               '1100' &&
           _SharedGenerations[[generation_index]].arrived_participants ==
               '1100' &&
           _SharedGenerations[[generation_index]].specialized_inputs_valid &&
           _SharedGenerations[[generation_index]].specialized_metadata ==
               Zeros{PTO_XLEN} + 25;
    assert SharedTilePublished((Zeros{6} + 58) as SharedTileID) &&
           SharedTileRecord((Zeros{6} + 58) as SharedTileID).tile.data_type ==
               TileDataType_U8 &&
           TileReadLogicalElement(
               SharedTileRecord((Zeros{6} + 58) as SharedTileID).tile, 0) ==
               Zeros{PTO_XLEN} + 0x5a;
    SubmitSharedMixedTMOV(2, TileLayout_CUBE_M32, 24, 4096, 6, 7, 32,
        (Zeros{6} + 58) as SharedTileID, '110', TRUE);
    assert SharedTilePublished((Zeros{6} + 58) as SharedTileID) &&
           SharedTileRecord((Zeros{6} + 58) as SharedTileID).tile.data_type ==
               TileDataType_U8 &&
           TileReadLogicalElement(
               SharedTileRecord((Zeros{6} + 58) as SharedTileID).tile, 0) ==
               Zeros{PTO_XLEN} + 0x5a;
    StopMemoryEventCapture();
    assert _MemoryEventCount == 0;
end;

func RunConvertedAndNORMMixedGeneration()
begin
    ResetProfileState();
    InstallPriorSharedGeneration((Zeros{6} + 59) as SharedTileID);
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    StartMemoryEventCapture(0);
    SubmitSharedMixedTMOV(0, TileLayout_CUBE_M16, 25, 2048, 5, 8, 0,
        (Zeros{6} + 59) as SharedTileID, '111', FALSE);
    let generation_index = SharedTileArrayIndex(
        (Zeros{6} + 59) as SharedTileID);
    assert BundleSharedGenerationOpen((Zeros{6} + 59) as SharedTileID) &&
           _SharedGenerations[[generation_index]].working_initialized_mask ==
               '1000' &&
           SharedTilePublished((Zeros{6} + 59) as SharedTileID);
    SubmitSharedMixedTMOV(1, TileLayout_CUBE_M16, 0, 16384, 8, 8, 0,
        (Zeros{6} + 59) as SharedTileID, '111', TRUE);
    assert SharedTilePublished((Zeros{6} + 59) as SharedTileID) &&
           SharedTileRecord((Zeros{6} + 59) as SharedTileID).tile.data_type ==
               TileDataType_U8 &&
           TileReadLogicalElement(
               SharedTileRecord((Zeros{6} + 59) as SharedTileID).tile, 0) ==
               Zeros{PTO_XLEN} + 0x5a;
    StopMemoryEventCapture();
    assert _MemoryEventCount == 0;
end;

func main() => integer
begin
    RunM16M32MixedGeneration();
    RunConvertedAndNORMMixedGeneration();
    return 0;
end;
