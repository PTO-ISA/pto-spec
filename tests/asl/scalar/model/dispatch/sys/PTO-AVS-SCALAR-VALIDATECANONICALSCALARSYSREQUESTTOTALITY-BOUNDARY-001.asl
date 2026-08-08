// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSREQUESTTOTALITY-BOUNDARY-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"boundary","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSRequestTotality","pass_condition":"ValidateCanonicalScalarSYSRequestTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRequestTotality();
    return 0;
end;
