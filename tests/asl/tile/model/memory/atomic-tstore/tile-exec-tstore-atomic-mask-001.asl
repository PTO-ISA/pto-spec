// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-MASK-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"Atomic TSTORE obeys PE selection, Local CUBE ExecutionMask polarity and zero policy, and Shared mask rejection","pass_condition":"a one-PE binding updates only its selected coordinate, an all-inactive mask has zero effects, PredInv selects the complement, Zero=1 rejects before effects, PE_MASK=0 skips an invalid address, and a Shared per-element mask is rejected","related_sources":["asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/tile/model/execution/execution-mask.asl"]}
pure func AtomicMaskStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func AtomicMaskDATR(pred_inv: boolean, zero: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = Zeros{3};
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 25;
    instruction[14] = if pred_inv then '1' else '0';
    instruction[13] = if zero then '1' else '0';
    return instruction;
end;

pure func AtomicMaskTileBinding(pe_mode: bits(3), with_mask: boolean)
    => bits(64)
begin
    var instruction = if with_mask then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 3;
    if with_mask then instruction[31:26] = Zeros{6} + 4; end;
    instruction[19] = '1';
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func AtomicMaskSharedBinding(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = '111';
    return instruction;
end;

pure func AtomicMaskAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunAtomicMaskLocal(pe: MemoryAgentId, base: Word,
    pe_mode: bits(3), pred_inv: boolean, zero: boolean,
    with_mask: boolean) => boolean
begin
    SelectExecutionContext(0, pe);
    ResetBundleControlState();
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);
    let start = ExecuteCommandInstruction(AtomicMaskStart(), 32);
    let attributes = ExecuteCommandInstruction(
        AtomicMaskDATR(pred_inv, zero), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(
        AtomicMaskTileBinding(pe_mode, with_mask), 32);
    let address = ExecuteCommandInstruction(AtomicMaskAddress(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed;
    assert BundleTileSourcePayloadsAvailable();
    let completed = ExecuteBundleTileOperation();
    return completed;
end;

func RunAtomicMaskSharedRejected(base: Word)
begin
    SelectExecutionContext(0, 0);
    ResetBundleControlState();
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);
    let start = ExecuteCommandInstruction(AtomicMaskStart(), 32);
    let attributes = ExecuteCommandInstruction(
        AtomicMaskDATR(FALSE, FALSE), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let shared = ExecuteCommandInstruction(
        AtomicMaskSharedBinding(Zeros{6} + 42), 32);
    let address = ExecuteCommandInstruction(AtomicMaskAddress(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           shared == CommandExecution_Executed &&
           address == CommandExecution_Executed;
    CaptureBundleExecutionMaskPredicateTile(
        4, TileLayout_CUBE_M16, 1, 2);
    let completed = ExecuteBundleAtomicTSTOREOperation();
    assert !completed && _LastFault == Fault_TileLegality &&
           _MemoryEventCount == 2;
end;

func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTileForMaskWithPhysical(3, 256,
        16, 2, 1, 2, TileDataType_U32, TileLayout_CUBE_M16, '1111');
    let mask_ready = ConfigurePredicateCellForMask(
        4, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16, '1111');
    assert source_ready && mask_ready && TileCubeDescriptorLegal(_Tiles[[3]]) &&
           TilePredicateCellDescriptorLegal(4);
    InstallRelativeTileFixture(3, 3);
    InstallRelativeTileFixture(4, 4);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 5);
    MarkTileValidRegionDefined(3);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(4);

    for column = 0 to 1 do
        Store(Zeros{PTO_XLEN} + 0x200 + column * 4, 4,
            Zeros{PTO_XLEN} + 10 + column * 10);
        Store(Zeros{PTO_XLEN} + 0x220 + column * 4, 4,
            Zeros{PTO_XLEN} + 10 + column * 10);
        Store(Zeros{PTO_XLEN} + 0x240 + column * 4, 4,
            Zeros{PTO_XLEN} + 10 + column * 10);
    end;
    Store(Zeros{PTO_XLEN} + 0x260, 4, Zeros{PTO_XLEN} + 31);
    StartMemoryEventCapture(0);

    _Tiles[[3]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[3]].defined_valid_elements = 0;
    _Tiles[[3]].contents_defined = FALSE;
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let completed = RunAtomicMaskLocal(
            pe_number as MemoryAgentId, Zeros{PTO_XLEN} + 0x200,
            '001', FALSE, FALSE, TRUE);
        assert completed && _LastFault == Fault_None &&
               _MemoryEventCount == 0;
    end;
    let selected_undefined = RunAtomicMaskLocal(0,
        Zeros{PTO_XLEN} + 0x200, '001', FALSE, FALSE, TRUE);
    assert !selected_undefined && _LastFault == Fault_TileLegality &&
           _MemoryEventCount == 0;
    ClearFault();
    let source_restored = ConfigureCubeTileForMaskWithPhysical(3, 256,
        16, 2, 1, 2, TileDataType_U32, TileLayout_CUBE_M16, '1111');
    assert source_restored;
    InstallRelativeTileFixture(3, 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 5);
    MarkTileValidRegionDefined(3);
    assert TileCubeDescriptorLegal(_Tiles[[3]]);
    assert _Tiles[[3]].contents_defined;
    let selected = RunAtomicMaskLocal(0, Zeros{PTO_XLEN} + 0x200,
        '001', FALSE, FALSE, TRUE);
    assert selected && _LastFault == Fault_None && _MemoryEventCount == 1;
    let retried_operation = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    assert retried_operation != PTO_TILE_OPERATION_COUNT;
    assert TileElementwiseSourceContentsDefined(3);
    assert TileElementwiseSourceEncodingsValidAs(3, TileDataType_U32);
    assert BundleExecutionMaskDataAttributesLegal(
        retried_operation as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert BundleOperationScalarBindingSchemaLegal(
        retried_operation as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert BundleOperationGPRBindingValuesLegal(
        retried_operation as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert BundleTileBindingCount() == 1 &&
           BundleLocalTileSourceCount() == 2 &&
           BundleLocalTileDestinationCount() == 0;
    assert _BundleTileBindings[[0]].source0_valid &&
           _BundleTileBindings[[0]].source1_valid &&
           _BundleTileBindings[[0]].last;
    assert BundleExecutionMaskTileCarrierPresent(
        retried_operation as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert BundleExecutionMaskOrdinaryTileSourceCount(
        retried_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) == 1;
    assert _BundleExecutionMask.valid &&
           _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile &&
           _BundleExecutionMask.predicate_source_ordinal == 1;
    let binding_expected_sources =
        (if TileOperandPresent(retried_operation as
            integer {0..PTO_TILE_OPERATION_COUNT-1}, TileOperand_source0)
         then 1 else 0) +
        (if TileOperandPresent(retried_operation as
            integer {0..PTO_TILE_OPERATION_COUNT-1}, TileOperand_source1)
         then 1 else 0) +
        (if TileOperandPresent(retried_operation as
            integer {0..PTO_TILE_OPERATION_COUNT-1}, TileOperand_source2)
         then 1 else 0) +
        (if TileOperandPresent(retried_operation as
            integer {0..PTO_TILE_OPERATION_COUNT-1}, TileOperand_source3)
         then 1 else 0) +
        (if TileOperandPresent(retried_operation as
            integer {0..PTO_TILE_OPERATION_COUNT-1}, TileOperand_source4)
         then 1 else 0) + 1;
    assert binding_expected_sources == BundleLocalTileSourceCount();
    let binding_expected_destinations = if TileOperandPresent(
        retried_operation as integer {0..PTO_TILE_OPERATION_COUNT-1},
        TileOperand_destination0) then 1 else 0;
    let binding_actual_destinations = BundleLocalTileParentRefCount() +
        BundleSharedPhysicalDestinationCount() +
        BundleSharedReusedDestinationCount();
    assert binding_expected_destinations == binding_actual_destinations;
    assert BundleAssembleOutputStructureLegal() &&
           BundleTileBindingStreamTerminated();
    assert BundleOperationBindingsComplete(
        retried_operation as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert SelectedBundleTileMasksLegal();
    let (retry_type_valid, retry_type) = ResolveBundleEffectiveDataType();
    assert retry_type_valid && retry_type == TileDataType_U32;

    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    let inactive = RunAtomicMaskLocal(0, Zeros{PTO_XLEN} + 0x220,
        '111', FALSE, FALSE, TRUE);
    assert inactive && _LastFault == Fault_None && _MemoryEventCount == 1;

    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    let inverted = RunAtomicMaskLocal(0, Zeros{PTO_XLEN} + 0x220,
        '111', TRUE, FALSE, TRUE);
    assert inverted && _LastFault == Fault_None && _MemoryEventCount == 2;

    let rejected_zero = RunAtomicMaskLocal(0, Zeros{PTO_XLEN} + 0x240,
        '111', FALSE, TRUE, TRUE);
    assert !rejected_zero && _LastFault == Fault_TileLegality &&
           _MemoryEventCount == 2;
    let zero_pe_mask = RunAtomicMaskLocal(0, Zeros{PTO_XLEN} + 0x241,
        Zeros{3}, FALSE, FALSE, FALSE);
    assert zero_pe_mask && _LastFault == Fault_None && _MemoryEventCount == 2;

    StopMemoryEventCapture();
    assert !_MemoryEventCaptureEnabled && _MemoryEventCount == 2;
    let selected_word0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    let selected_word1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x204, 4);
    let inactive_word0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x220, 4);
    let inactive_word1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x224, 4);
    let zero_reject_word0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x240, 4);
    let zero_reject_word1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x244, 4);
    let zero_mask_sentinel = LoadUnsigned(Zeros{PTO_XLEN} + 0x260, 4);
    assert selected_word0 == Zeros{PTO_XLEN} + 13 &&
           selected_word1 == Zeros{PTO_XLEN} + 20 &&
           inactive_word0 == Zeros{PTO_XLEN} + 10 &&
           inactive_word1 == Zeros{PTO_XLEN} + 25 &&
           zero_reject_word0 == Zeros{PTO_XLEN} + 10 &&
           zero_reject_word1 == Zeros{PTO_XLEN} + 20 &&
           zero_mask_sentinel == Zeros{PTO_XLEN} + 31;
    let selected_event = _MemoryEvents[[0]];
    let inverted_event = _MemoryEvents[[1]];
    assert selected_event.kind == MemoryEvent_Atomic &&
           selected_event.agent == 0 &&
           selected_event.address == Zeros{PTO_XLEN} + 0x200 &&
           selected_event.read_value == Zeros{PTO_XLEN} + 10 &&
           selected_event.write_value == Zeros{PTO_XLEN} + 13 &&
           inverted_event.kind == MemoryEvent_Atomic &&
           inverted_event.address == Zeros{PTO_XLEN} + 0x224 &&
           inverted_event.read_value == Zeros{PTO_XLEN} + 20 &&
           inverted_event.write_value == Zeros{PTO_XLEN} + 25;

    ConfigureTile(5, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 9);
    InstallSharedTile((Zeros{6} + 42) as SharedTileID, _Tiles[[5]], '1111');
    Store(Zeros{PTO_XLEN} + 0x280, 4, Zeros{PTO_XLEN} + 12);
    Store(Zeros{PTO_XLEN} + 0x284, 4, Zeros{PTO_XLEN} + 14);
    RunAtomicMaskSharedRejected(Zeros{PTO_XLEN} + 0x280);
    let shared_after_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x280, 4);
    let shared_after_second = LoadUnsigned(Zeros{PTO_XLEN} + 0x284, 4);
    let shared_source_value = ReadSharedTileWord(
        (Zeros{6} + 42) as SharedTileID, 0);
    assert !_MemoryEventCaptureEnabled &&
           shared_after_first == Zeros{PTO_XLEN} + 12 &&
           shared_after_second == Zeros{PTO_XLEN} + 14 &&
           shared_source_value == Zeros{PTO_XLEN} + 7;
    return 0;
end;
