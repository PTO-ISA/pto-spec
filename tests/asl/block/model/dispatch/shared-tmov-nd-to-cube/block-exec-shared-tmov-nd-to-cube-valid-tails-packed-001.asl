// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-VALID-TAILS-PACKED-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"reverse TMOV maps only valid tail elements and leaves zeroed padding undefined for byte and packed sources","pass_condition":"M32 U8 and U4X2 conversions use complete row ranges with clipped valid rows/columns; each valid raw value maps exactly, invalid source padding is never consumed, and every destination padding element is raw zero and undefined","related_sources":["asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/tile/model/memory/shared-nd-to-cube.asl","asl/tile/model/definedness/packed-boundary.asl"]}

pure func SharedNDToCubeTailStart(carrier: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = carrier;
    return instruction;
end;

pure func SharedNDToCubeTailDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeTailShared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeTailSubview(size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000053;
    instruction[19:15] = Zeros{5} + 2;
    instruction[10:7] = size_code;
    return instruction;
end;

pure func SharedNDToCubeTailDestination(size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeTailU8(row: integer {0..99},
    column: integer {0..116}) => Word
begin
    return Zeros{PTO_XLEN} + 1 + row * 67 + column * 31 +
        ((row * column) MOD 109);
end;

pure func SharedNDToCubeTailU4(row: integer {0..49},
    column: integer {0..12}) => Word
begin
    return Zeros{PTO_XLEN} + ((row * 3 + column * 5 +
        ((row * column) MOD 7)) MOD 16);
end;

func RunSharedNDToCubeU8Tail()
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x280);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x280);
    ConfigureTileForMask(10, 16384, 128, 128, 100, 117,
        TileDataType_U8, TileLayout_RowMajor, '1000');
    for row = 0 to 99 looplimit 100 do
        for column = 0 to 116 looplimit 117 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeTailU8(row as integer {0..99},
                    column as integer {0..116}));
        end;
    end;
    let shared_id = (Zeros{6} + 41) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    assert SharedTilePublished(shared_id) &&
           SharedTileRecord(shared_id).tile.contents_defined;

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeTailStart(
            TileDataTypeToEncoding(TileDataType_U8)), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeTailDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 117);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 4);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeTailShared(shared_id as bits(6)), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 96);
    let subview_status = ExecuteCommandInstruction(
        SharedNDToCubeTailSubview(Zeros{4} + 6), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeTailDestination(Zeros{4} + 6), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           subview_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None;
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
    assert found;
    let result = _Tiles[[destination]];
    assert result.rows == 32 && result.columns == 128 &&
           result.valid_rows == 4 && result.valid_columns == 117 &&
           result.data_type == TileDataType_U8 && result.contents_defined;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            let element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            if row < 4 && column < 117 then
                assert TileLogicalElementDefined(result, element) &&
                       ReadTileElement(destination,
                           row as integer {0..65535},
                           column as integer {0..65535}) ==
                           SharedNDToCubeTailU8(
                               (96 + row) as integer {0..99},
                               column as integer {0..116});
            else
                assert !TileLogicalElementDefined(result, element) &&
                       TileReadLogicalElement(result, element) ==
                           Zeros{PTO_XLEN};
            end;
        end;
    end;
end;

func RunSharedNDToCubePackedTail()
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x300);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    ConfigureTileForMask(10, 512, 64, 16, 50, 13,
        TileDataType_U4X2, TileLayout_RowMajor, '1000');
    for row = 0 to 49 looplimit 50 do
        for column = 0 to 12 looplimit 13 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeTailU4(row as integer {0..49},
                    column as integer {0..12}));
        end;
    end;
    let shared_id = (Zeros{6} + 42) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    assert SharedTilePublished(shared_id) &&
           SharedTileRecord(shared_id).tile.contents_defined;

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeTailStart(
            TileDataTypeToEncoding(TileDataType_U4X2)), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeTailDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 13);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 18);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeTailShared(shared_id as bits(6)), 32);
    WriteGPR(2, Zeros{PTO_XLEN} + 2);
    let subview_status = ExecuteCommandInstruction(
        SharedNDToCubeTailSubview(Zeros{4} + 2), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeTailDestination(Zeros{4} + 2), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           subview_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None;
    var destination = 0 as TileIndex;
    var found = FALSE;
    for tile = 0 to 63 do
        if !found && _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 &&
           _Tiles[[tile]].capacity_bytes == 256 then
            destination = tile as TileIndex;
            found = TRUE;
        end;
    end;
    assert found;
    let result = _Tiles[[destination]];
    assert result.rows == 32 && result.columns == 16 &&
           result.valid_rows == 18 && result.valid_columns == 13 &&
           result.data_type == TileDataType_U4X2 && result.contents_defined;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 15 looplimit 16 do
            let element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            if row < 18 && column < 13 then
                assert TileLogicalElementDefined(result, element) &&
                       ReadTileElement(destination,
                           row as integer {0..65535},
                           column as integer {0..65535}) ==
                           SharedNDToCubeTailU4(
                               (32 + row) as integer {0..49},
                               column as integer {0..12});
            else
                assert !TileLogicalElementDefined(result, element) &&
                       TileReadLogicalElement(result, element) ==
                           Zeros{PTO_XLEN};
            end;
        end;
    end;
end;

func main() => integer
begin
    RunSharedNDToCubeU8Tail();
    RunSharedNDToCubePackedTail();
    return 0;
end;
