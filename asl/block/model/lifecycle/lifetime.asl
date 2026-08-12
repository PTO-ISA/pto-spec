// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME","surface":"block","classification":["model","lifecycle","lifetime"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP"]}
func SaveExecutionContextState(base_address: Word, length_bytes: Word,
                               kind: Word)
begin
    let ring = CurrentACR();
    SaveTrapContext(ring, ring);
    _LastMemoryCommandAddress = base_address;
    _LastMemoryCommandSize = length_bytes;
    _ControlRequestOperand = kind;
end;

func RecoverExecutionContextState(base_address: Word, length_bytes: Word,
                                  kind: Word)
begin
    let ring = CurrentACR();
    if !RecoverTrapContext(ring) then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _LastMemoryCommandAddress = base_address;
        _LastMemoryCommandSize = length_bytes;
        _ControlRequestOperand = kind;
    end;
end;

// Frame templates are instruction-atomic: all legality and data-access
// checks happen before any SP, GPR, memory, bookkeeping, or TPC effect.
pure func FrameEndpointLegal(begin_reg: Reg5Selector,
                             end_reg: Reg5Selector) => boolean
begin
    return begin_reg >= 2 && begin_reg <= 23 &&
           end_reg >= 2 && end_reg <= 23;
end;

pure func FrameRegisterAt(begin_reg: Reg5Selector,
                          offset: integer {0..21}) => Reg5Selector
begin
    let candidate = begin_reg + offset;
    if candidate > 23 then return (candidate - 22) as Reg5Selector;
    else return candidate as Reg5Selector;
    end;
end;

pure func FrameRangeLength(begin_reg: Reg5Selector,
                           end_reg: Reg5Selector) => integer {1..22}
begin
    var result: integer {1..22} = 22;
    for offset = 0 to 21 do
        if FrameRegisterAt(begin_reg, offset as integer {0..21}) == end_reg then
            result = (offset + 1) as integer {1..22};
        end;
    end;
    return result;
end;

pure func FrameFormLegal(begin_reg: Reg5Selector,
                         end_reg: Reg5Selector, size: Word,
                         stack_return: boolean) => boolean
begin
    if !FrameEndpointLegal(begin_reg, end_reg) then return FALSE; end;
    let count = FrameRangeLength(begin_reg, end_reg);
    return UInt(size) MOD 8 == 0 && UInt(size) >= count * 8 &&
           (!stack_return || begin_reg == 10);
end;

func FrameSetBookkeeping(begin_reg: Reg5Selector, end_reg: Reg5Selector,
                         size: Word, entering: boolean)
begin
    _LastFrameBegin = begin_reg;
    _LastFrameEnd = end_reg;
    _LastFrameSize = size;
    if entering then
        if _FrameDepth != PTO_MODEL_MEMORY_EVENTS then
            _FrameDepth = (_FrameDepth + 1) as integer {0..PTO_MODEL_MEMORY_EVENTS};
        end;
    elsif _FrameDepth != 0 then
        _FrameDepth = (_FrameDepth - 1) as integer {0..PTO_MODEL_MEMORY_EVENTS};
    end;
end;

func ExecuteFrameEntry(begin_reg: Reg5Selector, end_reg: Reg5Selector,
                       size: Word)
begin
    if !FrameFormLegal(begin_reg, end_reg, size, FALSE) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let count = FrameRangeLength(begin_reg, end_reg);
    let caller_sp = ReadGPR(1);
    let new_sp = caller_sp - size;
    var slots: array [[22]] of Word;
    var probes: array [[22]] of DataAccessProbe;
    for index = 0 to 21 do
        if index < count then
            let slot = caller_sp - NaturalToWord(
                ((index + 1) * 8) as integer {0..262144});
            slots[[index]] = ReadGPR(FrameRegisterAt(begin_reg,
                index as integer {0..21}) as GPRIndex);
            probes[[index]] = ProbeDataAccess(slot, 8, 8, TRUE);
            if RaiseDataAccessFault(probes[[index]], slot) then return; end;
        end;
    end;
    WriteGPR(1, new_sp);
    for index = 0 to 21 do
        if index < count then
            let slot = caller_sp - NaturalToWord(
                ((index + 1) * 8) as integer {0..262144});
            StoreTranslated(slot, probes[[index]].translated_address, 8,
                            slots[[index]]);
            RecordStoreEvent(probes[[index]].translated_address, 8,
                             slots[[index]], MemoryOrder_Relaxed);
        end;
    end;
    FrameSetBookkeeping(begin_reg, end_reg, size, TRUE);
end;

func ExecuteFrameRestore(begin_reg: Reg5Selector, end_reg: Reg5Selector,
                         size: Word, return_kind: integer {0..2})
begin
    let stack_return = return_kind == 2;
    if !FrameFormLegal(begin_reg, end_reg, size, stack_return) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let count = FrameRangeLength(begin_reg, end_reg);
    let frame_sp = ReadGPR(1);
    let caller_sp = frame_sp + size;
    var slots: array [[22]] of Word;
    var probes: array [[22]] of DataAccessProbe;
    var target: Word = Zeros{PTO_XLEN};

    // FRET.STK uses slot zero as its return source. Probe/read it once before
    // target validation; later slots are probed only after target validation.
    if stack_return then
        let slot0 = caller_sp - NaturalToWord(8);
        probes[[0]] = ProbeDataAccess(slot0, 8, 8, FALSE);
        if RaiseDataAccessFault(probes[[0]], slot0) then return; end;
        slots[[0]] = LoadTranslatedUnsigned(probes[[0]].translated_address, 8);
        target = slots[[0]];
        if target[0] == '1' then
            SetFault(Fault_InstructionPC, target);
            return;
        end;
    elsif return_kind == 1 then
        target = _ReturnAddress;
        if target[0] == '1' then
            SetFault(Fault_InstructionPC, target);
            return;
        end;
    end;

    for index = 0 to 21 do
        if index < count && (!stack_return || index != 0) then
            let slot = caller_sp - NaturalToWord(
                ((index + 1) * 8) as integer {0..262144});
            probes[[index]] = ProbeDataAccess(slot, 8, 8, FALSE);
            if RaiseDataAccessFault(probes[[index]], slot) then return; end;
            slots[[index]] = LoadTranslatedUnsigned(
                probes[[index]].translated_address, 8);
        end;
    end;

    WriteGPR(1, caller_sp);
    for index = 0 to 21 do
        if index < count then
            if stack_return && index == 0 then
                RecordLoadEvent(probes[[0]].translated_address, 8,
                                slots[[0]], MemoryOrder_Relaxed);
            else
                RecordLoadEvent(probes[[index]].translated_address, 8,
                                slots[[index]], MemoryOrder_Relaxed);
            end;
            let reg = FrameRegisterAt(begin_reg, index as integer {0..21});
            WriteGPR(reg as GPRIndex, slots[[index]]);
            if reg == 10 then _ReturnAddress = slots[[index]]; end;
        end;
    end;
    FrameSetBookkeeping(begin_reg, end_reg, size, FALSE);
    if return_kind != 0 then WriteTPC(target); end;
end;
