// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-TYPE-MATRIX-005","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-TMOV-CUBE-TO-SHARED-ND-001","PTO-BSTART-TMOV-SHARED-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Shared CUBE-to-ND preserves backing types, carrier interpretation, packed rows, and M32 b64 words","pass_condition":"Encoded singleton conversions cover DTYPE_NONE fallback, U16/FP16 carrier reinterpretation, FP16/BF16/FP32, same-type packed U4X2 odd row tails, M32 FP64 low/high CELL pairs, E6M2/RCPE6M2 source-only interpretation, and M32 U8 capacity-derived physical columns; every valid output raw element matches its independent coordinate formula and destination backing type remains the source type","related_sources":["asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","asl/block/model/dispatch/tile-schema.asl","asl/tile/model/memory/shared-cube-to-nd.asl","asl/tile/model/shape/cube-double-cell.asl"]}

pure func SharedCubeToNDTypeStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func SharedCubeToNDTypeDATR(layout: integer {24,25}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + layout;
    return instruction;
end;

pure func SharedCubeToNDTypeShared(shared_id: bits(6),
    size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = '100';
    return instruction;
end;

pure func SharedCubeToNDTypeSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '100';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedCubeToNDTypeGolden(row: integer {0..31},
    column: integer {0..127}, data_type: TileDataType) => Word
begin
    let value = 1 + (row * 17 + column * 3 + row * column) MOD 251;
    if data_type == TileDataType_U4X2 then
        return Zeros{PTO_XLEN} + (value MOD 16);
    elsif data_type == TileDataType_E6M2 ||
          data_type == TileDataType_RCPE6M2 then
        return Zeros{PTO_XLEN} + (value MOD 255);
    elsif data_type == TileDataType_FP64 then
        return Zeros{PTO_XLEN} + 0x1234567800000000 + value;
    elsif TileElementBits(data_type) == 16 then
        return Zeros{PTO_XLEN} + 0x5100 + value;
    elsif TileElementBits(data_type) == 32 then
        return Zeros{PTO_XLEN} + 0x51000000 + value;
    end;
    return Zeros{PTO_XLEN} + 0x51 + value;
end;

func RunSharedCubeToNDTypeCase(layout: TileLayout,
    capacity_bytes: integer {128..4096}, size_code: integer {1..6},
    rows: integer {16,32}, valid_columns: integer {1..128},
    backing_type: TileDataType, operation_type: bits(5),
    shared_id: SharedTileID)
begin
    let configured = ConfigureCubeTileForMask(0, capacity_bytes, rows,
        valid_columns, backing_type, layout, '0001');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    for row = 0 to rows - 1 looplimit 65536 do
        for column = 0 to valid_columns - 1 looplimit 65536 do
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535},
                SharedCubeToNDTypeGolden(
                    row as integer {0..31},
                    column as integer {0..127}, backing_type));
        end;
    end;
    assert TileCubeDescriptorLegal(_Tiles[[0]]) &&
           _Tiles[[0]].capacity_bytes == capacity_bytes &&
           _Tiles[[0]].columns ==
               TileCubePhysicalColumnsFromCapacity(capacity_bytes,
                   layout, backing_type) &&
           _Tiles[[0]].contents_defined;

    let start_status = ExecuteCommandInstruction(
        SharedCubeToNDTypeStart(operation_type), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedCubeToNDTypeDATR(
            if layout == TileLayout_CUBE_M32 then 24 else 25), 32);
    let shared_status = ExecuteCommandInstruction(
        SharedCubeToNDTypeShared(shared_id as bits(6),
            (Zeros{4} + size_code) as bits(4)), 32);
    let source_status = ExecuteCommandInstruction(
        SharedCubeToNDTypeSource(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           source_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None && SharedTilePublished(shared_id);

    let converted = SharedTileRecord(shared_id).tile;
    let physical_columns = TileCubePhysicalColumnsFromCapacity(
        capacity_bytes, layout, backing_type);
    assert converted.layout == TileLayout_RowMajor &&
           converted.data_type == backing_type &&
           converted.capacity_bytes == capacity_bytes &&
           converted.rows == rows && converted.columns == physical_columns &&
           converted.valid_rows == rows &&
           converted.valid_columns == valid_columns;
    for row = 0 to rows - 1 looplimit 65536 do
        for column = 0 to valid_columns - 1 looplimit 65536 do
            let index = TileLogicalLinearIndex(converted,
                row as integer {0..65535},
                column as integer {0..65535});
            assert TileLogicalElementDefined(converted, index) &&
                TileReadLogicalElement(converted, index) ==
                    SharedCubeToNDTypeGolden(
                        row as integer {0..31},
                        column as integer {0..127}, backing_type);
        end;
    end;
    if valid_columns < physical_columns then
        let padding = TileLogicalLinearIndex(converted, 0,
            valid_columns as integer {0..65535});
        assert !TileLogicalElementDefined(converted, padding);
    end;
end;

func RunSharedCubeToNDNormalCarrier()
begin
    ConfigureTileForMask(0, 128, 2, 2, 2, 2,
        TileDataType_U16, TileLayout_RowMajor, '0001');
    InstallRelativeTileFixture(0, 0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x1234);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x5678);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0x9abc);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 0xdef0);
    let start_status = ExecuteCommandInstruction(
        SharedCubeToNDTypeStart(Zeros{5} + 4), 32);
    let shared_status = ExecuteCommandInstruction(
        SharedCubeToNDTypeShared((Zeros{6} + 46) as bits(6),
            Zeros{4} + 1), 32);
    let source_status = ExecuteCommandInstruction(
        SharedCubeToNDTypeSource(), 32);
    assert start_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           source_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None &&
           SharedTilePublished((Zeros{6} + 46) as SharedTileID);
    let copied = SharedTileRecord((Zeros{6} + 46) as SharedTileID).tile;
    assert copied.data_type == TileDataType_U16 &&
           copied.layout == TileLayout_RowMajor &&
           copied.capacity_bytes == 128 &&
           TileReadLogicalElement(copied, 0) == Zeros{PTO_XLEN} + 0x1234 &&
           TileReadLogicalElement(copied, 1) == Zeros{PTO_XLEN} + 0x5678 &&
           TileReadLogicalElement(copied, 2) == Zeros{PTO_XLEN} + 0x9abc &&
           TileReadLogicalElement(copied, 3) == Zeros{PTO_XLEN} + 0xdef0;
