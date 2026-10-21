// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-CUBE-M16-SOURCE-FREE-PARENT-004","source":"asl/block/model/operands/local-generation-cube-writer-effects.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Encoded source-free CUBE_M16 Local continuation retains its U-bank parent geometry","pass_condition":"Two 128-byte writers at offsets 0 and 1 complete through the source-free CUBE producer path in a 256-byte parent allocated to Tile16; continuation compares computed M16 output rows, finalizes full physical 16x16 capacity geometry, and publishes the 16-column prefix","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/operands/local-generation-cube.asl","asl/block/model/operands/local-generation.asl"]}

pure func SourceFreeM16Start() => bits(64)
begin
    return Zeros{64} + 0xdbb19181;
end;

pure func SourceFreeM16Attributes() => bits(64)
begin
    return Zeros{64} + 0x01f01fa3;
end;

pure func SourceFreeM16InitDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 2;
    instruction[8:7] = '01';
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func SourceFreeM16ParentRef() => bits(64)
begin
    return Zeros{64} + 0x01085e13;
end;

pure func SourceFreeM16Assemble(init: boolean, last: boolean,
    offset: integer {0,1}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = '0001';
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;

func RunSourceFreeM16Writer(init: boolean, last: boolean,
    offset: integer {0,1}, producer_pc: integer)
begin
    let start = ExecuteCommandInstruction(SourceFreeM16Start(), 32);
    let attributes = ExecuteCommandInstruction(SourceFreeM16Attributes(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 16);
    var destination = CommandExecution_Executed;
    if init then
        destination = ExecuteCommandInstruction(
            SourceFreeM16InitDestination(), 32);
    else
        destination = ExecuteCommandInstruction(
            SourceFreeM16ParentRef(), 32);
    end;
    let assembled = ExecuteCommandInstruction(
        SourceFreeM16Assemble(init, last, offset), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           destination == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + producer_pc);
    assert completed && _LastFault == Fault_None;
    let slot = BundleLocalGenerationSlot(1, '1111');
    let ready = CompleteBundleLocalGenerationWriterEvent(
        slot, _BundleExecutionDomainToken, offset, 1);
    assert ready;
end;

func main() => integer
begin
    ResetProfileState();
    RunSourceFreeM16Writer(TRUE, FALSE, 0, 0x100);
    let slot = BundleLocalGenerationSlot(1, '1111');
    let parent = _LocalGenerations[[slot]].working_destination;
    assert parent == 16 && !_Tiles[[0]].allocated &&
           _Tiles[[parent]].capacity_bytes == 256 &&
           _Tiles[[parent]].rows == 16 && _Tiles[[parent]].columns == 16;
    RunSourceFreeM16Writer(FALSE, TRUE, 1, 0x200);
    assert _LocalGenerations[[slot]].published &&
           _Tiles[[parent]].rows == 16 &&
           _Tiles[[parent]].columns == 16 &&
           _Tiles[[parent]].valid_rows == 16 &&
           _Tiles[[parent]].valid_columns == 16;
    return 0;
end;
