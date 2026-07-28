// PTO-REQ-SCALAR-AMO-001: LR/SC, CAS, RMW, and exact 64-byte DMA.

readonly impdef func AtomicAddress(address: Word, far: boolean) => Word
begin
    // The portable model has one flat address domain. FAR remains an explicit
    // address-class hint so profiles can refine it without changing decoding.
    if far then return address; else return address; end;
end;

pure func NormalizeAtomicReturn(value: Word,
                                size_bytes: integer {1,2,4,8}) => Word
begin
    case size_bytes of
        when 1 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 2 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 4 => return SignExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

func LoadReserved(address: Word, size_bytes: integer {1,2,4,8},
                  order: MemoryOrder) => Word
begin
    let result = LoadUnsigned(address, size_bytes);
    if _LastFault == Fault_None then
        ApplyMemoryOrderBefore(order);
        _ReservationValid = TRUE;
        _ReservationAddress = address;
        _ReservationSize = size_bytes;
        ApplyMemoryOrderAfter(order);
    end;
    return result;
end;

func StoreConditional(address: Word, size_bytes: integer {1,2,4,8},
                      value: Word, order: MemoryOrder) => Word
begin
    let succeeds = _ReservationValid &&
        _ReservationAddress == address && _ReservationSize == size_bytes;
    _ReservationValid = FALSE;
    if succeeds then
        ApplyMemoryOrderBefore(order);
        Store(address, size_bytes, value);
        ApplyMemoryOrderAfter(order);
        return Zeros{PTO_XLEN};
    else
        return Zeros{PTO_XLEN} + 1;
    end;
end;

pure func AtomicValue(op: AtomicOperation, old_value: Word, operand: Word) => Word
begin
    case op of
        when Atomic_SWAP => return operand;
        when Atomic_ADD  => return old_value + operand;
        when Atomic_AND  => return old_value AND operand;
        when Atomic_OR   => return old_value OR operand;
        when Atomic_XOR  => return old_value XOR operand;
        when Atomic_SMIN =>
            if SInt(old_value) < SInt(operand) then return old_value; else return operand; end;
        when Atomic_SMAX =>
            if SInt(old_value) > SInt(operand) then return old_value; else return operand; end;
        when Atomic_UMIN =>
            if UInt(old_value) < UInt(operand) then return old_value; else return operand; end;
        when Atomic_UMAX =>
            if UInt(old_value) > UInt(operand) then return old_value; else return operand; end;
    end;
end;

pure func NormalizeAtomicUnsigned(value: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    case size_bytes of
        when 1 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 2 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 4 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

pure func NormalizeAtomicSigned(value: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    case size_bytes of
        when 1 => return SignExtend{PTO_XLEN}(value[7:0]);
        when 2 => return SignExtend{PTO_XLEN}(value[15:0]);
        when 4 => return SignExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

pure func AtomicValueSized(op: AtomicOperation, old_value: Word, operand: Word,
                           size_bytes: integer {1,2,4,8}) => Word
begin
    let old_unsigned = NormalizeAtomicUnsigned(old_value, size_bytes);
    let operand_unsigned = NormalizeAtomicUnsigned(operand, size_bytes);
    let old_signed = NormalizeAtomicSigned(old_value, size_bytes);
    let operand_signed = NormalizeAtomicSigned(operand, size_bytes);
    case op of
        when Atomic_SMIN =>
            if SInt(old_signed) < SInt(operand_signed) then return old_unsigned;
            else return operand_unsigned; end;
        when Atomic_SMAX =>
            if SInt(old_signed) > SInt(operand_signed) then return old_unsigned;
            else return operand_unsigned; end;
        otherwise => return NormalizeAtomicUnsigned(AtomicValue(op, old_unsigned, operand_unsigned), size_bytes);
    end;
end;

func AtomicReadModifyWrite(address: Word, size_bytes: integer {1,2,4,8},
                           op: AtomicOperation, operand: Word,
                           order: MemoryOrder) => Word
begin
    ApplyMemoryOrderBefore(order);
    let old_value = LoadUnsigned(address, size_bytes);
    if _LastFault == Fault_None then
        Store(address, size_bytes, AtomicValueSized(op, old_value, operand, size_bytes));
        ApplyMemoryOrderAfter(order);
    end;
    return old_value;
end;

func CompareAndSwap(address: Word, size_bytes: integer {1,2,4,8},
                    expected: Word, desired: Word, order: MemoryOrder) => Word
begin
    ApplyMemoryOrderBefore(order);
    let old_value = LoadUnsigned(address, size_bytes);
    if _LastFault == Fault_None &&
       old_value == NormalizeAtomicUnsigned(expected, size_bytes) then
        Store(address, size_bytes, desired);
    end;
    if _LastFault == Fault_None then ApplyMemoryOrderAfter(order); end;
    return old_value;
end;

func DMA64(source_address: Word, destination_address: Word)
begin
    if UInt(source_address) + 64 > PTO_MODEL_MEMORY_BYTES then
        SetFault(Fault_DataPage, source_address);
        return;
    end;
    if UInt(destination_address) + 64 > PTO_MODEL_MEMORY_BYTES then
        SetFault(Fault_DataPage, destination_address);
        return;
    end;

    // Snapshot before writing so overlapping ranges have memmove semantics and
    // a preflight fault leaves the destination unchanged.
    var snapshot: array [[64]] of Byte;
    for byte_index = 0 to 63 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        snapshot[[byte_index]] = ReadMemoryByte(source_address + offset);
    end;
    for byte_index = 0 to 63 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(destination_address + offset, snapshot[[byte_index]]);
    end;
    _ReservationValid = FALSE;
    _MemoryReleaseEpoch = _MemoryReleaseEpoch + 1;
    _MemoryAcquireEpoch = _MemoryAcquireEpoch + 1;
end;
