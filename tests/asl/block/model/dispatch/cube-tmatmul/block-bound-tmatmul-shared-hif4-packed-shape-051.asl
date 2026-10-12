// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-HIF4-PACKED-SHAPE-051","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"boundary","summary":"HiF4X2 parity applies to Shared Matrix-MX A and B roles only.","pass_condition":"K=2 Shared HiF4X2 primary schemas pass for A and B under their legal transpose forms; K=3 rejects in both roles, HiF4X2 remains MX-supported and ordinary-Matrix-excluded, and mixed Shared source/scale descriptors remain generically legal.","related_sources":["asl/tile/model/legality/matrix-functions.asl","asl/block/model/dispatch/shared-cube-matrix.asl"]}

func RunSharedHiF4Shape(right_role: boolean, k: integer {2,3},
                        trans_a: boolean, trans_b: boolean)
begin
    ResetProfileState();
    let left_type = if right_role then TileDataType_FP16
        else TileDataType_HiF4X2;
    let right_type = if right_role then TileDataType_HiF4X2
        else TileDataType_FP16;
    let a_pitch = if trans_a then 2 else if k == 2 then 2 else 4;
    let b_pitch = if trans_b then 1 else k;
    if right_role then
        let primary_pitch = if trans_b then 2
            else if k == 2 then 2 else 4;
        let primary_rows = if trans_b then k else 1;
        let primary_columns = if trans_b then 1 else k;
        let primary_physical_rows = DerivedTileRows(
            128, primary_pitch, TileDataType_HiF4X2);
        ConfigureTileForMask(10, 128, primary_physical_rows,
            primary_pitch, primary_rows, primary_columns,
            TileDataType_HiF4X2, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(10);
        ConfigureTileForMask(11, 128,
            DerivedTileRows(128, 4, TileDataType_U32), 4,
            1, 1, TileDataType_U32, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(11);
        InstallSharedTile((Zeros{6} + 41) as SharedTileID,
            _Tiles[[10]], '1111');
        InstallSharedTile((Zeros{6} + 42) as SharedTileID,
            _Tiles[[11]], '1111');
    else
        let primary_rows = if trans_a then k else 1;
        let primary_columns = if trans_a then 1 else k;
        let primary_physical_rows = DerivedTileRows(
            128, a_pitch, TileDataType_HiF4X2);
        ConfigureTileForMask(10, 128, primary_physical_rows,
            a_pitch, primary_rows, primary_columns,
            TileDataType_HiF4X2, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(10);
        ConfigureTileForMask(11, 128,
            DerivedTileRows(128, 4, TileDataType_U32), 4,
            1, 1, TileDataType_U32, TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(11);
        let b_rows = if trans_b then k else 1;
        let b_columns = if trans_b then 1 else k;
        ConfigureTileForMask(12, 128,
            DerivedTileRows(128, b_pitch, TileDataType_FP16), b_pitch,
            b_rows, b_columns, TileDataType_FP16,
            TileLayout_RowMajor, '1111');
        MarkTileValidRegionDefined(12);
        InstallSharedTile((Zeros{6} + 40) as SharedTileID,
            _Tiles[[10]], '1111');
        InstallSharedTile((Zeros{6} + 41) as SharedTileID,
            _Tiles[[11]], '1111');
        InstallSharedTile((Zeros{6} + 42) as SharedTileID,
            _Tiles[[12]], '1111');
    end;

    var start: bits(64) = Zeros{64} + 0x00431181;
    start[31:27] = TileDataTypeToEncoding(left_type);
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(TileDataTypeToEncoding(right_type),
        Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        trans_a, trans_b);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + k);
    if right_role then
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 42) as SharedTileID, 0, '1111');
    else
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 42) as SharedTileID, 0, '1111');
    end;
    let shared_count = if right_role then 2 else 3;
    assert TileMXInputTypeSupported(TileDataType_HiF4X2);
    assert !TileOrdinaryMatrixInputTypeSupported(TileDataType_HiF4X2);
    assert TileMXOperandPairLegal(left_type, right_type);
    assert BundleMatrixSharedSchemasLegal(
        4, left_type, right_type, 1, 1, k, shared_count) == (k == 2);
end;

func main() => integer
begin
    for role = 0 to 1 looplimit 2 do
        let right_role = role == 1;
        for k_case = 0 to 1 looplimit 2 do
            let k = if k_case == 0 then 2 else 3;
            for transpose_case = 0 to 3 looplimit 4 do
                let trans_a = !right_role && transpose_case MOD 2 == 1;
                let trans_b = transpose_case >= 2;
                RunSharedHiF4Shape(right_role, k, trans_a, trans_b);
            end;
        end;
    end;
    return 0;
end;
