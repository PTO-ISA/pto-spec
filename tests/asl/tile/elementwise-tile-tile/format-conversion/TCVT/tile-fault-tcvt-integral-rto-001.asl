// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-INTEGRAL-RTO-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-B-DATR-FIELDS-001"],"kind":"fault","summary":"Same-type RTO rejects all four round-to-integral TCVT pairs before effects","pass_condition":"Each encoded FP16, BF16, FP32, and FP64 bundle rejects RTO in operand and complete-schema preflight, raises Fault_TileLegality, and preserves status, source, existing destination, allocation, and capacity","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/numeric/e8m0-conversion.asl"]}
pure func TCVTRTOType(type_index: integer {0..3}) => TileDataType
begin
    case type_index of
        when 0 => return TileDataType_FP16;
        when 1 => return TileDataType_BF16;
        when 2 => return TileDataType_FP32;
        when 3 => return TileDataType_FP64;
    end;
end;

pure func TCVTRTORows(data_type: TileDataType)
    => integer {1..65535}
begin
    return DerivedTileRows(256, 16, data_type) as integer {1..65535};
end;

pure func TCVTRTOValue(data_type: TileDataType) => Word
begin
    if data_type == TileDataType_FP16 then
        return Zeros{PTO_XLEN} + 0x4180;
    elsif data_type == TileDataType_BF16 then
        return Zeros{PTO_XLEN} + 0x4030;
    elsif data_type == TileDataType_FP32 then
        return Zeros{PTO_XLEN} + 0x40300000;
    else
        assert data_type == TileDataType_FP64;
        return Zeros{PTO_XLEN} + 0x4006000000000000;
    end;
end;

pure func TCVTRTOStart(data_type: TileDataType) => bits(64)
begin
    var instruction = Zeros{64} + 0x09b19181;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func TCVTRTODATR(data_type: TileDataType) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = TileDataTypeToEncoding(data_type);
    instruction[17:15] = '110';
    return instruction;
end;

pure func TCVTRTODimension(index: integer {0..2}, value: integer {1..16})
    => bits(64)
begin
    var instruction = if index == 0 then Zeros{64} + 0x00000043
        else if index == 1 then Zeros{64} + 0x00001043
        else Zeros{64} + 0x00002043;
    instruction[31:20] = Zeros{12} + value;
    return instruction;
end;

pure func TCVTRTOBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4} + 2;
    instruction[11:9] = '111';
    instruction[8:7] = '01';
    instruction[19] = '1';
    return instruction;
end;

func RunTCVTRTORejected(data_type: TileDataType)
begin
    ResetProfileState();
    let rows = TCVTRTORows(data_type);
    ConfigureTile(0, 256, rows, 16, 1, 1, data_type,
        TileLayout_RowMajor);
    ConfigureTile(2, 256, rows, 16, 1, 1, data_type,
        TileLayout_RowMajor);
    let input = TCVTRTOValue(data_type);
    WriteTileElement(0, 0, 0, input);
    WriteTileElement(2, 0, 0, input);
    RecordNumericStatusFlags('00010');
    let source_before = _Tiles[[0]];
    let old_destination_before = _Tiles[[2]];
    let capacity_before = TileCapacityInUse();

    let start = ExecuteCommandInstruction(TCVTRTOStart(data_type), 32);
    assert start == CommandExecution_Executed;
    let datr = ExecuteCommandInstruction(TCVTRTODATR(data_type), 32);
    assert datr == CommandExecution_Executed;
    let control = NumericExecutionControl {
        rounding_mode = NumericRound_RTO,
        saturating = FALSE
    };
    assert !TileOperandsLegal_TCVT(2, 0, control);

    for dimension = 0 to 2 do
        let value = if dimension == 0 then 1
            else if dimension == 1 then 1 else 16;
        let dim_status = ExecuteCommandInstruction(
            TCVTRTODimension(dimension, value), 32);
        assert dim_status == CommandExecution_Executed;
    end;
    let binding = ExecuteCommandInstruction(TCVTRTOBinding(), 32);
    assert binding == CommandExecution_Executed;
    assert !SelectedBundleClosedTCVTSchemaLegal(23);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_Tiles[[16]].allocated;
    assert TileCapacityInUse() == capacity_before;
    assert NumericStatusFlags() == '00010';
    assert _Tiles[[0]].data_type == source_before.data_type;
    assert _Tiles[[0]].layout == source_before.layout;
    assert _Tiles[[0]].rows == source_before.rows;
    assert _Tiles[[0]].columns == source_before.columns;
    assert ReadTileElement(0, 0, 0) == input;
    assert _Tiles[[2]].data_type == old_destination_before.data_type;
    assert _Tiles[[2]].layout == old_destination_before.layout;
    assert _Tiles[[2]].rows == old_destination_before.rows;
    assert _Tiles[[2]].columns == old_destination_before.columns;
    assert ReadTileElement(2, 0, 0) == input;
end;

func main() => integer
begin
    for type_index = 0 to 3 do
        RunTCVTRTORejected(TCVTRTOType(type_index));
    end;
    return 0;
end;
