// PTO-TEST: {"id":"PTO-AVS-TILE-TDEQUANT-BUNDLE-001","source":"asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl","requirements":["PTO-INST-TILE-TDEQUANT"],"kind":"execution","summary":"A complete TDEQUANT bundle allocates an FP32 destination and uses the omitted affine defaults","pass_condition":"S8 one and two become FP32 one and two while the Local source persists","related_sources":["asl/block/model/dispatch/quantization-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
pure func TDEQUANTStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '01011';
    instruction[31:27] = Zeros{5} + 19;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 64, 2, 1, 2, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);

    let started = ExecuteCommandInstruction(TDEQUANTStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 1, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
