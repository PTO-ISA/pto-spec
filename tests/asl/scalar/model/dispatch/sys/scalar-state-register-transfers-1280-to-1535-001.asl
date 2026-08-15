// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-REG-XFER-1280-1535-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"state-transition","summary":"Covers Canonical Scalar SYS Register Transfers1280 To1535.","pass_condition":"ValidateCanonicalScalarSYSRegisterTransfers1280To1535 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRegisterTransfers1280To1535();
    return 0;
end;
