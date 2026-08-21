// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMOV-EXTRACT-001","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-INST-BLOCK-BSTART-TMOV"],"kind":"execution","summary":"EXTRACT reads an unallocated Shared register without allocating it","pass_condition":"selected destination quarters receive undefined-register values, unselected payload remains unchanged, and Sx stays absent","related_sources":["asl/tile/model/state/shared-registers.asl","asl/tile/model/memory/shared-movement.asl"]}
pure func TMOVExtractStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00c11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TMOVExtractShared(shared_id: bits(8), pe_mode: bits(3))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
    instruction[18:15] = '0000';
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func TMOVExtractDestination(pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = '0001';
    instruction[11:9] = pe_mode;
    instruction[8:7] = '01';
    instruction[19] = '1';
    return instruction;
end;

func TMOVExtractExecute(instruction: bits(64))
begin
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = Zeros{8} + 42;
    _Tiles[[16]].payload[[32]] = Zeros{PTO_XLEN} + 0x77;
    assert !SharedTileRecord(shared_id).descriptor_valid;
    TMOVExtractExecute(TMOVExtractStart());
    TMOVExtractExecute(TMOVExtractShared(shared_id, '001'));
    TMOVExtractExecute(TMOVExtractDestination('001'));
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _Tiles[[16]].allocated;
    assert _Tiles[[16]].payload[[0]] ==
        UndefinedSharedTileWord(shared_id, 0);
    assert _Tiles[[16]].payload[[32]] == Zeros{PTO_XLEN} + 0x77;
    assert !_Tiles[[16]].contents_defined;
    assert !SharedTileRecord(shared_id).descriptor_valid;
    return 0;
end;
