// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-NORM-PHYSICAL-SHAPE-006","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"fault","summary":"Ordinary-layout TCVT retains source physical shape for admitted odd columns","pass_condition":"FP16 32x17 converts to E2M1X2 and back with physical Row=32, odd-tail padding and definedness preserved; bundle allocation publishes Row=32; a destination one row-byte short rejects before allocation, while legacy power-of-two shape mismatch still rejects","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/shape/rows-columns.asl"]}
func AssertDirectPhysicalShapePairing()
begin
    ResetProfileState();
    ConfigureTile(
        0, 256, 64, 1, 64, 1, TileDataType_FP32,
        TileLayout_RowMajor);
    ConfigureTile(
        1, 128, 128, 1, 64, 1, TileDataType_E8M0,
        TileLayout_RowMajor);
    ConfigureTile(
        2, 512, 128, 1, 64, 1, TileDataType_FP32,
        TileLayout_RowMajor);
    MarkTileValidRegionDefined(0);
    MarkTileValidRegionDefined(2);

    assert !TileOperandsLegal_TCVT(
        1, 0, DefaultNumericExecutionControl());
    assert TileOperandsLegal_TCVT(
        1, 2, DefaultNumericExecutionControl());
end;

func AssertBundlePhysicalMismatchRejectedBeforeAllocation()
begin
    ResetProfileState();
    ConfigureTile(
        1, 256, 64, 1, 64, 1, TileDataType_FP32,
        TileLayout_RowMajor);
    MarkTileValidRegionDefined(1);
    let capacity_before = TileCapacityInUse();
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x09b19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 13, Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 64);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert TileCapacityInUse() == capacity_before;
end;

func WriteOddFP16Source(index: TileIndex)
begin
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 16 looplimit 17 do
            let value = if column MOD 5 == 0 then 0x3800
                else if column MOD 5 == 1 then 0x3c00
                else if column MOD 5 == 2 then 0x3e00
                else if column MOD 5 == 3 then 0x4000
                else 0x4200;
            WriteTileElement(index, row as integer {0..65535},
                column as integer {0..65535}, Zeros{PTO_XLEN} + value);
        end;
    end;
end;

func WriteOddE2M1Source(index: TileIndex)
begin
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 16 looplimit 17 do
            let value = if column MOD 5 == 0 then 1
                else if column MOD 5 == 1 then 2
                else if column MOD 5 == 2 then 3
                else if column MOD 5 == 3 then 4
                else 5;
            WriteTileElement(index, row as integer {0..65535},
                column as integer {0..65535}, Zeros{PTO_XLEN} + value);
        end;
    end;
end;

