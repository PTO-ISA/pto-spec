func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarFSUEffects();
    ValidateCanonicalScalarFSUAliases();
    ValidateCanonicalScalarFSUFlagAndRoundingHelpers();
    TestScalarFPDispatchEffects();
    TestScalarFloating();
    return 0;
end;
