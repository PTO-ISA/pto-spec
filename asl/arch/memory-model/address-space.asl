// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE","surface":"arch","classification":["memory-model","address-space"],"depends_on":["PTO-ARCH-STATE-DEFINEDNESS"]}

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-MEMORY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// PTO memory operations MUST reach physical byte storage only through
// ReadPhysicalMemoryByte and WritePhysicalMemoryByte. A functional-model
// binding MAY replace the reference array with host storage, but MUST preserve
// the ASL-owned translation, permission, preflight, ordering, and precise-fault
// behavior. The reference array bound MUST NOT constrain a host address space.
// NDF-END: PTO-REQ-FUNCTIONAL-MEMORY-001

readonly impdef func ReadPhysicalMemoryByte(address: Word) => Byte
begin
    return Zeros{8};
end;

impdef func WritePhysicalMemoryByte(address: Word, value: Byte)
begin
    assert FALSE;
end;

readonly func ReadMemoryByte(address: Word) => Byte
begin
    return ReadPhysicalMemoryByte(address);
end;

func WriteMemoryByte(address: Word, value: Byte)
begin
    WritePhysicalMemoryByte(address, value);
end;
