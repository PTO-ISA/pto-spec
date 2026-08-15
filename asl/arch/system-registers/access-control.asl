// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL","surface":"arch","classification":["system-registers","access-control"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
readonly func CurrentACR() => AccessControlRing
begin
    return _CurrentACR;
end;

pure func AccessControlRingBits(ring: AccessControlRing) => bits(4)
begin
    case ring of
        when 0 => return '0000';
        when 1 => return '0001';
        when 2 => return '0010';
        when 3 => return '0011';
        when 4 => return '0100';
        when 5 => return '0101';
        when 6 => return '0110';
        when 7 => return '0111';
        when 8 => return '1000';
        when 9 => return '1001';
        when 10 => return '1010';
        when 11 => return '1011';
        when 12 => return '1100';
        when 13 => return '1101';
        when 14 => return '1110';
        when 15 => return '1111';
    end;
end;

func SetCurrentACR(ring: AccessControlRing)
begin
    _CurrentACR = ring;
    _SystemRegisters.core_state[3:0] = AccessControlRingBits(ring);
end;

pure func TrapTargetForFault(source: AccessControlRing) => AccessControlRing
begin
    if source == 0 then return 0; else return 1; end;
end;

pure func TrapTargetForInterrupt(source: AccessControlRing) => AccessControlRing
begin
    return TrapTargetForFault(source);
end;

pure func ServiceRequestPermitted(source: AccessControlRing,
                                  request_type: bits(4)) => boolean
begin
    if source == 1 then
        return request_type == '0000' || request_type == '0010';
    elsif source >= 2 then
        return UInt(request_type) <= 2;
    else
        return FALSE;
    end;
end;

pure func ServiceRequestTarget(source: AccessControlRing,
                               request_type: bits(4)) => AccessControlRing
begin
    assert ServiceRequestPermitted(source, request_type);
    if request_type == '0001' then return 1; else return 0; end;
end;

readonly func TrapVectorEntry(target: AccessControlRing,
                              fault_address: Word) => Word
begin
    let index = ((target * 4096) + 0x0f01) as SystemRegisterFileIndex;
    let vector_base = _ExtendedSystemRegisters[[index]];
    if vector_base == Zeros{PTO_XLEN} then return fault_address;
    else return vector_base;
    end;
end;
