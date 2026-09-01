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

constant PTO_FRAME_SP_INDEX = 1;
constant PTO_FRAME_RA_INDEX = 10;

pure func FrameRegisterEndpointLegal(selector: Reg5Selector) => boolean
begin
    return selector >= 2 && selector <= 23;
end;

pure func FrameRegisterRangeCount(begin_reg: Reg5Selector,
                                  end_reg: Reg5Selector)
                                  => FrameRegisterCount
begin
    assert FrameRegisterEndpointLegal(begin_reg);
    assert FrameRegisterEndpointLegal(end_reg);
    if end_reg >= begin_reg then
        return ((end_reg - begin_reg) + 1) as FrameRegisterCount;
    else
        return (((24 - begin_reg) + end_reg) - 1)
            as FrameRegisterCount;
    end;
end;

pure func FrameRegisterAt(begin_reg: Reg5Selector,
                          ordinal: FrameRegisterOrdinal) => GPRIndex
begin
    let unwrapped = begin_reg + ordinal;
    let wrapped = if unwrapped <= 23 then unwrapped else unwrapped - 22;
    return wrapped as GPRIndex;
end;

pure func FrameSlotAddress(caller_sp: Word,
                           ordinal: FrameRegisterOrdinal) => Word
begin
    let byte_offset = (ordinal + 1) * 8;
    return caller_sp - NaturalToWord(byte_offset as integer {0..262144});
end;

pure func FrameTemplateOperandsLegal(kind: FrameTemplateKind,
                                     begin_reg: Reg5Selector,
                                     end_reg: Reg5Selector,
                                     size: Word) => boolean
begin
    if !FrameRegisterEndpointLegal(begin_reg) ||
       !FrameRegisterEndpointLegal(end_reg) then
        return FALSE;
    end;
    if kind == FrameTemplate_ReturnStack &&
       begin_reg != PTO_FRAME_RA_INDEX then
        return FALSE;
    end;
    let count = FrameRegisterRangeCount(begin_reg, end_reg);
    return size[2:0] == Zeros{3} && UInt(size) >= count * 8;
end;

func StartFrameTemplate(kind: FrameTemplateKind,
                        begin_reg: Reg5Selector,
                        end_reg: Reg5Selector,
                        size: Word) => boolean
begin
    if !FrameTemplateOperandsLegal(kind, begin_reg, end_reg, size) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;

    let count = FrameRegisterRangeCount(begin_reg, end_reg);
    let current_sp = ReadGPR(PTO_FRAME_SP_INDEX);
    _FrameTemplate.active = TRUE;
    _FrameTemplate.kind = kind;
    _FrameTemplate.instruction_pc = ReadTPC();
    _FrameTemplate.begin_reg = begin_reg;
    _FrameTemplate.end_reg = end_reg;
    _FrameTemplate.register_count = count;
    _FrameTemplate.frame_size = size;
    _FrameTemplate.caller_sp = if kind == FrameTemplate_Entry then
        current_sp
    else
        current_sp + size;
    _FrameTemplate.stack_adjusted = FALSE;
    _FrameTemplate.progress = 0;
    _FrameTemplate.return_target = if kind == FrameTemplate_ReturnAddress then
        _ReturnAddress
    else
        Zeros{PTO_XLEN};
    _FrameTemplate.return_target_valid =
        kind == FrameTemplate_ReturnAddress;

    if _FrameTemplate.return_target_valid &&
       _FrameTemplate.return_target[0] == '1' then
        _FrameTemplate.active = FALSE;
        SetFault(Fault_InstructionPC, _FrameTemplate.return_target);
        return FALSE;
    end;

    // FENTRY snapshots every source before the destructive sp update.
    if kind == FrameTemplate_Entry then
        for item = 0 to 21 do
            let ordinal = item as FrameRegisterOrdinal;
            if item < count then
                let register = FrameRegisterAt(begin_reg, ordinal);
                _FrameTemplate.source_values[[ordinal]] = ReadGPR(register);
            else
                _FrameTemplate.source_values[[ordinal]] = Zeros{PTO_XLEN};
            end;
        end;
    end;
    return TRUE;
end;

func AdjustFrameStackPointer()
begin
    if _FrameTemplate.kind == FrameTemplate_Entry then
        WriteGPR(
            PTO_FRAME_SP_INDEX,
            _FrameTemplate.caller_sp - _FrameTemplate.frame_size);
    else
        WriteGPR(PTO_FRAME_SP_INDEX, _FrameTemplate.caller_sp);
    end;
    _FrameTemplate.stack_adjusted = TRUE;
end;

