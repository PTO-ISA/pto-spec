// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-NONPOWER-RANGES-039","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"execution","summary":"Decoded all-Shared TMATMUL accepts non-power N and K at small, medium, and large source shapes.","pass_condition":"M=2 with (N,K)=(3,3),(9,17),(24,193) completes from real Shared descriptors and publishes a defined exact-shape Local U32 destination.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/execution/cube.asl"]}

func main() => integer
begin
    for instance = 0 to 2 looplimit 3 do
        ResetProfileState();
        let n = if instance == 0 then 3 else if instance == 1 then 9 else 24;
        let k = if instance == 0 then 3 else if instance == 1 then 17 else 193;
        let pitch = if instance == 0 then 4 else if instance == 1 then 32 else 256;
        let capacity_a = pitch * 2 * 16;
        let capacity_b = pitch * 2 * 32;
        let physical_rows_a = DerivedTileRows(
            capacity_a, pitch, TileDataType_U16);
        let physical_rows_b = DerivedTileRows(
            capacity_b, pitch, TileDataType_U16);
        ConfigureTileForMask(10, capacity_a, physical_rows_a, pitch,
            2, k, TileDataType_U16, TileLayout_RowMajor, '1111');
        ConfigureTileForMask(11, capacity_b, physical_rows_b, pitch,
            n, k, TileDataType_U16, TileLayout_RowMajor, '1111');
        for row = 0 to 1 looplimit 2 do
            for column = 0 to k - 1 looplimit 256 do
                WriteTileElement(10, row, column, Zeros{PTO_XLEN});
            end;
        end;
        for row = 0 to n - 1 looplimit 32 do
            for column = 0 to k - 1 looplimit 256 do
                WriteTileElement(11, row, column, Zeros{PTO_XLEN});
            end;
        end;
        InstallSharedTile((Zeros{6} + 40) as SharedTileID,
            _Tiles[[10]], '1111');
        InstallSharedTile((Zeros{6} + 41) as SharedTileID,
            _Tiles[[11]], '1111');

        var start: bits(64) = Zeros{64} + 0x00031181;
        start[31:27] = Zeros{5} + 26;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
            FALSE, FALSE, FALSE);
        SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
        SetBundleDimension(1, Zeros{PTO_XLEN} + n);
        SetBundleDimension(2, Zeros{PTO_XLEN} + k);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        AddBundleTileBinding(
            TRUE, 0, 6, '1111', FALSE, FALSE, 0, 0, TRUE);

        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let destination = BundleMatrixDestinationAt(0);
        assert _Tiles[[destination]].contents_defined;
        assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
        assert _Tiles[[destination]].valid_rows == 2;
        assert _Tiles[[destination]].valid_columns == n;
        assert TileCubeDescriptorLegal(_Tiles[[destination]]);
    end;
    return 0;
end;
