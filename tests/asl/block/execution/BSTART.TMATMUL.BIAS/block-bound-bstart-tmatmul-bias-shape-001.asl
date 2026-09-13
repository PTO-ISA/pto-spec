// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-BIAS-SHAPE-001","source":"asl/block/execution/BSTART.TMATMUL.BIAS.asl","requirements":["PTO-TMATMUL-BIAS-CONTRACT-001"],"kind":"boundary","summary":"TMATMUL.BIAS accepts only a resolved-M-layout 1xN Bias of the result type.","pass_condition":"Scalar 1x1, column Mx1, full MxN, mismatched CUBE_N8, and input-typed Bias descriptors all reject before destination allocation.","related_sources":["asl/tile/model/legality/matrix-shape.asl"]}
func RejectBias(valid_rows: integer {1..16}, valid_columns: integer {1..16},
                data_type: TileDataType, layout: TileLayout)
begin
    ResetProfileState();
    ConfigureCubeTile(1, 128, 2, 2, TileDataType_S16,
        TileLayout_CUBE_M16);
    ConfigureCubeTile(2, 128, 2, 2, TileDataType_S8,
        TileLayout_CUBE_N8);
    ConfigureCubeTile(3, 512, valid_rows, valid_columns,
        data_type, layout);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    var start: bits(64) = Zeros{64} + 0x00131181;
    start[31:27] = Zeros{5} + 18;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5} + 19, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
end;

func main() => integer
begin
    RejectBias(1, 1, TileDataType_S32, TileLayout_CUBE_M16);
    RejectBias(2, 1, TileDataType_S32, TileLayout_CUBE_M16);
    RejectBias(2, 2, TileDataType_S32, TileLayout_CUBE_M16);
    RejectBias(1, 2, TileDataType_S32, TileLayout_CUBE_N8);
    RejectBias(1, 2, TileDataType_S16, TileLayout_CUBE_M16);
    return 0;
end;
