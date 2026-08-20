// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-CUBE-001","source":"asl/tile/model/memory/load-store.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"TLOAD maps one strided GM rectangle into persistent CUBE_N8 storage","pass_condition":"FP16 values spanning K and N CELL boundaries occupy the CUBE payload indices for their logical coordinates","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(0, 768, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix);
    assert configured;
    let base = Zeros{PTO_XLEN} + 0x400;
    let stride = Zeros{PTO_XLEN} + 21;
    for row = 0 to 12 do
        for column = 0 to 18 do
            let logical = row * 21 + column;
            let address = base + (logical * 2);
            let value = Zeros{PTO_XLEN} + (row * 32 + column + 1);
            Store(address, 2, value);
        end;
    end;

    TLOAD(0, base, stride);

    assert _LastFault == Fault_None;
    let tile = _Tiles[[0]];
    assert tile.payload[[TileStorageIndex(tile, 0, 0)]] ==
        Zeros{PTO_XLEN} + 1;
    assert tile.payload[[TileStorageIndex(tile, 7, 7)]] ==
        Zeros{PTO_XLEN} + 232;
    assert tile.payload[[TileStorageIndex(tile, 8, 0)]] ==
        Zeros{PTO_XLEN} + 257;
    assert tile.payload[[TileStorageIndex(tile, 12, 18)]] ==
        Zeros{PTO_XLEN} + 403;
    assert tile.defined_valid_elements == 13 * 19;
    assert tile.contents_defined;
    return 0;
end;
