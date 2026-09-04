// PTO-TEST: {"id":"PTO-AVS-BLOCK-TIMG2COL-RESERVED-PARAMETERS-001","source":"asl/block/model/operands/timg2col-parameters.asl","requirements":["PTO-BSTART-TIMG2COL-PARAMS-001"],"kind":"fault","summary":"The base TIMG2COL parameter version accepts no extension or reserved bits.","pass_condition":"Bit 54, ParamVersion, ExtensionClass, and bit 63 each reject before memory, Shared publication, or payload effects.","related_sources":["asl/block/model/dispatch/timg2col-execution.asl","asl/block/execution/BSTART.TIMG2COL.asl"]}
pure func ReservedTIMG2COLStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x01c11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func ReservedTIMG2COLIOR(
    source0: integer, source1: integer, source2: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

pure func ReservedTIMG2COLSharedDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

func RunReservedTIMG2COLCase(case_index: integer {0..3})
begin
    ResetProfileState();
    var param1 = Zeros{64} + (1 << 32) + (1 << 37) +
        (1 << 42) + (1 << 48);
    if case_index == 0 then param1[54] = '1';
    elsif case_index == 1 then param1[55] = '1';
    elsif case_index == 2 then param1[59] = '1';
    else param1[63] = '1';
    end;
    WritePEGPR(0, 2, Zeros{PTO_XLEN});
    WritePEGPR(0, 3, Zeros{64} + 1 + (1 << 16) + (32 << 32) +
        (1 << 48) + (1 << 56));
    WritePEGPR(0, 4, param1);
    WritePEGPR(0, 5, Zeros{PTO_XLEN});
    let start = ExecuteCommandInstruction(ReservedTIMG2COLStart(), 32);
    assert start == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    let gm = ExecuteCommandInstruction(ReservedTIMG2COLIOR(2, 0, 0), 32);
    let parameters = ExecuteCommandInstruction(
        ReservedTIMG2COLIOR(3, 4, 5), 32);
    let destination = ExecuteCommandInstruction(
        ReservedTIMG2COLSharedDestination(), 32);
    assert gm == CommandExecution_Executed &&
        parameters == CommandExecution_Executed &&
        destination == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert !SharedTilePublished((Zeros{6} + 8) as SharedTileID);
end;

func main() => integer
begin
    for case_index = 0 to 3 looplimit 4 do
        RunReservedTIMG2COLCase(case_index);
    end;
    return 0;
end;
