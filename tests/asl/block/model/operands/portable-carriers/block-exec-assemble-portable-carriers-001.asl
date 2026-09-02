// PTO-TEST: {"id":"PTO-AVS-BLOCK-ASSEMBLE-PORTABLE-CARRIERS-001","source":"asl/block/model/operands/portable-carriers.asl","requirements":["PTO-B-ASSEMBLE-CONSUMER-READINESS-001","PTO-B-ASSEMBLE-SPECULATION-001","PTO-B-ASSEMBLE-PRODUCER-EFFECT-ELIGIBILITY-001","PTO-INST-BLOCK-BSTART","PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-SUBVIEW","PTO-INST-BLOCK-B-ASSEMBLE"],"kind":"execution","summary":"Decoded Local assembly binds portable range readiness, cancels wrong-path writers, and rejects a nonrollback producer before effects.","pass_condition":"A decoded post-LAST range waits without a fault or temporary source effect until its selected cells become ready; decoded writer squash removes coverage and allocation while preserving sources; a decoded B.ASSEMBLE producer with a nonrollback handler raises Fault_TileLegality before effects.","related_sources":["asl/block/model/operands/local-generation.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func Start() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;
pure func ConsumerStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;
pure func MatrixBinding(source0: integer, source1: integer,
                        destination: integer, size_code: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + source1;
    instruction[25:20] = Zeros{6} + source0;
    instruction[19] = '1'; instruction[18:15] = Zeros{4} + size_code;
    instruction[11:9] = '111'; instruction[8:7] = Zeros{2} + destination;
    return instruction;
end;
pure func DataAttribute(data_type: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = Zeros{5} + data_type;
    return instruction;
end;
pure func Binding(source0: integer, source1: integer, destination: integer,
                 size_code: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + source1;
    instruction[25:20] = Zeros{6} + source0;
    instruction[19] = '1'; instruction[18:15] = Zeros{4} + size_code;
    instruction[11:9] = '111'; instruction[8:7] = Zeros{2} + destination;
    return instruction;
end;
pure func Subview() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;
pure func StoreStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;
pure func StoreBinding(source: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + source;
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
    let left = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix, '1111');
    let right = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix, '1111');
    assert left && right;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x4200);
end;
func Writer(init: boolean, last: boolean) => boolean
begin
    let started = ExecuteCommandInstruction(Start(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let bound = ExecuteCommandInstruction(Binding(1, 2, 0, 2), 32);
    let parent = if init && last then 2 else 4;
    let assembled = ExecuteCommandInstruction(
        Assemble(init, last, parent, 0), 32);
    assert started == CommandExecution_Executed &&
           bound == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    return CompleteBundleAt(Zeros{PTO_XLEN} + 0x700);
end;
func main() => integer
begin
    assert BundleProducerEffectClassOfHandler(TileHandler_TSTORE) ==
        BundleProducerEffect_NonRollbackAuxiliary;
    assert BundleProducerEffectClassOfHandler(TileHandler_TMATMUL) ==
        BundleProducerEffect_AtomicAuxiliary;
    for operation = 0 to PTO_TILE_OPERATION_COUNT - 1
        looplimit PTO_TILE_OPERATION_COUNT do
        let effect_class = BundleProducerEffectClassOfOperation(operation);
        assert effect_class == BundleProducerEffect_RollbackSafe ||
               effect_class == BundleProducerEffect_AtomicAuxiliary ||
               effect_class == BundleProducerEffect_NonRollbackAuxiliary;
    end;
    ResetProfileState(); Source();
    let opened = Writer(TRUE, FALSE);
    assert opened && _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    let domain = _BundleExecutionDomainToken;
    EnterBundleExecutionDomainSquashEvent(domain);
    assert _LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].writer_count == 0;
    assert !_Tiles[[0]].allocated;
    var source_count: integer {0..64} = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated then
            source_count = (source_count + 1) as integer {0..64};
        end;
    end;
    assert source_count == 2;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].open;
    assert !_LocalGenerations[[BundleLocalGenerationSlot(0, '1111')]].committed_valid;
    assert _Tiles[[1]].allocated && _Tiles[[2]].allocated;

    ResetProfileState(); Source();
    let writer_done = Writer(TRUE, TRUE);
    let slot = BundleLocalGenerationSlot(0, '1111');
    assert _LastFault == Fault_None;
    assert _LocalGenerations[[slot]].last_seen;
    assert _LocalGenerations[[slot]].parent_descriptor.valid;
    assert _LocalGenerations[[slot]].parent_cell_count > 0;
    // Decoded LAST closes the writer set but cannot publish a not-yet-ready
    // writer.  Completion is delivered through the formal architecture event.
    assert writer_done && _LocalGenerations[[slot]].closed &&
           !_LocalGenerations[[slot]].open &&
           !_LocalGenerations[[slot]].published &&
           _LocalGenerations[[slot]].covered_cells[0] == '1' &&
           _LocalGenerations[[slot]].ready_cells[0] == '0';
    let destination = _LocalGenerations[[slot]].working_destination;
    let writer_domain = _BundleExecutionDomainToken;
    let consumer_start = ExecuteCommandInstruction(ConsumerStart(), 32);
    let consumer_data = ExecuteCommandInstruction(DataAttribute(4), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let consumer_binding = ExecuteCommandInstruction(
        MatrixBinding(destination, 3, 1, 1), 32);
    let consumer_view = ExecuteCommandInstruction(Subview(), 32);
    assert consumer_start == CommandExecution_Executed &&
           consumer_data == CommandExecution_Executed &&
           consumer_binding == CommandExecution_Executed &&
           consumer_view == CommandExecution_Executed;
    let waiting = ExecuteBundleTileOperation();
    assert !waiting && _LastFault == Fault_None;
    assert _LocalGenerations[[slot]].consumers[[0]].state ==
        BundleConsumerDependency_Waiting;
    // A second decoded consumer without B.SUBVIEW binds the whole parent.
    // Both dependencies are created while the generation is closed-pending.
    StopBundleAt(Zeros{PTO_XLEN} + 0x800);
    let whole_start = ExecuteCommandInstruction(ConsumerStart(), 32);
    let whole_data = ExecuteCommandInstruction(DataAttribute(4), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let whole_binding = ExecuteCommandInstruction(
        MatrixBinding(destination, 3, 3, 1), 32);
    assert whole_start == CommandExecution_Executed &&
           whole_data == CommandExecution_Executed &&
           whole_binding == CommandExecution_Executed;
    let whole_waiting = ExecuteBundleTileOperation();
    assert !whole_waiting && _LastFault == Fault_None;
    assert _LocalGenerations[[slot]].consumers[[1]].mode ==
        BundleConsumerDependency_WholeParent &&
        _LocalGenerations[[slot]].consumers[[1]].state ==
            BundleConsumerDependency_Waiting;
    let completed = CompleteBundleLocalGenerationWriterEvent(
        slot, writer_domain, 0, 2);
    assert completed;
    assert _LocalGenerations[[slot]].published;
    assert _LocalGenerations[[slot]].ready_cells[0] == '1';
    assert _LocalGenerations[[slot]].consumers[[0]].state ==
        BundleConsumerDependency_Eligible;
    assert _LocalGenerations[[slot]].consumers[[1]].state ==
        BundleConsumerDependency_Eligible;
    let whole_ready = ExecuteBundleTileOperation();
    assert whole_ready && _LastFault == Fault_None;
    assert _LocalGenerations[[slot]].consumers[[1]].state ==
        BundleConsumerDependency_Retired;
    let whole_output = _BundleTileBindings[[0]].destination;
    assert _Tiles[[whole_output]].allocated &&
           ReadTileElement(whole_output, 0, 0) ==
               Zeros{PTO_XLEN} + 0x41900000 &&
           ReadTileElement(destination, 0, 0) ==
               Zeros{PTO_XLEN} + 0x40c00000;

    // Re-enter the decoded range path after publication to prove the same
    // selected-cell observable, while the first range consumer above proves
    // the closed-pending waiting/eligibility transition.
    StopBundleAt(Zeros{PTO_XLEN} + 0x900);
    let range_start2 = ExecuteCommandInstruction(ConsumerStart(), 32);
    let range_data2 = ExecuteCommandInstruction(DataAttribute(4), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    let range_binding2 = ExecuteCommandInstruction(
        MatrixBinding(destination, 3, 1, 1), 32);
    let range_view2 = ExecuteCommandInstruction(Subview(), 32);
    assert range_start2 == CommandExecution_Executed &&
           range_data2 == CommandExecution_Executed &&
           range_binding2 == CommandExecution_Executed &&
           range_view2 == CommandExecution_Executed;
    let range_ready = ExecuteBundleTileOperation();
    assert range_ready && _LastFault == Fault_None;
    let range_output = _BundleTileBindings[[0]].destination;
    assert _Tiles[[range_output]].allocated &&
           ReadTileElement(range_output, 0, 0) ==
               Zeros{PTO_XLEN} + 0x41900000 &&
           ReadTileElement(destination, 0, 0) ==
               Zeros{PTO_XLEN} + 0x40c00000;

    ResetProfileState();
    ConfigureTileForMask(1, 128, 1, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor, TileLocation_Any, '1111');
    InstallRelativeTileFixture(1, 1);
    assert _Tiles[[1]].allocated;
    let store_start = ExecuteCommandInstruction(StoreStart(), 32);
    let store_binding = ExecuteCommandInstruction(StoreBinding(1), 32);
    let store_assemble = ExecuteCommandInstruction(
        Assemble(TRUE, TRUE, 1, 0), 32);
    assert store_start == CommandExecution_Executed &&
           store_binding == CommandExecution_Executed &&
           store_assemble == CommandExecution_Executed;
    let store_rejected = ExecuteBundleTileOperation();
    assert !store_rejected && _LastFault == Fault_TileLegality;
    assert _Tiles[[1]].allocated;
    return 0;
end;
