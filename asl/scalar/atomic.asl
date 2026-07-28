// PTO-REQ-SCALAR-AMO-001, PTO-REQ-MEMORY-TSO-001: LR/SC, CAS, and atomic
// read-modify-write operations represented as indivisible TSO events.

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

// DMA copies one 64-byte command payload. Both ranges are translated and
// permission-checked before any byte is read or written. Source bytes are
// snapshotted before the destination commit, so overlapping ranges have
// memmove semantics and any fault leaves memory unchanged.
func ExecuteScalarDMACopy64(source_address: Word, destination_address: Word)
begin
    let source_probe = ProbeDataAccess(source_address, 64, 1, FALSE);
    if RaiseDataAccessFault(source_probe, source_address) then return; end;
    let destination_probe = ProbeDataAccess(destination_address, 64, 1, TRUE);
    if RaiseDataAccessFault(destination_probe, destination_address) then return; end;

    let snapshot = LoadTranslatedBytes64(source_probe.translated_address);
    StoreTranslatedBytes64(destination_address, destination_probe.translated_address,
                           snapshot);
end;

func LoadReserved(address: Word, size_bytes: integer {1,2,4,8},
                  order: MemoryOrder) => Word
begin
    let result = LoadUnsigned(address, size_bytes);
    if _LastFault == Fault_None then
        _ReservationValid = TRUE;
        _ReservationAddress = address - NaturalToWord(
            (UInt(address) MOD PTO_RESERVATION_GRANULE_BYTES) as
                integer {0..262144});
        _ReservationSize = size_bytes;
    end;
    return result;
end;

func StoreConditional(address: Word, size_bytes: integer {1,2,4,8},
                      value: Word, order: MemoryOrder) => Word
begin
    let granule_address = address - NaturalToWord(
        (UInt(address) MOD PTO_RESERVATION_GRANULE_BYTES) as
            integer {0..262144});
    let succeeds = _ReservationValid && _ReservationAddress == granule_address;
    if succeeds then
        let probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
        if RaiseDataAccessFault(probe, address) then return Zeros{PTO_XLEN}; end;
        _ReservationValid = FALSE;
        StoreTranslated(address, probe.translated_address, size_bytes, value);
        return Zeros{PTO_XLEN};
    else
        _ReservationValid = FALSE;
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
    let read_probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(read_probe, address) then return Zeros{PTO_XLEN}; end;
    let write_probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(write_probe, address) then return Zeros{PTO_XLEN}; end;
    let old_value = LoadTranslatedUnsigned(
        read_probe.translated_address, size_bytes);
    StoreTranslated(address, write_probe.translated_address, size_bytes,
        AtomicValueSized(op, old_value, operand, size_bytes));
    return old_value;
end;

func CompareAndSwap(address: Word, size_bytes: integer {1,2,4,8},
                    expected: Word, desired: Word, order: MemoryOrder) => Word
begin
    let read_probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(read_probe, address) then return Zeros{PTO_XLEN}; end;
    let write_probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(write_probe, address) then return Zeros{PTO_XLEN}; end;
    let old_value = LoadTranslatedUnsigned(
        read_probe.translated_address, size_bytes);
    if old_value == NormalizeAtomicUnsigned(expected, size_bytes) then
        StoreTranslated(address, write_probe.translated_address,
            size_bytes, desired);
    end;
    return old_value;
end;
