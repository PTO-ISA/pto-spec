// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-LOCAL-FOURSTREAM-010","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-SHARED-WHOLE-PARENT-READY-001"],"kind":"execution","summary":"encoded Shared-to-Local TLSU writes only each selected PE's private Local destination","pass_condition":"four independent encoded streams retain the original two-PE mask; PE0 and PE1 receive complete copies in their own Local banks, while PE2 and PE3 allocate or fault nothing and the Core Shared parent stays unchanged","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/memory/shared-movement.asl","asl/arch/state/pe-execution-context.asl"]}
pure func SharedLocalFourStreamStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func SharedLocalFourStreamSource(shared_id: bits(6),
                                      pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func SharedLocalFourStreamDestination(pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = '0001';
    instruction[8:7] = '10';
    instruction[11:9] = pe_mode;
    instruction[19] = '1';
    return instruction;
end;

func ExecuteSharedLocalFourStreamPE(pe: MemoryAgentId)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    assert !_Tiles[[2]].allocated;
    let start = ExecuteCommandInstruction(SharedLocalFourStreamStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let shared = ExecuteCommandInstruction(SharedLocalFourStreamSource(
        Zeros{6} + 43, '101'), 32);
    let destination = ExecuteCommandInstruction(
        SharedLocalFourStreamDestination('101'), 32);
    assert start == CommandExecution_Executed;
    assert shared == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].pe_mask == '1100';
    assert _BundleTileBindings[[0]].pe_mask == '1100';
    // B.IOT selects hand 2; destination allocation chooses the first free
    // Local register in that hand, which is register 32 in this fixture.
    let destination_index = 32 as TileIndex;
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed && _LastFault == Fault_None;
    if pe == 0 || pe == 1 then
        assert _Tiles[[destination_index]].allocated;
        assert _Tiles[[destination_index]].contents_defined;
        assert ReadTileElement(destination_index, 0, 0) ==
            Zeros{PTO_XLEN} + 0x5a;
    else
        assert !_Tiles[[destination_index]].allocated;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x200);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    InstallSharedTile((Zeros{6} + 43) as SharedTileID,
        _Tiles[[0]], '1000');
    let prior = SharedTileRecord((Zeros{6} + 43) as SharedTileID);

    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        ExecuteSharedLocalFourStreamPE(pe_number as MemoryAgentId);
    end;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
        if pe_number == 0 || pe_number == 1 then
            assert _Tiles[[32]].allocated && _Tiles[[32]].contents_defined;
            assert ReadTileElement(32 as TileIndex, 0, 0) ==
                Zeros{PTO_XLEN} + 0x5a;
        else
            assert !_Tiles[[32]].allocated;
        end;
    end;
    let after = SharedTileRecord((Zeros{6} + 43) as SharedTileID);
    assert after.descriptor_valid == prior.descriptor_valid;
    assert after.allocation_mask == prior.allocation_mask;
    assert after.initialized_mask == prior.initialized_mask;
    assert after.whole_parent_ready == prior.whole_parent_ready;
    assert after.published == prior.published;
    assert after.tile.allocated == prior.tile.allocated;
    assert after.tile.capacity_bytes == prior.tile.capacity_bytes;
    assert after.tile.rows == prior.tile.rows &&
        after.tile.columns == prior.tile.columns;
    assert after.tile.payload[[0]] == prior.tile.payload[[0]];
    return 0;
end;
