<!-- GENERATED FROM: asl/scalar/model/agu/memory.asl -->
# Memory

**Normative ASL source:** `asl/scalar/model/agu/memory.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-AGU-MEMORY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-agu-memory-purpose role=purpose-scope -->
## Purpose and scope

This unit is the byte-level memory layer used by scalar loads, stores, and atomics, and also by some Tile and Block memory helpers. It decides whether an access may happen, turns bytes into little-endian values, and invalidates the load-reserved reservation when a store overlaps it.

It defines four main groups of helpers, plus `RangesOverlap` and `ReservationGranuleAddress` for the reservation check:

- Probing: `TranslateDataAddress`, `DataAccessPermitted`, `ProbeDataAccess`, and `RaiseDataAccessFault`.
- Raw byte access: `LoadTranslatedUnsigned`, `StoreTranslated`, and the 64-byte and bounded variants.
- Value normalization: `NormalizeLoadedValue` and `NormalizeMemoryAccessValue`.
- Complete accesses: `LoadWithOrder`, `LoadUnsigned`, `LoadSigned`, `StoreWithOrder`, and `Store`.

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-concepts role=concepts-state -->
## Concepts and visible state

A probe is the check that runs before any byte moves. `ProbeDataAccess` returns a `DataAccessProbe` with a fault code and a translated address.

Translation is the identity in this model: `TranslateDataAddress` returns its input.

Values are little-endian. Byte `i` of a value lives at the translated address plus `i`.

The reservation is the state left by a load-reserved instruction: `_ReservationValid`, `_ReservationAddress`, and `_ReservationSize`. Its granule is the aligned block of `PTO_RESERVATION_GRANULE_BYTES` (64) bytes that contains the reserved address.

A memory event is a record of a completed access for the memory-ordering model. Loads and stores record events only after their bytes move.

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-rules role=rules-interactions -->
## Rules and interactions

`ProbeDataAccess` checks in a fixed order:

1. Alignment. If the address is not a multiple of `alignment_bytes`, the result is `Fault_DataAlignment`.
2. Translation, which cannot fail here.
3. Permission. `DataAccessPermitted` rejects an access whose end passes `PTO_MODEL_MEMORY_BYTES`. When the current access ring is 2 or higher, it also rejects an access that ends past byte 3072. Either rejection is `Fault_DataPage`.

Design point: alignment is checked first, so a misaligned access reports `Fault_DataAlignment` even if it would also fail permission. Permission and bounds share one visible cause, `Fault_DataPage`.

`RaiseDataAccessFault` calls `SetFault` with the original address that the caller passes, not the translated one, and returns TRUE for a failed probe.

`LoadWithOrder` probes with alignment equal to the access size, returns zero if the probe faults, and otherwise reads the bytes and records one load event. `StoreWithOrder` probes, returns on a fault, and otherwise writes the bytes and records one store event. `LoadSigned` sign-extends the result of `LoadUnsigned`.

Design point: every complete access probes before it reads or writes, and records its event only after the bytes move. A faulting access therefore changes no memory and records no event. This matches the precise-fault contract owned by fault precision.

Every store helper in this unit clears `_ReservationValid` when its original-address range overlaps the reservation granule. A plain store to the reserved 64-byte line therefore breaks the reservation.

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-boundaries role=boundaries -->
## Architectural boundaries

`PTO_MODEL_MEMORY_BYTES` is a model configuration value (4096 by default, 256 through 65536 allowed). The comment in `ProbeDataAccess` states that the active profile owns the physical address limit, and that a hosted profile may authorize addresses outside the reference array.

The 3072-byte limit for access rings 2 through 15 is a PTO v0 rule stated in `DataAccessPermitted`.

The raw byte helpers such as `StoreTranslated` do not probe. Their callers must probe first. For example, the pair and atomic helpers probe every address and then call the raw helpers.

This unit does not decide ordering semantics. It passes a `MemoryOrder` to `RecordLoadEvent` and `RecordStoreEvent`, which belong to the atomicity and memory-event owners.

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-example role=example-usage -->
## Non-normative reading example

Assume the default 4096-byte memory.

| Access | Ring | Probe result |
| --- | --- | --- |
| 4 bytes at 0xFFE | 0 | `Fault_DataAlignment`, since 0xFFE is not a multiple of 4 |
| 4 bytes at 0xFFC | 0 | permitted, since the access ends at 4096 |
| 4 bytes at 0xFFC | 2 | `Fault_DataPage`, since 4096 is past 3072 |
| 1 byte at 0x1000 | 0 | `Fault_DataPage`, since the access ends at 4097 |

For a successful 2-byte `LoadSigned` of bytes 0x34 then 0x92, the raw value is 0x9234 and the result is 0xFFFFFFFFFFFF9234.

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-related role=related-owners-navigation -->
## Related owners

- [Scalar addressing](addressing.md) builds loads, stores, and pairs on these helpers.
- [AMO semantics](../amo/semantics.md) uses probing, raw access, and the reservation.
- [Address space](../../../arch/memory-model/address-space.md) owns `ReadMemoryByte` and `WriteMemoryByte`.
- [Atomicity](../../../arch/memory-model/atomicity.md) owns `RecordLoadEvent` and `RecordStoreEvent`.
- [Fault precision](../../../arch/memory-model/fault-precision.md) owns `SetFault`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/agu/memory.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-AGU-MEMORY","surface":"scalar","classification":["model","agu","memory"],"depends_on":["PTO-SCALAR-MODEL-BRU-SEMANTICS","PTO-ARCH-MEMORY-MODEL-ORDERING"]}
// PTO-REQ-MEMORY-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-RC-001: profile-backed, little-endian memory with precise
// instruction-wide completion and PTO-RC event extraction.

pure func RangesOverlap(left_address: Word, left_size: integer,
                        right_address: Word, right_size: integer) => boolean
begin
    let left_start = UInt(left_address);
    let right_start = UInt(right_address);
    return left_start < right_start + right_size &&
           right_start < left_start + left_size;
end;

readonly func ReservationGranuleAddress() => Word
begin
    return _ReservationAddress - NaturalToWord(
        (UInt(_ReservationAddress) MOD PTO_RESERVATION_GRANULE_BYTES) as
            integer {0..262144});
end;

readonly func TranslateDataAddress(address: Word,
                                                  size_bytes: integer {1..262144},
                                                  write: boolean) => Word
begin
    return address;
end;

readonly func DataAccessPermitted(address: Word,
                                                 size_bytes: integer {1..262144},
                                                 write: boolean) => boolean
begin
    let end_address = UInt(address) + size_bytes;
    if end_address > PTO_MODEL_MEMORY_BYTES then
        return FALSE;
    end;
    // PTO v0 assigns ACR0 and ACR1 full bounded-memory access. ACR2 through
    // ACR15 use the bounded 3072-byte application region.
    if CurrentACR() >= 2 then return end_address <= 3072;
    else return TRUE;
    end;
end;

func ProbeDataAccess(address: Word,
                     size_bytes: integer {1..262144},
                     alignment_bytes: integer {1,2,4,8},
                     write: boolean) => DataAccessProbe
begin
    if UInt(address) MOD alignment_bytes != 0 then
        return DataAccessProbe {
            fault = Fault_DataAlignment,
            translated_address = address
        };
    end;
    let translated_address = TranslateDataAddress(address, size_bytes, write);
    // The active profile owns the physical address-space limit.  The
    // reference profile still applies PTO_MODEL_MEMORY_BYTES in its
    // DataAccessPermitted implementation, while a hosted profile may
    // authorize addresses outside the reference array.
    if !DataAccessPermitted(translated_address, size_bytes, write) then
        return DataAccessProbe {
            fault = Fault_DataPage,
            translated_address = translated_address
        };
    end;
    return DataAccessProbe {
        fault = Fault_None,
        translated_address = translated_address
    };
end;

func RaiseDataAccessFault(probe: DataAccessProbe, address: Word) => boolean
begin
    if probe.fault == Fault_None then return FALSE; end;
    SetFault(probe.fault, address);
    return TRUE;
end;

readonly func LoadTranslatedUnsigned(translated_address: Word,
                                     size_bytes: integer {1,2,4,8}) => Word
begin
    var result: Word = Zeros{PTO_XLEN};
    for byte_index = 0 to size_bytes - 1 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        result[(byte_index * 8) +: 8] = ReadMemoryByte(byte_address);
    end;
    return result;
end;

readonly func LoadTranslatedBytes64(translated_address: Word) => array [[64]] of Byte
begin
    var result: array [[64]] of Byte;
    for byte_index = 0 to 63 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        result[[byte_index]] = ReadMemoryByte(byte_address);
    end;
    return result;
end;

pure func Bytes64ChunkValue(value: array [[64]] of Byte,
                            chunk: integer {0..7}) => Word
begin
    var result: Word = Zeros{PTO_XLEN};
    for byte_index = 0 to 7 do
        let snapshot_index = (chunk * 8 + byte_index) as integer {0..63};
        result[(byte_index * 8) +: 8] = value[[snapshot_index]];
    end;
    return result;
end;

readonly func LoadTranslatedBytesBounded(translated_address: Word,
                                         byte_count: integer {0..63})
                                         => array [[64]] of Byte
begin
    var result: array [[64]] of Byte;
    for byte_index = 0 to 63 do
        if byte_index < byte_count then
            let byte_address = translated_address +
                NaturalToWord(byte_index as integer {0..262144});
            result[[byte_index]] = ReadMemoryByte(byte_address);
        else
            result[[byte_index]] = Zeros{8};
        end;
    end;
    return result;
end;

pure func NormalizeLoadedValue(value: Word,
                               size_bytes: integer {1,2,4,8},
                               signed_load: boolean) => Word
begin
    if !signed_load then return value; end;
    case size_bytes of
        when 1 => return SignExtend{PTO_XLEN}(value[7:0]);
        when 2 => return SignExtend{PTO_XLEN}(value[15:0]);
        when 4 => return SignExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

pure func NormalizeMemoryAccessValue(value: Word,
                                     size_bytes: integer {1,2,4,8}) => Word
begin
    case size_bytes of
        when 1 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 2 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 4 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

func StoreTranslatedBytes64(original_address: Word, translated_address: Word,
                            value: array [[64]] of Byte)
begin
    for byte_index = 0 to 63 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(byte_address, value[[byte_index]]);
    end;
    if _ReservationValid &&
       RangesOverlap(original_address, 64,
                     ReservationGranuleAddress(),
                     PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func StoreTranslatedBytesBounded(original_address: Word,
                                 translated_address: Word,
                                 byte_count: integer {0..63},
                                 value: array [[64]] of Byte)
begin
    for byte_index = 0 to 63 do
        if byte_index < byte_count then
            let byte_address = translated_address +
                NaturalToWord(byte_index as integer {0..262144});
            WriteMemoryByte(byte_address, value[[byte_index]]);
        end;
    end;
    if _ReservationValid &&
       RangesOverlap(original_address, byte_count,
                     ReservationGranuleAddress(),
                     PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func StoreTranslatedFillModelBounded(
    original_address: Word,
    translated_address: Word,
    byte_count: integer {1..262144},
    value: Byte)
begin
    for byte_index = 0 to byte_count - 1
        looplimit 262144 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(byte_address, value);
    end;
    if _ReservationValid &&
       RangesOverlap(original_address, byte_count,
                     ReservationGranuleAddress(),
                     PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func StoreTranslated(original_address: Word, translated_address: Word,
                     size_bytes: integer {1,2,4,8}, value: Word)
begin
    for byte_index = 0 to size_bytes - 1 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(byte_address, value[(byte_index * 8) +: 8]);
    end;
    if _ReservationValid &&
       RangesOverlap(original_address, size_bytes,
                     ReservationGranuleAddress(),
                     PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func LoadWithOrder(address: Word, size_bytes: integer {1,2,4,8},
                   order: MemoryOrder) => Word
begin
    let probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(probe, address) then return Zeros{PTO_XLEN}; end;
    let value = LoadTranslatedUnsigned(probe.translated_address, size_bytes);
    RecordLoadEvent(probe.translated_address, size_bytes, value, order);
    return value;
end;

func LoadUnsigned(address: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    return LoadWithOrder(address, size_bytes, MemoryOrder_Relaxed);
end;

func LoadSigned(address: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    let value = LoadUnsigned(address, size_bytes);
    return NormalizeLoadedValue(value, size_bytes, TRUE);
end;

func StoreWithOrder(address: Word, size_bytes: integer {1,2,4,8}, value: Word,
                    order: MemoryOrder)
begin
    let probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(probe, address) then return; end;
    StoreTranslated(address, probe.translated_address, size_bytes, value);
    RecordStoreEvent(probe.translated_address, size_bytes, value, order);
end;

func Store(address: Word, size_bytes: integer {1,2,4,8}, value: Word)
begin
    StoreWithOrder(address, size_bytes, value, MemoryOrder_Relaxed);
end;
```
<!-- GENERATED-ASL-END: unit -->
