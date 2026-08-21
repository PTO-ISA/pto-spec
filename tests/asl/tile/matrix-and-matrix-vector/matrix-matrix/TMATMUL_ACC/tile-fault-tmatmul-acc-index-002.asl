// PTO-TEST: {"id":"PTO-AVS-TILE-TMATMUL-ACC-INDEX-002","source":"asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl","requirements":["PTO-CUBE-ACCUMULATOR-OUTPUT-001"],"kind":"fault","summary":"Direct TMATMUL_ACC rejects one TileIndex used for both C and D","pass_condition":"direct decode rejects before changing the accumulator payload or numeric status","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
func main() => integer
begin
    ResetProfileState();
    InstallBundleOperationDescriptor(BundleOperationDescriptor {
        valid = TRUE, form_identity = Zeros{7},
        operation_class = BundleOperation_TileMatrix,
        selector_valid = TRUE, selector = Zeros{10} + 2,
        data_type_valid = TRUE, data_type = '00100',
        mode_valid = FALSE, mode = Zeros{2},
        branch_type_valid = FALSE, branch_type = Zeros{3}
    });
    let a_ready = ConfigureCubeTile(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix);
    let b_ready = ConfigureCubeTile(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix);
    let c_ready = ConfigureCubeTile(3, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert a_ready && b_ready && c_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    let before = ReadTileElement(3, 0, 0);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 3;
    operands.source0 = 3;
    operands.source1 = 1;
    operands.source2 = 2;

    let (status, -) = ExecuteTileInstruction(
        TileDecode_CUBE, Zeros{12} + 2, operands);

    assert status == TileExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(3, 0, 0) == before;
    return 0;
end;
