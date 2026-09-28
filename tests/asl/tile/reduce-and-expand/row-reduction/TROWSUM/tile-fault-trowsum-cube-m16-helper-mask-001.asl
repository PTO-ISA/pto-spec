// PTO-TEST: {"id":"PTO-AVS-TILE-TROWSUM-CUBE-M16-HELPER-MASK-ROLLBACK-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl","requirements":["PTO-TROWSUM-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"fault","summary":"A decoded CUBE_M16 TROWSUM rejects a helper-injected Local ExecutionMask before effects.","pass_condition":"With a complete nonzero-PE BSTART/B.DATR/B.DIM/B.IOT bundle and valid FP32 source values, helper-injected CUBE_M16 mask state makes reduction source and closed-schema legality false; execution raises Fault_TileLegality without destination publication, capacity use, status change, or source descriptor/payload mutation.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/execution-mask-state.asl","asl/tile/model/execution/reduction.asl"]}
pure func TrowsumHelperMaskStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP32);
    return instruction;
end;

pure func TrowsumHelperMaskAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[28:27] = '11';
    return instruction;
end;

pure func TrowsumHelperMaskBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 2;
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTileForMaskWithPhysical(
        1, 256, 16, 4, 3, 2, TileDataType_U32,
        TileLayout_CUBE_M16, '0001');
    assert configured;
    InstallRelativeTileFixture(1, 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x40800000);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x41000000);
    WriteTileElement(1, 2, 0, Zeros{PTO_XLEN} + 0x41800000);
    WriteTileElement(1, 2, 1, Zeros{PTO_XLEN} + 0x42000000);
    assert TileCubeDescriptorLegal(_Tiles[[1]]);
    let source_before = _Tiles[[1]];
    let raw00 = ReadTileElement(1, 0, 0);
    let raw01 = ReadTileElement(1, 0, 1);
    let raw10 = ReadTileElement(1, 1, 0);
    let raw11 = ReadTileElement(1, 1, 1);
    let raw20 = ReadTileElement(1, 2, 0);
    let raw21 = ReadTileElement(1, 2, 1);

    let started = ExecuteCommandInstruction(TrowsumHelperMaskStart(), 32);
    let attributes = ExecuteCommandInstruction(
        TrowsumHelperMaskAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(TrowsumHelperMaskBinding(), 32);
    assert bound == CommandExecution_Executed;
    let capacity_before = CoreTileCapacityInUse();
    RecordNumericStatusFlags(Zeros{5} + 1);
    let status_before = NumericStatusFlags();

    var mask_low = Zeros{PTO_XLEN};
    mask_low[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask_low, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 3, 2);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert !TileReductionSourceLegalAs(1, TileDataType_FP32);
    assert !SelectedBundleClosedReductionSchemaLegal(operation);
    assert !SelectedBundleClosedSchemasLegal(operation);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
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
    assert ReadTileElement(1, 2, 0) == raw20;
    assert ReadTileElement(1, 2, 1) == raw21;
    return 0;
end;
