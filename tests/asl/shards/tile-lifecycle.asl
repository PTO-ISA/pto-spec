func main() => integer
begin
    ResetProfileState();
    TestTileHandlerClosure();
    TestTileSelectorClosureExtensions();
    TestDecodedTileExecution();
    TestTileCapacityLegality();
    TestTileElementDefinedness();
    TestDecodedTileLegalityFaults();
    TestTileMemoryCompletionAndRestart();
    return 0;
end;
