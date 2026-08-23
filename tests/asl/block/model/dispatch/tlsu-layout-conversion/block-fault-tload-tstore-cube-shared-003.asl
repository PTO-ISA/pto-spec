// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-TSTORE-CUBE-SHARED-003","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"Every CUBE Layout conversion rejects a Shared B.IOS binding before effects","pass_condition":"Codes 21 through 26 leave Local capacity Shared descriptors memory and event state unchanged","related_sources":["asl/block/operands/B.IOS.asl","asl/block/model/dispatch/shared-tlsu.asl"]}
pure func CubeSharedStart(load: boolean) => bits(64)
begin
    var instruction: bits(64) = if load then
        Zeros{64} + 0x00011181 else Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeSharedAttributes(code: integer {21..26}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + code;
    return instruction;
end;

func CubeSharedRejects(code: integer {21..26}) => boolean
begin
    ResetProfileState();
    let load = code <= 23;
    let start_status = ExecuteCommandInstruction(CubeSharedStart(load), 32);
    let datr_status = ExecuteCommandInstruction(
        CubeSharedAttributes(code), 32);
    if start_status != CommandExecution_Executed ||
       datr_status != CommandExecution_Executed then return FALSE; end;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    BindBundleSharedIO(
        (Zeros{6} + code) as SharedTileID,
        if load then 1 else 0,
        '0001');
    _Memory[[0]] = Zeros{8} + 0xa5;
    let completed = ExecuteBundleTileOperation();
    return !completed && _LastFault == Fault_TileLegality &&
           CoreTileCapacityInUse() == 0 &&
           !SharedTileRecord((Zeros{6} + code) as SharedTileID).descriptor_valid &&
           _Memory[[0]] == Zeros{8} + 0xa5 && _MemoryEventCount == 0;
end;

func main() => integer
begin
    for code = 21 to 26 do
        let rejected = CubeSharedRejects(code as integer {21..26});
        assert rejected;
    end;
    return 0;
end;
