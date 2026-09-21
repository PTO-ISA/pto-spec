// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-SOURCE-VIEW-BOUNDARY-009","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"fault","summary":"TCVT source reinterpretation remains bounded by width, packing, type-pair, CUBE geometry, and definedness rules.","pass_condition":"Wrong-width, packed, U8-backed RCPE6M2, explicit CUBE LB2, and undefined E8M0 source views fault before allocation while preserving capacity, source descriptor and payload, and numeric status.","related_sources":["asl/tile/model/numeric/e8m0-conversion.asl","asl/block/model/dispatch/tcvt-schema.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/numeric/formats.asl"]}
pure func TCVTSourceViewStart(source_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x09b19181;
    instruction[31:27] = TileDataTypeToEncoding(source_type);
    return instruction;
end;

func BeginRejectedSourceView(
    source_operation_type: TileDataType,
    destination_type: TileDataType,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    physical_columns: integer {0..65535})
begin
    let started = ExecuteCommandInstruction(
        TCVTSourceViewStart(source_operation_type), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        TileDataTypeToEncoding(destination_type),
        Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + valid_rows);
    if physical_columns != 0 then
        SetBundleDimension(2, Zeros{PTO_XLEN} + physical_columns);
    end;
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
end;

func AssertRejectedWithoutEffects(source_before: TileInfo,
                                  capacity_before: integer)
begin
    assert !SelectedBundleClosedTCVTSchemaLegal(23);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert TileCapacityInUse() == capacity_before;
    assert _Tiles[[1]].allocated == source_before.allocated;
    assert _Tiles[[1]].storage_kind == source_before.storage_kind;
    assert _Tiles[[1]].contents_defined == source_before.contents_defined;
    assert _Tiles[[1]].defined_elements == source_before.defined_elements;
    assert _Tiles[[1]].defined_valid_elements ==
        source_before.defined_valid_elements;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;
    assert _Tiles[[1]].valid_rows == source_before.valid_rows;
    assert _Tiles[[1]].valid_columns == source_before.valid_columns;
    assert _Tiles[[1]].data_type == source_before.data_type;
    assert _Tiles[[1]].predicate_basis_type ==
        source_before.predicate_basis_type;
    assert _Tiles[[1]].layout == source_before.layout;
    assert _Tiles[[1]].cube_k_repeat == source_before.cube_k_repeat;
    assert _Tiles[[1]].cube_n_repeat == source_before.cube_n_repeat;
    assert _Tiles[[1]].cube_cell_count == source_before.cube_cell_count;
    assert _Tiles[[1]].cube_storage_bytes ==
        source_before.cube_storage_bytes;
    assert _Tiles[[1]].payload[[0]] == source_before.payload[[0]];
    assert _Tiles[[1]].payload[[1]] == source_before.payload[[1]];
    assert NumericStatusFlags() == Zeros{5};
end;

func CheckWrongWidthRejected()
begin
    ResetProfileState();
    ConfigureTile(1, 256, 16, 8, 1, 1, TileDataType_U16,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7f);
    MarkTileValidRegionDefined(1);
    let source_before = _Tiles[[1]];
    let capacity_before = TileCapacityInUse();
    BeginRejectedSourceView(TileDataType_E8M0, TileDataType_FP16, 1, 1, 8);
    AssertRejectedWithoutEffects(source_before, capacity_before);
end;

func CheckPackedBackingRejected()
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 8, 1, 1, TileDataType_E2M1X2,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7);
    MarkTileValidRegionDefined(1);
    let source_before = _Tiles[[1]];
    let capacity_before = TileCapacityInUse();
    BeginRejectedSourceView(TileDataType_E8M0, TileDataType_FP16, 1, 1, 8);
    AssertRejectedWithoutEffects(source_before, capacity_before);
end;

func CheckRCPE6M2PairRemainsClosed()
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 8, 1, 1, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x80);
    MarkTileValidRegionDefined(1);
    let source_before = _Tiles[[1]];
    let capacity_before = TileCapacityInUse();
    BeginRejectedSourceView(
        TileDataType_RCPE6M2, TileDataType_FP16, 1, 1, 8);
    AssertRejectedWithoutEffects(source_before, capacity_before);
end;

func CheckCubeLB2Rejected()
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(
        1, 128, 1, 1, TileDataType_U8, TileLayout_CUBE_M32);
    assert configured;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7f);
    MarkTileValidRegionDefined(1);
    let source_before = _Tiles[[1]];
    let capacity_before = TileCapacityInUse();
    BeginRejectedSourceView(TileDataType_E8M0, TileDataType_FP16, 1, 1, 4);
    AssertRejectedWithoutEffects(source_before, capacity_before);
end;

func CheckUndefinedSourceRejected()
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 8, 1, 2, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7f);
    let source_before = _Tiles[[1]];
    let capacity_before = TileCapacityInUse();
    BeginRejectedSourceView(TileDataType_E8M0, TileDataType_FP16, 1, 2, 8);
    AssertRejectedWithoutEffects(source_before, capacity_before);
end;

func main() => integer
begin
    CheckWrongWidthRejected();
    CheckPackedBackingRejected();
    CheckRCPE6M2PairRemainsClosed();
    CheckCubeLB2Rejected();
    CheckUndefinedSourceRejected();
    return 0;
end;
