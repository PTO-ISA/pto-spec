// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-SELECTOR-001","source":"asl/tile/model/dispatch/top-level.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"execution","summary":"TEPL selector 0x01D is TEXPDIF and the following selector codes remain reserved","pass_condition":"0x01D decodes to SFU TEXPDIF with ExecuteTileExpdif, while 0x01E and 0x01F fail closed","related_sources":["asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl"]}
func main() => integer
begin
    let decoded = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x01D);
    assert decoded == 117;
    assert TileOperationOfIndex(
        decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
           TileOperation_TEXPDIF;
    assert TileHandlerOfIndex(
        decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
           TileHandler_ExecuteTileExpdif;
    assert TileEngineOfIndex(
        decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) == TileEngine_SFU;
    assert InstructionContractHandler_TEXPDIF() ==
           TileHandler_ExecuteTileExpdif;
    assert DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x01E) == PTO_TILE_OPERATION_COUNT;
    assert DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x01F) == PTO_TILE_OPERATION_COUNT;
    return 0;
end;
