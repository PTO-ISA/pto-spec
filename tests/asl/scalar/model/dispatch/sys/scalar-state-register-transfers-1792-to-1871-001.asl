// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-REG-XFER-1792-1871-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"state-transition","summary":"Covers the final canonical scalar SYS register-transfer shard.","pass_condition":"ValidateCanonicalScalarSYSRegisterTransfers1792To1871 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSRegisterTransfers1792To1871();
    return 0;
end;
