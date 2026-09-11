// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DATR-LAYOUT-MAP-001","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-INST-BLOCK-B-DATR"],"kind":"boundary","summary":"The twenty-three assigned Layout encodings have exact bidirectional mappings.","pass_condition":"Every assigned sparse code, including OHWI2NK, OIHW2NK, direct CUBE_M32, and direct CUBE_M16, maps to its named layout or transformation and round-trips; every other code is reserved.","related_sources":["asl/block/model/state/control-state.asl"]}
func main() => integer
begin
    var accepted_count: integer {0..32} = 0;
    for code = 0 to 31 do
        let encoded = Zeros{5} + code;
        if TileDataLayoutCodeAccepted(encoded) then
            let mapped = TileDataLayoutOfCode(encoded);
            assert TileDataLayoutCodeOf(mapped) == encoded;
            accepted_count = (accepted_count + 1) as integer {0..32};
        end;
    end;
    assert accepted_count == 23;
    assert TileDataLayoutOfCode(Zeros{5}) == TileDataLayout_NORM;
    assert TileDataLayoutOfCode(Zeros{5} + 1) == TileDataLayout_ND2DN;
    assert TileDataLayoutOfCode(Zeros{5} + 3) == TileDataLayout_ND2ZN;
    assert TileDataLayoutOfCode(Zeros{5} + 10) == TileDataLayout_OHWI2NK;
    assert TileDataLayoutOfCode(Zeros{5} + 11) == TileDataLayout_OIHW2NK;
    assert TileDataLayoutOfCode(Zeros{5} + 21) == TileDataLayout_ND2M32;
    assert TileDataLayoutOfCode(Zeros{5} + 28) == TileDataLayout_NZ2DN;
    assert TileDataLayoutOfCode(Zeros{5} + 29) == TileDataLayout_CUBE_M32;
    assert TileDataLayoutOfCode(Zeros{5} + 30) == TileDataLayout_NZ2ZN;
    assert TileDataLayoutOfCode(Zeros{5} + 31) == TileDataLayout_CUBE_M16;
    assert !TileDataLayoutCodeAccepted(Zeros{5} + 12);
    assert !TileDataLayoutCodeAccepted(Zeros{5} + 13);
    return 0;
end;
