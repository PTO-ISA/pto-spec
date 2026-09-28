// PTO-TEST: {"id":"PTO-AVS-TILE-TROWSUM-CUBE-UNMASKED-CROSS-BACKING-FAULTS-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl","requirements":["PTO-TROWSUM-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"fault","summary":"Unmasked CUBE_M16 and CUBE_M32 reductions validate every valid cross-backing coordinate under the selected operation type.","pass_condition":"For equal-width U32 backing and TF32 operation views in CUBE_M16 and CUBE_M32, a malformed later valid coordinate causes Fault_TileLegality before destination publication, capacity use, status update, or source descriptor/payload mutation.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func CubeCrossBackingFaultStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_TF32);
    return instruction;
end;

pure func CubeCrossBackingFaultAttributes(layout: TileLayout) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = if layout == TileLayout_CUBE_M16
        then Zeros{5} + 31 else Zeros{5} + 29;
    instruction[28:27] = '11';
    return instruction;
end;

pure func CubeCrossBackingFaultBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

func RunCubeCrossBackingMalformedCoordinate(
    layout: TileLayout, physical_rows: integer {16,32},
    source_capacity: integer {256,512})
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMaskWithPhysical(
        1, source_capacity, physical_rows, 4, 2, 2,
        TileDataType_U32, layout, '0001');
    assert configured;
    InstallRelativeTileFixture(1, 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x3f800001);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x40400000);
    assert TileCubeDescriptorLegal(_Tiles[[1]]);
    let source_before = _Tiles[[1]];
    let raw00 = ReadTileElement(1, 0, 0);
    let raw01 = ReadTileElement(1, 0, 1);
    let raw10 = ReadTileElement(1, 1, 0);
    let raw11 = ReadTileElement(1, 1, 1);

    let started = ExecuteCommandInstruction(
        CubeCrossBackingFaultStart(), 32);
    let attributes = ExecuteCommandInstruction(
        CubeCrossBackingFaultAttributes(layout), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let binding = ExecuteCommandInstruction(
        CubeCrossBackingFaultBinding(), 32);
    assert binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert !_BundleExecutionMask.valid;
    assert !TileReductionSourceLegalAs(1, TileDataType_TF32);
    assert !SelectedBundleClosedReductionSchemaLegal(operation);
    RecordNumericStatusFlags(Zeros{5} + 1);
    let status_before = NumericStatusFlags();
    let capacity_before = CoreTileCapacityInUse();
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_Tiles[[0]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert CoreTileCapacityInUse() == capacity_before;
    assert NumericStatusFlags() == status_before;
    assert _Tiles[[1]].allocated == source_before.allocated;
    assert _Tiles[[1]].data_type == source_before.data_type;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;
    assert _Tiles[[1]].valid_rows == source_before.valid_rows;
    assert _Tiles[[1]].valid_columns == source_before.valid_columns;
    assert _Tiles[[1]].layout == source_before.layout;
    assert _Tiles[[1]].cube_storage_bytes == source_before.cube_storage_bytes;
    assert _Tiles[[1]].contents_defined == source_before.contents_defined;
    assert ReadTileElement(1, 0, 0) == raw00;
    assert ReadTileElement(1, 0, 1) == raw01;
    assert ReadTileElement(1, 1, 0) == raw10;
    assert ReadTileElement(1, 1, 1) == raw11;
end;

func main() => integer
begin
    RunCubeCrossBackingMalformedCoordinate(
        TileLayout_CUBE_M16, 16, 256);
    RunCubeCrossBackingMalformedCoordinate(
        TileLayout_CUBE_M32, 32, 512);
    return 0;
end;
