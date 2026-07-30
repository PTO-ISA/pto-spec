func main() => integer
begin
    ResetProfileState();
    TestTileElementwiseAndAliasing();
    TestTileMemory();
    TestTileMatmul();
    TestTileReduction();
    TestTileExpansion();
    TestTileGeneration();
    TestTileRearrangement();
    TestTileComplex();
    TestTileConversion();
    return 0;
end;
