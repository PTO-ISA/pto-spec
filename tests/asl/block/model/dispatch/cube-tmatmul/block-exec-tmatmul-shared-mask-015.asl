// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-MASK-015","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"execution","summary":"Cooperative TMATMUL accepts only all-four participation or the strict zero no-op.","pass_condition":"Every sparse nonzero mask raises TileLegality before Local allocation, while 1111 executes and publishes only the current PE fragment.","related_sources":["asl/tile/model/legality/pe-mask.asl","asl/block/model/dispatch/cube-destination.asl"]}

func PrepareMaskSharedOperand(index: TileIndex, shared_tile_id: bits(6),
                              value: integer)
begin
    ConfigureTileForMask(index, 128, 64, 1, 1, 1,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    WriteTileElement(index, 0, 0, Zeros{PTO_XLEN} + value);
    InstallSharedTile(shared_tile_id as SharedTileID,
        _Tiles[[index]], '1111');
end;

func main() => integer
begin
    for raw_mask = 1 to 15 do
        let mask = Zeros{4} + raw_mask;
        assert BundleTMATMULCooperativeMaskValueLegal(mask) ==
            (raw_mask == 15);
    end;

    for representative = 0 to 1 do
        ResetProfileState();
        let raw_mask = if representative == 0 then 3 else 15;
        let mask = Zeros{4} + raw_mask;
        PrepareMaskSharedOperand(10, Zeros{6} + 50, 2);
        PrepareMaskSharedOperand(11, Zeros{6} + 51, 3);
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
        if representative == 1 then
            assert completed && _LastFault == Fault_None;
            let destination = BundleMatrixDestinationAt(0);
            assert _TileAllocationMasks[[destination]] == '1000';
            assert CoreTileCapacityInUse() == shared_capacity + 128;
        else
            assert !completed && _LastFault == Fault_TileLegality;
            assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
            assert CoreTileCapacityInUse() == shared_capacity;
        end;
    end;
    return 0;
end;
