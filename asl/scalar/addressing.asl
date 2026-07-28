// PTO-REQ-SCALAR-ADDRESS-001: scalar addressing and register writeback.

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
                           size_bytes: integer {1,2,4,8}, signed_load: boolean,
                           mode: AddressUpdateMode)
begin
    let base = ReadGPR(base_register);
    let address = EffectiveAddress(base, offset, mode);
    let second_address = address + NaturalToWord(size_bytes as integer {0..262144});
    let low = if signed_load then LoadSigned(address, size_bytes)
              else LoadUnsigned(address, size_bytes);
    let high = if signed_load then LoadSigned(second_address, size_bytes)
               else LoadUnsigned(second_address, size_bytes);
    if _LastFault == Fault_None then
        WriteGPR(destination_low, low);
        WriteGPR(destination_high, high);
        if mode == AddressUpdate_PreIndex || mode == AddressUpdate_PostIndex then
            WriteGPR(base_register, base + offset);
        end;
    end;
end;

func ExecuteScalarStorePair(source_low: GPRIndex, source_high: GPRIndex,
                            base_register: GPRIndex, offset: Word,
                            size_bytes: integer {1,2,4,8}, mode: AddressUpdateMode)
begin
    let base = ReadGPR(base_register);
    let address = EffectiveAddress(base, offset, mode);
    let second_address = address + NaturalToWord(size_bytes as integer {0..262144});
    Store(address, size_bytes, ReadGPR(source_low));
    if _LastFault == Fault_None then Store(second_address, size_bytes, ReadGPR(source_high)); end;
    if _LastFault == Fault_None &&
       (mode == AddressUpdate_PreIndex || mode == AddressUpdate_PostIndex) then
        WriteGPR(base_register, base + offset);
    end;
end;

func ScalarPrefetch(base: Word, offset: Word, size_bytes: integer {1,2,4,8})
begin
    // Scalar prefetch is a non-faulting hint. Address formation is retained so
    // the operand contract is explicit, but no translation or memory access is
    // architecturally observed.
    let address = base + offset;
    assert UInt(address) >= 0;
    assert size_bytes >= 1;
end;
