<!-- GENERATED FROM: asl/scalar/model/agu/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/scalar/model/agu/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-AGU-ADDRESSING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-purpose role=purpose-scope -->
## Purpose and scope

This unit defines direct scalar load, store, pair, and prefetch helpers. Each helper takes already-resolved register indexes and an offset, forms an address, and performs one memory transaction through the helpers in [scalar memory](memory.md).

The unit contains four kinds of helper:

- `EffectiveAddress`, which picks the accessed address for an update mode.
- `ExecuteScalarLoad` and `ExecuteScalarStore`, which access one element and may write back an updated base.
- `ExecuteScalarLoadPair` and `ExecuteScalarStorePair`, which access two adjacent elements.
- `ScalarPrefetchAddress` and `ScalarPrefetch`, which form a prefetch address without touching memory.

No ASL code calls `EffectiveAddress` or the four load, store, and pair helpers; the `ScalarHandler_*` handler names only label catalog forms. The decoded path in [AGU dispatch](../dispatch/agu.md) repeats the same rules with decoded fields, and it calls `ScalarPrefetch` and `ScalarPrefetchAddress` from this unit.

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-concepts role=concepts-state -->
## Concepts and visible state

An address update mode is one of `AddressUpdate_None`, `AddressUpdate_PreIndex`, or `AddressUpdate_PostIndex`. The updated base is always `base + offset`. Pre-index and no-update accesses use the updated base as the address. Post-index accesses use the original base.

All address arithmetic uses 64-bit `Word` values, so it wraps modulo 2^64.

A load helper normalizes the loaded value to 64 bits. A signed load sign-extends from the access width; an unsigned load zero-extends.

The helpers read GPRs through `ReadGPR` and write them through `WriteGPR`. They touch memory, memory events, the reservation, and `_LastFault`. They do not advance TPC; a fault raised through `SetFault` also records the fault address and trap context and redirects TPC to the trap vector.

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-rules role=rules-interactions -->
## Rules and interactions

`ExecuteScalarLoad` reads the base, performs `LoadSigned` or `LoadUnsigned`, and then checks `_LastFault`. Only when no fault was raised does it write the destination and, for pre-index or post-index, the updated base. The destination is written before the base.

`ExecuteScalarStore` reads the base and the data register, calls `Store`, and writes back the updated base only if `_LastFault` is still `Fault_None`.

Design point: in the single-element helpers, every destination and base write is guarded by `_LastFault == Fault_None`. A faulting access therefore leaves the destination and base GPRs unchanged. Recovery can reissue the complete instruction from its original sources, because no partial base update has been published.

The pair helpers never write back a base. They compute the second address as the first address plus the access size. They then probe the first address and the second address with `ProbeDataAccess`, in that order, before any data moves. The first failing probe raises its fault at its own original address and the helper returns.

Design point: both probes finish before the first load or store. A pair store can therefore not write the first element and then fault on the second. On success, the pair loads both values, records two relaxed load events with the low element first, and writes the low destination before the high destination. A pair store reads both source registers before either store, then stores and records the low element before the high element.

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-boundaries role=boundaries -->
## Architectural boundaries

`ScalarPrefetch` forms `base + offset` and discards it. It performs no translation, no permission check, no memory access, and records no event, so a prefetch cannot raise a data fault. Its `model` argument is not used by the helper. Legality of the encoded `model` value is decided before dispatch, by the catalog constraint on the form.

Alignment, the bounded-memory limit, and the access-ring limit are owned by `ProbeDataAccess` in [scalar memory](memory.md), not by this unit.

The direct helpers take absolute GPR indexes. They do not handle T/U queue selectors, compressed forms, PC-relative bases, or offset scaling; those belong to decoded dispatch.

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-example role=example-usage -->
## Non-normative reading example

Consider `ExecuteScalarLoad` with destination GPR 5, base GPR 6 holding 0x100, offset 8, size 4, unsigned, and mode `AddressUpdate_PostIndex`.

- `EffectiveAddress` returns the original base 0x100, because the mode is post-index.
- `LoadUnsigned` probes 0x100. It is 4-byte aligned, so no alignment fault is raised.
- If the access is permitted, GPR 5 receives the zero-extended 32-bit value, and then GPR 6 receives 0x108.
- If the probe fails, `_LastFault` is set, and neither GPR 5 nor GPR 6 changes.

With `AddressUpdate_PreIndex` the same call would access 0x108 and also write 0x108 to GPR 6.

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-related role=related-owners-navigation -->
## Related owners

