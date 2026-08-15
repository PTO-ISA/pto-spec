// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-REG-XFER-1024-1279-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"state-transition","summary":"Covers Canonical Scalar SYS Register Transfers1024 To1279.","pass_condition":"ValidateCanonicalScalarSYSRegisterTransfers1024To1279 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRegisterTransfers1024To1279();
    return 0;
end;
