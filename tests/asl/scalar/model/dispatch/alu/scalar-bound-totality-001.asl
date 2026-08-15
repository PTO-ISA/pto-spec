// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-ALU-TOTALITY-001","source":"asl/scalar/model/dispatch/alu.asl","requirements":[],"kind":"boundary","summary":"Covers Canonical Scalar ALU Totality.","pass_condition":"ValidateCanonicalScalarALUTotality completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarALUTotality();
    return 0;
end;
