// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-CUBE-PAD-004","source":"asl/tile/model/memory/load-store.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"state-transition","summary":"TLOAD applies every B.DATR PadValue only to physical CUBE tail positions","pass_condition":"Zero Max and Min tails are defined with exact raw FP16 values while Null tails remain undefined and valid definedness is unchanged","related_sources":["asl/block/model/state/control-state.asl","asl/tile/model/definedness/elements.asl"]}
func CheckCubeLoadPadding(pad_code: bits(2), expected: Word,
                          padding_defined: boolean)
begin
    ResetProfileState();
    let configured = ConfigureCubeTile(0, 128, 2, 3,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix);
    assert configured;
    _BundleDataAttributesPresent = TRUE;
    _BundleDataAttributes.pad_value = pad_code;
    for element = 0 to 5 do
        Store(Zeros{PTO_XLEN} + 0x500 + element * 2,
            2, Zeros{PTO_XLEN} + element + 1);
    end;

    TLOAD(0, Zeros{PTO_XLEN} + 0x500, Zeros{PTO_XLEN} + 6);

    let tile = _Tiles[[0]];
    let row_tail = TileStorageIndex(tile, 2, 0);
    let column_tail = TileStorageIndex(tile, 0, 3);
    assert tile.payload[[row_tail]] == expected;
    assert tile.payload[[column_tail]] == expected;
    assert (tile.defined_elements[row_tail] == '1') == padding_defined;
    assert (tile.defined_elements[column_tail] == '1') == padding_defined;
    assert tile.defined_valid_elements == 6;
    assert tile.contents_defined;
end;

func main() => integer
begin
    CheckCubeLoadPadding('00', Zeros{PTO_XLEN}, TRUE);
    CheckCubeLoadPadding('01', Zeros{PTO_XLEN} + 0x7bff, TRUE);
    CheckCubeLoadPadding('10', Zeros{PTO_XLEN} + 0xfbff, TRUE);
    CheckCubeLoadPadding('11', Zeros{PTO_XLEN}, FALSE);
    return 0;
end;
