// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-DEFINED-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"boundary","summary":"TFMA requires every valid element of all three sources to be defined.","pass_condition":"An unwritten addend makes operand preflight fail without changing the destination.","related_sources":["asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 3 looplimit 4 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    assert !InstructionContractOperandsLegal_TFMA(0, 1, 2, 3);
    assert !TileElementDefined(0, 0, 0);
    return 0;
end;
