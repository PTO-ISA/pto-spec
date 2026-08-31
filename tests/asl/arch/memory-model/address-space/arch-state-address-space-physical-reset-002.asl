// PTO-TEST: {"id":"PTO-AVS-ARCH-ADDRESS-SPACE-PHYSICAL-RESET-002","source":"asl/arch/memory-model/address-space.asl","requirements":["PTO-REQ-PHYSICAL-MEMORY-BINDING-001"],"kind":"state-transition","summary":"The reference profile binds physical byte primitives to resettable reference memory.","pass_condition":"Bytes written through WritePhysicalMemoryByte read back as zero after ResetProfileState.","related_sources":["asl/arch/profile/reference-profile.asl","asl/arch/profile/reset.asl"]}
func main() => integer
begin
    ResetProfileState();
    let low_address = Zeros{PTO_XLEN} + 0x20;
    let high_address = Zeros{PTO_XLEN} +
        (PTO_MODEL_MEMORY_BYTES - 1);
    WritePhysicalMemoryByte(low_address, Zeros{8} + 0xa5);
    WritePhysicalMemoryByte(high_address, Zeros{8} + 0x5a);
    assert ReadPhysicalMemoryByte(low_address) == Zeros{8} + 0xa5;
    assert ReadPhysicalMemoryByte(high_address) == Zeros{8} + 0x5a;

    ResetProfileState();

    assert ReadPhysicalMemoryByte(low_address) == Zeros{8};
    assert ReadPhysicalMemoryByte(high_address) == Zeros{8};
    return 0;
end;
