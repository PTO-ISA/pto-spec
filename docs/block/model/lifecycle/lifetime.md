<!-- GENERATED FROM: asl/block/model/lifecycle/lifetime.asl -->
# Lifetime

**Normative ASL source:** `asl/block/model/lifecycle/lifetime.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the frame templates behind `FENTRY`, `FEXIT`, `FRET.RA`, and `FRET.STK`. A frame template saves or restores a contiguous range of general registers on the stack and adjusts the stack pointer, all as one command.

It also defines two execution-context helpers, `SaveExecutionContextState` and `RecoverExecutionContextState`. The command dispatcher never reaches them in PTO; see the boundaries section.

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-concepts role=concepts-state -->
## Concepts and visible state

- The stack pointer is GPR 1 (`PTOFrameStackPointerIndex`). The return-address register is GPR 10 (`PTO_FRAME_RA_INDEX`).
- A register range runs from a begin register to an end register. Both endpoints must be in `2..23`. When the end is lower than the begin, the range wraps from 23 back to 2, so the 22 registers `R2..R23` form a ring.
- Slot `k` of a frame is at `caller_sp - 8*(k+1)`. Slot 0 holds the begin register.
- `_FrameTemplate` records the kind, the instruction PC, the register range, the frame size, the caller stack pointer, whether the stack pointer has been adjusted, the progress (the next register not yet transferred), the return target, and, for `FENTRY`, the source values.
- `_FrameDepth`, `_LastFrameBegin`, `_LastFrameEnd`, and `_LastFrameSize` are updated when a template completes.

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-rules role=rules-interactions -->
## Rules and interactions

A template starts only if its operands are legal: both endpoints in `2..23`, a frame size that is a multiple of 8 and at least 8 bytes per register, and, for `FRET.STK`, a begin register of 10. Otherwise it raises `Fault_IllegalInstruction` before any effect.

`FENTRY` takes the current stack pointer as the caller stack pointer and copies every source register into the template. It then sets the stack pointer to `caller_sp - size` and stores one 8-byte register per step. The exit forms compute `caller_sp = sp + size`, restore the stack pointer to that value, and load one register per step.

`FRET.RA` takes its return target from `_ReturnAddress`. `FRET.STK` takes it from the first loaded slot. An odd return target raises `Fault_InstructionPC`. On completion, `FENTRY` increments `_FrameDepth`, the exit forms decrement it, and both return forms write `TPC` with the return target.

Design point: each 8-byte access is its own restart boundary. A step that faults does not advance `progress`, and `_FrameTemplate` is saved in the trap context. When the same instruction runs again, it continues at the first register that has not been transferred. Committed stores or loads are never repeated.

Design point: a restart does not start a new template. The template is reused only when its recorded PC and kind match the current instruction; otherwise the instruction raises `Fault_IllegalInstruction`. The `stack_adjusted` flag prevents a second stack-pointer adjustment on the retry.

Design point: `FENTRY` copies its sources before it changes the stack pointer. A restarted `FENTRY` stores the values captured on its first attempt, not whatever the registers hold at the retry.

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-boundaries role=boundaries -->
## Architectural boundaries

Frame templates are standalone commands. They do not open or commit a bundle and do not write `BARG`.

`SaveExecutionContextState` and `RecoverExecutionContextState` are defined here, but `CommandHandlerSupported` returns false for their handlers. `ESAVE` and `ERCOV` therefore raise `Fault_IllegalInstruction` before either helper runs.

`_FrameDepth` saturates. It is not incremented past `PTO_MODEL_MEMORY_EVENTS` and not decremented below zero.

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`FENTRY` with begin register 20, end register 3, and a 48-byte frame saves six registers: 20, 21, 22, 23, 2, and 3. With `sp = 0x8000`, the stack pointer becomes `0x7FD0`. Register 20 is stored at `0x7FF8`, and register 3 at `0x7FD0`. If the store of register 2 faults, `progress` is 4. The retry stores registers 2 and 3 only.

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-related role=related-owners-navigation -->
## Related owners

- [FENTRY](../../lifecycle/FENTRY.md), [FEXIT](../../lifecycle/FEXIT.md), [FRET.RA](../../lifecycle/FRET.RA.md), and [FRET.STK](../../lifecycle/FRET.STK.md) are the instruction pages that call these templates.
- [ESAVE](../../lifecycle/ESAVE.md) and [ERCOV](../../lifecycle/ERCOV.md) are the rejected context commands.
- [State types](../state/types.md) defines `FrameTemplateState`.
- [Trap context](../../../arch/state/trap-context.md) saves and restores `_FrameTemplate`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/lifecycle/lifetime.asl -->
```asl
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

// The stack-pointer ABI is profile-owned state, while save/restore semantics
// remain entirely ASL-defined and shared by every frame instruction.
constant PTO_FRAME_RA_INDEX = 10;

// The frame stack register is an explicit model-profile choice.  Keep the
// accessor in ASL (rather than baking an ABI index into the host runner) so
// FENTRY/FEXIT/FRET all consume the same architectural state definition.
readonly func PTOFrameStackPointerIndex() => GPRIndex
begin
    return 1;
end;

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
    let current_sp = ReadGPR(PTOFrameStackPointerIndex());
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
            PTOFrameStackPointerIndex(),
            _FrameTemplate.caller_sp - _FrameTemplate.frame_size);
    else
        WriteGPR(PTOFrameStackPointerIndex(), _FrameTemplate.caller_sp);
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
```
<!-- GENERATED-ASL-END: unit -->
