// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-CONTEXT","surface":"arch","classification":["system-registers","context"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL"]}
pure func ContextRegisterIndex(ring: AccessControlRing,
                               low_index: integer {0..4095})
    => SystemRegisterFileIndex
begin
    return ((ring * 4096) + low_index) as SystemRegisterFileIndex;
end;


readonly func ReadContextRegister(ring: AccessControlRing,
                                       low_index: integer {0..4095}) => Word
begin
    return _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, low_index)]];
end;

func WriteContextRegister(ring: AccessControlRing,
                               low_index: integer {0..4095}, value: Word)
begin
    _ExtendedSystemRegisters[[ContextRegisterIndex(ring, low_index)]] =
        value;
end;
