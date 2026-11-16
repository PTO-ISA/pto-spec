// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MGATHER-ZERO-BOUND-PAYLOAD-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-BSTART-MGATHER-SCHEMA-001"],"kind":"boundary","summary":"Nonzero bound selectors containing zero describe the legal singleton range Min=Max=0.","pass_condition":"The encoded range remains present and allows the U32 load at index zero from [Base,Base+4), producing the expected value.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/tile/model/memory/addressing.asl"]}
pure func ZeroBoundStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00411181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func ZeroBoundInput() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func ZeroBoundIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{64});
    Store(Zeros{PTO_XLEN} + 0x700, 4, Zeros{PTO_XLEN} + 0x12345678);
    WritePEGPR(0, 2, Zeros{64} + 0x700);
    WritePEGPR(0, 3, Zeros{64});
    WritePEGPR(0, 4, Zeros{64});
    let started = ExecuteCommandInstruction(ZeroBoundStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let input = ExecuteCommandInstruction(ZeroBoundInput(), 32);
    let scalar = ExecuteCommandInstruction(ZeroBoundIOR(), 32);
    assert input == CommandExecution_Executed &&
           scalar == CommandExecution_Executed;
    let operation = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    assert BundleIndexedTLSURangeDescriptorPresent(operation as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert SInt(ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source1)) == 0;
    assert SInt(ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source2)) == 0;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x700;
    StopMemoryEventCapture();
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x12345678;
    return 0;
end;
