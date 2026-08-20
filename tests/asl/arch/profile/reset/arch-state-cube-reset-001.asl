// PTO-TEST: {"id":"PTO-AVS-ARCH-CUBE-RESET-001","source":"asl/arch/profile/reset.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"state-transition","summary":"Release and architectural reset clear every persistent CUBE descriptor field","pass_condition":"a configured CUBE Tile returns to the ordinary unallocated zero-geometry state after release and after reset","related_sources":["asl/tile/model/state/allocation.asl","asl/tile/model/state/types.asl"]}
func AssertCubeFieldsCleared(index: TileIndex)
begin
    assert !_Tiles[[index]].allocated;
    assert _Tiles[[index]].layout == TileLayout_RowMajor;
    assert _Tiles[[index]].cube_k_repeat == 0;
    assert _Tiles[[index]].cube_n_repeat == 0;
    assert _Tiles[[index]].cube_cell_count == 0;
    assert _Tiles[[index]].cube_storage_bytes == 0;
    assert _Tiles[[index]].defined_elements ==
        Zeros{PTO_MODEL_TILE_ELEMENTS};
    assert _Tiles[[index]].defined_valid_elements == 0;
    assert !_Tiles[[index]].contents_defined;
end;

func main() => integer
begin
    ResetProfileState();
    let configured_before_release = ConfigureCubeTile(0, 768, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix);
    assert configured_before_release;
    ReleaseTile(0);
    AssertCubeFieldsCleared(0);
    let configured_before_reset = ConfigureCubeTile(0, 768, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix);
    assert configured_before_reset;
    ResetProfileState();
    AssertCubeFieldsCleared(0);
    return 0;
end;
