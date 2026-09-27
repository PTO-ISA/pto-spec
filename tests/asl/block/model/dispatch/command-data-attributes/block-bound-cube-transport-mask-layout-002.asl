// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-TRANSPORT-MASK-LAYOUT-002","source":"asl/block/model/dispatch/command-data-attributes.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-DATR-FIELDS-001"],"kind":"boundary","summary":"CUBE transport data-attribute legality evaluates conversion layouts without projecting them through direct Local layout decoding","pass_condition":"unpredicated M32, M16, and N8 conversion layouts remain legal, predicated M16 remains eligible, and predicated N8 rejects without an internal layout assertion","related_sources":["asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/block/model/dispatch/execution-mask-schema.asl"]}
pure func TransportMaskLayoutStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func TransportMaskLayoutAttributes(layout: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = layout;
    return instruction;
end;

func TransportMaskLayoutLegal(layout: bits(5), predicated: boolean)
    => boolean
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TransportMaskLayoutStart(), 32);
    let attributed = ExecuteCommandInstruction(
        TransportMaskLayoutAttributes(layout), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    if predicated then
        _BundleExecutionMask.valid = TRUE;
        _BundleExecutionMask.carrier = BundleExecutionMask_GPR;
    end;
    let decoded = DecodeTileOperation(
        TileDecode_TLSU, BundleOperationDecodeCode(_BundleOperation));
    assert decoded != PTO_TILE_OPERATION_COUNT;
    return BundleExecutionMaskDataAttributesLegal(
        decoded as integer {0..PTO_TILE_OPERATION_COUNT-1});
end;

func main() => integer
begin
    let m32 = TransportMaskLayoutLegal(Zeros{5} + 21, FALSE);
    let m16 = TransportMaskLayoutLegal(Zeros{5} + 22, FALSE);
    let n8 = TransportMaskLayoutLegal(Zeros{5} + 23, FALSE);
    let masked_m16 = TransportMaskLayoutLegal(Zeros{5} + 22, TRUE);
    let masked_n8 = TransportMaskLayoutLegal(Zeros{5} + 23, TRUE);
    assert m32 && m16 && n8 && masked_m16 && !masked_n8;
    return 0;
end;
