// PTO-TEST: {"id":"PTO-AVS-TILE-TQUANT-MASK-ZERO-001","source":"asl/tile/irregular-and-complex/format-conversion/TQUANT.asl","requirements":["PTO-INST-TILE-TQUANT"],"kind":"execution","summary":"TQUANT PE_MASK zero exits before schema, GPR, descriptor, and allocation checks","pass_condition":"an otherwise incomplete zero-participation bundle completes without fault or destination allocation","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/block/model/dispatch/quantization-schema.asl"]}
pure func TQUANTZeroMaskStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '01010';
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TQUANTZeroMaskStart(), 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE, 0, 1, '0000', TRUE, FALSE, 63, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    assert !_Tiles[[0]].allocated;
    return 0;
end;
