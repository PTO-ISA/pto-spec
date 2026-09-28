// PTO-TEST: {"id":"PTO-AVS-BLOCK-ROW-EXPAND-BROADCAST-BYTE-OFFSET-R2-ENCODING-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-TROWEXPANDMAX-CONTRACT-001"],"kind":"execution","summary":"Arithmetic row expansion validates the selected CUBE byte-offset element and ignores invalid encodings in unselected broadcast columns.","pass_condition":"For TF32 CUBE_M16 with byte offset 4, MAX succeeds when slot 1 is valid and slot 0 has an invalid TF32 encoding, and faults before destination allocation when the selected slot 1 has an invalid encoding.","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/expansion.asl","asl/tile/model/legality/dtype-layout.asl"]}

pure func RowExpandStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '01001';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_TF32);
    return instruction;
end;

pure func RowExpandAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[17:15] = Zeros{3} + 4;
    instruction[11:7] = Zeros{5} + 31;
    return instruction;
end;

pure func RowExpandBinaryBinding(source0: bits(6), source1: bits(6))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

func RunSelectedEncodingCase(selected_invalid: boolean)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(1, 256, 2, 2,
        TileDataType_TF32, TileLayout_CUBE_M16);
    let broadcast_ready = ConfigureCubeTile(2, 256, 2, 2,
        TileDataType_TF32, TileLayout_CUBE_M16);
    assert source_ready && broadcast_ready;
    let invalid_tf32 = Zeros{PTO_XLEN} + 0x3f800001;
    let one = Zeros{PTO_XLEN} + 0x3f800000;
    let two = Zeros{PTO_XLEN} + 0x40000000;
    assert !TileNumericEncodingValid(TileDataType_TF32, invalid_tf32);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(1, row, column, one);
        end;
        WriteTileElement(2, row, 0,
            if selected_invalid then two else invalid_tf32);
        WriteTileElement(2, row, 1,
            if selected_invalid then invalid_tf32 else two);
    end;

    let started = ExecuteCommandInstruction(RowExpandStart(), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let binding = ExecuteCommandInstruction(
        RowExpandBinaryBinding(Zeros{6} + 1, Zeros{6} + 2), 32);
    assert binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x049)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed == !selected_invalid;
    if selected_invalid then
        assert _LastFault == Fault_TileLegality;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    else
        assert _LastFault == Fault_None;
        let destination = _BundleTileBindings[[0]].destination;
        for row = 0 to 1 looplimit 2 do
            for column = 0 to 1 looplimit 2 do
                assert ReadTileElement(destination, row, column) ==
                    Zeros{PTO_XLEN} + 0x40000000;
            end;
        end;
        assert NumericStatusFlags() == Zeros{5};
    end;
end;

func main() => integer
begin
    // The nonzero byte offset selects slot 1; invalid TF32 in slot 0 is
    // outside the consumed broadcast view and remains unvalidated.
    RunSelectedEncodingCase(FALSE);
    // Invalid TF32 in the selected slot is rejected before allocation.
    RunSelectedEncodingCase(TRUE);
    return 0;
end;
