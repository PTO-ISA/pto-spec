// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALAREXECUTION-EXECUTION-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarExecution","pass_condition":"ValidateCanonicalScalarExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarExecution();
    return 0;
end;
