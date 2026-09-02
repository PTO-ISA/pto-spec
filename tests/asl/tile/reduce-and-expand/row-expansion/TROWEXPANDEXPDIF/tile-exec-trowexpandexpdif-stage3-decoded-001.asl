// PTO-TEST: {"id":"PTO-AVS-TILE-EXPDIF-STAGE3-DECODED-001","source":"asl/tile/reduce-and-expand/row-expansion/TROWEXPANDEXPDIF.asl","requirements":["PTO-TROWEXPANDEXPDIF-CONTRACT-001","PTO-TCOLEXPANDEXPDIF-CONTRACT-001","PTO-INST-TILE-TROWEXPANDEXPDIF","PTO-INST-TILE-TCOLEXPANDEXPDIF"],"kind":"execution","summary":"decoded row and column EXPDIF cover all five pairs, DTYPE_NONE inheritance with PadValue, FP64 zero rejection, and atomic fault preflight","pass_condition":"all five legal pairs execute through both decoded selectors; DTYPE_NONE inherits with PadValue and publishes the selected destination; mixed results match independent FP32 widen-before-SUB/EXP and differ from source-precision subtraction; unsupported pairs fault before allocation","related_sources":["asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDEXPDIF.asl","asl/block/model/dispatch/expansion-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/expansion.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}

pure func ExpdifStage3Start(axis: TileAxis, source_type: TileDataType)
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = if axis == TileAxis_Row then '01011' else '11011';
    instruction[31:27] = TileDataTypeToEncoding(source_type);
    return instruction;
