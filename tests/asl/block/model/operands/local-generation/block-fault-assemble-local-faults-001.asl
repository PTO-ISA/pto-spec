// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-LOCAL-FAULTS-001","source":"asl/block/model/operands/local-generation.asl","requirements":["PTO-B-ASSEMBLE-LOCAL-GENERATION-001","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT"],"kind":"fault","summary":"Decoded Local generation faults reject replacement, identity, coverage, allocation, and replay violations without partial publication.","pass_condition":"Missing or duplicate INIT, second-open, equal-range distinct-instance overlap, out-of-bounds, participant-mask, normalized-descriptor/object-name, no-modifier open-key, incomplete LAST, allocation failure, and writer-after-LAST cases report exact BundleControl/TileLegality/TileAllocation results; speculative state aborts while sources remain allocated and defined.","related_sources":["asl/block/model/faults/rollback.asl","asl/block/model/dispatch/tile-execution.asl"]}
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
pure func BindingMode(mode: integer) => bits(64)
begin
    var instruction = Binding();
    instruction[11:9] = Zeros{3} + mode;
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
func BeginSource()
begin
    let source = ConfigureCubeTileForMask(1, 256, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let source1 = ConfigureCubeTileForMask(2, 256, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert source && source1;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
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
func RunMode(init: boolean, last: boolean, parent: integer, offset: integer,
             mode: integer) => boolean
begin
    let started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let bound = ExecuteCommandInstruction(BindingMode(mode), 32);
    let assembled = ExecuteCommandInstruction(
        Assemble(init, last, parent, offset), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    return CompleteBundleAt(Zeros{PTO_XLEN} + 0x700);
end;
func RunWithoutAssemble() => boolean
begin
    let started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let bound = ExecuteCommandInstruction(Binding(), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    return CompleteBundleAt(Zeros{PTO_XLEN} + 0x700);
end;
func main() => integer
begin
    ResetProfileState(); BeginSource();
    let missing_init = Run(FALSE, TRUE, 0, 0);
    assert !missing_init && _LastFault == Fault_BundleControl;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;

    ResetProfileState(); BeginSource();
    let first_init = Run(TRUE, FALSE, 1, 0);
    assert first_init && _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    let overlap = Run(FALSE, FALSE, 0, 0);
    assert !overlap && _LastFault == Fault_TileLegality;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;

    // A decoded writer in another selected-PE domain cannot silently open a
    // second generation for the same architectural hand while the original
    // domain remains open.
    ResetProfileState(); BeginSource();
    let domain_base = Run(TRUE, FALSE, 4, 0);
    assert domain_base && _LocalGenerations[[
        BundleLocalGenerationSlot(0, '1111')]].open;
    let domain_mismatch = RunMode(FALSE, FALSE, 0, 2, 3);
    assert !domain_mismatch && _LastFault == Fault_TileLegality;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;

    // A normal decoded destination with no B.ASSEMBLE cannot replace or
    // release the still-open hand; only a matching writer may advance it.
    ResetProfileState(); BeginSource();
    let standalone_base = Run(TRUE, FALSE, 4, 0);
    assert standalone_base && _LocalGenerations[[
        BundleLocalGenerationSlot(0, '1111')]].open;
    let standalone = RunWithoutAssemble();
    assert !standalone && _LastFault == Fault_BundleControl;
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;

    // A descriptor mutation after decoded INIT is rejected before a writer
    // can rebind the working object; the old source remains live and defined.
    ResetProfileState(); BeginSource();
    let descriptor_base = Run(TRUE, FALSE, 4, 0);
    assert descriptor_base;
    let descriptor_slot = BundleLocalGenerationSlot(0, '1111');
    let descriptor_object = _LocalGenerations[[descriptor_slot]].working_destination;
    _Tiles[[descriptor_object]].layout = TileLayout_RowMajor;
    let descriptor_mismatch = Run(FALSE, FALSE, 0, 2);
    assert !descriptor_mismatch && _LastFault == Fault_TileLegality;
    assert !_LocalGenerations[[descriptor_slot]].open &&
           _Tiles[[1]].allocated && _Tiles[[1]].contents_defined;

    // A normalized object-name mismatch is distinct from a range overlap and
    // also aborts only the speculative generation.
    ResetProfileState(); BeginSource();
    let object_base = Run(TRUE, FALSE, 4, 0);
    assert object_base;
    let object_slot = BundleLocalGenerationSlot(0, '1111');
    _LocalGenerations[[object_slot]].parent_descriptor.object_name = 15;
    let object_mismatch = Run(FALSE, FALSE, 0, 2);
    assert !object_mismatch && _LastFault == Fault_TileLegality;
    assert !_LocalGenerations[[object_slot]].open &&
           _Tiles[[1]].allocated && _Tiles[[1]].contents_defined;

    ResetProfileState(); BeginSource();
    let kind_base = Run(TRUE, FALSE, 4, 0);
    assert kind_base;
    let kind_slot = BundleLocalGenerationSlot(0, '1111');
    let kind_object = _LocalGenerations[[kind_slot]].working_destination;
    _Tiles[[kind_object]].storage_kind = TileStorage_Predicate;
    let kind_mismatch = Run(FALSE, FALSE, 0, 2);
    assert !kind_mismatch && _LastFault == Fault_TileLegality;
    assert !_LocalGenerations[[kind_slot]].open &&
           _Tiles[[1]].allocated && _Tiles[[1]].contents_defined;

    ResetProfileState(); BeginSource();
    let duplicate_base = Run(TRUE, FALSE, 1, 0);
    assert duplicate_base && _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    let duplicate_init = Run(TRUE, FALSE, 1, 0);
    assert !duplicate_init && _LastFault == Fault_BundleControl;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;

    ResetProfileState(); BeginSource();
    let bounds_base = Run(TRUE, FALSE, 1, 0);
    assert bounds_base && _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    let out_of_bounds = Run(FALSE, TRUE, 0, 1);
    assert !out_of_bounds && _LastFault == Fault_TileLegality;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;

    ResetProfileState(); BeginSource();
    let incomplete = Run(TRUE, TRUE, 2, 0);
    assert !incomplete && _LastFault == Fault_TileLegality;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;

    ResetProfileState(); BeginSource();
    let closed = Run(TRUE, TRUE, 1, 0);
    assert closed && _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].closed;
    let after_last = Run(FALSE, FALSE, 0, 0);
    assert !after_last && _LastFault == Fault_BundleControl;

    // Force the architectural capacity boundary after the decoded sources
    // exist; INIT allocation fails atomically without changing them.
    ResetProfileState(); BeginSource();
    _SystemRegisters.tile_capacity = Zeros{PTO_XLEN} + 2048;
    let allocation_failed = Run(TRUE, FALSE, 4, 0);
    assert !allocation_failed && _LastFault == Fault_TileAllocation;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open &&
           _Tiles[[1]].allocated && _Tiles[[2]].allocated &&
           _Tiles[[1]].contents_defined && _Tiles[[2]].contents_defined;
    return 0;
end;
