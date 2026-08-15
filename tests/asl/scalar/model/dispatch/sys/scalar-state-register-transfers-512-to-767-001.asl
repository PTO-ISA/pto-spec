// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-REG-XFER-512-767-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"state-transition","summary":"Covers Canonical Scalar SYS Register Transfers512 To767.","pass_condition":"ValidateCanonicalScalarSYSRegisterTransfers512To767 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRegisterTransfers512To767();
    return 0;
end;
