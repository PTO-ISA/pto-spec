// PTO-TEST: {"id":"PTO-AVS-BLOCK-LOCAL-CUBE-WIDE-TLOAD-001","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-BSTART-TLOAD"],"kind":"execution","summary":"A real encoded M32/U8 TLOAD fills a 128-column writer while preserving its larger allocation-backed parent","pass_condition":"the writer record and completed payload cover 32x128 including a distinctive column 127 value; the 8192-byte parent remains physical 32x256 before-view and after execution","related_sources":["asl/block/model/operands/local-generation-cube-writer-effects.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/tile/model/memory/load-store.asl"]}
pure func WideTLOADStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func WideTLOADAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func WideTLOADParentDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 7;
    instruction[19] = '1';
    instruction[8:7] = '00';
    instruction[11:9] = '111';
    return instruction;
end;

pure func WideTLOADIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

pure func WideTLOADAssemble() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = Zeros{4} + 6;
    instruction[30:20] = Zeros{11};
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let base = Zeros{PTO_XLEN};
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 128);
    for index = 0 to 4095 looplimit 4096 do
        let value = if index MOD 128 == 127 then 0x7b else 0x31;
        Store(base + index, 1, Zeros{PTO_XLEN} + value);
    end;
    assert _LastFault == Fault_None;

    let start_form = DecodeCommandForm(WideTLOADStart(), 32);
    assert start_form != PTO_COMMAND_FORM_COUNT;
    let descriptor = DecodeBundleOperationDescriptor(WideTLOADStart(),
        start_form as integer {0..PTO_COMMAND_FORM_COUNT-1});
    assert BundleOperationDescriptorLegal(descriptor);
    let start = ExecuteCommandInstruction(WideTLOADStart(), 32);
    assert start == CommandExecution_Executed;
    let attributes = ExecuteCommandInstruction(WideTLOADAttributes(), 32);
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let ior = ExecuteCommandInstruction(WideTLOADIOR(), 32);
    let destination = ExecuteCommandInstruction(
        WideTLOADParentDestination(), 32);
    let assemble = ExecuteCommandInstruction(WideTLOADAssemble(), 32);
    assert ior == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;
    assert assemble == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100);
    assert completed && _LastFault == Fault_None;

    let slot = BundleLocalGenerationSlot(0, '1111');
    let ready = CompleteBundleLocalGenerationWriterEvent(
        slot, _BundleExecutionDomainToken, 0, 32);
    assert ready;
    let parent = _LocalGenerations[[slot]].working_destination;
    let writer_record = _LocalGenerations[[slot]].writers[[0]];
    assert _LocalGenerations[[slot]].writer_count == 1 &&
           writer_record.valid &&
           writer_record.offset_cells == 0 && writer_record.cell_count == 32 &&
           writer_record.physical_rows == 32 &&
           writer_record.physical_columns == 128 &&
           writer_record.valid_rows == 32 &&
           writer_record.valid_columns == 128;
    assert parent == 0 && _Tiles[[parent]].capacity_bytes == 8192 &&
           _Tiles[[parent]].rows == 32 && _Tiles[[parent]].columns == 256 &&
           _Tiles[[parent]].valid_rows == 32 &&
           _Tiles[[parent]].valid_columns == 128 &&
           _LocalGenerations[[slot]].published;
    assert ReadTileElement(parent, 0, 64) == Zeros{PTO_XLEN} + 0x31 &&
           ReadTileElement(parent, 0, 127) == Zeros{PTO_XLEN} + 0x7b &&
           TileElementDefined(parent, 0, 127) &&
           !TileElementDefined(parent, 0, 128);
    return 0;
end;
