// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-RESTART-001","source":"asl/block/model/operands/local-generation.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT"],"kind":"fault","summary":"Decoded INIT, MIDDLE, and LAST Local generation faults retain the original operation address, restart at INIT, and abort speculative state.","pass_condition":"Each decoded INIT, MIDDLE, and LAST fault reports the original operation address, restores the earliest INIT TPC, and leaves no open generation, partial coverage, readiness, or publication.","related_sources":["asl/arch/state/trap-context.asl","asl/arch/memory-model/fault-precision.asl"]}
pure func Start() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;
pure func Binding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 2;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1'; instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '111'; instruction[8:7] = '00';
    return instruction;
end;
pure func Assemble(init: boolean, last: boolean, parent: integer,
                   offset: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
func Source()
begin
    let ready = ConfigureCubeTileForMask(1, 256, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let ready1 = ConfigureCubeTileForMask(2, 256, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert ready && ready1;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 9);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 9);
end;
func Run(init: boolean, last: boolean, parent: integer, offset: integer)
        => boolean
begin
    let started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let bound = ExecuteCommandInstruction(Binding(), 32);
    let assembled = ExecuteCommandInstruction(
        Assemble(init, last, parent, offset), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    return CompleteBundleAt(Zeros{PTO_XLEN} + 0x700);
end;
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    Source();
    let expected_init = ReadTPC();
    let rejected_init = Run(TRUE, TRUE, 2, 0);
    assert !rejected_init && _LastFault == Fault_TileLegality;
    let target = CurrentACR();
    assert _TrapContexts[[target]].valid;
    assert _TrapContexts[[target]].tpc == expected_init;
    assert _FaultAddress != expected_init;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;

    ResetProfileState();
    Source();
    let opened = Run(TRUE, FALSE, 1, 0);
    assert opened && _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    let earliest = _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].init_tpc;
    let rejected_middle = Run(FALSE, FALSE, 0, 8);
    assert !rejected_middle && _LastFault == Fault_TileLegality;
    let middle_target = CurrentACR();
    assert _TrapContexts[[middle_target]].valid;
    assert _TrapContexts[[middle_target]].tpc == earliest;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;

    ResetProfileState();
    Source();
    let opened_for_last = Run(TRUE, FALSE, 4, 0);
    assert opened_for_last;
    let last_earliest = _LocalGenerations[[
        BundleLocalGenerationSlot(0, '1111')]].init_tpc;
    let rejected_last = Run(FALSE, TRUE, 0, 1);
    assert !rejected_last && _LastFault == Fault_TileLegality;
    let last_target = CurrentACR();
    assert _TrapContexts[[last_target]].valid;
    assert _TrapContexts[[last_target]].tpc == last_earliest;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].published;
    return 0;
end;
