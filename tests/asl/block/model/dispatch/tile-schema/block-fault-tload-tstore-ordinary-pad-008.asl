// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-TSTORE-ORDINARY-PAD-008","source":"asl/block/model/dispatch/tile-schema.asl","requirements":["PTO-INST-BLOCK-BSTART-TLOAD","PTO-INST-BLOCK-BSTART-TSTORE"],"kind":"fault","summary":"Ordinary TLOAD and TSTORE keep PadValue zero-only after CUBE conversion gains padding","pass_condition":"a nonzero PadValue with NORM layout rejects both operations before allocation descriptor or memory effects","related_sources":["asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/block/attributes/B.DATR.asl"]}
pure func OrdinaryPadStart(load: boolean) => bits(64)
begin
    var instruction: bits(64) = if load then
        Zeros{64} + 0x00011181 else Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func OrdinaryPadAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5};
    instruction[28:27] = '01';
    return instruction;
end;

pure func OrdinaryPadTileBinding(load: boolean) => bits(64)
begin
    var instruction: bits(64) = if load then
        Zeros{64} + 0x00006013 else Zeros{64} + 0x00005013;
    instruction[18:15] = if load then '0001' else '0000';
    instruction[19] = '1';
    instruction[11:9] = '001';
    return instruction;
end;

func OrdinaryPadRejects(load: boolean) => boolean
begin
    ResetProfileState();
    let start_status = ExecuteCommandInstruction(OrdinaryPadStart(load), 32);
    let datr_status = ExecuteCommandInstruction(OrdinaryPadAttributes(), 32);
    if start_status != CommandExecution_Executed ||
       datr_status != CommandExecution_Executed then return FALSE; end;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let binding_status = ExecuteCommandInstruction(
        OrdinaryPadTileBinding(load), 32);
    if binding_status != CommandExecution_Executed then return FALSE; end;
    let completed = ExecuteBundleTileOperation();
    return !completed && _LastFault == Fault_TileLegality &&
           CoreTileCapacityInUse() == 0 && _MemoryEventCount == 0;
end;

func main() => integer
begin
    let load_rejected = OrdinaryPadRejects(TRUE);
    assert load_rejected;
    let store_rejected = OrdinaryPadRejects(FALSE);
    assert store_rejected;
    return 0;
end;
