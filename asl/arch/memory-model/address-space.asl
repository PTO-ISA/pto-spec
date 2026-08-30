// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE","surface":"arch","classification":["memory-model","address-space"],"depends_on":["PTO-ARCH-STATE-DEFINEDNESS"]}
readonly impdef func HostReadMemoryByte(address: Word) => Byte
begin
    return Zeros{8};
end;

impdef func HostWriteMemoryByte(address: Word, value: Byte)
begin
    pass;
end;

// Instruction fetch uses a separate permission hook from data accesses.  A
// hosted model may bind both hooks to one address-space implementation, but
// keeping the architectural actions distinct prevents a data-only ACR rule
// from silently becoming an instruction-fetch rule.
readonly impdef func InstructionAccessPermitted(
    address: Word, size_bytes: integer {2,4,6,8}) => boolean
begin
    if PTO_MODEL_HOST_MEMORY then return TRUE; end;
    return UInt(address) + size_bytes <= PTO_MODEL_MEMORY_BYTES;
end;

readonly func IsModelAddress(address: Word) => boolean
begin
    return UInt(address) < PTO_MODEL_MEMORY_BYTES;
end;

readonly func ReadMemoryByte(address: Word) => Byte
begin
    if PTO_MODEL_HOST_MEMORY then
        return HostReadMemoryByte(address);
    end;
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    return _Memory[[index]];
end;

func WriteMemoryByte(address: Word, value: Byte)
begin
    if PTO_MODEL_HOST_MEMORY then
        HostWriteMemoryByte(address, value);
        return;
    end;
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    _Memory[[index]] = value;
end;
