// PTO-TEST: {"id":"PTO-AVS-TILE-TMATMUL-MX-ACC-INDEX-002","source":"asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_ACC.asl","requirements":["PTO-CUBE-ACCUMULATOR-OUTPUT-001"],"kind":"fault","summary":"Direct TMATMUL_MX_ACC rejects one TileIndex used for both C and D","pass_condition":"scaled direct decode rejects before changing FP32 C or numeric status","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE, form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE, selector = Zeros{10} + 6,
        data_type_valid = TRUE, data_type = '00111',
        mode_valid = FALSE, mode = Zeros{2},
        branch_type_valid = FALSE, branch_type = Zeros{3}
    });
    let a_ready = ConfigureCubeTile(1, 128, 1, 1,
        TileDataType_E4M3, TileLayout_CUBE_M16, TileLocation_Matrix);
    let b_ready = ConfigureCubeTile(3, 128, 1, 1,
        TileDataType_E4M3, TileLayout_CUBE_N8, TileLocation_Matrix);
    let c_ready = ConfigureCubeTile(5, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert a_ready && b_ready && c_ready;
    ConfigureTile(2, 128, 128, 1, 1, 1,
        TileDataType_E8M0, TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(4, 128, 128, 1, 1, 1,
        TileDataType_E8M0, TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 5);
    let before = ReadTileElement(5, 0, 0);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 5;
    operands.source0 = 5;
    operands.source1 = 1;
    operands.source2 = 2;
    operands.source3 = 3;
    operands.source4 = 4;

    let (status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 6, operands);

    assert status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(5, 0, 0) == before;
    return 0;
end;
