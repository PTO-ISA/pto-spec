// PTO-TEST: {"id":"PTO-AVS-TILE-TROWSUM-OPERATION-VIEW-CAPACITY-MASK-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl","requirements":["PTO-TROWSUM-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"fault","summary":"A cross-type reduction rejects an undersized result and preserves the strict zero-PE-mask no-op.","pass_condition":"A BF16 output requiring ten rows faults allocation atomically when given a 128-byte TSize; PE_MASK zero ignores absent dimensions, invalid source identity, capacity, status, and allocation state.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/dispatch/tile-execution.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
pure func TrowsumCapacityOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 2048, 128, 8, 100, 2,
        TileDataType_U16, TileLayout_RowMajor);
    for row = 0 to 99 looplimit 100 do
        WriteTileElement(1, row as integer {0..65535}, 0,
            Zeros{PTO_XLEN} + 0x3f80);
        WriteTileElement(1, row as integer {0..65535}, 1,
            Zeros{PTO_XLEN} + 0x3f80);
    end;
    let raw_before = ReadTileElement(1, 99, 1);
    let source_before = _Tiles[[1]];
    let started = ExecuteCommandInstruction(
        TrowsumCapacityOperationViewStart(TileDataType_BF16), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 100);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let status_before = NumericStatusFlags();
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert !_Tiles[[0]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert NumericStatusFlags() == status_before;
    assert ReadTileElement(1, 99, 1) == raw_before;
    assert _Tiles[[1]].data_type == TileDataType_U16;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;

    ResetProfileState();
    let no_op_start = ExecuteCommandInstruction(
        TrowsumCapacityOperationViewStart(TileDataType_BF16), 32);
    assert no_op_start == CommandExecution_Executed;
    var zero_mask = Zeros{64} + 0x00005013;
    zero_mask[25:20] = Ones{6};
    zero_mask[19] = '1';
    let zero_bound = ExecuteCommandInstruction(zero_mask, 32);
    assert zero_bound == CommandExecution_Executed;
    assert BundleTileBindingCount() == 0;
    let no_op_status = NumericStatusFlags();
    let no_op_completed = ExecuteBundleTileOperation();
    assert no_op_completed;
    assert _LastFault == Fault_None;
    assert NumericStatusFlags() == no_op_status;
    assert !_Tiles[[0]].allocated;
    assert SelectedBundleTileMaskIsZero();
    return 0;
end;
