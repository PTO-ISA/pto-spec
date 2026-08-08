// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-TIMER","surface":"arch","classification":["system-registers","timer"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-CONTEXT"]}
pure func TimerInterruptId(ring: AccessControlRing) => InterruptID
begin
    return if ring == 0 then 1 else 3;
end;

func RefreshTimerPending(ring: AccessControlRing)
begin
    let comparison = _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, 0x0f21)]];
    let interrupt_id = TimerInterruptId(ring);
    if comparison != Zeros{PTO_XLEN} &&
       UInt(_SystemRegisters.cycle) >= UInt(comparison) then
        SetInterruptPending(ring, interrupt_id);
    else
        ClearInterruptPending(ring, interrupt_id);
    end;
end;

