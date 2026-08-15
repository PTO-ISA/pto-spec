// PTO-TEST: {"id":"PTO-AVS-TILE-TTRI-BUNDLE-001","source":"asl/tile/irregular-and-complex/initialization/TTRI.asl","requirements":["PTO-INST-TILE-TTRI"],"kind":"execution","summary":"A complete TTRI bundle uses omitted diagonal and orientation defaults","pass_condition":"the new FP16 destination contains the default lower triangle and Null padding","related_sources":["asl/block/model/dispatch/generation-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
pure func TTRIBundleStart() => bits(64)
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
    let started = ExecuteCommandInstruction(TTRIBundleStart(), 32);
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

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_FP16;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 3;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3c00;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 1, 1) ==
        Zeros{PTO_XLEN} + 0x3c00;
    let padding = TileLinearIndex(_Tiles[[destination]], 0, 3);
    assert _Tiles[[destination]].defined_elements[padding] == '0';
    return 0;
end;
