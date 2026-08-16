// PTO-TEST: {"id":"PTO-AVS-TILE-VEC-SFU-SELECTOR-BOUND-001","source":"asl/tile/model/dispatch/top-level.asl","requirements":[],"kind":"boundary","summary":"VEC and SFU selector decoding is complete and engine classified","pass_condition":"all assigned selectors decode to a VEC or SFU operation and the assigned count is exact","related_sources":[]}
func TestVecSfuDecodedSelectorClosure()
begin
    var assigned: integer {0..128} = 0;
    for selector = 0 to 127 do
        let decoded = DecodeTileOperation(
            TileDecode_TEPL,
            Zeros{12} + selector);
        if decoded != PTO_TILE_OPERATION_COUNT then
            let operation =
                decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
            let engine = TileEngineOfIndex(operation);
            assert engine == TileEngine_VEC || engine == TileEngine_SFU;
            - = TileHandlerOfIndex(operation);
            assigned = (assigned + 1) as integer {0..128};
        end;
    end;
    assert assigned == 87;
end;

func main() => integer
begin
    ResetProfileState();
    TestVecSfuDecodedSelectorClosure();
    return 0;
end;
