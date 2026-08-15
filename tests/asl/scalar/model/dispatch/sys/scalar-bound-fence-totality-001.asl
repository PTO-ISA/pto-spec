// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-FENCE-TOTALITY-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"boundary","summary":"Covers Canonical Scalar SYS Fence Totality.","pass_condition":"ValidateCanonicalScalarSYSFenceTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSFenceTotality();
    return 0;
end;
