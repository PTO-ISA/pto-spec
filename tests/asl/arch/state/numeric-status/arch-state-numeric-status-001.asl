// PTO-TEST: {"id":"PTO-AVS-ARCH-NUMERIC-STATUS-001","source":"asl/arch/state/numeric-status.asl","requirements":["PTO-NUMERIC-STATUS-STICKY-001"],"kind":"state-transition","summary":"numeric status accumulates sticky architectural flags","pass_condition":"new flags are ORed into CORE_STATE without clearing an existing flag","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    _SystemRegisters.core_state[36:32] = '00100';

    RecordNumericStatusFlags('00010');

    assert NumericStatusFlags() == '00110';
    return 0;
end;
