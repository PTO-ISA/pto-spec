// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE","surface":"arch","classification":["memory-model","address-space"],"depends_on":["PTO-ARCH-STATE-DEFINEDNESS"]}

// NDF-BEGIN: PTO-REQ-PHYSICAL-MEMORY-BINDING-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// PTO memory operations MUST reach physical byte storage through
// ReadPhysicalMemoryByte and WritePhysicalMemoryByte. An executable profile MAY
// bind those primitives to external storage, but MUST preserve ASL-owned
// translation, permission, ordering, preflight, precise-fault, and commit
// behavior. Fixed reference-array bounds MUST NOT constrain every
// implementation.
// NDF-END: PTO-REQ-PHYSICAL-MEMORY-BINDING-001

readonly impdef func ReadPhysicalMemoryByte(address: Word) => Byte
begin
    return Zeros{8};
end;

impdef func WritePhysicalMemoryByte(address: Word, value: Byte)
begin
    pass;
end;

readonly func IsModelAddress(address: Word) => boolean
begin
    return UInt(address) < PTO_MODEL_MEMORY_BYTES;
end;

readonly func ReadMemoryByte(address: Word) => Byte
begin
    return ReadPhysicalMemoryByte(address);
end;

func WriteMemoryByte(address: Word, value: Byte)
begin
    WritePhysicalMemoryByte(address, value);
end;
