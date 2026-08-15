// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-REQUEST-TOTALITY-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"boundary","summary":"Covers Canonical Scalar SYS Request Totality.","pass_condition":"ValidateCanonicalScalarSYSRequestTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRequestTotality();
    return 0;
end;
