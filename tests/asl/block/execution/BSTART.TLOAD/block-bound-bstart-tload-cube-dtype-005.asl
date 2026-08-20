// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-CUBE-DTYPE-005","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"boundary","summary":"CUBE TLOAD rejects every assigned 64-bit type and HiF4X2 before allocation","pass_condition":"FP64 S64 U64 and HiF4X2 each raise Tile legality with no destination capacity","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl"]}
pure func CubeDTypeStart(code: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = code;
    return instruction;
end;

pure func CubeDTypeAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 22;
    return instruction;
end;

pure func CubeDTypeDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = '0001';
    instruction[19] = '1';
    return instruction;
end;

func CubeDTypeRejects(code: bits(5)) => boolean
begin
    ResetProfileState();
    let start_status = ExecuteCommandInstruction(CubeDTypeStart(code), 32);
    let datr_status = ExecuteCommandInstruction(CubeDTypeAttributes(), 32);
    if start_status != CommandExecution_Executed ||
       datr_status != CommandExecution_Executed then return FALSE; end;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let destination_status = ExecuteCommandInstruction(
        CubeDTypeDestination(), 32);
    if destination_status != CommandExecution_Executed then return FALSE; end;
    let completed = ExecuteBundleTileOperation();
    return !completed && _LastFault == Fault_TileLegality &&
           CoreTileCapacityInUse() == 0;
end;

func main() => integer
begin
    let fp64 = CubeDTypeRejects(Zeros{5});
    assert fp64;
    let hif4 = CubeDTypeRejects(Zeros{5} + 14);
    assert hif4;
    let s64 = CubeDTypeRejects(Zeros{5} + 16);
    assert s64;
    let u64 = CubeDTypeRejects(Zeros{5} + 24);
    assert u64;
    return 0;
end;
