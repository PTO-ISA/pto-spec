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

func EnterFrame(begin_reg: Reg5Selector, end_reg: Reg5Selector, size: Word)
begin
    _LastFrameBegin = begin_reg;
    _LastFrameEnd = end_reg;
    _LastFrameSize = size;
    if _FrameDepth != PTO_MODEL_MEMORY_EVENTS then
        _FrameDepth = (_FrameDepth + 1) as integer {0..PTO_MODEL_MEMORY_EVENTS};
    end;
end;

func ExitFrame(begin_reg: Reg5Selector, end_reg: Reg5Selector, size: Word)
begin
    _LastFrameBegin = begin_reg;
    _LastFrameEnd = end_reg;
    _LastFrameSize = size;
    if _FrameDepth != 0 then
        _FrameDepth = (_FrameDepth - 1) as integer {0..PTO_MODEL_MEMORY_EVENTS};
    end;
end;

func ReturnFromFrame(begin_reg: Reg5Selector, end_reg: Reg5Selector,
                     size: Word, use_return_address: boolean)
begin
    ExitFrame(begin_reg, end_reg, size);
    if use_return_address then
        WriteTPC(_ReturnAddress);
    else
        WriteTPC(_BundleReturnTarget);
    end;
end;

