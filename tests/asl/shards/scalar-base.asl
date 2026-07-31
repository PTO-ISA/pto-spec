func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarExecution();
    ValidateCanonicalScalarBinaryEffects();
    TestScalarDispatchEffects();
    TestScalarQueueDispatch();
    TestScalarAliasingOrder();
    TestScalarMemory();
    TestScalarPairMemoryCompletion();
    return 0;
end;
