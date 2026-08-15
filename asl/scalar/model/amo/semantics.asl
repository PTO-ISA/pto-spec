// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-AMO-SEMANTICS","surface":"scalar","classification":["model","amo","semantics"],"depends_on":["PTO-SCALAR-MODEL-AGU-ADDRESSING","PTO-ARCH-MEMORY-MODEL-ATOMICITY"]}
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
    if RaiseDataAccessFault(source_probe, source_address) then
        return;
    end;

    let destination_probe = ProbeDataAccess(destination_address, 64, 1, TRUE);
    if RaiseDataAccessFault(destination_probe, destination_address) then
        return;
    end;

    let snapshot = LoadTranslatedBytes64(source_probe.translated_address);
    var event_values: array [[8]] of Word;
    for chunk = 0 to 7 do
        let offset = (chunk * 8) as integer {0..262144};
        let translated_source = source_probe.translated_address +
            NaturalToWord(offset);
        let snapshot_value = Bytes64ChunkValue(snapshot, chunk);
        event_values[[chunk]] = snapshot_value;
        RecordLoadEvent(
            translated_source,
            8,
            snapshot_value,
            MemoryOrder_Relaxed);
    end;

    StoreTranslatedBytes64(
        destination_address,
        destination_probe.translated_address,
        snapshot);

    for chunk = 0 to 7 do
        let offset = (chunk * 8) as integer {0..262144};
        let translated_destination = destination_probe.translated_address +
            NaturalToWord(offset);
        RecordStoreEvent(
            translated_destination,
            8,
            event_values[[chunk]],
            MemoryOrder_Relaxed);
    end;
end;

func LoadReserved(address: Word, size_bytes: integer {1,2,4,8},
                  order: MemoryOrder) => Word
begin
    let result = LoadWithOrder(address, size_bytes, order);
    // A fault has no LR reservation effect. In particular, it preserves an
    // older reservation rather than replacing or clearing it.
    if _LastFault == Fault_None then
        _ReservationValid = TRUE;
        _ReservationAddress = address;
        _ReservationSize = size_bytes;
    end;
    return result;
end;

func StoreConditional(address: Word, size_bytes: integer {1,2,4,8},
                      value: Word, order: MemoryOrder) => Word
begin
    let reservation_granule = ReservationGranuleAddress();
    let requested_granule = address - NaturalToWord(
        (UInt(address) MOD PTO_RESERVATION_GRANULE_BYTES) as
            integer {0..262144});
    // PTO's local exclusive monitor is cache-line based: SC width and exact
    // byte address do not narrow the reservation once the 64-byte line matches.
    let succeeds = _ReservationValid && reservation_granule == requested_granule;
    if succeeds then
        // Every SC attempt clears the local monitor, including a successful
        // reservation check followed by an access fault.
        _ReservationValid = FALSE;
        let probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
        if RaiseDataAccessFault(probe, address) then return Zeros{PTO_XLEN}; end;
        StoreTranslated(address, probe.translated_address, size_bytes, value);
        RecordStoreEvent(probe.translated_address, size_bytes, value, order);
        return Zeros{PTO_XLEN};
    else
        // A reservation miss is deliberately probe-free, even when address is
        // misaligned or outside the active access domain.
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
    if read_probe.translated_address != write_probe.translated_address then
        SetFault(Fault_DataPage, address);
        return Zeros{PTO_XLEN};
    end;
    let old_value = LoadTranslatedUnsigned(
        read_probe.translated_address, size_bytes);
    let new_value = AtomicValueSized(op, old_value, operand, size_bytes);
    StoreTranslated(address, write_probe.translated_address, size_bytes,
        new_value);
    RecordAtomicEvent(write_probe.translated_address, size_bytes, old_value,
        new_value, order, TRUE);
    return old_value;
end;

func CompareAndSwap(address: Word, size_bytes: integer {1,2,4,8},
                    expected: Word, desired: Word, order: MemoryOrder) => Word
begin
    let read_probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(read_probe, address) then return Zeros{PTO_XLEN}; end;
    let write_probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(write_probe, address) then return Zeros{PTO_XLEN}; end;
    if read_probe.translated_address != write_probe.translated_address then
        SetFault(Fault_DataPage, address);
        return Zeros{PTO_XLEN};
    end;
    let old_value = LoadTranslatedUnsigned(
        read_probe.translated_address, size_bytes);
    let succeeds = old_value == NormalizeAtomicUnsigned(expected, size_bytes);
    if succeeds then
        StoreTranslated(address, write_probe.translated_address,
            size_bytes, desired);
    end;
    RecordAtomicEvent(write_probe.translated_address, size_bytes, old_value,
        NormalizeAtomicUnsigned(desired, size_bytes), order, succeeds);
    return old_value;
end;
