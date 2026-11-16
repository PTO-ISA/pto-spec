// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-FOUR-PE-GPR-RANGES-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-SUBVIEW-SHARED-PER-PE-001","PTO-TMOV-SHARED-ND-TO-CUBE-001"],"kind":"execution","summary":"four actual PEs select distinct Shared ND row ranges from their private GPRs","pass_condition":"the encoded ND2M32 bundle runs in permuted PE order over a published 128x128 U8 parent; GPR offsets 0,32,64,96 select the corresponding rows without implicit PE partitioning, and each private Local CUBE receives its exact bitwise fragment","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/operands/shared-generation.asl","asl/tile/model/memory/shared-nd-to-cube.asl"]}

pure func SharedNDToCubeFourPEDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeFourPEShared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedNDToCubeFourPEDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[8:7] = '10';
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeFourPEStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeFourPESubview() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000053;
    instruction[19:15] = Zeros{5} + 2;
    instruction[10:7] = Zeros{4} + 6;
    return instruction;
end;

pure func SharedNDToCubeFourPEGolden(row: integer {0..127},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 1 + row * 71 + column * 29 +
        ((row * column) MOD 113);
end;

pure func SharedNDToCubeFourPEOffset(pe: integer {0..3})
    => integer {0..96}
begin
    if pe == 0 then return 96; end;
    if pe == 1 then return 0; end;
    if pe == 2 then return 64; end;
    return 32;
end;

func RunSharedNDToCubeFourPE(pe: MemoryAgentId)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    WriteGPR(2, Zeros{PTO_XLEN} +
        SharedNDToCubeFourPEOffset(pe as integer {0..3}));
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeFourPEStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeFourPEDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeFourPEShared(Zeros{6} + 40), 32);
    let subview_status = ExecuteCommandInstruction(
        SharedNDToCubeFourPESubview(), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeFourPEDestination(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           subview_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].source0_subview.valid &&
           _BundleSharedBindings[[0]].source0_subview.offset ==
               (Zeros{PTO_XLEN} + SharedNDToCubeFourPEOffset(
                   pe as integer {0..3}));
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive;
    var destination = 0 as TileIndex;
    var destination_count: integer {0..64} = 0;
    for tile = 0 to 63 do
        if _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].capacity_bytes == 4096 then
            destination = tile as TileIndex;
            destination_count = (destination_count + 1) as integer {0..64};
        end;
    end;
    assert destination_count == 1;
    let result = _Tiles[[destination]];
    let first_row = SharedNDToCubeFourPEOffset(
        pe as integer {0..3});
    assert result.rows == 32 && result.columns == 128 &&
           result.valid_rows == 32 && result.valid_columns == 128 &&
           result.data_type == TileDataType_U8 &&
           result.layout == TileLayout_CUBE_M32 &&
           result.contents_defined;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            assert ReadTileElement(destination,
                       row as integer {0..65535},
                       column as integer {0..65535}) ==
                       SharedNDToCubeFourPEGolden(
                           (first_row + row) as integer {0..127},
                           column as integer {0..127});
        end;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x200);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    ConfigureTileForMask(10, 16384, 128, 128,
        128, 128, TileDataType_U8, TileLayout_RowMajor, '1111');
    for row = 0 to 127 looplimit 128 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeFourPEGolden(
                    row as integer {0..127},
                    column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 40) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1111');
    let source_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);
    StartMemoryEventCapture(0);

    RunSharedNDToCubeFourPE(2 as MemoryAgentId);
    RunSharedNDToCubeFourPE(0 as MemoryAgentId);
    RunSharedNDToCubeFourPE(3 as MemoryAgentId);
    RunSharedNDToCubeFourPE(1 as MemoryAgentId);
    StopMemoryEventCapture();
    assert _MemoryEventCount == 0;
    for pe = 0 to 3 do
        SelectExecutionContext(0 as PTOModelCoreIdentity,
            pe as MemoryAgentId);
        var destination_found = FALSE;
        for tile = 0 to 63 do
            if !destination_found && _Tiles[[tile]].allocated &&
               _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
               _Tiles[[tile]].capacity_bytes == 4096 then
                destination_found = TRUE;
                let first_row = SharedNDToCubeFourPEOffset(pe);
                for row = 0 to 31 looplimit 32 do
                    for column = 0 to 127 looplimit 128 do
                        assert ReadTileElement(tile as TileIndex,
                                   row as integer {0..65535},
                                   column as integer {0..65535}) ==
                               SharedNDToCubeFourPEGolden(
                                   (first_row + row) as integer {0..127},
                                   column as integer {0..127});
                    end;
                end;
            end;
        end;
        assert destination_found;
    end;
    let source_after = SharedTileRecord(shared_id);
    assert source_after.payload_generation == source_before.payload_generation &&
           source_after.published == source_before.published &&
           source_after.payload_live == source_before.payload_live;
    return 0;
end;
