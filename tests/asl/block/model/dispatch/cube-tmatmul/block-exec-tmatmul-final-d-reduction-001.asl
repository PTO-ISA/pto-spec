// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-FINAL-D-REDUCTION-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-B-FPATR-MATRIX-POSTPROCESS-001","PTO-MATRIX-POSTPROCESS-BITEXACT-001","PTO-CUBE-AUX-CELLREG-001"],"kind":"execution","summary":"TMATMUL reduces final FP16 D values after per-column quantization and overflow encoding","pass_condition":"raw FP32 maximum 2.0 becomes final FP16 positive infinity after per-column scaling; D and both auxiliary descriptors use CUBE_M16 FP16; full and partial groups and RowMaxIn are covered","related_sources":["asl/tile/model/execution/postprocess.asl","asl/tile/model/legality/matrix-postprocess.asl","asl/block/model/dispatch/cube-destination.asl"]}

pure func FinalDReductionStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func FinalDReductionHalf(value: integer {0..9}) => Word
begin
    case value of
        when 0 => return Zeros{PTO_XLEN} + 0x4000;
        when 1, 2, 3, 4, 5, 6 => return Zeros{PTO_XLEN} + 0x3c00;
        when 7, 9 => return Zeros{PTO_XLEN} + 0x3e00;
        when 8 => return Zeros{PTO_XLEN} + 0x3c00;
    end;
end;

pure func FinalDReductionScale(column: integer {0..9}) => Word
begin
    let fp32_scale = if column == 0 then
        Zeros{PTO_XLEN} + 0x3f000000
    else if column == 7 then
        Zeros{PTO_XLEN} + 0x47800000
    else if column == 9 then
        Zeros{PTO_XLEN} + 0x40800000
    else
        Zeros{PTO_XLEN} + 0x3f800000;
    return MatrixQuantParameter(
        FP32ToFP19(fp32_scale), Zeros{PTO_XLEN}, 0);
end;

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 256, 1, 10,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    let row_max_in_ready = ConfigureCubeTileForMask(3, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    let quant_ready = ConfigureCubeTileForMask(4, 256, 1, 10,
        TileDataType_U64, TileLayout_CUBE_N8, '1111');
    assert a_ready && b_ready && row_max_in_ready && quant_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    for column = 0 to 9 looplimit 10 do
        WriteTileElement(2, 0, column,
            FinalDReductionHalf(column as integer {0..9}));
        WriteTileElement(4, 0, column,
            FinalDReductionScale(column as integer {0..9}));
    end;
    // RowMaxIn uses the effective FP16 type and seeds the maximum at five.
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x4500);

    let started = ExecuteCommandInstruction(FinalDReductionStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        '100001', Zeros{3}, '0001', TRUE, TRUE, TRUE, TRUE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 10);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 3, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '1111', TRUE, TRUE, 3, 4, FALSE);
    AddBundleTileBinding(
        TRUE, 2, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    let row_max = BundleMatrixDestinationAt(1);
    let group_max = BundleMatrixDestinationAt(2);
    assert _Tiles[[destination]].data_type == TileDataType_FP16;
    assert _Tiles[[row_max]].data_type == TileDataType_FP16;
    assert _Tiles[[group_max]].data_type == TileDataType_FP16;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[row_max]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[group_max]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[row_max]].rows ==
        TileCubeStorageRows(TileLayout_CUBE_M16, 1,
            TileDataType_FP16);
    assert _Tiles[[row_max]].columns ==
        TileCubeStorageColumns(TileLayout_CUBE_M16, 1,
            TileDataType_FP16);
    assert _Tiles[[group_max]].rows ==
        TileCubeStorageRows(TileLayout_CUBE_M16, 1,
            TileDataType_FP16);
    assert _Tiles[[group_max]].columns ==
        TileCubeStorageColumns(TileLayout_CUBE_M16, 2,
            TileDataType_FP16);
    assert _Tiles[[row_max]].cube_storage_bytes == 128;
    assert _Tiles[[group_max]].cube_storage_bytes == 128;
    assert TileCubeDescriptorLegal(_Tiles[[destination]]);
    assert TileCubeDescriptorLegal(_Tiles[[row_max]]);
    assert TileCubeDescriptorLegal(_Tiles[[group_max]]);
    // Raw products are [2,1,1,1,1,1,1,1.5,1,1.5], whose maximum is 2.0.
    // Per-column scaling makes column seven overflow the final FP16 encoding
    // and column nine the maximum in the partial second group.
    assert _Tiles[[destination]].valid_columns == 10;
    assert _Tiles[[group_max]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3c00;
    assert ReadTileElement(destination, 0, 7) ==
        Zeros{PTO_XLEN} + 0x7c00;
    assert ReadTileElement(destination, 0, 9) ==
        Zeros{PTO_XLEN} + 0x4600;
    assert ReadTileElement(row_max, 0, 0) ==
        Zeros{PTO_XLEN} + 0x7c00;
    assert ReadTileElement(group_max, 0, 0) ==
        Zeros{PTO_XLEN} + 0x7c00;
    assert ReadTileElement(group_max, 0, 1) ==
        Zeros{PTO_XLEN} + 0x4600;
    assert _Tiles[[3]].data_type == TileDataType_FP16;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x4500;
    assert NumericStatusFlags() == Zeros{5} + 0x14;
    return 0;
end;