func ExecuteFrameStoreStep()
begin
    assert _FrameTemplate.progress < _FrameTemplate.register_count;
    let ordinal = _FrameTemplate.progress as FrameRegisterOrdinal;
    let address = FrameSlotAddress(_FrameTemplate.caller_sp, ordinal);
    let write_probe = ProbeDataAccess(address, 8, 8, TRUE);
    if RaiseDataAccessFault(write_probe, address) then
        return;
    end;

    let value = _FrameTemplate.source_values[[ordinal]];
    StoreTranslated(address, write_probe.translated_address, 8, value);
    RecordStoreEvent(
        write_probe.translated_address,
        8,
        value,
        MemoryOrder_Relaxed);
    _FrameTemplate.progress = (_FrameTemplate.progress + 1)
        as FrameRegisterCount;
end;

func ExecuteFrameLoadStep()
begin
    assert _FrameTemplate.progress < _FrameTemplate.register_count;
    let ordinal = _FrameTemplate.progress as FrameRegisterOrdinal;
    let address = FrameSlotAddress(_FrameTemplate.caller_sp, ordinal);
    let read_probe = ProbeDataAccess(address, 8, 8, FALSE);
    if RaiseDataAccessFault(read_probe, address) then
        return;
    end;

    let value = LoadTranslatedUnsigned(read_probe.translated_address, 8);
    let register = FrameRegisterAt(_FrameTemplate.begin_reg, ordinal);
    if _FrameTemplate.kind == FrameTemplate_ReturnStack && ordinal == 0 then
        if value[0] == '1' then
            SetFault(Fault_InstructionPC, value);
            return;
        end;
        _FrameTemplate.return_target = value;
        _FrameTemplate.return_target_valid = TRUE;
    end;

    RecordLoadEvent(
        read_probe.translated_address,
        8,
        value,
        MemoryOrder_Relaxed);
    WriteGPR(register, value);
    if register == PTO_FRAME_RA_INDEX then
        _ReturnAddress = value;
    end;
    _FrameTemplate.progress = (_FrameTemplate.progress + 1)
        as FrameRegisterCount;
end;

func CompleteFrameTemplate()
begin
    let kind = _FrameTemplate.kind;
    _LastFrameBegin = _FrameTemplate.begin_reg;
    _LastFrameEnd = _FrameTemplate.end_reg;
    _LastFrameSize = _FrameTemplate.frame_size;
    _FrameTemplate.active = FALSE;

    if kind == FrameTemplate_Entry then
        if _FrameDepth != PTO_MODEL_MEMORY_EVENTS then
            _FrameDepth = (_FrameDepth + 1)
                as integer {0..PTO_MODEL_MEMORY_EVENTS};
        end;
    else
        if _FrameDepth != 0 then
            _FrameDepth = (_FrameDepth - 1)
                as integer {0..PTO_MODEL_MEMORY_EVENTS};
        end;
        if kind == FrameTemplate_ReturnAddress ||
           kind == FrameTemplate_ReturnStack then
            assert _FrameTemplate.return_target_valid;
            WriteTPC(_FrameTemplate.return_target);
        end;
    end;
end;

func ExecuteFrameTemplate(kind: FrameTemplateKind,
                          begin_reg: Reg5Selector,
                          end_reg: Reg5Selector,
                          size: Word)
begin
    if !_FrameTemplate.active then
        if !StartFrameTemplate(kind, begin_reg, end_reg, size) then
            return;
        end;
    end;

    if _FrameTemplate.instruction_pc != ReadTPC() ||
       _FrameTemplate.kind != kind then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;

    if !_FrameTemplate.stack_adjusted then
        AdjustFrameStackPointer();
    end;
    for step = 0 to 21 looplimit 22 do
        if _FrameTemplate.active &&
           _LastFault == Fault_None &&
           _FrameTemplate.progress < _FrameTemplate.register_count then
            if kind == FrameTemplate_Entry then
                ExecuteFrameStoreStep();
            else
                ExecuteFrameLoadStep();
            end;
        end;
    end;
    if _FrameTemplate.active &&
       _LastFault == Fault_None &&
       _FrameTemplate.progress == _FrameTemplate.register_count then
        CompleteFrameTemplate();
    end;
end;

func EnterFrame(begin_reg: Reg5Selector,
                end_reg: Reg5Selector,
                size: Word)
begin
    ExecuteFrameTemplate(FrameTemplate_Entry, begin_reg, end_reg, size);
end;

func ExitFrame(begin_reg: Reg5Selector,
               end_reg: Reg5Selector,
               size: Word)
begin
    ExecuteFrameTemplate(FrameTemplate_Exit, begin_reg, end_reg, size);
end;

func ReturnFromFrame(begin_reg: Reg5Selector,
                     end_reg: Reg5Selector,
                     size: Word,
                     use_return_address: boolean)
begin
    let kind = if use_return_address then
        FrameTemplate_ReturnAddress
    else
        FrameTemplate_ReturnStack;
    ExecuteFrameTemplate(kind, begin_reg, end_reg, size);
end;
