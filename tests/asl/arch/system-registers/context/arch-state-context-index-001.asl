// PTO-TEST: {"id":"PTO-AVS-ARCH-SYSTEM-REGISTERS-CONTEXT-INDEX-001","source":"asl/arch/system-registers/context.asl","requirements":[],"kind":"state-transition","summary":"PTOv0 context access uses the ring-times-4096 plus low-index mapping","pass_condition":"both index helpers agree and PTOv0 read returns the value written at the selected extended-register entry","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    let ring: AccessControlRing = 2;
    let low_index: integer {0..4095} = 0x0123;
    let expected = ((2 * 4096) + 0x0123) as SystemRegisterFileIndex;

    assert ContextRegisterIndex(ring, low_index) == expected;
    assert PTOv0ContextRegisterIndex(ring, low_index) == expected;
    PTOv0WriteContextRegister(ring, low_index, Zeros{PTO_XLEN} + 0x5a);
    assert PTOv0ReadContextRegister(ring, low_index) ==
        Zeros{PTO_XLEN} + 0x5a;
    assert _ExtendedSystemRegisters[[expected]] == Zeros{PTO_XLEN} + 0x5a;
    return 0;
end;
