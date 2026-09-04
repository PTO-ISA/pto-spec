// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-SHARED-GENERATION","surface":"block","classification":["model","state","shared-generation-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
func ClearBundleSharedGenerationState(shared_tile_id: SharedTileID)
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    _SharedGenerations[[index]].open = FALSE;
    _SharedGenerations[[index]].closed = FALSE;
    _SharedGenerations[[index]].published = FALSE;
    _SharedGenerations[[index]].shared_tile_id = shared_tile_id;
    _SharedGenerations[[index]].participant_mask = Zeros{4};
    _SharedGenerations[[index]].parent_size_code = 0;
    _SharedGenerations[[index]].parent_cell_count = 0;
    _SharedGenerations[[index]].covered_cells = Zeros{8192};
    _SharedGenerations[[index]].ready_cells = Zeros{8192};
    _SharedGenerations[[index]].arrived_participants = Zeros{4};
    _SharedGenerations[[index]].specialized_inputs_valid = FALSE;
    _SharedGenerations[[index]].specialized_input0 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input1 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input2 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input3 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_metadata = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].last_seen = FALSE;
    _SharedGenerations[[index]].working_valid = FALSE;
    _SharedGenerations[[index]].working_tile =
        _SharedTiles[[index]].tile;
    _SharedGenerations[[index]].working_initialized_mask = Zeros{4};
end;

func ResetBundleSharedGenerationState()
begin
    for raw_id = 0 to PTO_SHARED_TILE_COUNT - 1 do
        ClearBundleSharedGenerationState(
            (Zeros{6} + raw_id) as SharedTileID);
    end;
end;

readonly func BundleSharedGenerationOpen(shared_tile_id: SharedTileID)
    => boolean
begin
    return _SharedGenerations[[SharedTileArrayIndex(shared_tile_id)]].open;
end;

func AbortBundleSharedGeneration(shared_tile_id: SharedTileID)
begin
    ClearBundleSharedGenerationState(shared_tile_id);
end;
