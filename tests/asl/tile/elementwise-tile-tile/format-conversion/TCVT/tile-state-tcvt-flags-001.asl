// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-FLAGS-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"state-transition","summary":"TCVT publishes accumulated numeric flags with the converted destination","pass_condition":"the commit boundary ORs conversion flags into sticky status and publishes the prepared destination payload","related_sources":["asl/tile/model/numeric/formats.asl","asl/scalar/model/fsu/profile.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        16,
        8,
        1,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    var result = _Tiles[[0]];
    result.payload[[0]] = Zeros{PTO_XLEN} + 9;
    _SystemRegisters.core_state[36:32] = '00100';

    TileCommitConversionResult(0, result, '00010');

    assert ScalarFPFlags() == '00110';
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 9;
    return 0;
end;
