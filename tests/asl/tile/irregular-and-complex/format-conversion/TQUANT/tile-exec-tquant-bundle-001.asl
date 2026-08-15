// PTO-TEST: {"id":"PTO-AVS-TILE-TQUANT-BUNDLE-001","source":"asl/tile/irregular-and-complex/format-conversion/TQUANT.asl","requirements":["PTO-INST-TILE-TQUANT"],"kind":"execution","summary":"A complete TQUANT bundle allocates an S8 destination and uses the omitted affine defaults","pass_condition":"FP32 one and two become S8 one and two while the Local source persists","related_sources":["asl/block/model/dispatch/quantization-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
pure func TQUANTStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '01010';
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x40000000);

    let started = ExecuteCommandInstruction(TQUANTStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 19, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_S8;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    return 0;
end;