end;
pure func ExpdifStage3DATR(data_type: bits(5), pad_value: bits(2)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = pad_value;
    instruction[24:20] = data_type;
    return instruction;
end;
pure func ExpdifStage3Carrier(
    data_type: TileDataType,
    two: boolean,
    fp32_discriminator: bits(2)) => Word
begin
    if two then
        case data_type of
            when TileDataType_FP16 => return Zeros{PTO_XLEN} + 0x2000;
            when TileDataType_BF16 => return Zeros{PTO_XLEN} + 0x3f80;
            when TileDataType_FP32 =>
                if fp32_discriminator == '01' then
                    return Zeros{PTO_XLEN} + 0x3f800000;
                elsif fp32_discriminator == '10' then
                    return Zeros{PTO_XLEN} + 0x3f000000;
                else
                    return Zeros{PTO_XLEN} + 0x40000000;
                end;
            otherwise => unreachable;
        end;
    end;
    case data_type of
        when TileDataType_FP16 => return Zeros{PTO_XLEN} + 0x0001;
        when TileDataType_BF16 => return Zeros{PTO_XLEN} + 0x3b00;
        when TileDataType_FP32 =>
            if fp32_discriminator == '01' then
                return Zeros{PTO_XLEN};
            elsif fp32_discriminator == '10' then
                return Zeros{PTO_XLEN};
            else
                return Zeros{PTO_XLEN} + 0x3f800000;
            end;
        otherwise => unreachable;
    end;
end;
func PrepareDecodedExpdifStage3(axis: TileAxis,
    source_type: TileDataType,
    destination_type_code: bits(5),
    datr_present: boolean,
    pad_value: bits(2),
    fp32_discriminator: bits(2))
begin
    ResetProfileState();
    let broadcast_rows = if axis == TileAxis_Row then 2 else 1;
    let broadcast_columns = if axis == TileAxis_Row then 1 else 2;
    let selected_destination_type = if !datr_present ||
        destination_type_code == DTYPE_NONE then source_type
        else BundleTileDataType(destination_type_code);
    let physical_rows = if selected_destination_type == TileDataType_FP32 then
        32 else 64;
    let source_capacity = TileStorageBytes(
        physical_rows, 2, source_type) as integer {0..262144};
    ConfigureTile(
        1, source_capacity, physical_rows, 2, 2, 2, source_type,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 256,
        if axis == TileAxis_Row then physical_rows else 1,
        broadcast_columns,
        broadcast_rows, broadcast_columns, source_type,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(
                1, row, column,
                ExpdifStage3Carrier(
                    source_type, TRUE, fp32_discriminator));
        end;
    end;
    for row = 0 to broadcast_rows - 1 looplimit 2 do
        for column = 0 to broadcast_columns - 1 looplimit 2 do
            WriteTileElement(
                2, row, column,
                ExpdifStage3Carrier(
                    source_type, FALSE, fp32_discriminator));
        end;
    end;
    let started = ExecuteCommandInstruction(
        ExpdifStage3Start(axis, source_type), 32);
    assert started == CommandExecution_Executed;
    if datr_present then
        let datr_started = ExecuteCommandInstruction(
            ExpdifStage3DATR(destination_type_code, pad_value), 32);
        assert datr_started == CommandExecution_Executed;
    end;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE,
        0,
        2,
        '1111',
        TRUE,
        TRUE,
        1,
        2,
        TRUE);
end;
func ExpdifStage3ApplyExp(
    destination_type: TileDataType,
    difference: Word) => Word
begin
    let (handled, special_result, -) = TileSFUUnarySpecialValue(
        TileUnary_EXP,
        destination_type,
        difference);
    if handled then return special_result; end;
    let (profile_result, -) = TileProfileUnary(
        TileUnary_EXP,
        destination_type,
        difference);
    return profile_result;
end;
func ExpdifStage3Expected(
    source_type: TileDataType,
    destination_type: TileDataType,
    left: Word,
    broadcast: Word) => Word
begin
    var widened_left = left;
    var widened_broadcast = broadcast;
    if source_type != destination_type then
        widened_left = if source_type == TileDataType_FP16 then
            ExactWidenFP16ToFP32(left)
        else
            ExactWidenBF16ToFP32(left);
        widened_broadcast = if source_type == TileDataType_FP16 then
            ExactWidenFP16ToFP32(broadcast)
        else
            ExactWidenBF16ToFP32(broadcast);
        let (profile_result, -) = TileProfileMixedExpdifFP32(
            source_type,
            widened_left,
            widened_broadcast);
        return profile_result;
    end;
    let (difference, -) = TileProfileBinaryWithFlags(
        TileBinary_SUB,
        destination_type,
        widened_left,
        widened_broadcast);
    return ExpdifStage3ApplyExp(destination_type, difference);
end;

func RunDecodedExpdifStage3Positive(axis: TileAxis,
    source_type: TileDataType,
    destination_type: TileDataType,
    destination_type_code: bits(5),
    datr_present: boolean,
    pad_value: bits(2),
    fp32_discriminator: bits(2))
begin
    PrepareDecodedExpdifStage3(
        axis,
        source_type,
        destination_type_code,
        datr_present,
        pad_value,
        fp32_discriminator);
    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        if axis == TileAxis_Row then Zeros{12} + 0x04B
        else Zeros{12} + 0x05B)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let (types_legal, selected_source_type, selected_destination_type) =
        SelectedBundleExpansionExponentialDifferenceTypes();
    assert types_legal;
    assert selected_source_type == source_type;
    assert selected_destination_type == destination_type;
    if datr_present then
        assert CurrentBundleDataTypeCode() == destination_type_code;
        let expected_pad = if pad_value == '01' then TilePad_Max
            else TilePad_Zero;
        assert CurrentBundlePadValue() == expected_pad;
    end;
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedExpansionSchemaLegal(operation);
    let source_before = ReadTileElement(1, 0, 0);
    let broadcast_before = ReadTileElement(2, 0, 0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let operands = BundleTileInstructionOperands(operation);
    assert operands.source0 == 1;
    assert operands.source1 == 2;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].allocated;
    assert _Tiles[[destination]].storage_kind == TileStorage_Numeric;
    assert _Tiles[[destination]].layout == TileLayout_RowMajor;
    assert _Tiles[[destination]].data_type == destination_type;
    assert _Tiles[[destination]].capacity_bytes == 256;
    assert TileLogicalShapeMatch(destination, operands.source0);
    assert TileSourceContentsDefined(operands.source0);
    assert TileSourceContentsDefined(operands.source1);
    assert TileSourceEncodingsValid(operands.source0);
    assert TileSourceEncodingsValid(operands.source1);
    let actual = ReadTileElement(destination, 0, 0);
    let expected = ExpdifStage3Expected(
        source_type,
        destination_type,
        source_before,
        broadcast_before);
    assert actual == expected;
    if source_type != destination_type then
        let wide_left = if source_type == TileDataType_FP16 then
            ExactWidenFP16ToFP32(source_before)
        else
            ExactWidenBF16ToFP32(source_before);
        let wide_broadcast = if source_type == TileDataType_FP16 then
            ExactWidenFP16ToFP32(broadcast_before)
        else
            ExactWidenBF16ToFP32(broadcast_before);
        assert wide_left == if source_type == TileDataType_FP16 then
            Zeros{PTO_XLEN} + 0x3c000000
        else
            Zeros{PTO_XLEN} + 0x3f800000;
        assert wide_broadcast == if source_type == TileDataType_FP16 then
            Zeros{PTO_XLEN} + 0x33800000
        else
            Zeros{PTO_XLEN} + 0x3b000000;
        if source_type == TileDataType_FP16 then
            assert actual == Zeros{PTO_XLEN} + 0x3f810100;
            assert actual != Zeros{PTO_XLEN} + 0x3f810101;
        else
            assert actual == Zeros{PTO_XLEN} + 0x402da16e;
            assert actual != Zeros{PTO_XLEN} + 0x402df854;
        end;
    elsif source_type == TileDataType_FP32 &&
          fp32_discriminator != '00' then
        if fp32_discriminator == '01' then
            assert actual != Zeros{PTO_XLEN} + 0x3f810100;
        else
            assert actual != Zeros{PTO_XLEN} + 0x402da16e;
        end;
    end;
    let source_after = ReadTileElement(1, 0, 0);
    let broadcast_after = ReadTileElement(2, 0, 0);
    assert source_after == source_before;
    assert broadcast_after == broadcast_before;
