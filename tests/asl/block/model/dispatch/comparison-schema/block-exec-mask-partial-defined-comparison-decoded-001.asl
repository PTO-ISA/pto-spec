// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXEC-MASK-PARTIAL-DEFINED-CMP-DECODED-001","source":"asl/block/model/dispatch/comparison-schema.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TCMPS-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded TCMP and TCMPS inspect only ExecutionMask-active coordinates in partial-defined CUBE sources","pass_condition":"both forms accept when the undefined coordinate is inactive, reject when it is active, and preserve the GPR destination on rejection; unmasked TCMP retains full-source definedness","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/legality/execution-mask-source-schema.asl"]}
pure func PartialCompareStart(selector: bits(10), data_type: bits(5))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func PartialCompareAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5};
    return instruction;
end;

pure func PartialTCMPInputs(left: bits(6), right: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = right;
    instruction[25:20] = left;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func PartialTCMPSInput(source: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

pure func PartialCompareIOR(destination: bits(5), source0: bits(5),
    source1: bits(5), present: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[26] = if present then '1' else '0';
    return instruction;
end;

func InstallPartialCUBESources(right_present: boolean)
begin
    let left_ready = ConfigureCubeTile(
        8, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    var right_ready = TRUE;
    if right_present then
        right_ready = ConfigureCubeTile(
            10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    end;
    assert left_ready && right_ready;
    InstallRelativeTileFixture(8, 8);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN} + 5);
    if right_present then
        InstallRelativeTileFixture(10, 10);
        WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 5);
    end;
end;

func BeginPartialComparison(selector: bits(10))
begin
    let started = ExecuteCommandInstruction(
        PartialCompareStart(selector,
            TileDataTypeToEncoding(TileDataType_U32)), 32);
    let attributes = ExecuteCommandInstruction(
        PartialCompareAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
end;

func RunPartialTCMP(mask_column0: boolean, present: boolean,
    should_complete: boolean)
begin
    ResetProfileState();
    InstallPartialCUBESources(TRUE);
    var mask = Zeros{PTO_XLEN};
    if mask_column0 then mask[0] = '1'; else mask[16] = '1'; end;
    WritePEGPR(0, 3, mask);
    BeginPartialComparison(Zeros{10} + 0x00d);
    let inputs = ExecuteCommandInstruction(
        PartialTCMPInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let output = ExecuteCommandInstruction(
        PartialCompareIOR(Zeros{5} + 3,
            if present then Zeros{5} + 3 else Zeros{5},
            Zeros{5}, present), 32);
    assert inputs == CommandExecution_Executed &&
           output == CommandExecution_Executed;
    let before = ReadPEGPR(0, 3);
    let completed = ExecuteBundleTileOperation();
    assert completed == should_complete;
    if should_complete then
        assert _LastFault == Fault_None;
        let result = ReadPEGPR(0, 3);
        assert result[16] == '1';
    else
        assert _LastFault == Fault_TileLegality;
        assert ReadPEGPR(0, 3) == before;
    end;
end;

func RunPartialTCMPS(mask_column0: boolean, should_complete: boolean)
begin
    ResetProfileState();
    InstallPartialCUBESources(FALSE);
    var mask = Zeros{PTO_XLEN};
    if mask_column0 then mask[0] = '1'; else mask[16] = '1'; end;
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 5);
    WritePEGPR(0, 3, mask);
    BeginPartialComparison(Zeros{10} + 0x02d);
    let input = ExecuteCommandInstruction(
        PartialTCMPSInput(Zeros{6} + 8), 32);
    let output = ExecuteCommandInstruction(
        PartialCompareIOR(Zeros{5} + 3, Zeros{5} + 2,
            Zeros{5} + 3, TRUE), 32);
    assert input == CommandExecution_Executed &&
           output == CommandExecution_Executed;
    let before = ReadPEGPR(0, 3);
    let completed = ExecuteBundleTileOperation();
    assert completed == should_complete;
    if should_complete then
        assert _LastFault == Fault_None;
        assert ReadPEGPR(0, 3)[16] == '1';
    else
        assert _LastFault == Fault_TileLegality;
        assert ReadPEGPR(0, 3) == before;
    end;
end;

func main() => integer
begin
    // The undefined column 0 is suppressed while column 1 is active.
    RunPartialTCMP(FALSE, TRUE, TRUE);
    RunPartialTCMPS(FALSE, TRUE);

    // Activating the undefined column rejects without publishing the GPR.
    RunPartialTCMP(TRUE, TRUE, FALSE);
    RunPartialTCMPS(TRUE, FALSE);

    // Without an ExecutionMask, TCMP retains its whole-source preflight.
    ResetProfileState();
    InstallPartialCUBESources(TRUE);
    BeginPartialComparison(Zeros{10} + 0x00d);
    let unmasked_inputs = ExecuteCommandInstruction(
        PartialTCMPInputs(Zeros{6} + 8, Zeros{6} + 10), 32);
    let unmasked_output = ExecuteCommandInstruction(
        PartialCompareIOR(Zeros{5} + 3, Zeros{5}, Zeros{5}, FALSE), 32);
    assert unmasked_inputs == CommandExecution_Executed &&
           unmasked_output == CommandExecution_Executed;
    let prior = ReadPEGPR(0, 3);
    let unmasked = ExecuteBundleTileOperation();
    assert !unmasked && _LastFault == Fault_TileLegality;
    assert ReadPEGPR(0, 3) == prior;
    return 0;
end;
