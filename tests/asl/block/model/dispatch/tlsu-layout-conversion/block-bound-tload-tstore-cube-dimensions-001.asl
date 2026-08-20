// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-TSTORE-CUBE-DIMENSIONS-001","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"boundary","summary":"CUBE TLOAD and TSTORE require explicit nonzero LB0 and LB1 while forbidding LB2","pass_condition":"Each missing zero or surplus dimension rejects before Local allocation or memory effects","related_sources":["asl/block/execution/BSTART.TLOAD.asl","asl/block/execution/BSTART.TSTORE.asl"]}
pure func CubeDimensionStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeDimensionAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 22;
    return instruction;
end;

pure func CubeDimensionDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = '0001';
    instruction[19] = '1';
    return instruction;
end;

func CubeDimensionsReject(
    lb0_present: boolean, lb0: integer {0..4},
    lb1_present: boolean, lb1: integer {0..4},
    lb2_present: boolean) => boolean
begin
    ResetProfileState();
    let start_status = ExecuteCommandInstruction(CubeDimensionStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        CubeDimensionAttributes(), 32);
    if start_status != CommandExecution_Executed ||
       datr_status != CommandExecution_Executed then return FALSE; end;
    if lb0_present then
        SetBundleDimension(0, Zeros{PTO_XLEN} + lb0);
    end;
    if lb1_present then
        SetBundleDimension(1, Zeros{PTO_XLEN} + lb1);
    end;
    if lb2_present then
        SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    end;
    let destination_status = ExecuteCommandInstruction(
        CubeDimensionDestination(), 32);
    if destination_status != CommandExecution_Executed then return FALSE; end;
    let completed = ExecuteBundleTileOperation();
    return !completed && _LastFault == Fault_TileLegality &&
           CoreTileCapacityInUse() == 0 && _MemoryEventCount == 0;
end;

func main() => integer
begin
    let missing_lb0 = CubeDimensionsReject(
        FALSE, 0, TRUE, 2, FALSE);
    assert missing_lb0;
    let zero_lb0 = CubeDimensionsReject(
        TRUE, 0, TRUE, 2, FALSE);
    assert zero_lb0;
    let missing_lb1 = CubeDimensionsReject(
        TRUE, 3, FALSE, 0, FALSE);
    assert missing_lb1;
    let zero_lb1 = CubeDimensionsReject(
        TRUE, 3, TRUE, 0, FALSE);
    assert zero_lb1;
    let surplus_lb2 = CubeDimensionsReject(
        TRUE, 3, TRUE, 2, TRUE);
    assert surplus_lb2;
    return 0;
end;
