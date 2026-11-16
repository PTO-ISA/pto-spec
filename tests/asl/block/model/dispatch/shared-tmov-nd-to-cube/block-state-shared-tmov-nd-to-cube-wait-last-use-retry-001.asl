// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-WAIT-LAST-USE-RETRY-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-B-IOS-SHARED-STATE-001","PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-TMOV-SHARED-ND-TO-CUBE-001"],"kind":"state-transition","summary":"an encoded reverse TMOV waits on absent and unpublished Shared generations without pinning or consuming its last-use binding","pass_condition":"the same decoded PE0 ND2M32 request waits first on an unallocated Sx and then on an unpublished complete descriptor with no fault, allocation, binding consumption, or source lifetime capture; after publication it succeeds once, produces the expected Local CUBE values, and completes exactly one last-use release","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/operands/shared-bindings.asl","asl/block/model/state/source-lifetime.asl","asl/tile/model/state/shared-registers.asl"]}

pure func SharedNDToCubeWaitStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeWaitDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeWaitLastUse(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    instruction[26] = '1';
    return instruction;
end;

pure func SharedNDToCubeWaitDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeWaitGolden(row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 1 + row * 67 + column * 31 +
        ((row * column) MOD 101);
end;

readonly func SharedNDToCubeWaitHasSourceLifetime(
    shared_id: SharedTileID) => boolean
begin
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].resource ==
               (UInt(shared_id) as TileIndex) then
            return TRUE;
        end;
    end;
    return FALSE;
end;

readonly func SharedNDToCubeWaitHasDestination() => boolean
begin
    for tile = 0 to 63 do
        if _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].capacity_bytes == 4096 then
            return TRUE;
        end;
    end;
    return FALSE;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x400);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    ConfigureTileForMask(10, 4096, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_RowMajor, '1000');
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeWaitGolden(row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 44) as SharedTileID;
    assert !SharedTileRecord(shared_id).descriptor_valid;

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeWaitStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeWaitDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeWaitLastUse(shared_id as bits(6)), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeWaitDestination(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed &&
           !_BundleSharedBindings[[0]].source_reuse;

    let parked_tpc = ReadTPC();
    let waiting_unallocated = ExecuteCommandInstruction(Zeros{64}, 16);
    assert waiting_unallocated == CommandExecution_Executed &&
           _LastFault == Fault_None &&
           _BundleActive && _BundleSharedBindings[[0]].valid &&
           !_BundleSharedBindings[[0]].consumed &&
           ReadTPC() == parked_tpc &&
           !SharedNDToCubeWaitHasDestination() &&
           !SharedNDToCubeWaitHasSourceLifetime(shared_id);

    let installed_unpublished = AtomicUpdateSharedTileWithPublication(
        shared_id, _Tiles[[10]], '1000', FALSE);
    assert installed_unpublished &&
           SharedTileRecord(shared_id).descriptor_valid &&
           !SharedTilePublished(shared_id);
    let waiting_unpublished = ExecuteCommandInstruction(Zeros{64}, 16);
    assert waiting_unpublished == CommandExecution_Executed &&
           _LastFault == Fault_None &&
           _BundleActive && _BundleSharedBindings[[0]].valid &&
           !_BundleSharedBindings[[0]].consumed &&
           ReadTPC() == parked_tpc &&
           !SharedNDToCubeWaitHasDestination() &&
           !SharedNDToCubeWaitHasSourceLifetime(shared_id);

    let published = AtomicUpdateSharedTileWithPublication(
        shared_id, _Tiles[[10]], '1000', TRUE);
    assert published && SharedTilePublished(shared_id);
    let generation = SharedTileRecord(shared_id).payload_generation;
    let completed = ExecuteCommandInstruction(Zeros{64}, 16);
    assert completed == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive;
    assert SharedTileRecord(shared_id).payload_generation == generation;
    assert !SharedTileRecord(shared_id).payload_live;
    assert !SharedSourceLifetimePinned(shared_id);
    assert SharedNDToCubeWaitHasDestination();

    var destination = 0 as TileIndex;
    var found = FALSE;
    for tile = 0 to 63 do
        if !found && _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].capacity_bytes == 4096 then
            destination = tile as TileIndex;
            found = TRUE;
        end;
    end;
    assert found && _Tiles[[destination]].contents_defined;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            assert ReadTileElement(destination,
                       row as integer {0..65535},
                       column as integer {0..65535}) ==
                       SharedNDToCubeWaitGolden(
                           row as integer {0..31},
                           column as integer {0..127});
        end;
    end;
    return 0;
end;
