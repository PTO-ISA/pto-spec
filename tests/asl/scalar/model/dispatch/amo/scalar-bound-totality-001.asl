// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-AMO-TOTALITY-001","source":"asl/scalar/model/dispatch/amo.asl","requirements":[],"kind":"boundary","summary":"Covers Canonical Scalar AMO Totality.","pass_condition":"ValidateCanonicalScalarAMOTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAMOTotality();
    return 0;
end;
