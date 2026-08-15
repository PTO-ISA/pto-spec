// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-AMO-ALIASES-001","source":"asl/scalar/model/dispatch/amo.asl","requirements":[],"kind":"execution","summary":"Covers Canonical Scalar AMO Aliases.","pass_condition":"ValidateCanonicalScalarAMOAliases completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAMOAliases();
    return 0;
end;
