// PTO-TEST: {"id":"PTO-AVS-TILE-TMULS-CUBE-M16-M32-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TMULS.asl","requirements":["PTO-TMULS-CONTRACT-001"],"kind":"execution","summary":"TMULS multiplies integer elements on both accepted Local CUBE layouts.","pass_condition":"Direct TMULS on U8 CUBE_M16 and CUBE_M32 publishes 21 for source 7 and scalar 3 with no fault.","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/elementwise.asl"]}
func RunTMULSCube(layout: TileLayout) => boolean
begin
    ResetProfileState();
    let source_configured = ConfigureCubeTile(
        0, 128, 1, 1, TileDataType_U8, layout);
    let destination_configured = ConfigureCubeTile(
        1, 128, 1, 1, TileDataType_U8, layout);
    assert source_configured && destination_configured;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    assert InstructionContractOperandsLegal_TMULS(
        1, 0, Zeros{PTO_XLEN} + 3);
    InstructionContractExecute_TMULS(
        1, 0, Zeros{PTO_XLEN} + 3);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 21;
    assert _LastFault == Fault_None;
    return TRUE;
end;

func main() => integer
begin
    let m16 = RunTMULSCube(TileLayout_CUBE_M16);
    let m32 = RunTMULSCube(TileLayout_CUBE_M32);
    assert m16 && m32;
    return 0;
end;
