func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarALUEffects();
    ValidateCanonicalScalarALUTotality();
    ValidateCanonicalScalarBRUEffects();
    ValidateCanonicalScalarBRUTotality();
    ValidateCanonicalScalarBRUAliasAndFaults();
    TestScalarInteger();
    TestScalarBitfieldBoundaryContract();
    TestScalarALUBoundaryMatrix();
    TestScalarALUAliasMatrix();
    return 0;
end;