end;
func RunDecodedExpdifStage3Reject(axis: TileAxis,
    source_type: TileDataType,
    destination_type_code: bits(5))
begin
    PrepareDecodedExpdifStage3(
        axis,
        source_type,
        destination_type_code,
        TRUE,
        '00',
        '00');
    let source_before = ReadTileElement(1, 0, 0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    let source_after = ReadTileElement(1, 0, 0);
    assert source_after == source_before;
    assert !_Tiles[[0]].allocated;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;
func main() => integer
begin
    RunDecodedExpdifStage3Positive(TileAxis_Row, TileDataType_FP16, TileDataType_FP16, TileDataTypeToEncoding(TileDataType_FP16), FALSE, '00', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Row, TileDataType_BF16, TileDataType_BF16, DTYPE_NONE, TRUE, '01', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Row, TileDataType_FP32, TileDataType_FP32, TileDataTypeToEncoding(TileDataType_FP32), FALSE, '00', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Row, TileDataType_FP16, TileDataType_FP32, TileDataTypeToEncoding(TileDataType_FP32), TRUE, '00', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Row, TileDataType_BF16, TileDataType_FP32, TileDataTypeToEncoding(TileDataType_FP32), TRUE, '00', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Column, TileDataType_FP16, TileDataType_FP16, TileDataTypeToEncoding(TileDataType_FP16), TRUE, '00', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Column, TileDataType_BF16, TileDataType_BF16, TileDataTypeToEncoding(TileDataType_BF16), TRUE, '00', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Column, TileDataType_FP32, TileDataType_FP32, TileDataTypeToEncoding(TileDataType_FP32), FALSE, '00', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Column, TileDataType_FP16, TileDataType_FP32, TileDataTypeToEncoding(TileDataType_FP32), TRUE, '00', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Column, TileDataType_BF16, TileDataType_FP32, TileDataTypeToEncoding(TileDataType_FP32), TRUE, '00', '00');
    RunDecodedExpdifStage3Positive(TileAxis_Row, TileDataType_FP32, TileDataType_FP32, TileDataTypeToEncoding(TileDataType_FP32), FALSE, '00', '01');
    RunDecodedExpdifStage3Positive(TileAxis_Column, TileDataType_FP32, TileDataType_FP32, TileDataTypeToEncoding(TileDataType_FP32), FALSE, '00', '10');
    RunDecodedExpdifStage3Reject(TileAxis_Row, TileDataType_FP16, Zeros{5});
    RunDecodedExpdifStage3Reject(TileAxis_Row, TileDataType_FP16, TileDataTypeToEncoding(TileDataType_BF16));
    RunDecodedExpdifStage3Reject(TileAxis_Column, TileDataType_BF16, TileDataTypeToEncoding(TileDataType_FP16));
    RunDecodedExpdifStage3Reject(TileAxis_Column, TileDataType_FP32, TileDataTypeToEncoding(TileDataType_FP16));
    return 0;
end;
