func main() => integer
begin
    ResetProfileState();
    TestTileElementwiseAndAliasing();
    TestTileMemory();
    TestTileMatmul();
    TestMatrixNumericContractLegality();
    TestMatrixPhysicalAccumulatorClasses();
    TestTileReduction();
    TestTileExpansion();
    TestTileGeneration();
    TestTileRearrangement();
    TestTileComplex();
    TestTileConversion();
    return 0;
end;
