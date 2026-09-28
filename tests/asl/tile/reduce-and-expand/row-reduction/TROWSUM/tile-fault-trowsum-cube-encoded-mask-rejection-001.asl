// PTO-TEST: {"id":"PTO-AVS-TILE-TROWSUM-CUBE-ENCODED-MASK-REJECTION-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl","requirements":["PTO-TROWSUM-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001","PTO-B-IOS-SHARED-STATE-001"],"kind":"fault","summary":"All twelve reductions exclude Local CUBE ExecutionMask; decoded TROWSUM B.IOR, extra B.IOT predicate source, and B.IOS streams fault before effects.","pass_condition":"The execution-mask eligibility predicate is false for every row and column reduction; in decoded Local CUBE TROWSUM cases, B.IOR ExecMaskPresent and a second B.IOT predicate source fault at bundle-control preflight, while B.IOS faults at closed reduction schema; all leave destination publication, capacity, numeric status, and source descriptor/payload unchanged.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func TrowsumMaskRejectStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func TrowsumMaskRejectAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[28:27] = '11';
    return instruction;
end;

pure func TrowsumMaskRejectIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[26] = '1';
    return instruction;
end;

pure func TrowsumMaskRejectSourceBinding(
    source: bits(6), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = if last then '1' else '0';
    instruction[11:9] = '001';
    return instruction;
end;

pure func TrowsumMaskRejectDestinationBinding(
    source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

pure func TrowsumMaskRejectExtraSourceDestination(
    source0: bits(6), source1: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

pure func TrowsumMaskRejectSharedSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

func PrepareTrowsumMaskRejectBundle()
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMaskWithPhysical(
        1, 256, 16, 4, 3, 2, TileDataType_U32,
        TileLayout_CUBE_M16, '0001');
    assert configured;
    InstallRelativeTileFixture(1, 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 11);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 13);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 17);
    WriteTileElement(1, 2, 0, Zeros{PTO_XLEN} + 19);
    WriteTileElement(1, 2, 1, Zeros{PTO_XLEN} + 23);
    let started = ExecuteCommandInstruction(TrowsumMaskRejectStart(), 32);
    let attributes = ExecuteCommandInstruction(
        TrowsumMaskRejectAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
end;

func AssertTrowsumMaskRejectionNoEffects(
    capacity_before: integer,
    status_before: bits(5), source_before: TileInfo,
    expected_fault: FaultCode,
    raw00: Word, raw01: Word)
begin
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert !SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == expected_fault;
    assert !_Tiles[[0]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert CoreTileCapacityInUse() == capacity_before;
    assert NumericStatusFlags() == status_before;
    assert _Tiles[[1]].allocated == source_before.allocated;
    assert _Tiles[[1]].data_type == source_before.data_type;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].storage_kind == source_before.storage_kind;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;
    assert _Tiles[[1]].valid_rows == source_before.valid_rows;
    assert _Tiles[[1]].valid_columns == source_before.valid_columns;
    assert _Tiles[[1]].layout == source_before.layout;
    assert _Tiles[[1]].predicate_basis_type ==
        source_before.predicate_basis_type;
    assert _Tiles[[1]].cube_k_repeat == source_before.cube_k_repeat;
    assert _Tiles[[1]].cube_n_repeat == source_before.cube_n_repeat;
    assert _Tiles[[1]].cube_cell_count == source_before.cube_cell_count;
    assert _Tiles[[1]].cube_storage_bytes == source_before.cube_storage_bytes;
    assert _Tiles[[1]].contents_defined == source_before.contents_defined;
    assert ReadTileElement(1, 0, 0) == raw00;
    assert ReadTileElement(1, 0, 1) == raw01;
    assert ReadTileElement(1, 1, 0) == Zeros{PTO_XLEN} + 13;
    assert ReadTileElement(1, 1, 1) == Zeros{PTO_XLEN} + 17;
    assert ReadTileElement(1, 2, 0) == Zeros{PTO_XLEN} + 19;
    assert ReadTileElement(1, 2, 1) == Zeros{PTO_XLEN} + 23;
end;

func RunTrowsumIORMaskRejection()
begin
    PrepareTrowsumMaskRejectBundle();
    let source_before = _Tiles[[1]];
    let raw00 = ReadTileElement(1, 0, 0);
    let raw01 = ReadTileElement(1, 0, 1);
    RecordNumericStatusFlags(Zeros{5} + 1);
    let status_before = NumericStatusFlags();
    let capacity_before = CoreTileCapacityInUse();
    let mask = ExecuteCommandInstruction(TrowsumMaskRejectIOR(), 32);
    let binding = ExecuteCommandInstruction(
        TrowsumMaskRejectDestinationBinding(Zeros{6} + 1), 32);
    assert mask == CommandExecution_Executed;
    assert binding == CommandExecution_Executed;
    assert _BundleScalarBindings[[0]].valid;
    assert _BundleScalarBindings[[0]].execution_mask_present;
    AssertTrowsumMaskRejectionNoEffects(
        capacity_before, status_before, source_before,
        Fault_BundleControl, raw00, raw01);
end;

func RunTrowsumExtraB_IOTPredicateRejection()
begin
    PrepareTrowsumMaskRejectBundle();
    let predicate_configured = ConfigurePredicateCell(
        2, 256, 3, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert predicate_configured;
    InstallRelativeTileFixture(2, 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    MarkTileValidRegionDefined(2);
    let source_before = _Tiles[[1]];
    let raw00 = ReadTileElement(1, 0, 0);
    let raw01 = ReadTileElement(1, 0, 1);
    RecordNumericStatusFlags(Zeros{5} + 1);
    let status_before = NumericStatusFlags();
    let capacity_before = CoreTileCapacityInUse();
    let first = ExecuteCommandInstruction(
        TrowsumMaskRejectSourceBinding(Zeros{6} + 1, FALSE), 32);
    let extra_predicate = ExecuteCommandInstruction(
        TrowsumMaskRejectExtraSourceDestination(
            Zeros{6} + 2, Zeros{6} + 1), 32);
    assert first == CommandExecution_Executed;
    assert extra_predicate == CommandExecution_Executed;
    assert BundleTileBindingCount() == 2;
    assert BundleLocalTileSourceCount() == 3;
    assert _BundleTileBindings[[1]].source0 == 2;
    assert _Tiles[[2]].storage_kind == TileStorage_PredicateCell;
    AssertTrowsumMaskRejectionNoEffects(
        capacity_before, status_before, source_before,
        Fault_BundleControl, raw00, raw01);
end;

func RunTrowsumB_IOSRejection()
begin
    PrepareTrowsumMaskRejectBundle();
    let source_before = _Tiles[[1]];
    let raw00 = ReadTileElement(1, 0, 0);
    let raw01 = ReadTileElement(1, 0, 1);
    RecordNumericStatusFlags(Zeros{5} + 1);
    let status_before = NumericStatusFlags();
    let capacity_before = CoreTileCapacityInUse();
    let shared_source = ExecuteCommandInstruction(
        TrowsumMaskRejectSharedSource(), 32);
    let binding = ExecuteCommandInstruction(
        TrowsumMaskRejectDestinationBinding(Zeros{6} + 1), 32);
    assert shared_source == CommandExecution_Executed;
    assert binding == CommandExecution_Executed;
    assert BundleSharedBindingCount() == 1;
    assert _BundleSharedBindings[[0]].valid;
    AssertTrowsumMaskRejectionNoEffects(
        capacity_before, status_before, source_before,
        Fault_TileLegality, raw00, raw01);
end;

func AssertReductionsExcludeExecutionMask()
begin
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x043)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x042)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x041)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x04d)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x04c)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x050)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x053)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x052)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x051)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x05d)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
    assert !TileOperationExecutionMaskEligible(DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x05c)
        as integer {0..PTO_TILE_OPERATION_COUNT-1});
end;

func main() => integer
begin
    AssertReductionsExcludeExecutionMask();
    RunTrowsumIORMaskRejection();
    RunTrowsumExtraB_IOTPredicateRejection();
    RunTrowsumB_IOSRejection();
    return 0;
end;
