// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DATR-CUBE-RESERVED-003","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-INST-BLOCK-B-DATR"],"kind":"boundary","summary":"Assigning six CUBE conversions and two direct CUBE layouts leaves every other sparse B.DATR Layout code reserved","pass_condition":"the accepted Layout count is twenty-one and codes 2 5 7 10 through 16 and 19 remain unassigned while 29 and 31 are assigned direct layouts","related_sources":["asl/block/model/state/control-state.asl"]}
func main() => integer
begin
    var accepted_count: integer {0..32} = 0;
    for code = 0 to 31 do
        if TileDataLayoutCodeAccepted(Zeros{5} + code) then
            accepted_count = (accepted_count + 1) as integer {0..32};
        end;
    end;
    assert accepted_count == 21;
    assert !TileDataLayoutCodeAccepted(Zeros{5} + 2);
    assert !TileDataLayoutCodeAccepted(Zeros{5} + 5);
    assert !TileDataLayoutCodeAccepted(Zeros{5} + 7);
    for code = 10 to 16 do
        assert !TileDataLayoutCodeAccepted(Zeros{5} + code);
    end;
    assert !TileDataLayoutCodeAccepted(Zeros{5} + 19);
    assert TileDataLayoutCodeAccepted(Zeros{5} + 29);
    assert TileDataLayoutCodeAccepted(Zeros{5} + 31);
    return 0;
end;
