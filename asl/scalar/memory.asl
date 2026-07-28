// PTO-REQ-MEMORY-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-TSO-001: profile-backed, little-endian memory with precise
// instruction-wide completion and PTO-TSO event extraction.

readonly func RangesOverlap(left_address: Word, left_size: integer,
                            right_address: Word, right_size: integer) => boolean
begin
    let left_start = UInt(left_address);
    let right_start = UInt(right_address);
    return left_start < right_start + right_size &&
           right_start < left_start + left_size;
end;

impdef func TranslateDataAddress(address: Word,
                                 size_bytes: integer {1..262144},
                                 write: boolean) => Word
begin
    // The portable model uses identity translation.
    return address;
end;

impdef func DataAccessPermitted(address: Word,
                                size_bytes: integer {1..262144},
                                write: boolean) => boolean
begin
    // The portable model exposes one bounded, readable, writable address space.
    return UInt(address) + size_bytes <= PTO_MODEL_MEMORY_BYTES;
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
    if !DataAccessPermitted(translated_address, size_bytes, write) ||
       UInt(translated_address) + size_bytes > PTO_MODEL_MEMORY_BYTES then
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
                     _ReservationAddress, PTO_RESERVATION_GRANULE_BYTES) then
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
                     _ReservationAddress, PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func StoreTranslatedFillBounded(original_address: Word,
                                translated_address: Word,
                                byte_count: integer {0..63},
                                value: Byte)
begin
    for byte_index = 0 to 63 do
        if byte_index < byte_count then
            let byte_address = translated_address +
                NaturalToWord(byte_index as integer {0..262144});
            WriteMemoryByte(byte_address, value);
        end;
    end;
    if _ReservationValid &&
       RangesOverlap(original_address, byte_count,
                     _ReservationAddress, PTO_RESERVATION_GRANULE_BYTES) then
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
                     _ReservationAddress, PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func LoadUnsigned(address: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    let probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(probe, address) then return Zeros{PTO_XLEN}; end;
    return LoadTranslatedUnsigned(probe.translated_address, size_bytes);
end;

func LoadSigned(address: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    let value = LoadUnsigned(address, size_bytes);
    return NormalizeLoadedValue(value, size_bytes, TRUE);
end;

func Store(address: Word, size_bytes: integer {1,2,4,8}, value: Word)
begin
    let probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(probe, address) then return; end;
    StoreTranslated(address, probe.translated_address, size_bytes, value);
end;
