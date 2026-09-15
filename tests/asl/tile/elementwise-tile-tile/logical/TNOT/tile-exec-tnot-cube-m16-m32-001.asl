// PTO-TEST: {"id":"PTO-AVS-TILE-TNOT-CUBE-M16-M32-001","source":"asl/tile/elementwise-tile-tile/logical/TNOT.asl","requirements":["PTO-TNOT-CONTRACT-001"],"kind":"execution","summary":"TNOT complements integer elements on both accepted Local CUBE layouts.","pass_condition":"Direct TNOT on U8 CUBE_M16 and CUBE_M32 publishes 0xf0 for source 0x0f with no fault.","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/unary.asl"]}
func RunTNOTCube(layout: TileLayout) => boolean
begin
    ResetProfileState();
    let source_configured = ConfigureCubeTile(
        0, 128, 1, 1, TileDataType_U8, layout);
    let destination_configured = ConfigureCubeTile(
        1, 128, 1, 1, TileDataType_U8, layout);
    assert source_configured && destination_configured;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x0f);
    assert InstructionContractOperandsLegal_TNOT(1, 0);
    InstructionContractExecute_TNOT(1, 0);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0xf0;
    assert _LastFault == Fault_None;
    return TRUE;
end;

func main() => integer
begin
    assert RunTNOTCube(TileLayout_CUBE_M16);
    assert RunTNOTCube(TileLayout_CUBE_M32);
    return 0;
end;
