func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarFSUEffects();
    ValidateCanonicalScalarFSUAliases();
    ValidateCanonicalScalarFSUFlagAndRoundingHelpers();
    TestScalarFPDispatchEffects();
    TestScalarFPFlagLifecycle();
    TestScalarFloating();
    return 0;
end;
