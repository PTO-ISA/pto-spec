// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-CUBE-M16-B4-005","source":"asl/tile/model/memory/load-store.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"TLOAD preserves the assigned M16 four-bit CELL column interleave","pass_condition":"logical nibbles 4 through 11 occupy physical payload positions 8 through 11 then 4 through 7","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/memory/addressing.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(0, 128, 2, 16,
        TileDataType_U4X2, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert configured;
    let base = Zeros{PTO_XLEN} + 0x600;
    _Memory[[0x600]] = Zeros{8} + 0x10;
    _Memory[[0x601]] = Zeros{8} + 0x32;
    _Memory[[0x602]] = Zeros{8} + 0x54;
    _Memory[[0x603]] = Zeros{8} + 0x76;
    _Memory[[0x604]] = Zeros{8} + 0x98;
    _Memory[[0x605]] = Zeros{8} + 0xba;
    _Memory[[0x606]] = Zeros{8} + 0xdc;
    _Memory[[0x607]] = Zeros{8} + 0xfe;

    TLOAD(0, base, Zeros{PTO_XLEN} + 16);

    let tile = _Tiles[[0]];
    assert tile.payload[[0]] == Zeros{PTO_XLEN};
    assert tile.payload[[3]] == Zeros{PTO_XLEN} + 3;
    assert tile.payload[[4]] == Zeros{PTO_XLEN} + 8;
    assert tile.payload[[7]] == Zeros{PTO_XLEN} + 11;
    assert tile.payload[[8]] == Zeros{PTO_XLEN} + 4;
    assert tile.payload[[11]] == Zeros{PTO_XLEN} + 7;
    assert tile.payload[[12]] == Zeros{PTO_XLEN} + 12;
    assert tile.payload[[15]] == Zeros{PTO_XLEN} + 15;
    return 0;
end;
