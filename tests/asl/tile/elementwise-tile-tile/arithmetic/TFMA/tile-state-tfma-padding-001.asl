// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-PADDING-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"state-transition","summary":"TFMA publishes its valid result and selected physical padding together.","pass_condition":"Explicit Max padding defines the destination element outside the valid rectangle.","related_sources":["asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 3 looplimit 4 do
        ConfigureTile(index as TileIndex, 128, 8, 2, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 4);
    SetBundleDataAttributeState(
        Zeros{5} + 24, Zeros{5}, '01',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;

    InstructionContractExecute_TFMA(0, 1, 2, 3);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert TileElementDefined(0, 0, 1);
    assert ReadTileElement(0, 0, 1) == Ones{PTO_XLEN};
    return 0;
end;
