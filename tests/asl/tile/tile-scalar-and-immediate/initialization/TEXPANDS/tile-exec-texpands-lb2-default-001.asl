// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPANDS-LB2-DEFAULT-001","source":"asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl","requirements":["PTO-INST-TILE-TEXPANDS"],"kind":"execution","summary":"An omitted B.DIM LB2 selects ValidCol as the physical column count","pass_condition":"TEXPANDS with LB0=2, LB1=1, and LB2 omitted allocates physical columns two and broadcasts the low scalar width to both valid elements","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/schema/dimensions.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x1ff);

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0xdbb19181,
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
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
    assert _Tiles[[destination]].columns == 2;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xff;
    return 0;
end;
