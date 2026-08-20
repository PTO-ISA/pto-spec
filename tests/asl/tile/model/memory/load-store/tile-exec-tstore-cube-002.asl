// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-CUBE-002","source":"asl/tile/model/memory/load-store.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"TSTORE maps persistent CUBE_N8 storage into one strided GM rectangle","pass_condition":"Every valid FP16 element is stored and row gaps plus physical CUBE padding remain absent from GM","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(1, 768, 13, 19,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix);
    assert configured;
    var tile = _Tiles[[1]];
    for row = 0 to 12 do
        for column = 0 to 18 do
            let element = TileStorageIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            tile.payload[[element]] =
                Zeros{PTO_XLEN} + (row * 32 + column + 1);
            tile.defined_elements[element] = '1';
        end;
    end;
    tile.defined_valid_elements = (13 * 19) as integer {0..16384};
    tile.contents_defined = TRUE;
    _Tiles[[1]] = tile;

    let base = Zeros{PTO_XLEN} + 0x800;
    let stride = Zeros{PTO_XLEN} + 21;
    for element = 0 to 273 do
        Store(base + (element * 2), 2, Zeros{PTO_XLEN} + 0x5a5a);
    end;

    TSTORE(base, stride, 1);

    assert _LastFault == Fault_None;
    let value00 = LoadUnsigned(base, 2);
    let value77 = LoadUnsigned(base + ((7 * 21 + 7) * 2), 2);
    let value1218 = LoadUnsigned(base + ((12 * 21 + 18) * 2), 2);
    let row_gap = LoadUnsigned(base + 19 * 2, 2);
    let after_valid = LoadUnsigned(base + ((13 * 21) * 2), 2);
    assert value00 == Zeros{PTO_XLEN} + 1;
    assert value77 == Zeros{PTO_XLEN} + 232;
    assert value1218 == Zeros{PTO_XLEN} + 403;
    assert row_gap == Zeros{PTO_XLEN} + 0x5a5a;
    assert after_valid == Zeros{PTO_XLEN} + 0x5a5a;
    assert _Tiles[[1]].allocated && _Tiles[[1]].contents_defined;
    return 0;
end;
