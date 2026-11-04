// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-M16-U16-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-BSTART-TMOV-SHARED-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"encoded M16 U16 reverse TMOV infers DTYPE_NONE and maps singleton and ranged PE fragments","pass_condition":"a published 16x64 U16 RowMajor Shared parent is consumed through decoded Function-2 TMOV Layout 22 with BSTART.TMOV DTYPE_NONE into an exact 2 KiB CUBE_M16 Local destination and all valid bits match; a second 64x64 parent is split into four explicit 16-row ranges for four PEs and each CUBE payload matches its independently mapped source rows","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/tile/model/memory/shared-nd-to-cube.asl"]}

pure func SharedNDToCubeM16Start(carrier: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = carrier;
    return instruction;
end;

pure func SharedNDToCubeM16DATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + 22;
    return instruction;
end;

pure func SharedNDToCubeM16Shared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeM16Destination(size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeM16Golden(row: integer {0..15},
    column: integer {0..63}) => Word
begin
    return Zeros{PTO_XLEN} + 0x1234 + row * 193 + column * 37 +
        ((row * column) MOD 251);
end;

pure func SharedNDToCubeM16RangedGolden(row: integer {0..63},
    column: integer {0..63}) => Word
begin
    return Zeros{PTO_XLEN} + 0x1000 + row * 733 + column * 47 +
        ((row * column) MOD 251);
end;

pure func SharedNDToCubeM16RangedShared(shared_id: bits(6))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedNDToCubeM16RangedSubview() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000053;
    instruction[19:15] = Zeros{5} + 2;
    instruction[10:7] = Zeros{4} + 5;
    return instruction;
end;

pure func SharedNDToCubeM16RangedDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 5;
    instruction[8:7] = '10';
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func RunSharedNDToCubeM16RangedPE(pe: integer {0..3})
begin
    let agent = pe as MemoryAgentId;
    SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
    WriteTPC(Zeros{PTO_XLEN} + 0x180);
    WriteGPR(2, Zeros{PTO_XLEN} + pe * 16);
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeM16Start(DTYPE_NONE), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeM16DATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 64);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeM16RangedShared(Zeros{6} + 39), 32);
    let subview_status = ExecuteCommandInstruction(
        SharedNDToCubeM16RangedSubview(), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeM16RangedDestination(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           subview_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive;
end;

func RunSharedNDToCubeM16Ranged()
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x180);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x180);
    ConfigureTileForMask(10, 8192, 64, 64, 64, 64,
        TileDataType_U16, TileLayout_RowMajor, '1111');
    for row = 0 to 63 looplimit 64 do
        for column = 0 to 63 looplimit 64 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeM16RangedGolden(
                    row as integer {0..63},
                    column as integer {0..63}));
        end;
    end;
    let shared_id = (Zeros{6} + 39) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1111');
    assert SharedTilePublished(shared_id);
    RunSharedNDToCubeM16RangedPE(2);
    RunSharedNDToCubeM16RangedPE(0);
    RunSharedNDToCubeM16RangedPE(3);
    RunSharedNDToCubeM16RangedPE(1);
    for pe = 0 to 3 do
        SelectExecutionContext(0 as PTOModelCoreIdentity,
            pe as MemoryAgentId);
        var found = FALSE;
        for tile = 32 to 47 do
            if !found && _Tiles[[tile]].allocated &&
               _Tiles[[tile]].layout == TileLayout_CUBE_M16 &&
               _Tiles[[tile]].capacity_bytes == 2048 &&
               _Tiles[[tile]].contents_defined then
                found = TRUE;
                let result = _Tiles[[tile]];
                assert result.rows == 16 && result.columns == 64 &&
                       result.valid_rows == 16 &&
                       result.valid_columns == 64 &&
                       result.data_type == TileDataType_U16;
                for row = 0 to 15 looplimit 16 do
                    for column = 0 to 63 looplimit 64 do
                        assert ReadTileElement(tile as TileIndex,
                                   row as integer {0..65535},
                                   column as integer {0..65535}) ==
                               SharedNDToCubeM16RangedGolden(
                                   (pe * 16 + row) as integer {0..63},
                                   column as integer {0..63});
                    end;
                end;
            end;
        end;
        assert found;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 39) as SharedTileID;
    ConfigureTileForMask(10, 2048, 16, 64, 16, 64,
        TileDataType_U16, TileLayout_RowMajor, '1000');
    for row = 0 to 15 looplimit 16 do
        for column = 0 to 63 looplimit 64 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeM16Golden(row as integer {0..15},
                    column as integer {0..63}));
        end;
    end;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    assert SharedTilePublished(shared_id);

    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x180);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x180);
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeM16Start(
            DTYPE_NONE), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeM16DATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 64);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeM16Shared(shared_id as bits(6)), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeM16Destination(Zeros{4} + 5), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    assert BundleSharedTMOVSharedNDToCubeSelected() &&
           BundleSharedTMOVSharedNDToCubeLayout() == TileLayout_CUBE_M16;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None;

    var destination = 0 as TileIndex;
    var destination_count: integer {0..64} = 0;
    for tile = 0 to 63 do
        if _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M16 &&
           _Tiles[[tile]].capacity_bytes == 2048 then
            destination = tile as TileIndex;
            destination_count = (destination_count + 1) as integer {0..64};
        end;
    end;
    assert destination_count == 1;
    let result = _Tiles[[destination]];
    assert result.rows == 16 && result.columns == 64 &&
           result.valid_rows == 16 && result.valid_columns == 64 &&
           result.data_type == TileDataType_U16 &&
           result.layout == TileLayout_CUBE_M16 &&
           result.contents_defined;
    for row = 0 to 15 looplimit 16 do
        for column = 0 to 63 looplimit 64 do
            let element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            assert TileLogicalElementDefined(result, element) &&
                   ReadTileElement(destination,
                       row as integer {0..65535},
                       column as integer {0..65535}) ==
                       SharedNDToCubeM16Golden(
                           row as integer {0..15},
                           column as integer {0..63});
        end;
    end;
    assert _MemoryEventCount == 0;
    RunSharedNDToCubeM16Ranged();
    return 0;
end;
