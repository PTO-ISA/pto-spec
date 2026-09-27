// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSELS-MASK-AWARE-SELECTOR-DECODED-003","source":"asl/block/model/dispatch/tile-scalar-schema.asl","requirements":["PTO-TSELS-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded CUBE TSELS validates its PredicateCell selector only at ExecutionMask-active coordinates","pass_condition":"an inactive undefined selector coordinate is ignored, activating it rejects before allocation, and a wrong-shape PredicateCell ExecutionMask rejects without consuming the selector","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/tile/model/execution/execution-mask-state.asl"]}
pure func MaskAwareTSELSStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    let selector = Zeros{10} + 0x03a;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func MaskAwareTSELSAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[13] = '1';
    return instruction;
end;

pure func MaskAwareTSELSIOT(source0: bits(6), source1: bits(6),
    source1_valid: boolean, destination_valid: boolean,
    last: boolean) => bits(64)
begin
    var instruction = if source1_valid then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00005013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = if destination_valid then '0010' else '0000';
    instruction[11:9] = '001';
    return instruction;
end;

pure func MaskAwareTSELSIOR(source0: bits(5), source1: bits(5),
    execution_mask_present: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[26] = if execution_mask_present then '1' else '0';
    return instruction;
end;

func BeginMaskAwareTSELS()
begin
    let started = ExecuteCommandInstruction(MaskAwareTSELSStart(), 32);
    let attributes = ExecuteCommandInstruction(
        MaskAwareTSELSAttributes(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
end;

func InstallMaskAwareTSELSSources()
begin
    let predicate_ready = ConfigurePredicateCell(
        8, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let source_ready = ConfigureCubeTile(
        10, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert predicate_ready && source_ready;
    InstallRelativeTileFixture(8, 8);
    InstallRelativeTileFixture(10, 10);
    // Column zero stays undefined; column one is canonical and defined.
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 11);
    MarkTileValidRegionDefined(10);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 77);
end;

func RunMaskAwareTSELS(active_undefined: boolean)
begin
    ResetProfileState();
    InstallMaskAwareTSELSSources();
    var execution_mask = Zeros{PTO_XLEN};
    if active_undefined then execution_mask[0] = '1';
    else execution_mask[16] = '1'; end;
    WritePEGPR(0, 3, execution_mask);
    BeginMaskAwareTSELS();
    let binding = ExecuteCommandInstruction(
        MaskAwareTSELSIOT(Zeros{6} + 8, Zeros{6} + 10,
            TRUE, TRUE, TRUE), 32);
    let scalars = ExecuteCommandInstruction(
        MaskAwareTSELSIOR(Zeros{5} + 2, Zeros{5} + 3, TRUE), 32);
    assert binding == CommandExecution_Executed &&
           scalars == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed != active_undefined;
    if active_undefined then
        assert _LastFault == Fault_TileLegality;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    else
        assert _LastFault == Fault_None;
    end;
end;

func RunMaskAwareTSELSWrongShape()
begin
    ResetProfileState();
    InstallMaskAwareTSELSSources();
    let mask_ready = ConfigurePredicateCell(
        12, 128, 1, 1, TileDataType_U32, TileLayout_CUBE_M16);
    assert mask_ready;
    InstallRelativeTileFixture(12, 12);
    MarkTileValidRegionDefined(12);
    BeginMaskAwareTSELS();
    let inputs = ExecuteCommandInstruction(
        MaskAwareTSELSIOT(Zeros{6} + 8, Zeros{6} + 10,
            TRUE, FALSE, FALSE), 32);
    let result = ExecuteCommandInstruction(
        MaskAwareTSELSIOT(Zeros{6} + 12, Zeros{6},
            FALSE, TRUE, TRUE), 32);
    let scalar = ExecuteCommandInstruction(
        MaskAwareTSELSIOR(Zeros{5} + 2, Zeros{5}, FALSE), 32);
    assert inputs == CommandExecution_Executed &&
           result == CommandExecution_Executed &&
           scalar == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
end;

func main() => integer
begin
    RunMaskAwareTSELS(FALSE);
    RunMaskAwareTSELS(TRUE);
    RunMaskAwareTSELSWrongShape();
    return 0;
end;
