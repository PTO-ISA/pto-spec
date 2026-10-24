// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-ATOMIC-M32-SLAB-001","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"two PE-local M32 producers atomically update the complete FP32 slab","pass_condition":"two distinct kernel PE requests add FP32 1.0 and 2.0 to every one of 8192 GM values initialized to 7.0, produce 10.0 everywhere, preserve outer guards, allocate no index tile, and run with event capture disabled under the 64-KiB profile","related_sources":["asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/tile/model/memory/atomic-tstore.asl"]}

pure func AtomicSlabStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP32);
    instruction[24:20] = Zeros{5} + 1;
    return instruction;
end;

pure func AtomicSlabDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = Zeros{3};
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 24; // M322ND
    return instruction;
end;

pure func AtomicSlabSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '101'; // PE0 and PE1
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicSlabAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func ConfigureAtomicSlabSource(input: Word)
begin
    let configured = ConfigureCubeTileForMaskWithPhysical(0, 32768,
        32, 256, 32, 256, TileDataType_FP32,
        TileLayout_CUBE_M32, '1111');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    var tile = _Tiles[[0]];
    for row = 0 to 31 do
        for column = 0 to 255 do
            let element = TileStorageIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            tile.payload[[element]] = input;
            tile.defined_elements[element] = '1';
        end;
    end;
    tile.defined_valid_elements = 8192;
    tile.contents_defined = TRUE;
    _Tiles[[0]] = tile;
end;

func ExecuteAtomicSlabProducer(pe: MemoryAgentId, value: Word,
                               dynamic_pc: Word)
begin
    SelectExecutionContext(0, pe);
    ConfigureAtomicSlabSource(value);
    WriteGPR(2, Zeros{PTO_XLEN} + 4096);
    WriteGPR(3, Zeros{PTO_XLEN} + 1024);
    _PC = dynamic_pc;
    _BPC = dynamic_pc;
    _CurrentProgramOrder = (20 + pe) as integer {0..65535};
    _PEProgramOrder[[0]][[pe]] = (20 + pe) as integer {0..65535};

    let start = ExecuteCommandInstruction(AtomicSlabStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 256);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let datr = ExecuteCommandInstruction(AtomicSlabDATR(), 32);
    let source = ExecuteCommandInstruction(AtomicSlabSource(), 32);
    let address = ExecuteCommandInstruction(AtomicSlabAddress(), 32);
    assert start == CommandExecution_Executed &&
           datr == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           _BundleTileBindings[[0]].pe_mask == '1100' &&
           BundleTileBindingCount() == 1 &&
           !_MemoryEventCaptureEnabled;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let source_tile_index = BundleTileSourceIndex(0, FALSE);
    assert BundleAtomicTStoreSelected() &&
           BundleAtomicTStoreCurrentPESelected() &&
           TileOperationOfIndex(operation) == TileOperation_TSTORE;
    assert BundleOperationScalarBindingSchemaLegal(operation) &&
           BundleOperationGPRBindingValuesLegal(operation) &&
           BundleOperationBindingsComplete(operation) &&
           SelectedBundleTileMasksLegal();
    let (type_valid, effective_type) = ResolveBundleEffectiveDataType();
    assert type_valid && effective_type == TileDataType_FP32 &&
           GMReductionOperationDataTypeLegal(GMReduction_ADD,
               effective_type) &&
           TileRegularTLSUDataTypeSupported(effective_type);
    assert _BundleDataAttributesPresent &&
           _BundleDataAttributes.canonicalize &&
           UInt(_BundleDataAttributes.rounding_mode) == 0 &&
           !_BundleDataAttributes.saturating &&
           _BundleDataAttributes.data_type == DTYPE_NONE &&
           _BundleDataAttributes.data_layout ==
               (Zeros{5} + 24) &&
           !_BundleDataAttributes.execution_mask_zero &&
           !_BundleDataAttributes.execution_mask_invert &&
           !_BundleControlAttributes.atomic;
    assert _BundleTileBindings[[0]].valid &&
           !_BundleTileBindings[[0]].destination_valid &&
           _BundleTileBindings[[0]].source0_valid &&
           !_BundleTileBindings[[0]].source1_valid &&
           _BundleTileBindings[[0]].last &&
           _BundleTileBindings[[0]].destination_size == 0;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN} + 256 &&
           _BundleDimensions[[1]] == Zeros{PTO_XLEN} + 32 &&
           _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 1 &&
           _BundleDimensionPresent[[0]] &&
           _BundleDimensionPresent[[1]] &&
           !_BundleDimensionPresent[[2]];
    assert TileCubeDescriptorLegal(_Tiles[[source_tile_index]]);
    assert _TileAllocationMasks[[source_tile_index]] == '1111';
    assert TileCubeLayoutDataTypeSupported(
        TileLayout_CUBE_M32, TileDataType_FP32);
    assert _Tiles[[source_tile_index]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[source_tile_index]].valid_rows == 32 &&
           _Tiles[[source_tile_index]].valid_columns == 256;
    assert TileElementwiseSourceContentsDefined(source_tile_index);
    assert TileElementwiseSourceEncodingsValidAs(
        source_tile_index, TileDataType_FP32);
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    assert !_MemoryEventCaptureEnabled;
end;