end;

func main() => integer
begin
    ResetProfileState();
    RunSharedCubeToNDTypeCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 31, (Zeros{6} + 42) as SharedTileID);
    ResetProfileState();
    RunSharedCubeToNDTypeCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_U16, Zeros{5} + 4, (Zeros{6} + 43) as SharedTileID);
    ResetProfileState();
    RunSharedCubeToNDTypeCase(TileLayout_CUBE_M16, 512, 3, 16, 16,
        TileDataType_BF16, Zeros{5} + 5, (Zeros{6} + 44) as SharedTileID);
    ResetProfileState();
    RunSharedCubeToNDTypeCase(TileLayout_CUBE_M16, 1024, 4, 16, 16,
        TileDataType_FP32, Zeros{5} + 1, (Zeros{6} + 45) as SharedTileID);
    ResetProfileState();
    RunSharedCubeToNDTypeCase(TileLayout_CUBE_M16, 128, 1, 16, 13,
        TileDataType_U4X2, Zeros{5} + 28, (Zeros{6} + 47) as SharedTileID);
    ResetProfileState();
    RunSharedCubeToNDTypeCase(TileLayout_CUBE_M32, 4096, 6, 32, 13,
        TileDataType_FP64, Zeros{5}, (Zeros{6} + 48) as SharedTileID);
    ResetProfileState();
    RunSharedCubeToNDTypeCase(TileLayout_CUBE_M16, 256, 2, 16, 16,
        TileDataType_E6M2, Zeros{5} + 15, (Zeros{6} + 49) as SharedTileID);
    ResetProfileState();
    RunSharedCubeToNDTypeCase(TileLayout_CUBE_M16, 256, 2, 16, 16,
        TileDataType_E6M2, Zeros{5} + 21, (Zeros{6} + 50) as SharedTileID);
    ResetProfileState();
    RunSharedCubeToNDTypeCase(TileLayout_CUBE_M32, 512, 3, 32, 12,
        TileDataType_U8, Zeros{5} + 27, (Zeros{6} + 51) as SharedTileID);
    ResetProfileState();
    RunSharedCubeToNDNormalCarrier();
    return 0;
end;