- [Scalar memory](memory.md) owns probing, byte access, normalization, and reservation invalidation.
- [AGU dispatch](../dispatch/agu.md) owns decoded address formation, scaling, and queue operands.
- [Fault precision](../../../arch/memory-model/fault-precision.md) owns the precise-fault and restart contract.
- [Memory events](../../../arch/memory-model/memory-events.md) owns the recorded load and store events.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/agu/addressing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-AGU-ADDRESSING","surface":"scalar","classification":["model","agu","addressing"],"depends_on":["PTO-SCALAR-MODEL-AGU-MEMORY"]}
// PTO-REQ-SCALAR-ADDRESS-001, PTO-REQ-MEMORY-COMPLETION-001: scalar addressing,
// pair preflight, and fault-suppressed register writeback.

pure func EffectiveAddress(base: Word, offset: Word, mode: AddressUpdateMode) => Word
begin
    if mode == AddressUpdate_PostIndex then return base;
    else return base + offset;
    end;
end;

func ExecuteScalarLoad(destination: GPRIndex, base_register: GPRIndex,
                       offset: Word, size_bytes: integer {1,2,4,8},
                       signed_load: boolean, mode: AddressUpdateMode)
begin
    let base = ReadGPR(base_register);
    let address = EffectiveAddress(base, offset, mode);
    let value = if signed_load then LoadSigned(address, size_bytes)
                else LoadUnsigned(address, size_bytes);
    if _LastFault == Fault_None then
        WriteGPR(destination, value);
        if mode == AddressUpdate_PreIndex || mode == AddressUpdate_PostIndex then
            WriteGPR(base_register, base + offset);
        end;
    end;
end;

func ExecuteScalarStore(source: GPRIndex, base_register: GPRIndex,
                        offset: Word, size_bytes: integer {1,2,4,8},
                        mode: AddressUpdateMode)
begin
    let base = ReadGPR(base_register);
    let address = EffectiveAddress(base, offset, mode);
    Store(address, size_bytes, ReadGPR(source));
    if _LastFault == Fault_None &&
       (mode == AddressUpdate_PreIndex || mode == AddressUpdate_PostIndex) then
        WriteGPR(base_register, base + offset);
    end;
end;

func ExecuteScalarLoadPair(destination_low: GPRIndex, destination_high: GPRIndex,
                           base_register: GPRIndex, offset: Word,
                           size_bytes: integer {1,2,4,8}, signed_load: boolean)
begin
    let base = ReadGPR(base_register);
    let address = base + offset;
    let second_address = address + NaturalToWord(size_bytes as integer {0..262144});
    let low_probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(low_probe, address) then return; end;
    let high_probe = ProbeDataAccess(
        second_address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(high_probe, second_address) then return; end;
    let low_raw = LoadTranslatedUnsigned(low_probe.translated_address, size_bytes);
    let high_raw = LoadTranslatedUnsigned(high_probe.translated_address, size_bytes);
    let low = NormalizeLoadedValue(low_raw, size_bytes, signed_load);
    let high = NormalizeLoadedValue(high_raw, size_bytes, signed_load);
    RecordLoadEvent(low_probe.translated_address, size_bytes,
        low_raw, MemoryOrder_Relaxed);
    RecordLoadEvent(high_probe.translated_address, size_bytes,
        high_raw, MemoryOrder_Relaxed);
    WriteGPR(destination_low, low);
    WriteGPR(destination_high, high);
end;

func ExecuteScalarStorePair(source_low: GPRIndex, source_high: GPRIndex,
                            base_register: GPRIndex, offset: Word,
                            size_bytes: integer {1,2,4,8})
begin
    let base = ReadGPR(base_register);
    let address = base + offset;
    let second_address = address + NaturalToWord(size_bytes as integer {0..262144});
    let low_probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(low_probe, address) then return; end;
    let high_probe = ProbeDataAccess(
        second_address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(high_probe, second_address) then return; end;
    let low = ReadGPR(source_low);
    let high = ReadGPR(source_high);
    StoreTranslated(address, low_probe.translated_address, size_bytes, low);
    RecordStoreEvent(low_probe.translated_address, size_bytes, low,
        MemoryOrder_Relaxed);
    StoreTranslated(second_address, high_probe.translated_address,
        size_bytes, high);
    RecordStoreEvent(high_probe.translated_address, size_bytes, high,
        MemoryOrder_Relaxed);
end;

pure func ScalarPrefetchAddress(base: Word, offset: Word) => Word
begin
    return base + offset;
end;

func ScalarPrefetch(base: Word, offset: Word, size_bytes: integer {1,2,4,8},
                    model: bits(5))
begin
    // Decode admits only the assigned L1/L2/L3 model values before sources are
    // read. Address formation is explicit, but no translation, permission
    // check, event, or memory effect is architecturally observed.
    - = ScalarPrefetchAddress(base, offset);
end;
```
<!-- GENERATED-ASL-END: unit -->
