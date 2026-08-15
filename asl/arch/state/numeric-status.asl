// PTO-UNIT: {"id":"PTO-ARCH-STATE-NUMERIC-STATUS","surface":"arch","classification":["state","numeric-status"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING"]}
// NDF-BEGIN: PTO-NUMERIC-STATUS-STICKY-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Numeric execution flags MUST map to CORE_STATE[36:32] as NV, DZ, OF, UF,
// and NX, and a successful numeric operation MUST OR its produced flags into
// the existing sticky status without clearing an earlier flag.
// NDF-END: PTO-NUMERIC-STATUS-STICKY-001
// DOC-BEGIN: state
readonly func NumericStatusFlags() => bits(5)
begin
    return _SystemRegisters.core_state[36:32];
end;

func RecordNumericStatusFlags(flags: bits(5))
begin
    _SystemRegisters.core_state[36:32] = NumericStatusFlags() OR flags;
end;
// DOC-END: state
