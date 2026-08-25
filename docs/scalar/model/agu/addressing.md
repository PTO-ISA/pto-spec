<!-- GENERATED FROM: asl/scalar/model/agu/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/scalar/model/agu/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-AGU-ADDRESSING}

<!-- SUPPLEMENTARY-BEGIN -->

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
