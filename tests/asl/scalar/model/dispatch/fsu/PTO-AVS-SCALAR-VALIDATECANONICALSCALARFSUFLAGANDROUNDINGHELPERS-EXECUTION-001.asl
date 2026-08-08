// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARFSUFLAGANDROUNDINGHELPERS-EXECUTION-001","source":"asl/scalar/model/dispatch/fsu.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarFSUFlagAndRoundingHelpers","pass_condition":"ValidateCanonicalScalarFSUFlagAndRoundingHelpers completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarFSUFlagAndRoundingHelpers();
    return 0;
end;
