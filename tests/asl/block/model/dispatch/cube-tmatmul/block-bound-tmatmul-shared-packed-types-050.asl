// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-TYPES-BOUNDARY-050","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"boundary","summary":"Four-bit packed Shared parity is checked by primary role and transpose form.","pass_condition":"For E2M1X2, E1M2X2, S4X2, and U4X2, legal even-pitch Shared source descriptors pass Matrix schemas at K=2 and odd K=3 rejects for both Shared roles across every all-Shared transpose pair and right-only TransB forms.","related_sources":["asl/tile/model/legality/matrix-shape.asl","asl/block/model/dispatch/shared-cube-matrix.asl"]}

func main() => integer
begin
    for type_case = 0 to 3 looplimit 4 do
        let data_type = if type_case == 0 then TileDataType_E2M1X2
            else if type_case == 1 then TileDataType_E1M2X2
            else if type_case == 2 then TileDataType_S4X2
            else TileDataType_U4X2;
        for k_case = 0 to 1 looplimit 2 do
            let k = if k_case == 0 then 2 else 3;
            for transpose_case = 0 to 3 looplimit 4 do
                for sharing_case = 0 to 1 looplimit 2 do
                    ResetProfileState();
                    let left_shared = sharing_case == 1;
                    let trans_a = left_shared && transpose_case MOD 2 == 1;
                    let trans_b = transpose_case >= 2;
                    let a_pitch = if trans_a then 2 else if k == 2 then 2 else 4;
                    let b_pitch = if trans_b then 2 else if k == 2 then 2 else 4;
                    let a_valid_rows = if trans_a then k else 1;
                    let a_valid_columns = if trans_a then 1 else k;
                    let b_valid_rows = if trans_b then k else 1;
                    let b_valid_columns = if trans_b then 1 else k;
                    let a_rows = DerivedTileRows(128, a_pitch, data_type);
                    let b_rows = DerivedTileRows(128, b_pitch, data_type);
                    if left_shared then
                        ConfigureTileForMask(10, 128, a_rows, a_pitch,
                            a_valid_rows, a_valid_columns, data_type,
                            TileLayout_RowMajor, '1111');
                        MarkTileValidRegionDefined(10);
                        InstallSharedTile((Zeros{6} + 40) as SharedTileID,
                            _Tiles[[10]], '1111');
                    end;
                    ConfigureTileForMask(11, 128, b_rows, b_pitch,
                        b_valid_rows, b_valid_columns, data_type,
                        TileLayout_RowMajor, '1111');
                    MarkTileValidRegionDefined(11);
                    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
                        _Tiles[[11]], '1111');

                    var start: bits(64) = Zeros{64} + 0x00031181;
                    start[31:27] = TileDataTypeToEncoding(data_type);
                    let started = ExecuteCommandInstruction(start, 32);
                    assert started == CommandExecution_Executed;
                    SetBundleDataAttributeState(
                        TileDataTypeToEncoding(data_type), Zeros{5},
                        Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
                    _BundleDataAttributesPresent = TRUE;
                    SetBundleFixedPointAttributeState(
                        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE,
                        FALSE, FALSE, trans_a, trans_b);
                    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
                    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
                    SetBundleDimension(2, Zeros{PTO_XLEN} + k);
                    if left_shared then
                        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID,
                            0, '1111');
                    end;
                    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID,
                        0, '1111');
                    let shared_count = if left_shared then 2 else 1;
                    assert TileInfoDescriptorLegal(_Tiles[[11]]);
                    let schemas_legal = BundleMatrixSharedSchemasLegal(
                        11, data_type, data_type, 1, 1, k, shared_count);
                    assert schemas_legal == (k == 2);
                end;
            end;
        end;
    end;
    return 0;
end;
