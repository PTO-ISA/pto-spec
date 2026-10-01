<!-- GENERATED FROM: asl/block/model/lifecycle/lifetime.asl -->
# Lifetime

**Normative ASL source:** `asl/block/model/lifecycle/lifetime.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-purpose role=purpose-scope -->
## 用途与范围

本单元定义 `FENTRY`、`FEXIT`、`FRET.RA` 和 `FRET.STK` 背后的帧模板。帧模板在栈上保存或恢复一段连续的通用寄存器，并调整栈指针，这一切都作为一条命令完成。

本单元还定义两个执行上下文辅助函数 `SaveExecutionContextState` 和 `RecoverExecutionContextState`。在 PTO 中，命令分派器永远不会到达它们；参见架构边界一节。

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-concepts role=concepts-state -->
## 概念与可见状态

- 栈指针是 GPR 1（`PTOFrameStackPointerIndex`）。返回地址寄存器是 GPR 10（`PTO_FRAME_RA_INDEX`）。
- 寄存器范围从起始寄存器延伸到结束寄存器。两个端点都必须在 `2..23` 内。当结束寄存器低于起始寄存器时，范围从 23 回绕到 2，因此 22 个寄存器 `R2..R23` 构成一个环。
- 帧的槽位 `k` 位于 `caller_sp - 8*(k+1)`。槽位 0 保存起始寄存器。
- `_FrameTemplate` 记录种类、指令 PC、寄存器范围、帧大小、调用者栈指针、栈指针是否已调整、进度（下一个尚未传输的寄存器）、返回目标，以及对 `FENTRY` 而言的源值。
- 模板完成时，更新 `_FrameDepth`、`_LastFrameBegin`、`_LastFrameEnd` 和 `_LastFrameSize`。

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-rules role=rules-interactions -->
## 规则与交互

只有当操作数合法时模板才会启动：两个端点都在 `2..23` 内，帧大小是 8 的倍数且每个寄存器至少 8 字节，并且对 `FRET.STK` 而言起始寄存器为 10。否则，它在任何效果之前引发 `Fault_IllegalInstruction`。

`FENTRY` 把当前栈指针作为调用者栈指针，并把每个源寄存器复制到模板中。然后它把栈指针设为 `caller_sp - size`，每步存储一个 8 字节寄存器。退出形式计算 `caller_sp = sp + size`，把栈指针恢复为该值，并每步加载一个寄存器。

`FRET.RA` 从 `_ReturnAddress` 取得返回目标。`FRET.STK` 从第一个加载的槽位取得返回目标。奇数返回目标引发 `Fault_InstructionPC`。完成时，`FENTRY` 递增 `_FrameDepth`，退出形式递减它，两种返回形式都用返回目标写入 `TPC`。

设计要点：每次 8 字节访问都是各自的重新启动边界。发生故障的步骤不会推进 `progress`，`_FrameTemplate` 会被保存在陷阱上下文中。同一条指令再次运行时，它从第一个尚未传输的寄存器继续。已提交的存储或加载永远不会重复。

设计要点：重新启动不会开始新的模板。只有当模板记录的 PC 和种类与当前指令匹配时才会复用该模板；否则该指令引发 `Fault_IllegalInstruction`。`stack_adjusted` 标志防止重试时第二次调整栈指针。

设计要点：`FENTRY` 在改变栈指针之前复制其源。重新启动的 `FENTRY` 存储的是第一次尝试时捕获的值，而不是重试时寄存器中的任意值。

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-boundaries role=boundaries -->
## 架构边界

帧模板是独立命令。它们不打开或提交指令束，也不写入 `BARG`。

`SaveExecutionContextState` 和 `RecoverExecutionContextState` 在此定义，但 `CommandHandlerSupported` 对它们的处理程序返回 false。因此 `ESAVE` 和 `ERCOV` 会在任一辅助函数运行之前引发 `Fault_IllegalInstruction`。

`_FrameDepth` 是饱和的。它不会递增超过 `PTO_MODEL_MEMORY_EVENTS`，也不会递减到零以下。

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

起始寄存器为 20、结束寄存器为 3、帧大小为 48 字节的 `FENTRY` 保存六个寄存器：20、21、22、23、2 和 3。当 `sp = 0x8000` 时，栈指针变为 `0x7FD0`。寄存器 20 存储在 `0x7FF8`，寄存器 3 存储在 `0x7FD0`。如果寄存器 2 的存储发生故障，`progress` 为 4。重试时只存储寄存器 2 和 3。

<!-- PTO-READER-BLOCK: block-model-lifecycle-lifetime-related role=related-owners-navigation -->
## 相关所有者

- [FENTRY](../../lifecycle/FENTRY.md)、[FEXIT](../../lifecycle/FEXIT.md)、[FRET.RA](../../lifecycle/FRET.RA.md) 和 [FRET.STK](../../lifecycle/FRET.STK.md) 是调用这些模板的指令页面。
- [ESAVE](../../lifecycle/ESAVE.md) 和 [ERCOV](../../lifecycle/ERCOV.md) 是被拒绝的上下文命令。
- [状态类型](../state/types.md)定义 `FrameTemplateState`。
- [陷阱上下文](../../../arch/state/trap-context.md)保存并恢复 `_FrameTemplate`。
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
