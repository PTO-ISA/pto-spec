// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-TYPE-SHAPE-006","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-TMOV-CUBE-TO-SHARED-ND-001","PTO-BSTART-TMOV-SHARED-001","PTO-B-DATR-FIELDS-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"Invalid CUBE-to-ND type, DATR, backing geometry, and writer extents fault before Shared publication","pass_condition":"Function-2 M322ND/M162ND rejects non-source-only RCPE6M2, persistent RCPE6M2, width mismatch, concrete and zero DATR types, nonzero numeric attributes, under-capacity physical columns, M16 b64, and WriterSizeCode/capacity mismatch with no Shared publication or GM events","related_sources":["asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/shape/cube-cell.asl"]}

pure func SharedCubeToNDRejectStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func SharedCubeToNDRejectDATR(layout: integer {24,25},
    data_type: bits(5), control: integer {0..7}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = data_type;
    instruction[11:7] = Zeros{5} + layout;
    if control == 1 then
        instruction[17:15] = Zeros{3} + 1;
    elsif control == 2 then
        instruction[28:27] = Zeros{2} + 1;
    elsif control == 3 then
        instruction[31:29] = Zeros{3} + 1;
    elsif control == 4 then
        instruction[26] = '1';
    elsif control == 5 then
        instruction[25] = '1';
    elsif control == 6 then
        instruction[14] = '1';
    elsif control == 7 then
        instruction[13] = '1';
    end;
    return instruction;
end;

pure func SharedCubeToNDRejectShared(shared_id: bits(6),
    size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = '100';
    return instruction;
end;

pure func SharedCubeToNDRejectSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '100';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedCubeToNDRejectAssemble(writer_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = writer_size;
    return instruction;
end;

pure func SharedCubeToNDRejectGPRMask() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[31:27] = Zeros{5} + 2;
    instruction[26] = '1';
    return instruction;
end;

func RunRejectedSharedCubeToNDCase(layout: TileLayout,
    source_capacity: integer {128..4096},
    parent_size_code: integer {1..6}, rows: integer {16,32},
    valid_columns: integer {1..32}, backing_type: TileDataType,
    start_type: bits(5), datr_type: bits(5), control: integer {0..7},
    invalid_columns: integer {0..32}, assembled_writer_size: integer {0..6},
    shared_id: SharedTileID)
begin
    ResetProfileState();
    let layout_code = if layout == TileLayout_CUBE_M32 then 24 else 25;
    let configured_type = if layout == TileLayout_CUBE_M16 &&
        backing_type == TileDataType_FP64 then TileDataType_U8
        else backing_type;
    let configured = ConfigureCubeTileForMask(0, source_capacity, rows,
        valid_columns, configured_type, layout, '0001');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    for row = 0 to rows - 1 looplimit 65536 do
        for column = 0 to valid_columns - 1 looplimit 65536 do
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + 1 + row * 3 + column);
        end;
    end;
    if layout == TileLayout_CUBE_M16 &&
       backing_type == TileDataType_FP64 then
        var b64_m16 = _Tiles[[0]];
        b64_m16.data_type = TileDataType_FP64;
        b64_m16.columns = 4;
        _Tiles[[0]] = b64_m16;
    end;
    if invalid_columns != 0 then
        var malformed = _Tiles[[0]];
        malformed.columns = invalid_columns as integer {1..65535};
        _Tiles[[0]] = malformed;
    end;
    let original_capacity = _Tiles[[0]].capacity_bytes;
    let original_type = _Tiles[[0]].data_type;
    StartMemoryEventCapture(0);
    let start_status = ExecuteCommandInstruction(
        SharedCubeToNDRejectStart(start_type), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedCubeToNDRejectDATR(layout_code, datr_type, control), 32);
    let shared_status = ExecuteCommandInstruction(
        SharedCubeToNDRejectShared(shared_id as bits(6),
            (Zeros{4} + parent_size_code) as bits(4)), 32);
    if assembled_writer_size != 0 then
        let assemble_status = ExecuteCommandInstruction(
            SharedCubeToNDRejectAssemble(
                (Zeros{4} + assembled_writer_size) as bits(4)), 32);
        assert assemble_status == CommandExecution_Executed;
    end;
    let source_status = ExecuteCommandInstruction(
        SharedCubeToNDRejectSource(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           source_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    StopMemoryEventCapture();
    assert _LastFault == Fault_TileLegality &&
           !SharedTilePublished(shared_id) &&
           _Tiles[[0]].capacity_bytes == original_capacity &&
           _Tiles[[0]].data_type == original_type && _MemoryEventCount == 0;
end;

func RunSharedCubeToNDMaskReject()
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMask(0, 512, 32, 12,
        TileDataType_U8, TileLayout_CUBE_M32, '0001');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    for row = 0 to 31 do
        for column = 0 to 11 do
            WriteTileElement(0, row, column,
                Zeros{PTO_XLEN} + 1 + row * 3 + column);
        end;
    end;
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(
        SharedCubeToNDRejectStart(Zeros{5} + 27), 32);
    let attributes = ExecuteCommandInstruction(
        SharedCubeToNDRejectDATR(24, Zeros{5} + 31, 0), 32);
    let mask = ExecuteCommandInstruction(SharedCubeToNDRejectGPRMask(), 32);
    let shared = ExecuteCommandInstruction(SharedCubeToNDRejectShared(
        (Zeros{6} + 55) as bits(6), Zeros{4} + 3), 32);
    let source = ExecuteCommandInstruction(SharedCubeToNDRejectSource(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           mask == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           source == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    StopMemoryEventCapture();
    assert _LastFault == Fault_TileLegality &&
           !SharedTilePublished((Zeros{6} + 55) as SharedTileID) &&
           _MemoryEventCount == 0;
end;

func main() => integer
begin
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M32, 512, 3, 32, 12,
        TileDataType_U8, Zeros{5} + 21, Zeros{5} + 31, 0, 0, 0,
        (Zeros{6} + 42) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 256, 2, 16, 16,
        TileDataType_RCPE6M2, Zeros{5} + 21, Zeros{5} + 31, 0, 0, 0,
        (Zeros{6} + 43) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 1, Zeros{5} + 31, 0, 0, 0,
        (Zeros{6} + 44) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, Zeros{5}, 0, 0, 0,
        (Zeros{6} + 45) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, Zeros{5} + 4, 0, 0, 0,
        (Zeros{6} + 46) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, Zeros{5} + 31, 1, 0, 0,
        (Zeros{6} + 47) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M32, 512, 3, 32, 12,
        TileDataType_U8, Zeros{5} + 27, Zeros{5} + 31, 0, 12, 0,
        (Zeros{6} + 48) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 256, 2, 16, 12,
        TileDataType_U8, Zeros{5} + 27, Zeros{5} + 31, 0, 12, 0,
        (Zeros{6} + 49) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_FP64, Zeros{5}, Zeros{5} + 31, 0, 0, 0,
        (Zeros{6} + 50) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M32, 512, 3, 32, 12,
        TileDataType_U8, Zeros{5} + 27, Zeros{5} + 31, 0, 0, 2,
        (Zeros{6} + 51) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, Zeros{5} + 31, 2, 0, 0,
        (Zeros{6} + 52) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, Zeros{5} + 31, 3, 0, 0,
        (Zeros{6} + 53) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, Zeros{5} + 31, 4, 0, 0,
        (Zeros{6} + 54) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, Zeros{5} + 31, 5, 0, 0,
        (Zeros{6} + 55) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, Zeros{5} + 31, 6, 0, 0,
        (Zeros{6} + 56) as SharedTileID);
    RunRejectedSharedCubeToNDCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, Zeros{5} + 31, 7, 0, 0,
        (Zeros{6} + 57) as SharedTileID);
    RunSharedCubeToNDMaskReject();
    return 0;
end;
