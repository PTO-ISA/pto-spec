// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DATR-CUBE-LAYOUTS-002","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-B-DATR"],"kind":"decode-positive","summary":"B.DATR codes 21 through 26 name the six exact GM Local CUBE layout conversions","pass_condition":"each code is assigned round-trips identifies load or store direction and selects the required persistent CUBE layout","related_sources":["asl/block/model/state/control-state.asl","asl/arch/data-types/tile-data-types.asl"]}
func main() => integer
begin
    for code = 21 to 26 do
        let encoded = Zeros{5} + code;
        assert TileDataLayoutCodeAccepted(encoded);
        assert TileDataLayoutIsCubeConversion(encoded);
        let mapped = TileDataLayoutOfCode(encoded);
        assert TileDataLayoutCodeOf(mapped) == encoded;
    end;
    assert TileDataLayoutConversionIsLoad(Zeros{5} + 21);
    assert TileDataLayoutConversionIsLoad(Zeros{5} + 22);
    assert TileDataLayoutConversionIsLoad(Zeros{5} + 23);
    assert !TileDataLayoutConversionIsLoad(Zeros{5} + 24);
    assert TileDataLayoutConversionIsStore(Zeros{5} + 24);
    assert TileDataLayoutConversionIsStore(Zeros{5} + 25);
    assert TileDataLayoutConversionIsStore(Zeros{5} + 26);
    assert !TileDataLayoutConversionIsStore(Zeros{5} + 23);
    assert TileDataLayoutCubeLayout(Zeros{5} + 21) == TileLayout_CUBE_M32;
    assert TileDataLayoutCubeLayout(Zeros{5} + 22) == TileLayout_CUBE_M16;
    assert TileDataLayoutCubeLayout(Zeros{5} + 23) == TileLayout_CUBE_N8;
    assert TileDataLayoutCubeLayout(Zeros{5} + 24) == TileLayout_CUBE_M32;
    assert TileDataLayoutCubeLayout(Zeros{5} + 25) == TileLayout_CUBE_M16;
    assert TileDataLayoutCubeLayout(Zeros{5} + 26) == TileLayout_CUBE_N8;
    return 0;
end;
