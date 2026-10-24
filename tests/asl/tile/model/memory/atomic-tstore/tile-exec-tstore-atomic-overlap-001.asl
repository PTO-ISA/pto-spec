// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-OVERLAP-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001"],"kind":"execution","summary":"zero-stride and cross-PE duplicate targets retain every U32 ADD contribution","pass_condition":"two logical elements per PE and two distinct PEs contribute exactly once to one aligned U32 target and emit four Atomic events","related_sources":["asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/arch/memory-model/atomicity.asl"]}
pure func OverlapStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func OverlapDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5};
    return instruction;
end;

pure func OverlapSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func OverlapIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunOverlapPE(pe: MemoryAgentId, first: Word, second: Word) => boolean
begin
    SelectExecutionContext(0, pe);
    ResetBundleControlState();
    ConfigureTile(0, 128, 2, 1, 2, 1,
        TileDataType_U32, TileLayout_RowMajor);
    assert TileDescriptorLegal(0);
    WriteTileElement(0, 0, 0, first);
    WriteTileElement(0, 1, 0, second);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN});
    let start = ExecuteCommandInstruction(OverlapStart(), 32);
    let datr = ExecuteCommandInstruction(OverlapDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(OverlapSource(), 32);
    let ior = ExecuteCommandInstruction(OverlapIOR(), 32);
    assert start == CommandExecution_Executed &&
           datr == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           ior == CommandExecution_Executed;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert decoded != PTO_TILE_OPERATION_COUNT &&
           TileOperationOfIndex(operation) == TileOperation_TSTORE;
    assert BundleTileBindingCount() == 1 &&
           _BundleTileBindings[[0]].pe_mask == '1111';
    assert BundleSharedBindingCount() == 0 &&
           BundleSharedBindingPhysicalCount() == 0 &&
           BundleTileBindingCount() == 1;
    assert BundleAtomicTStoreSelected() &&
           BundleAtomicTStoreCurrentPESelected() &&
           BundleOperationScalarBindingSchemaLegal(operation) &&
           BundleOperationGPRBindingValuesLegal(operation) &&
           BundleOperationBindingsComplete(operation) &&
           SelectedBundleTileMasksLegal() &&
           TileElementwiseSourceContentsDefined(0);
    let (type_valid, effective_type) = ResolveBundleEffectiveDataType();
    assert _BundleDataAttributesPresent &&
           _BundleDataAttributes.canonicalize &&
           _BundleDataAttributes.data_layout == Zeros{5} &&
           _BundleDataAttributes.pad_value == Zeros{2} &&
           UInt(_BundleDataAttributes.rounding_mode) == 0 &&
           !_BundleDataAttributes.saturating &&
           !_BundleDataAttributes.execution_mask_zero &&
           !_BundleControlAttributes.atomic;
    assert type_valid && effective_type == TileDataType_U32 &&
           GMReductionOperationDataTypeLegal(GMReduction_ADD,
               effective_type) && TileRegularTLSUDataTypeSupported(
                   effective_type);
    assert !_BundleExecutionMask.valid &&
           _BundleTileBindings[[0]].valid &&
           !_BundleTileBindings[[0]].destination_valid &&
           _BundleTileBindings[[0]].source0_valid &&
           !_BundleTileBindings[[0]].source1_valid &&
           _BundleTileBindings[[0]].last &&
           _BundleTileBindings[[0]].destination_size == 0;
    assert _Tiles[[0]].data_type == TileDataType_U32 &&
           _Tiles[[0]].layout == TileLayout_RowMajor &&
           _Tiles[[0]].columns == 1 && _Tiles[[0]].valid_rows == 2 &&
           _Tiles[[0]].valid_columns == 1 && TileDescriptorLegal(0) &&
           TileElementwiseSourceEncodingsValidAs(0, TileDataType_U32);
    assert UInt(_BundleDimensions[[0]]) == 1 &&
           UInt(_BundleDimensions[[1]]) == 2 &&
           UInt(_BundleDimensions[[2]]) == 1 &&
           BundleDestinationPhysicalColumns(TRUE, 0) == 1 &&
           !_BundleExecutionMask.valid &&
           _BundleDataAttributes.pad_value == Zeros{2} &&
           BundleExecutionMaskDataAttributesLegal(operation);
    assert _LastFault == Fault_None;
    let completed = ExecuteBundleTileOperation();
    return completed;
end;

func main() => integer
begin
    ResetProfileState();
    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN});
    StartMemoryEventCapture(0);
    let pe0_completed = RunOverlapPE(0 as MemoryAgentId, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2);
    assert pe0_completed;
    assert _LastFault == Fault_None;
    let pe1_completed = RunOverlapPE(1 as MemoryAgentId, Zeros{PTO_XLEN} + 10,
        Zeros{PTO_XLEN} + 20);
    assert pe1_completed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 4;
    StopMemoryEventCapture();
    let actual = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic &&
           _MemoryEvents[[0]].agent == 0 &&
           _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x200 &&
           _MemoryEvents[[0]].read_value == Zeros{PTO_XLEN} &&
           _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 1;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Atomic &&
           _MemoryEvents[[1]].agent == 0 &&
           _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x200 &&
           _MemoryEvents[[1]].read_value == Zeros{PTO_XLEN} + 1 &&
           _MemoryEvents[[1]].write_value == Zeros{PTO_XLEN} + 3;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Atomic &&
           _MemoryEvents[[2]].agent == 1 &&
           _MemoryEvents[[2]].address == Zeros{PTO_XLEN} + 0x200 &&
           _MemoryEvents[[2]].read_value == Zeros{PTO_XLEN} + 3 &&
           _MemoryEvents[[2]].write_value == Zeros{PTO_XLEN} + 13;
    assert _MemoryEvents[[3]].kind == MemoryEvent_Atomic &&
           _MemoryEvents[[3]].agent == 1 &&
           _MemoryEvents[[3]].address == Zeros{PTO_XLEN} + 0x200 &&
           _MemoryEvents[[3]].read_value == Zeros{PTO_XLEN} + 13 &&
           _MemoryEvents[[3]].write_value == Zeros{PTO_XLEN} + 33;
    assert actual == Zeros{PTO_XLEN} + 33;
    return 0;
end;