func main() => integer
begin
    ResetProfileState();
    assert PTO_MODEL_MEMORY_BYTES == 65536;
    let entry = Zeros{PTO_XLEN} + 0x200;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    assert invocation != 0;

    let base = Zeros{PTO_XLEN} + 4096;
    _Memory[[4095]] = Zeros{8} + 0xa5;
    for element = 0 to 8191 do
        let byte = 4096 + element * 4;
        _Memory[[byte + 0]] = Zeros{8};
        _Memory[[byte + 1]] = Zeros{8};
        _Memory[[byte + 2]] = Zeros{8} + 0xe0;
        _Memory[[byte + 3]] = Zeros{8} + 0x40;
    end;
    _Memory[[36864]] = Zeros{8} + 0x5a;

    ExecuteAtomicSlabProducer(0 as MemoryAgentId,
        Zeros{PTO_XLEN} + 0x3f800000, entry + 0x20);
    let producer0 = _GMObligations[[0]][[0]][[0]];
    assert producer0.active && producer0.state == GMObligation_Completed &&
           producer0.captured_atomic_tstore &&
           producer0.invocation == invocation && producer0.agent == 0 &&
           producer0.identity == 0 && producer0.core_identity == 0 &&
           producer0.atomic_tstore_target_count == 8192 &&
           producer0.atomic_tstore_committed_count == 8192;

    ExecuteAtomicSlabProducer(1 as MemoryAgentId,
        Zeros{PTO_XLEN} + 0x40000000, entry + 0x40);
    let producer1 = _GMObligations[[0]][[1]][[0]];
    assert producer1.active && producer1.state == GMObligation_Completed &&
           producer1.captured_atomic_tstore &&
           producer1.invocation == invocation && producer1.agent == 1 &&
           producer1.identity == 0 && producer1.core_identity == 0 &&
           producer1.atomic_tstore_target_count == 8192 &&
           producer1.atomic_tstore_committed_count == 8192;
    assert producer0.identity == producer1.identity;
    assert producer0.core_identity == producer1.core_identity;
    assert producer0.invocation == producer1.invocation;
    assert producer0.agent == 0 && producer1.agent == 1;
    assert producer0.base_address == base;
    assert producer1.base_address == base;
    assert producer0.row_stride_bytes == Zeros{PTO_XLEN} + 1024;
    assert producer1.row_stride_bytes == Zeros{PTO_XLEN} + 1024;

    SelectExecutionContext(0, 0);
    var source_register_count: integer {0..64} = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index as TileIndex]].allocated then
            source_register_count = (source_register_count + 1)
                as integer {0..64};
            assert index == 0 &&
                   _Tiles[[index as TileIndex]].data_type == TileDataType_FP32 &&
                   _Tiles[[index as TileIndex]].layout == TileLayout_CUBE_M32;
        end;
    end;
    assert source_register_count == 1;
    assert _Memory[[4095]] == Zeros{8} + 0xa5 &&
           _Memory[[36864]] == Zeros{8} + 0x5a;
    for element = 0 to 8191 do
        let byte = 4096 + element * 4;
        assert _Memory[[byte + 0]] == Zeros{8} &&
               _Memory[[byte + 1]] == Zeros{8} &&
               _Memory[[byte + 2]] == Zeros{8} + 0x20 &&
               _Memory[[byte + 3]] == Zeros{8} + 0x41;
    end;
    return 0;
end;
