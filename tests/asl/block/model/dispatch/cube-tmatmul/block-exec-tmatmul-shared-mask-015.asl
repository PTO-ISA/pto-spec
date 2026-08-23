// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-MASK-015","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"execution","summary":"Every nonzero four-bit cooperative Matrix mask selects only its Local output producers","pass_condition":"all fifteen masks complete full Shared readiness and publish CUBE D with exact allocation mask and popcount capacity charge","related_sources":["asl/tile/model/legality/pe-mask.asl","asl/block/model/dispatch/cube-destination.asl"]}
func PrepareMaskSharedOperand(index: TileIndex, shared_tile_id: bits(6),
                              value: integer, left: boolean)
begin
    let valid_rows = if left then 4 else 1;
    ConfigureTileForMask(index, 128, 64, 1, valid_rows, 1,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    for row = 0 to valid_rows - 1 do
        WriteTileElement(index, row, 0, Zeros{PTO_XLEN} + value);
    end;
    InstallSharedTile(shared_tile_id as SharedTileID, _Tiles[[index]], '1111');
end;

func main() => integer
begin
    for raw_mask = 1 to 15 do
        ResetProfileState();
        let mask = Zeros{4} + raw_mask;
        PrepareMaskSharedOperand(10, Zeros{6} + 50, 2, TRUE);
        PrepareMaskSharedOperand(11, Zeros{6} + 51, 3, FALSE);
        let shared_capacity = CoreTileCapacityInUse();

        var start: bits(64) = Zeros{64} + 0x00031181;
        start[31:27] = Zeros{5} + 26;
        let started = ExecuteCommandInstruction(start, 32);
        assert started == CommandExecution_Executed;
        SetBundleFixedPointAttributeState(
            Zeros{6}, Zeros{3}, Zeros{4},
            FALSE, FALSE, FALSE, FALSE);
        BindBundleSharedIO((Zeros{6} + 50) as SharedTileID, 0, mask);
        BindBundleSharedIO((Zeros{6} + 51) as SharedTileID, 0, mask);
        AddBundleTileBinding(
            TRUE, 0, 1, mask, FALSE, FALSE, 0, 0, TRUE);

        let completed = ExecuteBundleTileOperation();
        assert completed;
        let destination = BundleMatrixDestinationAt(0);
        assert _TileAllocationMasks[[destination]] == mask;
        assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
        assert ReadTileElement(destination, 0, 0) ==
            Zeros{PTO_XLEN} + 6;
        assert CoreTileCapacityInUse() == shared_capacity +
            PEMaskPopulation(mask) * 128;
    end;
    return 0;
end;
