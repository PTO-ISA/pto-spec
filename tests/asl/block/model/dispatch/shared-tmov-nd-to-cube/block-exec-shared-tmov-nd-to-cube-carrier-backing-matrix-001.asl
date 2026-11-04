// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-CARRIER-BACKING-MATRIX-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-CUBE-CELL-TRANSPORT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"reverse TMOV preserves legal source backing across compatible operation carriers","pass_condition":"decoded M16 S32 backing with FP32 carrier and M32 E6M2 backing with source-only RCPE6M2 carrier both commit exact CUBE descriptors retaining source dtype and all nonuniform raw values","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/tile/model/legality/dtype-layout.asl","asl/tile/model/memory/shared-nd-to-cube.asl"]}

pure func SharedNDToCubeCarrierStart(carrier: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = carrier;
    return instruction;
end;

pure func SharedNDToCubeCarrierDATR(selector: integer {21,22})
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + selector;
    return instruction;
end;

pure func SharedNDToCubeCarrierShared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeCarrierDestination(size_code: bits(4))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeCarrierGolden(data_type: TileDataType,
    row: integer {0..31}, column: integer {0..127}) => Word
begin
    if data_type == TileDataType_S32 then
        return Zeros{PTO_XLEN} + 0x80000001 + row * 65537 +
            column * 257 + ((row * column) MOD 251);
    end;
    return Zeros{PTO_XLEN} +
        ((0x81 + row * 47 + column * 19 +
            ((row * column) MOD 61)) MOD 256);
end;

func RunSharedNDToCubeCarrierCase(selector: integer {21,22},
    source_type: TileDataType, carrier_type: TileDataType,
    rows: integer {16,32}, columns: integer {16,64,128},
    capacity_bytes: integer {512,1024,2048,4096},
    destination_size: bits(4), shared_id: SharedTileID) => TileInfo
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x500);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    ConfigureTileForMask(10, capacity_bytes, rows, columns, rows,
        columns, source_type, TileLayout_RowMajor, '1000');
    for row = 0 to rows - 1 looplimit 32 do
        for column = 0 to columns - 1 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeCarrierGolden(source_type,
                    row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    assert SharedTilePublished(shared_id);
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeCarrierStart(
            TileDataTypeToEncoding(carrier_type)), 32);
    assert start_status == CommandExecution_Executed &&
           BundleTMOVSelected();
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeCarrierDATR(selector), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + rows);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeCarrierShared(shared_id as bits(6)), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeCarrierDestination(destination_size), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    assert BundleSharedTMOVSharedNDToCubeSelected() &&
           BundleSharedTMOVSharedNDToCubeSchemaLegal();
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None;
    var destination = 0 as TileIndex;
    var found = FALSE;
    let layout = if selector == 21 then TileLayout_CUBE_M32
        else TileLayout_CUBE_M16;
    for tile = 0 to 63 do
        if !found && _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == layout &&
           _Tiles[[tile]].capacity_bytes == capacity_bytes then
            destination = tile as TileIndex;
            found = TRUE;
        end;
    end;
    assert found;
    let result = _Tiles[[destination]];
    assert result.rows == rows && result.columns == columns &&
           result.valid_rows == rows && result.valid_columns == columns &&
           result.data_type == source_type && result.layout == layout &&
           result.contents_defined;
    for row = 0 to rows - 1 looplimit 32 do
        for column = 0 to columns - 1 looplimit 128 do
            assert ReadTileElement(destination,
                       row as integer {0..65535},
                       column as integer {0..65535}) ==
                       SharedNDToCubeCarrierGolden(source_type,
                           row as integer {0..31},
                           column as integer {0..127});
        end;
    end;
    return result;
end;

func main() => integer
begin
    let s32_output = RunSharedNDToCubeCarrierCase(22,
        TileDataType_S32, TileDataType_FP32, 16, 16, 1024,
        Zeros{4} + 4, (Zeros{6} + 46) as SharedTileID);
    assert s32_output.data_type == TileDataType_S32 &&
           s32_output.layout == TileLayout_CUBE_M16;
    let e6m2_output = RunSharedNDToCubeCarrierCase(21,
        TileDataType_E6M2, TileDataType_RCPE6M2, 32, 128, 4096,
        Zeros{4} + 6, (Zeros{6} + 47) as SharedTileID);
    assert e6m2_output.data_type == TileDataType_E6M2 &&
           e6m2_output.layout == TileLayout_CUBE_M32;
    let e4m3_output = RunSharedNDToCubeCarrierCase(21,
        TileDataType_E4M3, TileDataType_E4M3, 32, 128, 4096,
        Zeros{4} + 6, (Zeros{6} + 48) as SharedTileID);
    assert e4m3_output.data_type == TileDataType_E4M3 &&
           e4m3_output.layout == TileLayout_CUBE_M32;
    let e5m2_output = RunSharedNDToCubeCarrierCase(22,
        TileDataType_E5M2, TileDataType_E5M2, 16, 64, 1024,
        Zeros{4} + 4, (Zeros{6} + 49) as SharedTileID);
    assert e5m2_output.data_type == TileDataType_E5M2 &&
           e5m2_output.layout == TileLayout_CUBE_M16;
    return 0;
end;
