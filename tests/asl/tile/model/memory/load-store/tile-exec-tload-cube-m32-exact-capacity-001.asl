// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-CUBE-M32-EXACT-CAPACITY-001","source":"asl/tile/model/memory/load-store.asl","requirements":["PTO-CUBE-CELL-STATE-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"One-row M32/U8 TLOAD retains its capacity-backed CUBE descriptor and avoids a page-crossing padding read.","pass_condition":"A 1x12 valid U8 region in a 512-byte allocation uses physical 32x16 storage; its twelve valid reads end at the mapped-page boundary, while physical padding stays undefined.","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/state/allocation.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(
        0, 512, 1, 12, TileDataType_U8, TileLayout_CUBE_M32);
    assert configured;
    // Valid bytes end at the mapped-page boundary. An accidental read of the
    // first physical padding byte at column 12 would fault at address 4096.
    let base = Zeros{PTO_XLEN} + 4084;
    for column = 0 to 11 do
        Store(base + column, 1, Zeros{PTO_XLEN} + (column + 1));
    end;

    StartMemoryEventCapture(0);
    TLOAD(0, base, Zeros{PTO_XLEN} + 16);
    assert _LastFault == Fault_None && _MemoryEventCount == 12;
    StopMemoryEventCapture();

    let tile = _Tiles[[0]];
    assert tile.rows == 32 && tile.columns == 16 &&
           tile.valid_rows == 1 && tile.valid_columns == 12 &&
           tile.capacity_bytes == 512 && tile.cube_cell_count == 4 &&
           tile.cube_storage_bytes == 512;
    assert tile.payload[[TileStorageIndex(tile, 0, 0)]] ==
           Zeros{PTO_XLEN} + 1;
    assert tile.payload[[TileStorageIndex(tile, 0, 11)]] ==
           Zeros{PTO_XLEN} + 12;
    for column = 12 to 15 do
        assert !TileLogicalElementDefined(tile,
            TileLogicalLinearIndex(tile, 0, column));
    end;
    assert tile.defined_valid_elements == 12;
    return 0;
end;
