// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-ALLOCATION-RETRY-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"reverse TMOV rolls back a capacity fault and commits one successful reissue","pass_condition":"with PE0 Local capacity full and a free destination-hand slot, a decoded Shared ND-to-CUBE request faults without partial destination or Shared mutation; after freeing 8 KiB of capacity and recovering, reissuing the unchanged bundle publishes exactly one complete Local CUBE with every valid value copied","related_sources":["asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/faults/rollback.asl","asl/block/model/dispatch/destination-shape.asl","asl/block/model/state/control-state.asl"]}

pure func SharedNDToCubeRetryStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeRetryDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeRetryShared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeRetryDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeRetryGolden(
    row: integer {0..31}, column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 5 + row * 61 + column * 29 +
        ((row * column) MOD 89);
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x780);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x780);
    ConfigureTileForMask(10, 4096, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_RowMajor, '1000');
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeRetryGolden(
                    row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 46) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    let source_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);

    // Fill PE0's pool using 32 RowMajor descriptors; the selected hand2
    // destination range 32..47 remains free to isolate capacity preflight.
    for tile = 0 to 31 looplimit 32 do
        ConfigureTileForMask(tile as TileIndex, 8192, 32, 256, 32, 256,
            TileDataType_U8, TileLayout_RowMajor, '1000');
    end;
    assert TileCapacityInUseForPE(0) == TileCapacityLimitBytes();

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeRetryStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeRetryDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeRetryShared(shared_id as bits(6)), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeRetryDestination(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;

    let first_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    let failed_source = SharedTileRecord(shared_id);
    assert first_stop == CommandExecution_Rejected &&
           _LastFault == Fault_TileAllocation &&
           _TrapContexts[[0]].valid &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           TileCapacityInUseForPE(0) == TileCapacityLimitBytes();
    assert failed_source.payload_generation == source_before.payload_generation &&
           failed_source.payload_live == source_before.payload_live &&
           failed_source.published == source_before.published;

    ReleaseTile(0);
    assert TileCapacityInUseForPE(0) == TileCapacityLimitBytes() - 8192;
    let recovered = RecoverTrapContext(0);
    assert recovered && !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    ClearFault();
    assert _LastFault == Fault_None;
    assert _BundleActive && BundleTMOVSelected() &&
           BundleSharedTMOVSharedNDToCubeSelected();
    assert TileCapacityInUseForPE(0) == TileCapacityLimitBytes() - 8192;
    let retry_stop = ExecuteCommandInstruction(Zeros{64}, 16);
    let source_after = SharedTileRecord(shared_id);
    assert _LastFault == Fault_None;
    assert retry_stop == CommandExecution_Executed;
    assert !_BundleActive;
    assert TileCapacityInUseForPE(0) == TileCapacityLimitBytes() - 4096;
    assert source_after.payload_generation == source_before.payload_generation &&
           source_after.payload_live == source_before.payload_live &&
           source_after.published == source_before.published;

    var destination_count: integer {0..64} = 0;
    var destination = 0 as TileIndex;
    for tile = 0 to 63 looplimit 64 do
        if _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].contents_defined then
            destination_count = (destination_count + 1) as integer {0..64};
            destination = tile as TileIndex;
        end;
    end;
    assert destination_count == 1 && _Tiles[[destination]].valid_rows == 32 &&
           _Tiles[[destination]].valid_columns == 128 &&
           _Tiles[[destination]].data_type == TileDataType_U8;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            assert ReadTileElement(destination,
                       row as integer {0..65535},
                       column as integer {0..65535}) ==
                   SharedNDToCubeRetryGolden(
                       row as integer {0..31},
                       column as integer {0..127});
        end;
    end;
    return 0;
end;
