func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSEffects();
    ValidateCanonicalScalarSYSSelectorAliases();
    ValidateCanonicalScalarSYSControlTotality();
    TestScalarSystemDispatchEffects();
    TestScalarSystem();
    TestServiceRequestControl();
    return 0;
end;
