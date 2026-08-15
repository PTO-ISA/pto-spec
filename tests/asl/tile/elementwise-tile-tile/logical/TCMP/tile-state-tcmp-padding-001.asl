// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-PADDING-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-INST-TILE-TCMP"],"kind":"state-transition","summary":"TCMP applies predicate padding without changing its valid bits","pass_condition":"Max defines padding bits as one while Null leaves padding bits undefined","related_sources":["asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(0, 128, 2, 8, 1, 2);
    WriteTilePredicateBit(0, 0, 0, FALSE);
    WriteTilePredicateBit(0, 0, 1, TRUE);
    ApplyPredicateTilePadding(0, TilePad_Max);
    assert !ReadTilePredicateBit(0, 0, 0);
    assert ReadTilePredicateBit(0, 0, 1);
    assert ReadTilePredicateBit(0, 0, 2);
    assert TilePredicateBitDefined(0, 1, 7);

    ConfigurePredicateTile(1, 128, 2, 8, 1, 2);
    WriteTilePredicateBit(1, 0, 0, TRUE);
    WriteTilePredicateBit(1, 0, 1, FALSE);
    ApplyPredicateTilePadding(1, TilePad_Null);
    assert !TilePredicateBitDefined(1, 0, 2);
    return 0;
end;
