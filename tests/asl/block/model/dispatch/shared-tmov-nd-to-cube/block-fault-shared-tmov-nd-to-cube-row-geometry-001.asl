// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-ROW-GEOMETRY-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-B-SUBVIEW-SHARED-PER-PE-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"reverse TMOV rejects partial rows, invalid row extents, and noncontiguous 2-D extraction before destination effects","pass_condition":"decoded M32 requests fault with no Local CUBE allocation when the source subview begins mid-row, exceeds the parent, has no valid row, selects only 16 physical rows, mismatches destination and subview capacity, or attempts a 32x128 extraction from a 32x256 ND parent","related_sources":["asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/operands/subview-descriptor.asl","asl/block/model/dispatch/shared-tlsu.asl"]}

pure func SharedNDToCubeGeometryStart(carrier: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(carrier);
    return instruction;
end;

pure func SharedNDToCubeGeometryDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeGeometryShared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeGeometrySubview(size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000053;
    instruction[19:15] = Zeros{5} + 2;
    instruction[10:7] = size_code;
    return instruction;
end;

pure func SharedNDToCubeGeometryDestination(size_code: bits(4))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeGeometryValue(data_type: TileDataType,
    row: integer {0..63}, column: integer {0..255}) => Word
begin
    return Zeros{PTO_XLEN} + 0x80000001 + row * 65537 +
        column * 257 + ((row * column) MOD 251);
end;

func SharedNDToCubeGeometryRejects(source_type: TileDataType,
    source_rows: integer {32,64}, source_columns: integer {32,256},
    valid_rows: integer {32,64}, source_capacity: integer {8192,16384},
    subview_size: bits(4), destination_size: bits(4),
    offset_units: integer {0..64}, valid_columns: integer {32,256},
    lb0: integer {32,128,256}) => boolean
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x600);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    ConfigureTileForMask(10, source_capacity, source_rows, source_columns,
        valid_rows, source_columns, source_type, TileLayout_RowMajor, '1000');
    for row = 0 to valid_rows - 1 looplimit 64 do
        for column = 0 to source_columns - 1 looplimit 256 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeGeometryValue(source_type,
                    row as integer {0..63},
                    column as integer {0..255}));
        end;
    end;
    let shared_id = (Zeros{6} + 34) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    let source_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeGeometryStart(source_type), 32);
    assert start_status == CommandExecution_Executed &&
           BundleTMOVSelected();
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeGeometryDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + lb0);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeGeometryShared(shared_id as bits(6)), 32);
    assert shared_status == CommandExecution_Executed &&
           BundleSharedTMOVSharedNDToCubeSelected();
    WriteGPR(2, Zeros{PTO_XLEN} + offset_units);
    let subview_status = ExecuteCommandInstruction(
        SharedNDToCubeGeometrySubview(subview_size), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeGeometryDestination(destination_size), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           subview_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    assert !BundleSharedTMOVSharedNDToCubeSchemaLegal();
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    var cube_allocated = FALSE;
    for tile = 0 to 63 do
        if _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 then
            cube_allocated = TRUE;
        end;
    end;
    let source_after = SharedTileRecord(shared_id);
    assert _LastFault == Fault_TileLegality;
    assert !cube_allocated;
    assert source_after.payload_live == source_before.payload_live &&
           source_after.published == source_before.published &&
           source_after.payload_generation == source_before.payload_generation;
    assert stop_status == CommandExecution_Rejected;
    return TRUE;
end;

func main() => integer
begin
    // A 256-byte physical U64 row makes offset_units=1 a legal 128-byte
    // generic subview offset but an illegal half-row origin for ND-to-CUBE.
    let partial_row = SharedNDToCubeGeometryRejects(TileDataType_U64,
        64, 32, 64, 16384, Zeros{4} + 7, Zeros{4} + 7, 1, 32, 32);
    assert partial_row;
    // A complete 32-row range beginning at row one exceeds this parent.
    let parent_overflow = SharedNDToCubeGeometryRejects(TileDataType_U64,
        32, 32, 32, 8192, Zeros{4} + 7, Zeros{4} + 7, 2, 32, 32);
    assert parent_overflow;
    // Physical rows fit, but this range begins exactly at the valid tail.
    let no_valid_rows = SharedNDToCubeGeometryRejects(TileDataType_U64,
        64, 32, 32, 16384, Zeros{4} + 7, Zeros{4} + 7, 64, 32, 32);
    assert no_valid_rows;
    // Four KiB selects only 16 complete rows from a 256-byte row stride.
    let wrong_row_count = SharedNDToCubeGeometryRejects(TileDataType_U64,
        64, 32, 64, 16384, Zeros{4} + 6, Zeros{4} + 6, 0, 32, 32);
    assert wrong_row_count;
    // The B.SUBVIEW byte range must match the new Local destination capacity.
    let capacity_mismatch = SharedNDToCubeGeometryRejects(
        TileDataType_U64, 64, 32, 64, 16384, Zeros{4} + 7,
        Zeros{4} + 6, 0, 32, 32);
    assert capacity_mismatch;
    // A contiguous 4 KiB prefix cannot stand for 128 columns in every row
    // of a 32x256 RowMajor parent.
    let noncontiguous_columns = SharedNDToCubeGeometryRejects(
        TileDataType_U8, 32, 256, 32, 8192, Zeros{4} + 6,
        Zeros{4} + 6, 0, 256, 128);
    assert noncontiguous_columns;
    return 0;
end;