func AssertOddPhysicalDirectConversions()
begin
    ResetProfileState();
    ConfigureTile(0, 2048, 32, 17, 32, 17, TileDataType_FP16,
        TileLayout_RowMajor);
    ConfigureTile(1, 512, 32, 17, 32, 17, TileDataType_E2M1X2,
        TileLayout_RowMajor);
    assert _Tiles[[0]].rows == 32 && _Tiles[[1]].rows == 32;
    assert TileStorageBytes(32, 17, TileDataType_FP16) == 1088;
    assert TileStorageBytes(32, 17, TileDataType_E2M1X2) == 288;
    assert TileStorageFitsCapacity(32, 17, TileDataType_FP16, 2048);
    assert TileStorageFitsCapacity(32, 17, TileDataType_E2M1X2, 512);
    assert !TileStorageFitsCapacity(61, 17, TileDataType_FP16, 2048);
    assert !TileStorageFitsCapacity(57, 17, TileDataType_E2M1X2, 512);
    assert !TileShapeMatchesCapacity(2048, 61, 17, TileDataType_FP16);
    assert !TileShapeMatchesCapacity(512, 57, 17, TileDataType_E2M1X2);
    WriteOddFP16Source(0);
    assert TileOperandsLegal_TCVT(
        1, 0, DefaultNumericExecutionControl());
    InstructionContractExecute_TCVT(
        1, 0, DefaultNumericExecutionControl());
    assert NumericStatusFlags() == Zeros{5};
    for row = 0 to 31 looplimit 32 do
        assert ReadTileElement(1, row as integer {0..65535}, 0) ==
            Zeros{PTO_XLEN} + 1;
        assert ReadTileElement(1, row as integer {0..65535}, 1) ==
            Zeros{PTO_XLEN} + 2;
        assert ReadTileElement(1, row as integer {0..65535}, 2) ==
            Zeros{PTO_XLEN} + 3;
        assert ReadTileElement(1, row as integer {0..65535}, 3) ==
            Zeros{PTO_XLEN} + 4;
        assert ReadTileElement(1, row as integer {0..65535}, 4) ==
            Zeros{PTO_XLEN} + 5;
        assert !TileElementDefined(1, row as integer {0..65535}, 17);
    end;

    ResetProfileState();
    ConfigureTile(0, 512, 32, 17, 32, 17, TileDataType_E2M1X2,
        TileLayout_RowMajor);
    ConfigureTile(1, 2048, 32, 17, 32, 17, TileDataType_FP16,
        TileLayout_RowMajor);
    assert _Tiles[[0]].rows == 32 && _Tiles[[1]].rows == 32;
    WriteOddE2M1Source(0);
    assert TileOperandsLegal_TCVT(
        1, 0, DefaultNumericExecutionControl());
    InstructionContractExecute_TCVT(
        1, 0, DefaultNumericExecutionControl());
    assert NumericStatusFlags() == Zeros{5};
    for row = 0 to 31 looplimit 32 do
        assert ReadTileElement(1, row as integer {0..65535}, 0) ==
            Zeros{PTO_XLEN} + 0x3800;
        assert ReadTileElement(1, row as integer {0..65535}, 1) ==
            Zeros{PTO_XLEN} + 0x3c00;
        assert ReadTileElement(1, row as integer {0..65535}, 2) ==
            Zeros{PTO_XLEN} + 0x3e00;
        assert ReadTileElement(1, row as integer {0..65535}, 3) ==
            Zeros{PTO_XLEN} + 0x4000;
        assert ReadTileElement(1, row as integer {0..65535}, 4) ==
            Zeros{PTO_XLEN} + 0x4200;
        assert !TileElementDefined(1, row as integer {0..65535}, 17);
    end;
end;

func AssertOddPhysicalBundleAndShortCapacity()
begin
    ResetProfileState();
    ConfigureTile(1, 2048, 32, 17, 32, 17, TileDataType_FP16,
        TileLayout_RowMajor);
    WriteOddFP16Source(1);
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x21b19181, 32);
    assert started == CommandExecution_Executed;
    assert TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding) ==
        TileDataType_FP16;
    SetBundleDataAttributeState(
        Zeros{5} + 11, Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 17);
    AddBundleTileBinding(TRUE, 0, 3, '1111', TRUE, FALSE, 1, 0, TRUE);
    assert SelectedBundleClosedTCVTSchemaLegal(23);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].rows == 32;
    assert _Tiles[[destination]].columns == 17;
    assert _Tiles[[destination]].valid_rows == 32;
    assert _Tiles[[destination]].valid_columns == 17;
    assert _Tiles[[destination]].data_type == TileDataType_E2M1X2;
    assert ReadTileElement(destination, 31, 0) ==
        Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 31, 4) ==
        Zeros{PTO_XLEN} + 5;
    assert !TileElementDefined(destination, 31, 17);

    ResetProfileState();
    ConfigureTile(1, 2048, 32, 17, 32, 17, TileDataType_FP16,
        TileLayout_RowMajor);
    WriteOddFP16Source(1);
    let started_short = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x21b19181, 32);
    assert started_short == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 11, Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 17);
    AddBundleTileBinding(TRUE, 0, 2, '1111', TRUE, FALSE, 1, 0, TRUE);
    let capacity_before = TileCapacityInUse();
    assert !SelectedBundleClosedTCVTSchemaLegal(23);
    let short_completed = ExecuteBundleTileOperation();
    assert !short_completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert TileCapacityInUse() == capacity_before;
end;

func main() => integer
begin
    AssertDirectPhysicalShapePairing();
    AssertBundlePhysicalMismatchRejectedBeforeAllocation();
    AssertOddPhysicalDirectConversions();
    AssertOddPhysicalBundleAndShortCapacity();
    return 0;
end;
