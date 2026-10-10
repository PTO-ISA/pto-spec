// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-LOCAL-SUBVIEW-FOURSTREAM-011","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-SUBVIEW-SHARED-PER-PE-001","PTO-B-SHARED-WHOLE-PARENT-READY-001"],"kind":"execution","summary":"encoded Shared CELL subviews materialize only into the eligible PE's private Local bank","pass_condition":"four independent encoded streams retain the full logical mask and each selected PE receives only its own distinct Shared CELL view in its Local destination; nonselected PE effects and the Core Shared parent remain unchanged","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/operands/shared-generation.asl","asl/tile/model/memory/shared-movement.asl","asl/arch/state/pe-execution-context.asl"]}
pure func SharedLocalSubviewFourStreamStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = '00010';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedLocalSubviewFourStreamSource(shared_id: bits(6))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedLocalSubviewFourStreamSubview() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000053;
    instruction[19:15] = Zeros{5} + 2;
    instruction[10:7] = '0001';
    return instruction;
end;

pure func SharedLocalSubviewFourStreamDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = '0001';
    instruction[8:7] = '10';
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func ExecuteSharedLocalSubviewFourStreamPE(pe: MemoryAgentId)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    WriteGPR(2, Zeros{PTO_XLEN} + (pe as integer {0..3}));
    let start = ExecuteCommandInstruction(
        SharedLocalSubviewFourStreamStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    let source = ExecuteCommandInstruction(
        SharedLocalSubviewFourStreamSource(Zeros{6} + 43), 32);
    let subview = ExecuteCommandInstruction(
        SharedLocalSubviewFourStreamSubview(), 32);
    let destination = ExecuteCommandInstruction(
        SharedLocalSubviewFourStreamDestination(), 32);
    assert start == CommandExecution_Executed;
    assert source == CommandExecution_Executed;
    assert subview == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].pe_mask == '1111';
    assert _BundleTileBindings[[0]].pe_mask == '1111';
    assert _BundleSharedBindings[[0]].source0_subview.valid;
    assert _BundleSharedBindings[[0]].source0_subview.offset ==
        (Zeros{PTO_XLEN} + (pe as integer {0..3}));
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed && _LastFault == Fault_None;
    assert _Tiles[[32]].allocated && _Tiles[[32]].contents_defined;
    assert _Tiles[[32]].rows == 1 && _Tiles[[32]].columns == 128;
    for column = 0 to 127 looplimit 128 do
        assert ReadTileElement(32 as TileIndex, 0, column) ==
            Zeros{PTO_XLEN} + 0x10 + (pe as integer {0..3});
    end;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x200);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    ConfigureTile(10, 512, 1, 512, 1, 512, TileDataType_U8,
        TileLayout_RowMajor);
    for column = 0 to 511 looplimit 512 do
        WriteTileElement(10, 0, column,
            Zeros{PTO_XLEN} + 0x10 + (column DIVRM 128));
    end;
    InstallSharedTile((Zeros{6} + 43) as SharedTileID,
        _Tiles[[10]], '1111');
    let before = SharedTileRecord((Zeros{6} + 43) as SharedTileID);

    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        ExecuteSharedLocalSubviewFourStreamPE(
            pe_number as MemoryAgentId);
    end;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
        assert _Tiles[[32]].allocated && _Tiles[[32]].contents_defined;
        for column = 0 to 127 looplimit 128 do
            assert ReadTileElement(32 as TileIndex, 0, column) ==
                Zeros{PTO_XLEN} + 0x10 + pe_number;
        end;
    end;
    let after = SharedTileRecord((Zeros{6} + 43) as SharedTileID);
    assert after.tile.capacity_bytes == before.tile.capacity_bytes;
    assert after.tile.rows == before.tile.rows &&
        after.tile.columns == before.tile.columns;
    for column = 0 to 511 looplimit 512 do
        assert ReadSharedTileWord((Zeros{6} + 43) as SharedTileID,
            column as PackedTileElementIndex) ==
            Zeros{PTO_XLEN} + 0x10 + (column DIVRM 128);
    end;
    return 0;
end;
