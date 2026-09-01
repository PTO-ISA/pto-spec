// PTO-TEST: {"id":"PTO-AVS-TILE-TGPR2T-DESCRIPTOR-002","source":"asl/tile/layout-and-rearrangement/layout/TGPR2T.asl","requirements":["PTO-TGPR2T-CONTRACT-001"],"kind":"fault","summary":"TGPR2T rejects an incomplete or malformed CUBE destination descriptor","pass_condition":"corrupt physical rows fail direct legality while leaving the destination payload and all four GPR sources unchanged","related_sources":["asl/tile/model/execution/predicate-carriers.asl","asl/tile/model/legality/descriptor-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(
        0, 128, 32, 4, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert configured;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x1111);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x2222);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x3333);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x4444);
    assert TileOperandsLegal_TGPR2T(0, 1, 2, 3, 4);
    let old_payload = _Tiles[[0]].payload[[0]];

    _Tiles[[0]].rows = 31;
    assert !TileOperandsLegal_TGPR2T(0, 1, 2, 3, 4);
    assert !InstructionContractOperandsLegal_TGPR2T(0, 1, 2, 3, 4);
    assert _Tiles[[0]].payload[[0]] == old_payload;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x1111;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x2222;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x3333;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x4444;
    return 0;
end;
