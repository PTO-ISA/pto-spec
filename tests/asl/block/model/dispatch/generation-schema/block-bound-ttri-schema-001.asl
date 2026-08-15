// PTO-TEST: {"id":"PTO-AVS-BLOCK-TTRI-SCHEMA-001","source":"asl/block/model/dispatch/generation-schema.asl","requirements":["PTO-INST-TILE-TTRI"],"kind":"boundary","summary":"The TTRI bundle schema requires one terminating destination and explicit valid columns","pass_condition":"an FP16 destination-only schema is legal and becomes illegal when its physical columns are below ValidCol","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/generation.asl"]}
pure func TTRISchemaStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '00111';
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TTRISchemaStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        FALSE,
        FALSE,
        0,
        0,
        TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x067)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedGenerationSchemaLegal(operation);
    _BundleDimensions[[2]] = Zeros{PTO_XLEN} + 2;
    assert !SelectedBundleClosedGenerationSchemaLegal(operation);
    return 0;
end;
