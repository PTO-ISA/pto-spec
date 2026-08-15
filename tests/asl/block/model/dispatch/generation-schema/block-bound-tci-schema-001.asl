// PTO-TEST: {"id":"PTO-AVS-BLOCK-TCI-SCHEMA-001","source":"asl/block/model/dispatch/generation-schema.asl","requirements":["PTO-INST-TILE-TCI"],"kind":"boundary","summary":"The TCI bundle schema requires one terminating destination and one logical row","pass_condition":"a U16 destination-only schema is legal and becomes illegal when LB1 selects two valid rows","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/generation.asl"]}
pure func TCISchemaStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '00110';
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(TCISchemaStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
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
        Zeros{12} + 0x066)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedGenerationSchemaLegal(operation);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    assert !SelectedBundleClosedGenerationSchemaLegal(operation);
    return 0;
end;
