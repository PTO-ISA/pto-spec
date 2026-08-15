// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-ALIAS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001","PTO-INST-TILE-TFMA"],"kind":"execution","summary":"TFMA snapshots all sources before an aliased destination write.","pass_condition":"When destination aliases the left source, the fused value uses the complete old left payload and preserves the other sources.","related_sources":["asl/tile/model/execution/fused-multiply-add.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 4);

    InstructionContractExecute_TFMA(0, 0, 1, 2);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 4;
    return 0;
end;
