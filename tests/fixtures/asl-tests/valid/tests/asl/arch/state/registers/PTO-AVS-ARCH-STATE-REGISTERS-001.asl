// PTO-TEST: {"id":"PTO-AVS-ARCH-STATE-REGISTERS-001","source":"asl/arch/state/registers.asl","requirements":["PTO-REQ-REGISTERS"],"kind":"static-invariant","summary":"the fixture register contract is independently testable","pass_condition":"main returns zero","related_sources":[]}
func main() => integer
begin
    return 0;
end;
