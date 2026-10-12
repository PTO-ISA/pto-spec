// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PACKED-EVEN-041","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"fault","summary":"Every transpose rejects odd K and every packed primary rejects an odd original Shared pitch.","pass_condition":"K=1,3,17,193 rejects for all four transpose pairs; independently legal odd-pitch packed A and B parents reject Matrix use for all transpose pairs before destination allocation or Shared consumption.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/shape/rows-columns.asl"]}

func PreparePackedSource(index: TileIndex, shared_tile_id: bits(6),
                         left: boolean, transpose: boolean,
                         k: integer {1..65535}, odd_pitch: boolean)
begin
    let pitch = if left then
        (if transpose then (if odd_pitch then 3 else 4)
         else (if odd_pitch then 255 else 256))
        else (if transpose then (if odd_pitch then 3 else 4)
              else (if odd_pitch then 255 else 256));
    let capacity = if pitch > 128 then 1024 else 512;
    let rows = DerivedTileRows(
        capacity, pitch, TileDataType_E2M1X2);
    let logical_rows = if left then 2 else 3;
    let logical_columns = k;
    let stored_rows = if left then
        (if transpose then logical_columns else logical_rows)
        else (if transpose then logical_columns else logical_rows);
    let stored_columns = if transpose then logical_rows else logical_columns;
    ConfigureTileForMask(index, capacity, rows, pitch,
        stored_rows, stored_columns, TileDataType_E2M1X2,
        TileLayout_RowMajor, '1111');
    MarkTileValidRegionDefined(index);
    assert TileInfoDescriptorLegal(_Tiles[[index]]);
    InstallSharedTile(shared_tile_id as SharedTileID,
        _Tiles[[index]], '1111');
    assert SharedTileDescriptorLegal(shared_tile_id as SharedTileID);
end;

func PreparePackedFaultCase(k: integer {1..65535},
                            controls: integer {0..3},
                            odd_side: integer {0..2},
                            omit_k: boolean)
begin
    ResetProfileState();
    let trans_a = controls MOD 2 == 1;
    let trans_b = controls >= 2;
    PreparePackedSource(10, Zeros{6} + 40, TRUE, trans_a, k,
        odd_side == 1);
    PreparePackedSource(11, Zeros{6} + 41, FALSE, trans_b, k,
        odd_side == 2);

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 11;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        trans_a, trans_b);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    if !omit_k then SetBundleDimension(2, Zeros{PTO_XLEN} + k); end;
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', FALSE, FALSE, 0, 0, TRUE);
    assert !BundleMatrixSharedSchemasLegal(
        0, TileDataType_E2M1X2, TileDataType_E2M1X2,
        2, 3, k, 2);

    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleSharedBindings[[0]].consumed;
    assert !_BundleSharedBindings[[1]].consumed;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func main() => integer
begin
    // The omitted packed K default is one and is rejected without rounding.
    PreparePackedFaultCase(1, 0, 0, TRUE);
    for k_case = 0 to 3 looplimit 4 do
        let k = if k_case == 0 then 1
            else if k_case == 1 then 3
            else if k_case == 2 then 17 else 193;
        for controls = 0 to 3 looplimit 4 do
            PreparePackedFaultCase(k, controls, 0, FALSE);
        end;
    end;
    // An odd physical pitch remains a legal generic Shared descriptor, but
    // the Matrix-use schema rejects it for either packed primary role.
    for controls = 0 to 3 looplimit 4 do
        PreparePackedFaultCase(6, controls, 1, FALSE);
        PreparePackedFaultCase(6, controls, 2, FALSE);
    end;
    return 0;
end;
