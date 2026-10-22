// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-LOCAL-GENERATION-RANGED-PAYLOAD-010","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-B-SUBVIEW-RANGE-001","PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"execution","summary":"Encoded M32/U8 Local TLOAD writers update only their explicit CELL ranges and ranged TSTORE consumers observe the published prefix","pass_condition":"Distinct 256-byte and 128-byte TLOAD writer payloads at CELL offsets 0 and 2 publish valid 32x12 in a 512-byte physical 32x16 parent; encoded CUBE TSTORE source subviews observe the eight-column and four-column published ranges, preserve the first range, and leave the final CELL undefined","related_sources":["asl/block/model/operands/local-generation.asl","asl/block/model/operands/local-generation-cube.asl","asl/block/model/operands/subview-descriptor.asl","asl/block/operands/B.SUBVIEW.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/tile/model/memory/load-store.asl"]}

pure func RangedTLOADStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func RangedTLOADAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func RangedTLOADParentDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 3;
    instruction[19] = '1';
    instruction[8:7] = '00';
    instruction[11:9] = '111';
    return instruction;
end;

pure func RangedTLOADIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

pure func RangedAssemble(init: boolean, last: boolean,
    writer_size: integer {1,2}, offset: integer {0,2}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + writer_size;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;

pure func RangedTLOADParentRef() => bits(64)
begin
    return Zeros{64} + 0x00085e13;
end;

pure func RangedTSTOREStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func RangedTSTOREAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 24;
    return instruction;
end;

pure func RangedTSTORESource() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '100';
    instruction[19] = '1';
    return instruction;
end;

pure func RangedTSTORESubview(offset: integer {0..2},
    size_code: integer {1,2}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[30:20] = Zeros{11} + offset;
    instruction[11:7] = Zeros{5} + size_code;
    return instruction;
end;

pure func RangedTSTOREIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunRangedTSTORE(offset: integer {0,2},
    size_code: integer {1,2}, columns: integer {4,8},
    destination_column: integer {0,8}, continuation: integer)
begin
    WriteGPR(2, Zeros{PTO_XLEN} + 0xa00 + destination_column);
    WriteGPR(3, Zeros{PTO_XLEN} + 12);
    let start = ExecuteCommandInstruction(RangedTSTOREStart(), 32);
    let attributes = ExecuteCommandInstruction(
        RangedTSTOREAttributes(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let source = ExecuteCommandInstruction(RangedTSTORESource(), 32);
    let subview = ExecuteCommandInstruction(
        RangedTSTORESubview(offset, size_code), 32);
    let ior = ExecuteCommandInstruction(RangedTSTOREIOR(), 32);
    assert start == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert source == CommandExecution_Executed;
    assert subview == CommandExecution_Executed;
    assert ior == CommandExecution_Executed;
    let stored = CompleteBundleAt(Zeros{PTO_XLEN} + continuation);
    assert stored && _LastFault == Fault_None;
end;

func RunRangedTLOADWriter(base: integer, stride: integer,
    valid_columns: integer {4,8}, rows: integer {32},
    init: boolean, last: boolean, writer_size: integer {1,2},
    offset: integer {0,2}, producer_pc: integer)
begin
    WriteGPR(2, Zeros{PTO_XLEN} + base);
    WriteGPR(3, Zeros{PTO_XLEN} + stride);
    let start_form = DecodeCommandForm(RangedTLOADStart(), 32);
    assert start_form != PTO_COMMAND_FORM_COUNT;
    let start_descriptor = DecodeBundleOperationDescriptor(RangedTLOADStart(),
        start_form as integer {0..PTO_COMMAND_FORM_COUNT-1});
    assert BundleOperationDescriptorLegal(start_descriptor);
    assert !start_descriptor.branch_type_valid;
    assert CommandBundleTransferOfForm(
        start_form as integer {0..PTO_COMMAND_FORM_COUNT-1}) ==
            BundleTransfer_Fallthrough;
    assert !CommandHasSignedOffset(
        start_form as integer {0..PTO_COMMAND_FORM_COUNT-1});
    let started = ExecuteCommandInstruction(RangedTLOADStart(), 32);
    assert started == CommandExecution_Executed;
    let attributed = ExecuteCommandInstruction(
        RangedTLOADAttributes(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + rows);
    let ior = ExecuteCommandInstruction(RangedTLOADIOR(), 32);
    var destination_status = CommandExecution_Executed;
    if init then
        destination_status = ExecuteCommandInstruction(
            RangedTLOADParentDestination(), 32);
    else
        destination_status = ExecuteCommandInstruction(
            RangedTLOADParentRef(), 32);
    end;
    let assembled = ExecuteCommandInstruction(RangedAssemble(
        init, last, writer_size, offset), 32);
    assert attributed == CommandExecution_Executed;
    assert destination_status == CommandExecution_Executed;
    assert ior == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + producer_pc);
    assert _LastFault == Fault_None;
    assert completed;
    let slot = BundleLocalGenerationSlot(0, '1111');
    let writer = (_LocalGenerations[[slot]].writer_count - 1)
        as integer {0..15};
    let ready = CompleteBundleLocalGenerationWriterEvent(
        slot, _BundleExecutionDomainToken, offset,
        TileSizeCodeBytes(writer_size) DIVRM PTO_TILE_CELL_BYTES);
    assert ready && _LocalGenerations[[slot]].writers[[writer]].ready;
end;

func main() => integer
begin
    ResetProfileState();
    let first_base = Zeros{PTO_XLEN} + 0x400;
    let second_base = Zeros{PTO_XLEN} + 0x800;
    for index = 0 to 255 looplimit 256 do
        Store(first_base + index, 1, Zeros{PTO_XLEN} + 0x31);
    end;
    for index = 0 to 255 looplimit 256 do
        Store(second_base + index, 1, Zeros{PTO_XLEN} + 0x72);
    end;

    RunRangedTLOADWriter(1024, 8, 8, 32,
        TRUE, FALSE, 2, 0, 0x100);
    RunRangedTLOADWriter(2048, 8, 4, 32,
        FALSE, TRUE, 1, 2, 0x200);
    let slot = BundleLocalGenerationSlot(0, '1111');
    let parent = _LocalGenerations[[slot]].working_destination;
    assert parent == 0 && _Tiles[[parent]].capacity_bytes == 512 &&
           _Tiles[[parent]].rows == 32 && _Tiles[[parent]].columns == 16;
    assert _LocalGenerations[[slot]].published &&
           _Tiles[[parent]].valid_rows == 32 &&
           _Tiles[[parent]].valid_columns == 12 &&
           _Tiles[[parent]].cube_storage_bytes == 512 &&
           _Tiles[[parent]].contents_defined;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 7 looplimit 8 do
            assert ReadTileElement(parent, row as integer {0..31},
                       column as integer {0..7}) == Zeros{PTO_XLEN} + 0x31 &&
                   TileElementDefined(parent, row as integer {0..31},
                       column as integer {0..7});
        end;
        for column = 8 to 11 looplimit 4 do
            assert ReadTileElement(parent, row as integer {0..31},
                       column as integer {8..11}) == Zeros{PTO_XLEN} + 0x72;
            assert TileElementDefined(parent, row as integer {0..31},
                column as integer {8..11});
        end;
    end;
    assert !TileElementDefined(parent, 0, 12) &&
           !TileElementDefined(parent, 31, 15);

    RunRangedTSTORE(0, 2, 8, 0, 0x300);
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 7 looplimit 8 do
            let observed_first = LoadUnsigned(Zeros{PTO_XLEN} + 0xa00 +
                row * 12 + column, 1);
            assert observed_first == Zeros{PTO_XLEN} + 0x31;
        end;
    end;
    assert _LocalGenerations[[slot]].published;
    RunRangedTSTORE(2, 1, 4, 8, 0x400);
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 3 looplimit 4 do
            let observed_second = LoadUnsigned(Zeros{PTO_XLEN} + 0xa00 +
                row * 12 + 8 + column, 1);
            assert observed_second == Zeros{PTO_XLEN} + 0x72;
        end;
    end;
    assert _LocalGenerations[[slot]].published &&
           _Tiles[[parent]].contents_defined &&
           !TileElementDefined(parent, 0, 12) &&
           !TileElementDefined(parent, 31, 15);
    return 0;
end;
