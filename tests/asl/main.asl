func main() => integer
begin
    ValidateCanonicalDecoders();
    TestScalarState();
    TestTileRegisterMapping();
    TestScalarOperandBridge();
    ValidateCanonicalScalarExecution();
    TestScalarDispatchEffects();
    TestScalarSystemDispatchEffects();
    TestScalarAtomicDispatchEffects();
    TestScalarInteger();
    TestScalarMemory();
    TestScalarAtomics();
    TestScalarSystem();
    TestScalarFloating();
    TestTileElementwiseAndAliasing();
    TestTileMemory();
    TestTileMatmul();
    TestTileReduction();
    TestTileExpansion();
    TestTileGeneration();
    TestTileRearrangement();
    TestTileComplex();
    TestTileManagement();
    TestTileConversion();
    TestTileHandlerClosure();
    return 0;
end;
