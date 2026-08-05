func main() => integer
begin
    ResetProfileState();
    TestTileHandlerClosure();
    TestTileSelectorClosureExtensions();
    TestDecodedTileExecution();
    TestTileCapacityLegality();
    TestTileElementDefinedness();
    TestSharedRegisterAtomicUpdates();
    TestDecodedTileLegalityFaults();
    TestTileMemoryCompletionAndRestart();
    return 0;
end;
