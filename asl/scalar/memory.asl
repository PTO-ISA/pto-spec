// PTO-REQ-MEMORY-001: little-endian scalar memory helpers and visible faults.

readonly func RangesOverlap(left_address: Word, left_size: integer,
                            right_address: Word, right_size: integer) => boolean
begin
    let left_start = UInt(left_address);
    let right_start = UInt(right_address);
    return left_start < right_start + right_size &&
           right_start < left_start + left_size;
end;

func ApplyMemoryOrderBefore(order: MemoryOrder)
begin
    if order == MemoryOrder_Release || order == MemoryOrder_AcquireRelease then
        _MemoryReleaseEpoch = _MemoryReleaseEpoch + 1;
    end;
end;

func ApplyMemoryOrderAfter(order: MemoryOrder)
begin
    if order == MemoryOrder_Acquire || order == MemoryOrder_AcquireRelease then
        _MemoryAcquireEpoch = _MemoryAcquireEpoch + 1;
    end;
end;

func LoadUnsigned(address: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    if UInt(address) MOD size_bytes != 0 then
        SetFault(Fault_DataAlignment, address);
        return Zeros{PTO_XLEN};
    end;
    if UInt(address) + size_bytes > PTO_MODEL_MEMORY_BYTES then
        SetFault(Fault_DataPage, address);
        return Zeros{PTO_XLEN};
    end;
    var result: Word = Zeros{PTO_XLEN};
    for byte_index = 0 to size_bytes - 1 do
        let byte_address = address +
            NaturalToWord(byte_index as integer {0..262144});
        result[(byte_index * 8) +: 8] = ReadMemoryByte(byte_address);
    end;
    return result;
end;

func LoadSigned(address: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    let value = LoadUnsigned(address, size_bytes);
    case size_bytes of
        when 1 => return SignExtend{PTO_XLEN}(value[7:0]);
        when 2 => return SignExtend{PTO_XLEN}(value[15:0]);
        when 4 => return SignExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

func Store(address: Word, size_bytes: integer {1,2,4,8}, value: Word)
begin
    if UInt(address) MOD size_bytes != 0 then
        SetFault(Fault_DataAlignment, address);
        return;
    end;
    if UInt(address) + size_bytes > PTO_MODEL_MEMORY_BYTES then
        SetFault(Fault_DataPage, address);
        return;
    end;
    for byte_index = 0 to size_bytes - 1 do
        let byte_address = address +
            NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(byte_address, value[(byte_index * 8) +: 8]);
    end;
    if _ReservationValid &&
       RangesOverlap(address, size_bytes, _ReservationAddress, _ReservationSize) then
        _ReservationValid = FALSE;
    end;
end;
