// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-VALIDATECANONICALDECODERS-EXECUTION-001","source":"asl/arch/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalDecoders","pass_condition":"ValidateCanonicalDecoders completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalDecoders();
    return 0;
end;
