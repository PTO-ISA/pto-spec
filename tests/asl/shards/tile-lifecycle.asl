func main() => integer
begin
    ResetProfileState();
    TestTileHandlerClosure();
    TestTileSelectorClosureExtensions();
    TestDecodedTileExecution();
    TestTileCapacityLegality();
    TestTileElementDefinedness();
    TestTileManagementHandoff();
    TestDecodedTileLegalityFaults();
    TestTileMemoryCompletionAndRestart();
    return 0;
end;
