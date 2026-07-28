// PTO-REQ-SCALAR-SSR-001, PTO-REQ-PROFILE-001: canonical 24-bit
// system-register addressing with explicit Access Control Ring checks.

readonly impdef func SystemRegisterAccessPermitted(
    address: SystemRegisterAddress, write: boolean,
    ring: AccessControlRing) => boolean
begin
    // The active profile permits base registers at every ring and keeps
    // context-family registers root-ring-only.
    return UInt(address[11:0]) < 0x0f00 || ring == 0;
end;

pure func IsBaseSystemRegisterAddress(address: SystemRegisterAddress) => boolean
begin
    return address == Zeros{24} + 0x0000 ||
           address == Zeros{24} + 0x0001 ||
           address == Zeros{24} + 0x0010 ||
           address == Zeros{24} + 0x0020 ||
           address == Zeros{24} + 0x0021 ||
           address == Zeros{24} + 0x0022 ||
           address == Zeros{24} + 0x0023 ||
           address == Zeros{24} + 0x0024 ||
           address == Zeros{24} + 0x0025 ||
           address == Zeros{24} + 0x0026 ||
           address == Zeros{24} + 0x0027 ||
           address == Zeros{24} + 0x0050 ||
           address == Zeros{24} + 0x0051 ||
           address == Zeros{24} + 0x0c00;
end;

pure func BaseSystemRegisterOfAddress(address: SystemRegisterAddress) => SystemRegister
begin
    case UInt(address) of
        when 0x0000 => return SystemRegister_THREAD_PTR;
        when 0x0001 => return SystemRegister_GLOBAL_PTR;
        when 0x0010 => return SystemRegister_TIME;
        when 0x0020 => return SystemRegister_CORE_STATE;
        when 0x0021 => return SystemRegister_CORE_ID;
        when 0x0022 => return SystemRegister_VENDOR;
        when 0x0023 => return SystemRegister_VERSION;
        when 0x0024 => return SystemRegister_CORE_FEATURE;
        when 0x0025 => return SystemRegister_CORE_FEATURE_ENABLE;
        when 0x0026 => return SystemRegister_THREAD_ID;
        when 0x0027 => return SystemRegister_TILE_CAPACITY;
        when 0x0050 => return SystemRegister_BLOCKNUM;
        when 0x0051 => return SystemRegister_BLOCKID;
        when 0x0c00 => return SystemRegister_CYCLE;
        otherwise => unreachable;
    end;
end;

pure func SystemRegisterFileIndexOf(address: SystemRegisterAddress)
        => SystemRegisterFileIndex
begin
    assert address[23:16] == Zeros{8};
    return UInt(address[15:0]) as SystemRegisterFileIndex;
end;

func ReadSystemRegisterAddress(address: SystemRegisterAddress) => Word
begin
    if !SystemRegisterAccessPermitted(address, FALSE, CurrentACR()) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return Zeros{PTO_XLEN};
    end;
    let access = SystemRegisterAccessOf(address);
    if access == SystemRegisterAccess_Unknown ||
       access == SystemRegisterAccess_WriteOnly then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return Zeros{PTO_XLEN};
    end;
    if IsBaseSystemRegisterAddress(address) then
        return ReadSystemRegister(BaseSystemRegisterOfAddress(address));
    end;

    let low_index = UInt(address[11:0]);
    let ring = UInt(address[15:12]) as AccessControlRing;
    if low_index == 0x0f02 then return PackTrapStatus(ring); end;
    if low_index == 0x0f03 then return _ACRTrapArgument0[[ring]]; end;
    if low_index == 0x0f20 then return ReadMonotonicTime(); end;
    return _ExtendedSystemRegisters[[SystemRegisterFileIndexOf(address)]];
end;

func WriteSystemRegisterAddress(address: SystemRegisterAddress, value: Word)
begin
    if !SystemRegisterAccessPermitted(address, TRUE, CurrentACR()) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let access = SystemRegisterAccessOf(address);
    if access == SystemRegisterAccess_Unknown ||
       access == SystemRegisterAccess_ReadOnly then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    if IsBaseSystemRegisterAddress(address) then
        WriteSystemRegister(BaseSystemRegisterOfAddress(address), value);
        return;
    end;

    let low_index = UInt(address[11:0]);
    let ring = UInt(address[15:12]) as AccessControlRing;
    if low_index == 0x0f02 then
        UnpackTrapStatus(ring, value);
    elsif low_index == 0x0f03 then
        _ACRTrapArgument0[[ring]] = value;
    else
        _ExtendedSystemRegisters[[SystemRegisterFileIndexOf(address)]] = value;
        if low_index == 0x0f0a then
            _ACRTrapAsynchronous[[ring]] = FALSE;
            _ACRTrapArgumentValid[[ring]] = FALSE;
        end;
    end;
end;

func SwapSystemRegisterAddress(address: SystemRegisterAddress, value: Word) => Word
begin
    let old_value = ReadSystemRegisterAddress(address);
    if _LastFault == Fault_None then WriteSystemRegisterAddress(address, value); end;
    return old_value;
end;

func ExecuteSystemRegisterGet(destination: Reg5Selector,
                              address: SystemRegisterAddress)
begin
    let value = ReadSystemRegisterAddress(address);
    if _LastFault == Fault_None then WriteScalarDestination(destination, value); end;
end;

func ExecuteCompressedSystemRegisterGet(address: SystemRegisterAddress)
begin
    let value = ReadSystemRegisterAddress(address);
    if _LastFault == Fault_None then WriteCompressedTResult(value); end;
end;

func ExecuteSystemRegisterSet(source: Reg5Selector,
                              address: SystemRegisterAddress)
begin
    WriteSystemRegisterAddress(address, ReadScalarRegisterOperand(source));
end;

func ExecuteSystemRegisterSwap(destination: Reg5Selector, source: Reg5Selector,
                               address: SystemRegisterAddress)
begin
    let old_value = SwapSystemRegisterAddress(address, ReadScalarRegisterOperand(source));
    if _LastFault == Fault_None then WriteScalarDestination(destination, old_value); end;
end;
