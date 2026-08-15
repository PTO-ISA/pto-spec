// PTO-TEST: {"id":"PTO-AVS-TILE-TQUANT-ZERO-SCALE-001","source":"asl/tile/irregular-and-complex/format-conversion/TQUANT.asl","requirements":["PTO-INST-TILE-TQUANT"],"kind":"fault","summary":"A present B.IOR with a zero multiplier is not the omitted TQUANT default","pass_condition":"the bundle raises Fault_TileLegality before destination allocation and preserves the FP32 source","related_sources":["asl/block/model/dispatch/scalar-schema.asl","asl/block/model/dispatch/quantization-schema.asl"]}
pure func TQUANTZeroScaleStart() => bits(64)
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
    ConfigureTile(
        1,
        128,
        32,
        1,
        1,
        1,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(
        1,
        0,
        0,
        Zeros{PTO_XLEN} + 0x3f800000);

    let started = ExecuteCommandInstruction(
        TQUANTZeroScaleStart(),
        32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 19,
        Zeros{5},
        Zeros{2},
        Zeros{3},
        Zeros{3},
        FALSE,
        FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    SetBundleScalarBinding(0, 0, 0, 0, 0, 3);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        FALSE,
        1,
        0,
        TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_Tiles[[0]].allocated;
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f800000;
    return 0;
end;
