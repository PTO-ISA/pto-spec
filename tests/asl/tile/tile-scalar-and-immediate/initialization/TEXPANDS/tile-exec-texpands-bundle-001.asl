// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPANDS-BUNDLE-001","source":"asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl","requirements":["PTO-INST-TILE-TEXPANDS"],"kind":"execution","summary":"TEXPANDS allocates a source-free Local destination and broadcasts the low scalar width","pass_condition":"the low U8 encoding is copied to both valid elements while upper GPR bits are ignored","related_sources":["asl/block/model/dispatch/tile-scalar-schema.asl","asl/block/model/dispatch/destination-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x1ff);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xdbb19181,
        32);
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
    SetBundleScalarBinding(0, 0, 2, 0, 0, 3);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xff;
    return 0;
end;
