// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSTRAPANDRECOVERYTOTALITY-FAULT-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"fault","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSTrapAndRecoveryTotality","pass_condition":"ValidateCanonicalScalarSYSTrapAndRecoveryTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSTrapAndRecoveryTotality();
    return 0;
end;
