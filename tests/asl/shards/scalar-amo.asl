func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAMOEffects();
    ValidateCanonicalScalarAMOTotality();
    ValidateCanonicalScalarAMOAliases();
    TestScalarAtomicDispatchEffects();
    TestScalarAtomics();
    return 0;
end;
