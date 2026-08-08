// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARBRUTOTALITY-BOUNDARY-001","source":"asl/scalar/model/dispatch/bru.asl","requirements":[],"kind":"boundary","summary":"migrated independent behavior point for ValidateCanonicalScalarBRUTotality","pass_condition":"ValidateCanonicalScalarBRUTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarBRUTotality();
    return 0;
end;
