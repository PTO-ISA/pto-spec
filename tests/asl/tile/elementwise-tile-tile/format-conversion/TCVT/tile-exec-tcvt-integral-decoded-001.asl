// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-INTEGRAL-DECODED-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-B-DATR-FIELDS-001","PTO-B-DIM-WRITE-001","PTO-INST-BLOCK-B-IOT"],"kind":"execution","summary":"Encoded TCVT bundles preserve default versus explicit same-type integral rounding provenance","pass_condition":"FP16, BF16, FP32, and FP64 complete encoded BSTART, optional or encoded B.DATR, B.DIM, and B.IOT execution; omission and zero retain 2.75, while explicit RNE rounds to 3.0 with NX for inherited and concrete destinations","related_sources":["asl/block/model/dispatch/numeric-control.asl","asl/block/model/dispatch/tcvt-schema.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/numeric/formats.asl"]}
pure func TCVTDecodedType(type_index: integer {0..3}) => TileDataType
begin
    case type_index of
        when 0 => return TileDataType_FP16;
        when 1 => return TileDataType_BF16;
        when 2 => return TileDataType_FP32;
        when 3 => return TileDataType_FP64;
    end;
end;

pure func TCVTDecodedRows(data_type: TileDataType)
    => integer {1..65535}
begin
    return DerivedTileRows(256, 16, data_type) as integer {1..65535};
end;

pure func TCVTDecodedSource(data_type: TileDataType) => Word
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

pure func TCVTDecodedThree(data_type: TileDataType) => Word
begin
    if data_type == TileDataType_FP16 then
        return Zeros{PTO_XLEN} + 0x4200;
    elsif data_type == TileDataType_BF16 then
        return Zeros{PTO_XLEN} + 0x4040;
    elsif data_type == TileDataType_FP32 then
        return Zeros{PTO_XLEN} + 0x40400000;
    else
        assert data_type == TileDataType_FP64;
        return Zeros{PTO_XLEN} + 0x4008000000000000;
    end;
end;

pure func TCVTDecodedStart(data_type: TileDataType) => bits(64)
begin
    var instruction = Zeros{64} + 0x09b19181;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func TCVTDecodedDATR(data_type: bits(5), rounding: bits(3))
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = data_type;
    instruction[17:15] = rounding;
    return instruction;
end;

pure func TCVTDecodedDimension(index: integer {0..2}, value: integer {1..16})
    => bits(64)
begin
    var instruction = if index == 0 then Zeros{64} + 0x00000043
        else if index == 1 then Zeros{64} + 0x00001043
        else Zeros{64} + 0x00002043;
    instruction[31:20] = Zeros{12} + value;
    return instruction;
end;

pure func TCVTDecodedBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4} + 2;
    instruction[11:9] = '111';
    instruction[8:7] = '01';
    instruction[19] = '1';
    return instruction;
end;

func RunTCVTDecodedCase(
    data_type: TileDataType,
    datr_kind: integer {0..4})
begin
    ResetProfileState();
    let rows = TCVTDecodedRows(data_type);
    ConfigureTile(0, 256, rows, 16, 1, 1, data_type,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, TCVTDecodedSource(data_type));

    let start = ExecuteCommandInstruction(TCVTDecodedStart(data_type), 32);
    assert start == CommandExecution_Executed;
    if datr_kind != 0 then
        let destination_code = if datr_kind == 1 || datr_kind == 3 then DTYPE_NONE
            else TileDataTypeToEncoding(data_type);
        let mode_code = if datr_kind <= 2 then '000' else '001';
        let datr = ExecuteCommandInstruction(
            TCVTDecodedDATR(destination_code, mode_code), 32);
        assert datr == CommandExecution_Executed;
        assert _BundleDataAttributesPresent;
        assert _BundleDataAttributes.rounding_mode == mode_code;
        assert _BundleDataAttributes.data_type == destination_code;
    end;

    for dimension = 0 to 2 do
        let value = if dimension == 0 then 1
            else if dimension == 1 then 1 else 16;
        let dim_status = ExecuteCommandInstruction(
            TCVTDecodedDimension(dimension, value), 32);
        assert dim_status == CommandExecution_Executed;
    end;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN} + 1;
    assert _BundleDimensions[[1]] == Zeros{PTO_XLEN} + 1;
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 16;
    let binding = ExecuteCommandInstruction(TCVTDecodedBinding(), 32);
    assert binding == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].source0_valid;
    assert _BundleTileBindings[[0]].source0 == 0;
    assert _BundleTileBindings[[0]].destination_hand == '01';
    assert _BundleTileBindings[[0]].last;

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert destination == 16;
    assert _Tiles[[destination]].allocated;
    assert _Tiles[[destination]].rows == rows;
    assert _Tiles[[destination]].columns == 16;
    let expected = if datr_kind >= 3 then TCVTDecodedThree(data_type)
        else TCVTDecodedSource(data_type);
    assert ReadTileElement(destination, 0, 0) == expected;
    assert NumericStatusFlags() == if datr_kind >= 3 then '10000' else '00000';
    assert TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding) == data_type;
end;

func main() => integer
begin
    for type_index = 0 to 3 do
        let data_type = TCVTDecodedType(type_index);
        // Omitted B.DATR and present-zero DTYPE_NONE keep ordinary conversion.
        RunTCVTDecodedCase(data_type, 0);
        RunTCVTDecodedCase(data_type, 1);
        // Explicit RNE is integral rounding for both inheritance and concrete
        // same-type selection. FP64 concrete selection exercises encoded zero.
        RunTCVTDecodedCase(data_type, 2);
        RunTCVTDecodedCase(data_type, 3);
        RunTCVTDecodedCase(data_type, 4);
    end;
    return 0;
end;
