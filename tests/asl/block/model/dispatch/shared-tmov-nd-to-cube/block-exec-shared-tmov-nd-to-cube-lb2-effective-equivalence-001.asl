// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-LB2-EFFECTIVE-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-BSTART-TMOV-SHARED-001","PTO-BUNDLE-DIMENSION-DEFAULT-001"],"kind":"execution","summary":"omitted LB2, explicit one, and explicit capacity-derived columns produce equivalent reverse TMOV outputs","pass_condition":"decoded ND2M32/U8, ND2M16/U16, and ND2M32/FP64 singleton bundles accept LB2 omission, explicit 1, and explicit exact CUBE columns and produce identical descriptors, valid definedness, raw logical payload, and source lifetime; the FP64 M32 Cphys=1 tuple covers sentinel/result equality","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/schema/dimensions.asl","asl/tile/model/memory/shared-nd-to-cube.asl"]}

pure func SharedNDToCubeLB2Start(carrier: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = carrier;
    return instruction;
end;

pure func SharedNDToCubeLB2DATR(layout: integer {21,22}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5} + layout;
    return instruction;
end;

pure func SharedNDToCubeLB2Shared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeLB2Destination(size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeLB2Dimension(lb: integer {0..2},
    value: integer {0..4095}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000043;
    if lb == 1 then instruction = Zeros{64} + 0x00001043;
    elsif lb == 2 then instruction = Zeros{64} + 0x00002043; end;
    instruction[31:20] = Zeros{12} + value;
    return instruction;
end;

pure func SharedNDToCubeLB2CompressedDimension(lb: bits(2),
    value: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x003c;
    instruction[15:14] = lb;
    instruction[13:6] = value;
    return instruction;
end;

pure func SharedNDToCubeLB2Golden(data_type: TileDataType,
    row: integer {0..31}, column: integer {0..127}) => Word
begin
    if data_type == TileDataType_U8 then
        return Zeros{PTO_XLEN} +
            ((1 + row * 71 + column * 29 + ((row * column) MOD 113)) MOD 256);
    elsif data_type == TileDataType_U16 then
        return Zeros{PTO_XLEN} +
            ((0x8051 + row * 193 + column * 37 +
                ((row * column) MOD 251)) MOD 65536);
    end;
    return Zeros{PTO_XLEN} + 0x8123456789abcdef +
        row * 0x100010001 + column * 0x10101;
end;

func RunSharedNDToCubeLB2Case(selector: integer {21,22},
    source_type: TileDataType, carrier_type: TileDataType,
    rows: integer {16,32}, columns: integer {1..128},
    capacity_bytes: integer {256,2048,4096},
    destination_size: bits(4), lb2_mode: integer {0..3}) => TileInfo
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x380);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x380);
    ConfigureTileForMask(10, capacity_bytes, rows, columns, rows,
        columns, source_type, TileLayout_RowMajor, '1000');
    for row = 0 to rows - 1 looplimit 32 do
        for column = 0 to columns - 1 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeLB2Golden(source_type,
                    row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 43) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    let shared_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeLB2Start(
            TileDataTypeToEncoding(carrier_type)), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeLB2DATR(selector), 32);
    let lb0_status = ExecuteCommandInstruction(
        SharedNDToCubeLB2Dimension(0, columns), 32);
    let lb1_status = ExecuteCommandInstruction(
        SharedNDToCubeLB2Dimension(1, rows), 32);
    assert lb0_status == CommandExecution_Executed &&
           lb1_status == CommandExecution_Executed;
    if lb2_mode == 1 then
        let lb2_status = ExecuteCommandInstruction(
            SharedNDToCubeLB2Dimension(2, 1), 32);
        assert lb2_status == CommandExecution_Executed;
    elsif lb2_mode == 2 then
        let lb2_status = ExecuteCommandInstruction(
            SharedNDToCubeLB2Dimension(2, columns), 32);
        assert lb2_status == CommandExecution_Executed;
    elsif lb2_mode == 3 then
        let lb2_status = ExecuteCommandInstruction(
            SharedNDToCubeLB2CompressedDimension('10',
                (Zeros{8} + columns) as bits(8)), 16);
        assert lb2_status == CommandExecution_Executed;
    end;
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeLB2Shared(shared_id as bits(6)), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeLB2Destination(destination_size), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed &&
           BundleSharedTMOVSharedNDToCubeSelected();
    StartMemoryEventCapture(0);
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    StopMemoryEventCapture();
    assert stop_status == CommandExecution_Executed &&
           _LastFault == Fault_None && !_BundleActive &&
           _MemoryEventCount == 0;

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
           result.contents_defined &&
           result.defined_valid_elements == rows * columns;
    for row = 0 to rows - 1 looplimit 32 do
        for column = 0 to columns - 1 looplimit 128 do
            let element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            assert TileLogicalElementDefined(result, element) &&
                   TileReadLogicalElement(result, element) ==
                       SharedNDToCubeLB2Golden(source_type,
                           row as integer {0..31},
                           column as integer {0..127});
        end;
    end;
    let shared_after = SharedTileRecord(shared_id);
    assert shared_after.payload_generation ==
               shared_before.payload_generation &&
           shared_after.payload_live == shared_before.payload_live &&
           shared_after.published == shared_before.published;
    return result;
end;

readonly func SharedNDToCubeLB2OutputsEqual(left: TileInfo, right: TileInfo,
    rows: integer {16,32}, columns: integer {1..128}) => boolean
begin
    if left.capacity_bytes != right.capacity_bytes ||
       left.rows != right.rows || left.columns != right.columns ||
       left.valid_rows != right.valid_rows ||
       left.valid_columns != right.valid_columns ||
       left.data_type != right.data_type || left.layout != right.layout ||
       left.contents_defined != right.contents_defined ||
       left.defined_valid_elements != right.defined_valid_elements then
        return FALSE;
    end;
    for row = 0 to rows - 1 looplimit 32 do
        for column = 0 to columns - 1 looplimit 128 do
            let left_element = TileLogicalLinearIndex(left,
                row as integer {0..65535},
                column as integer {0..65535});
            let right_element = TileLogicalLinearIndex(right,
                row as integer {0..65535},
                column as integer {0..65535});
            if TileLogicalElementDefined(left, left_element) !=
                   TileLogicalElementDefined(right, right_element) ||
               TileReadLogicalElement(left, left_element) !=
                   TileReadLogicalElement(right, right_element) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

func main() => integer
begin
    let m32_omit = RunSharedNDToCubeLB2Case(21,
        TileDataType_U8, TileDataType_S8, 32, 128, 4096,
        Zeros{4} + 6, 0);
    let m32_one = RunSharedNDToCubeLB2Case(21,
        TileDataType_U8, TileDataType_S8, 32, 128, 4096,
        Zeros{4} + 6, 1);
    let m32_exact = RunSharedNDToCubeLB2Case(21,
        TileDataType_U8, TileDataType_S8, 32, 128, 4096,
        Zeros{4} + 6, 2);
    let m32_compressed_exact = RunSharedNDToCubeLB2Case(21,
        TileDataType_U8, TileDataType_S8, 32, 128, 4096,
        Zeros{4} + 6, 3);
    assert SharedNDToCubeLB2OutputsEqual(m32_omit, m32_one, 32, 128) &&
           SharedNDToCubeLB2OutputsEqual(m32_omit, m32_exact, 32, 128) &&
           SharedNDToCubeLB2OutputsEqual(m32_omit, m32_compressed_exact,
               32, 128);

    let m16_omit = RunSharedNDToCubeLB2Case(22,
        TileDataType_U16, TileDataType_S16, 16, 64, 2048,
        Zeros{4} + 5, 0);
    let m16_one = RunSharedNDToCubeLB2Case(22,
        TileDataType_U16, TileDataType_S16, 16, 64, 2048,
        Zeros{4} + 5, 1);
    let m16_exact = RunSharedNDToCubeLB2Case(22,
        TileDataType_U16, TileDataType_S16, 16, 64, 2048,
        Zeros{4} + 5, 2);
    assert SharedNDToCubeLB2OutputsEqual(m16_omit, m16_one, 16, 64) &&
           SharedNDToCubeLB2OutputsEqual(m16_omit, m16_exact, 16, 64);

    let b64_omit = RunSharedNDToCubeLB2Case(21,
        TileDataType_FP64, TileDataType_FP64, 32, 1, 256,
        Zeros{4} + 2, 0);
    let b64_one = RunSharedNDToCubeLB2Case(21,
        TileDataType_FP64, TileDataType_FP64, 32, 1, 256,
        Zeros{4} + 2, 1);
    let b64_exact = RunSharedNDToCubeLB2Case(21,
        TileDataType_FP64, TileDataType_FP64, 32, 1, 256,
        Zeros{4} + 2, 2);
    assert SharedNDToCubeLB2OutputsEqual(b64_omit, b64_one, 32, 1) &&
           SharedNDToCubeLB2OutputsEqual(b64_omit, b64_exact, 32, 1);
    return 0;
end;
