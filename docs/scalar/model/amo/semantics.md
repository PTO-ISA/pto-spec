<!-- GENERATED FROM: asl/scalar/model/amo/semantics.asl -->
# Semantics

**Normative ASL source:** `asl/scalar/model/amo/semantics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-AMO-SEMANTICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the scalar atomic memory operations: load-reserved and store-conditional (LR/SC), atomic read-modify-write (RMW), compare-and-swap (CAS), and the 64-byte `DMA` copy. RMW, CAS, and `DMA` probe their addresses before they read or write memory. LR and SC follow the reservation rules below.

[AMO dispatch](../dispatch/amo.md) reads the decoded operands and calls these helpers. It writes the returned value to the destination only when no fault was raised.

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-concepts role=concepts-state -->
## Concepts and visible state

The reservation is `_ReservationValid`, `_ReservationAddress`, and `_ReservationSize`. A successful LR sets all three. The reservation granule is the 64-byte line that contains `_ReservationAddress`.

`AtomicAddress` maps an address and the `far` hint to a flat address. In this model it returns the address unchanged, so `far` has no effect.

`AtomicValueSized` computes the new memory value at the access width:

- `SWAP` installs the operand.
- `ADD`, `AND`, `OR`, and `XOR` work on zero-extended width values and truncate the result.
- `SMIN` and `SMAX` compare sign-extended width values; `UMIN` and `UMAX` compare zero-extended ones.

`NormalizeAtomicReturn` shapes the old value for the destination. It zero-extends 1-byte and 2-byte values, sign-extends 4-byte values, and returns 8-byte values unchanged.

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-rules role=rules-interactions -->
## Rules and interactions

`LoadReserved` performs an ordered load. If the load faults, it leaves the reservation untouched, so an older reservation survives.

`StoreConditional` first compares granules. If the reservation is valid and the SC address falls in the same 64-byte line, it clears the reservation, probes the store, and on success stores the value, records a store event, and returns 0. On a miss it clears the reservation and returns 1 without probing.

Design point: a reservation miss is probe-free. An SC that cannot succeed never reports an alignment or page fault, even for a bad address; it simply returns 1. A matching SC clears the reservation before it probes, so a faulting SC also loses the reservation. A reissue after recovery then returns 1 unless software runs a new LR.

`AtomicReadModifyWrite` and `CompareAndSwap` probe the address for read and then for write. Both probes must pass, and the two translated addresses must be equal; otherwise the operation raises `Fault_DataPage`. Only then do they read the old value and write the new one. Both return the raw old value.

`CompareAndSwap` compares the old value with the width-normalized expected value. On a match it stores the desired value. It records an atomic event in both outcomes, with a success flag.

Design point: both probes and the translated-address check happen before the read. No old value is read and no byte is written unless both the read and the write can complete, so a faulting RMW or CAS leaves memory unchanged.

`ExecuteScalarDMACopy64` probes the 64-byte source for read and the 64-byte destination for write, with 1-byte alignment. It snapshots all 64 source bytes, records eight 8-byte load events, writes all 64 bytes, and records eight store events.

Design point: the snapshot happens before the first destination write, so overlapping source and destination ranges behave like `memmove`. A fault in either probe leaves memory unchanged.

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-boundaries role=boundaries -->
## Architectural boundaries

`PTO_RESERVATION_GRANULE_BYTES` is 64. With a valid reservation, SC success depends only on the line; the SC width and exact byte address need not match the LR.

Plain stores in [scalar memory](../agu/memory.md) also clear the reservation when the stored range overlaps its 64-byte granule. `FENCE.D` and `FENCE.I` clear it unconditionally.

`CompareAndSwap` stores the desired operand through `StoreTranslated`, which writes only `size_bytes` bytes. The atomic event records the desired value normalized to the width.

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-example role=example-usage -->
## Non-normative reading example

A program executes `LR.W` at 0x104, then `SC.D` at 0x138.

- `LoadReserved` succeeds and records reservation address 0x104, size 4.
- The reservation granule is 0x100, because 0x104 rounds down to a multiple of 64.
- The SC granule is also 0x100, so the SC matches.
- The reservation is cleared, the 8-byte probe at 0x138 passes, the value is stored, and the SC returns 0.

A second `SC.D` at 0x138 now misses, returns 1, and performs no probe.

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-related role=related-owners-navigation -->
## Related owners

- [AMO dispatch](../dispatch/amo.md) maps AMO forms, widths, and ordering bits to these helpers.
- [Scalar memory](../agu/memory.md) owns probing, raw access, and reservation invalidation by stores.
- [Atomicity](../../../arch/memory-model/atomicity.md) owns memory-event recording.
- [SYS semantics](../sys/semantics.md) owns the fences that clear the reservation.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/amo/semantics.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-AMO-SEMANTICS","surface":"scalar","classification":["model","amo","semantics"],"depends_on":["PTO-SCALAR-MODEL-AGU-ADDRESSING","PTO-ARCH-MEMORY-MODEL-ATOMICITY"]}
// PTO-REQ-SCALAR-AMO-001, PTO-REQ-MEMORY-RC-001: LR/SC, CAS, and atomic
// read-modify-write operations represented as indivisible PTO-RC memory events.

readonly func AtomicAddress(address: Word,
                                            far: boolean) => Word
begin
    return address;
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
```
<!-- GENERATED-ASL-END: unit -->
