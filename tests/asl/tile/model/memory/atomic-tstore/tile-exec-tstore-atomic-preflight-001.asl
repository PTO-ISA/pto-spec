// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-PREFLIGHT-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001"],"kind":"execution","summary":"Atomic TSTORE preflights the complete PE footprint before emitting an atomic effect","pass_condition":"last-coordinate page, permission, and alignment faults leave the first valid target and Atomic event stream unchanged, while Normal TSTORE retains its first completed store before the same later alignment fault","related_sources":["asl/scalar/model/agu/memory.asl","asl/tile/model/memory/load-store.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl"]}
pure func AtomicPreflightStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func AtomicPreflightDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5};
    return instruction;
end;

pure func AtomicPreflightSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    instruction[11:9] = '111';
    return instruction;
end;

pure func AtomicPreflightAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunAtomicPreflightFault(case_id: integer {0..2}) => boolean
begin
    ResetProfileState();
    SetCurrentACR(0);
    assert CurrentACR() == 0;
    let rows = if case_id == 2 then 2 else 1;
    let columns = if case_id == 2 then 1 else 2;
    let base = if case_id == 0 then Zeros{PTO_XLEN} + 4092
        else if case_id == 1 then Zeros{PTO_XLEN} + 3068
        else Zeros{PTO_XLEN} + 0x180;
    let stride = if case_id == 2 then Zeros{PTO_XLEN} + 5
        else Zeros{PTO_XLEN} + 8;
    ConfigureTile(0, 1024, 16, 16, rows, columns,
        TileDataType_U32, TileLayout_RowMajor);
    assert TileDescriptorLegal(0);
    for row = 0 to rows - 1 do
        for column = 0 to columns - 1 do
            WriteTileElement(0, row, column,
                Zeros{PTO_XLEN} + row + column + 1);
        end;
    end;
    MarkTileValidRegionDefined(0);
    Store(base, 4, Zeros{PTO_XLEN} + 10);
    assert _LastFault == Fault_None && CurrentACR() == 0;
    if case_id == 1 then
        Store(base + 4, 4, Zeros{PTO_XLEN} + 20);
        assert _LastFault == Fault_None && CurrentACR() == 0;
        let observed_second_after_store = LoadUnsigned(base + 4, 4);
        assert _LastFault == Fault_None &&
               observed_second_after_store == Zeros{PTO_XLEN} + 20;
    elsif case_id == 2 then
        Store(base + 5, 1, Zeros{PTO_XLEN} + 0xA1);
        Store(base + 6, 1, Zeros{PTO_XLEN} + 0xB2);
        Store(base + 7, 1, Zeros{PTO_XLEN} + 0xC3);
        Store(base + 8, 1, Zeros{PTO_XLEN} + 0xD4);
    end;
    let initial_first = LoadUnsigned(base, 4);
    assert initial_first == Zeros{PTO_XLEN} + 10;
    let initial_second = if case_id == 1 then
        LoadUnsigned(base + 4, 4) else Zeros{PTO_XLEN};
    if case_id == 1 then assert initial_second == Zeros{PTO_XLEN} + 20; end;
    if case_id == 2 then
        assert ReadMemoryByte(base + 5) == Zeros{8} + 0xA1 &&
               ReadMemoryByte(base + 6) == Zeros{8} + 0xB2 &&
               ReadMemoryByte(base + 7) == Zeros{8} + 0xC3 &&
               ReadMemoryByte(base + 8) == Zeros{8} + 0xD4;
    end;
    if case_id == 1 then SetCurrentACR(2); end;
    let first_target = TileMemoryStridedByteAddress(base, 0, 0, stride,
        TileDataType_U32);
    let second_target = TileMemoryStridedByteAddress(base,
        if case_id == 2 then 1 else 0, if case_id == 2 then 0 else 1,
        stride, TileDataType_U32);
    assert first_target == base;
    assert second_target == if case_id == 2 then base + 5 else base + 4;
    let first_read_probe = ProbeTileMemoryAccess(first_target,
        TileDataType_U32, FALSE);
    let first_write_probe = ProbeTileMemoryAccess(first_target,
        TileDataType_U32, TRUE);
    let second_read_probe = ProbeTileMemoryAccess(second_target,
        TileDataType_U32, FALSE);
    let second_write_probe = ProbeTileMemoryAccess(second_target,
        TileDataType_U32, TRUE);
    assert first_read_probe.fault == Fault_None &&
           first_write_probe.fault == Fault_None;
    if case_id == 2 then
        assert second_read_probe.fault == Fault_DataAlignment &&
               second_write_probe.fault == Fault_DataAlignment;
    else
        assert second_read_probe.fault == Fault_DataPage &&
               second_write_probe.fault == Fault_DataPage;
    end;

    WriteGPR(2, base);
    WriteGPR(3, stride);
    let start = ExecuteCommandInstruction(AtomicPreflightStart(), 32);
    let attributes = ExecuteCommandInstruction(AtomicPreflightDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + rows);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let source = ExecuteCommandInstruction(AtomicPreflightSource(), 32);
    let address = ExecuteCommandInstruction(AtomicPreflightAddress(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleTileSourcePayloadsAvailable();
    assert BundleLocalTileSourceCount() == 1 &&
           BundleTileBindingCount() == 1 &&
           SelectedBundleTileMasksLegal();
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    assert decoded != PTO_TILE_OPERATION_COUNT;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let (type_valid, effective_type) = ResolveBundleEffectiveDataType();
    assert BundleAtomicTStoreSelected() &&
           TileOperationOfIndex(operation) == TileOperation_TSTORE &&
           BundleOperationScalarBindingSchemaLegal(operation) &&
           BundleOperationGPRBindingValuesLegal(operation) &&
           BundleOperationBindingsComplete(operation) &&
           type_valid && effective_type == TileDataType_U32;
    assert !_BundleExecutionMask.valid &&
           _BundleDataAttributes.pad_value == Zeros{2} &&
           _Tiles[[0]].data_type == TileDataType_U32 &&
           _Tiles[[0]].layout == TileLayout_RowMajor &&
           _Tiles[[0]].valid_rows == rows &&
           _Tiles[[0]].valid_columns == columns;
    if case_id == 1 then assert CurrentACR() == 2; end;

    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    if case_id == 0 then
        assert _LastFault == Fault_DataPage && _FaultAddress == second_target;
    end;
    if case_id == 1 then
        assert _LastFault == Fault_DataPage && _FaultAddress == second_target;
    end;
    if case_id == 2 then
        assert _LastFault == Fault_DataAlignment &&
               _FaultAddress == second_target;
    end;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    assert !_MemoryEventCaptureEnabled;
    let after_atomic_first = LoadUnsigned(base, 4);
    assert after_atomic_first == initial_first;
    if case_id == 1 then
        let after_atomic_second = LoadUnsigned(base + 4, 4);
        assert after_atomic_second == initial_second;
    elsif case_id == 2 then
        assert ReadMemoryByte(base + 5) == Zeros{8} + 0xA1 &&
               ReadMemoryByte(base + 6) == Zeros{8} + 0xB2 &&
               ReadMemoryByte(base + 7) == Zeros{8} + 0xC3 &&
               ReadMemoryByte(base + 8) == Zeros{8} + 0xD4;
    end;

    if case_id == 2 then
        ClearFault();
        StartMemoryEventCapture(0);
        TSTORE(base, stride, 0);
        assert _LastFault == Fault_DataAlignment && _MemoryEventCount == 1;
        assert _MemoryEvents[[0]].kind == MemoryEvent_Store &&
               _MemoryEvents[[0]].address == base &&
               _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 1;
        StopMemoryEventCapture();
        let after_normal_first = LoadUnsigned(base, 4);
        assert ReadMemoryByte(base + 5) == Zeros{8} + 0xA1 &&
               ReadMemoryByte(base + 6) == Zeros{8} + 0xB2 &&
               ReadMemoryByte(base + 7) == Zeros{8} + 0xC3 &&
               ReadMemoryByte(base + 8) == Zeros{8} + 0xD4;
        assert after_normal_first == Zeros{PTO_XLEN} + 1;
    end;
    return TRUE;
end;

func main() => integer
begin
    let page_fault = RunAtomicPreflightFault(0);
    assert page_fault;
    let permission_fault = RunAtomicPreflightFault(1);
    assert permission_fault;
    let alignment_fault = RunAtomicPreflightFault(2);
    assert alignment_fault;
    return 0;
end;
