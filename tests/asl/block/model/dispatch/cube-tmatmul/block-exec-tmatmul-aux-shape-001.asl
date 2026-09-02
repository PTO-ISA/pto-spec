// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-AUX-SHAPE-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001"],"kind":"execution","summary":"TMATMUL derives distinct D, RowMaxOut, and GroupMaxOut descriptors before one output-group commit","pass_condition":"D is 1x8 while both enabled auxiliary outputs are 1x1 and contain the full product reduction","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/postprocess.asl"]}

pure func MatrixAuxiliaryStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func MatrixAuxiliaryFP16Value(value: integer {1..8}) => Word
begin
    case value of
        when 1 => return Zeros{PTO_XLEN} + 0x3c00;
        when 2 => return Zeros{PTO_XLEN} + 0x4000;
        when 3 => return Zeros{PTO_XLEN} + 0x4200;
        when 4 => return Zeros{PTO_XLEN} + 0x4400;
        when 5 => return Zeros{PTO_XLEN} + 0x4500;
        when 6 => return Zeros{PTO_XLEN} + 0x4600;
        when 7 => return Zeros{PTO_XLEN} + 0x4700;
        when 8 => return Zeros{PTO_XLEN} + 0x4800;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 8,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(2, 0, column,
            MatrixAuxiliaryFP16Value(
                (column + 1) as integer {1..8}));
    end;
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);

    let started = ExecuteCommandInstruction(MatrixAuxiliaryStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', TRUE, TRUE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 3, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '1111', TRUE, FALSE, 3, 0, FALSE);
    AddBundleTileBinding(
        TRUE, 2, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    let row_max = BundleMatrixDestinationAt(1);
    let group_max = BundleMatrixDestinationAt(2);
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 8;
    assert _Tiles[[row_max]].valid_rows == 1;
    assert _Tiles[[row_max]].valid_columns == 1;
    assert _Tiles[[group_max]].valid_rows == 1;
    assert _Tiles[[group_max]].valid_columns == 1;
    assert ReadTileElement(destination, 0, 7) ==
        Zeros{PTO_XLEN} + 0x41800000;
    assert ReadTileElement(row_max, 0, 0) ==
        Zeros{PTO_XLEN} + 0x41800000;
    assert ReadTileElement(group_max, 0, 0) ==
        Zeros{PTO_XLEN} + 0x41800000;
    return 0;
end;
