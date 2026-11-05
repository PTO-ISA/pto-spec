// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MGATHER-RANGE-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-BSTART-MGATHER-SCHEMA-001","PTO-INST-TILE-MGATHER","PTO-INST-BLOCK-BSTART-MGATHER"],"kind":"execution","summary":"Decoded MGATHER binds a conservative signed range without changing indexed loads or padding.","pass_condition":"S32 byte displacements -4, 0, and 3 produce [0xfc,0x104), exact loads and Max padding; the deferred GM-obligation snapshot does not reuse Min as a row stride; absence preserves the results; an index outside a present certificate still executes its architectural access without a new range fault; a decoded Min value with nonzero upper 32 bits orders above Max=1 and faults before effects, while Min=0 executes.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/gm-obligation-dispatch.asl","asl/block/model/dispatch/tlsu-mgather.asl","asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func RangeGatherStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func RangeGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    instruction[8:7] = '00';
    return instruction;
end;

pure func RangeGatherIOR(base: bits(5), minimum: bits(5),
                         maximum: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = base;
    instruction[24:20] = minimum;
    instruction[31:27] = maximum;
    return instruction;
end;

pure func RangeGatherMaxPad() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = '01';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

func RunRangeGather(descriptor_present: boolean)
begin
    ResetProfileState();
    if descriptor_present then
        let launched = LaunchKernelInvocation(0,
            Zeros{PTO_XLEN} + 0x800);
        assert launched == KernelLifecycle_Started;
        SelectExecutionContext(0, 0);
        _PC = Zeros{PTO_XLEN} + 0x800;
    end;
    ConfigureTile(0, 128, 1, 4, 1, 3, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} - 4);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 3);
    Store(Zeros{PTO_XLEN} + 0xfc, 1, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 0x100, 1, Zeros{PTO_XLEN} + 0x27);
    Store(Zeros{PTO_XLEN} + 0x103, 1, Zeros{PTO_XLEN} + 0x44);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(0, 3, if descriptor_present then Zeros{64} - 4
        else Zeros{64} + 99);
    WritePEGPR(0, 4, if descriptor_present then Zeros{64} + 3
        else Zeros{64} - 99);
    let started = ExecuteCommandInstruction(
        RangeGatherStart(TileDataTypeToEncoding(TileDataType_U8)), 32);
    let padded = ExecuteCommandInstruction(RangeGatherMaxPad(), 32);
    assert started == CommandExecution_Executed;
    assert padded == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    WritePEGPR(0, 5, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(RangeGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let range_ior = ExecuteCommandInstruction(
        RangeGatherIOR(Zeros{5} + 2,
            if descriptor_present then Zeros{5} + 3 else Zeros{5},
            if descriptor_present then Zeros{5} + 4 else Zeros{5}), 32);
    assert range_ior == CommandExecution_Executed;
    if descriptor_present then
        let operation = DecodeTileOperation(TileDecode_TLSU,
            BundleOperationDecodeCode(_BundleOperation));
        assert BundleIndexedTLSURangeDescriptorPresent(operation as integer {0..PTO_TILE_OPERATION_COUNT-1});
        let interval = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
            ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
                _BundleScalarBindings[[0]].source0),
            ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
                _BundleScalarBindings[[0]].source1),
            ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
                _BundleScalarBindings[[0]].source2), 1);
        assert interval.valid && interval.start_byte == 0xfc &&
               interval.end_byte_exclusive == 0x104;
    end;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    if descriptor_present then
        assert _GMObligations[[0]][[0]][[0]].active &&
               _GMObligations[[0]][[0]][[0]].row_stride_bytes == Zeros{PTO_XLEN};
        let ended = EndKernelInvocation(0);
        assert ended == KernelLifecycle_Started;
    end;
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0xfc;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEvents[[2]].address == Zeros{PTO_XLEN} + 0x103;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 3;
    assert _Tiles[[destination]].columns == 4;
    for row = 0 to _Tiles[[destination]].rows - 1 looplimit 65536 do
        for column = 0 to _Tiles[[destination]].columns - 1 looplimit 65536 do
            let expected = if row == 0 && column == 0 then Zeros{PTO_XLEN} + 0x11
                else if row == 0 && column == 1 then Zeros{PTO_XLEN} + 0x27
                else if row == 0 && column == 2 then Zeros{PTO_XLEN} + 0x44
                else Zeros{PTO_XLEN} + 0xff;
            assert ReadTileElement(destination,
                row as integer {0..65535},
                column as integer {0..65535}) == expected;
        end;
    end;
    StopMemoryEventCapture();
end;

func RunUncertifiedAccess()
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 4);
    Store(Zeros{PTO_XLEN} + 0x104, 1, Zeros{PTO_XLEN} + 0x5a);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(0, 3, Zeros{64});
    WritePEGPR(0, 4, Zeros{64});
    let started = ExecuteCommandInstruction(
        RangeGatherStart(TileDataTypeToEncoding(TileDataType_U8)), 32);
    let padded = ExecuteCommandInstruction(RangeGatherMaxPad(), 32);
    assert started == CommandExecution_Executed;
    assert padded == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let binding = ExecuteCommandInstruction(RangeGatherBinding(), 32);
    let scalar = ExecuteCommandInstruction(RangeGatherIOR(
        Zeros{5} + 2, Zeros{5} + 3, Zeros{5} + 4), 32);
    assert binding == CommandExecution_Executed;
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x104;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    StopMemoryEventCapture();
end;

func RunDecodedBoundWidthCase(minimum: Word, expect_fault: boolean)
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x100, 1, Zeros{PTO_XLEN} + 0x5a);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(0, 3, minimum);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 1);
    let started = ExecuteCommandInstruction(
        RangeGatherStart(TileDataTypeToEncoding(TileDataType_U8)), 32);
    let padded = ExecuteCommandInstruction(RangeGatherMaxPad(), 32);
    assert started == CommandExecution_Executed;
    assert padded == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let binding = ExecuteCommandInstruction(RangeGatherBinding(), 32);
    let scalar = ExecuteCommandInstruction(RangeGatherIOR(
        Zeros{5} + 2, Zeros{5} + 3, Zeros{5} + 4), 32);
    assert binding == CommandExecution_Executed;
    assert scalar == CommandExecution_Executed;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    let operation = decoded as integer
        {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleIndexedTLSURangeDescriptorPresent(operation);
    assert ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source1) == minimum;
    assert ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source2) == Zeros{PTO_XLEN} + 1;
    if expect_fault then
        assert !BundleIndexedTLSUCurrentPEBoundsOrdered(operation);
    else
        assert BundleIndexedTLSUCurrentPEBoundsOrdered(operation);
    end;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    if expect_fault then
        assert !completed && _LastFault == Fault_TileLegality;
        assert _MemoryEventCount == 0;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    else
        assert completed && _LastFault == Fault_None;
        assert _MemoryEventCount == 1;
        assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x100;
        let destination = _BundleTileBindings[[0]].destination;
        assert ReadTileElement(destination, 0, 0) ==
            Zeros{PTO_XLEN} + 0x5a;
    end;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    RunRangeGather(TRUE);
    RunRangeGather(FALSE);
    RunUncertifiedAccess();
    // Changing only Min's upper 32 bits distinguishes full-width comparison.
    RunDecodedBoundWidthCase(Zeros{PTO_XLEN}, FALSE);
    RunDecodedBoundWidthCase(Zeros{PTO_XLEN} + 0x0000000100000000, TRUE);
    return 0;
end;
