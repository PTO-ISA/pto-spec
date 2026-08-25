<!-- GENERATED FROM: asl/arch/memory-model/fault-precision.asl -->
# Fault Precision

**Normative ASL source:** `asl/arch/memory-model/fault-precision.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-fault-precision-purpose role=purpose-scope -->
## 用途与范围

本单元集中处理故障、服务请求、中断入口以及陷阱状态打包。对于同步 `SetFaultWithCause`，只有故障代码不是 `Fault_None` 时才会保存上下文并重定向到目标 `AccessControlRing`。

<!-- PTO-READER-BLOCK: arch-fault-precision-concepts role=concepts-state -->
## 陷阱入口状态

- `SetFaultWithCause` 对每个输入故障代码记录故障代码、地址、原因和陷阱状态。
- 当故障代码不是 `Fault_None` 时，它保存上下文、把目标 `AccessControlRing` 设为当前层级并重定向 `TPC`。对于 `Fault_None`，它保留源 ACR 层级，既不保存上下文也不重定向。
- `RaiseServiceRequest` 检查权限，保存位于源 `TPC` 之后四字节的恢复 `TPC`，再进入服务目标。
- `RaiseInterrupt` 先标记中断待处理状态，并且只在该中断已启用时进入。

<!-- PTO-READER-BLOCK: arch-fault-precision-rules role=rules-interactions -->
## 状态转换规则

- 同步故障入口把异步位设为假，并为非零故障设置陷阱参数有效位。
- 中断入口把异步位设为真，记录陷阱编号 `44`，并把 `InterruptID` 放入参数 `0`。
- `ClearFault` 清除当前 ACR 层级的故障报告，但不会重建较早上下文。
- `PackTrapStatus` 与 `UnpackTrapStatus` 映射异步位、参数有效位、24 位原因字段和 6 位编号字段。

<!-- PTO-READER-BLOCK: arch-fault-precision-boundaries role=boundaries -->
## 提交边界

`Fault_BundlePostCommit` 被表示为成功提交边界陷阱：保存上下文时后继位置已经选定。被拒绝的服务请求则会引发 `Fault_IllegalInstruction` 并返回假。

<!-- PTO-READER-BLOCK: arch-fault-precision-example role=example-usage -->
## 非规范阅读示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-fault-precision-related role=related-owners-navigation -->
## 相关所有者

- `PTO-ARCH-STATE-TRAP-CONTEXT` 拥有保存上下文的表示。
- 陷阱上下文恢复单元定义可恢复保存上下文对应的恢复路径。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/fault-precision.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","surface":"arch","classification":["memory-model","fault-precision"],"depends_on":["PTO-ARCH-STATE-TRAP-CONTEXT"]}
func SetFaultWithCause(code: FaultCode, address: Word, cause: bits(24))
begin
    let source_ring = CurrentACR();
    let ring = if code == Fault_None then source_ring
        else TrapTargetForFault(source_ring);
    if code != Fault_None then
        SaveTrapContext(ring, source_ring);
    end;
    _LastFault = code;
    _FaultAddress = address;
    _ACRTrapAsynchronous[[ring]] = FALSE;
    _ACRTrapArgumentValid[[ring]] = code != Fault_None;
    _ACRTrapCause[[ring]] = cause;
    case code of
        when Fault_None => _ACRTrapNumber[[ring]] = Zeros{6};
        when Fault_ExecutionStateCheck => _ACRTrapNumber[[ring]] = Zeros{6};
        when Fault_IllegalInstruction => _ACRTrapNumber[[ring]] = Zeros{6} + 4;
        when Fault_InstructionPC => _ACRTrapNumber[[ring]] = Zeros{6} + 32;
        when Fault_InstructionPage => _ACRTrapNumber[[ring]] = Zeros{6} + 33;
        when Fault_DataAlignment => _ACRTrapNumber[[ring]] = Zeros{6} + 34;
        when Fault_DataPage => _ACRTrapNumber[[ring]] = Zeros{6} + 35;
        when Fault_HardwareBreakpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 49;
        when Fault_SoftwareBreakpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 50;
        when Fault_HardwareWatchpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 51;
        when Fault_Assert => _ACRTrapNumber[[ring]] = Zeros{6} + 52;
        when Fault_TileLegality => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_TileAllocation => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_BundleControl => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        // B.CATR.trap is a successful-commit boundary trap, not a failed
        // instruction.  It uses the bundle exception class while preserving
        // the already selected continuation in the saved clean context.
        when Fault_BundlePostCommit => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_ServiceRequest => _ACRTrapNumber[[ring]] = Zeros{6} + 6;
    end;
    _ACRTrapArgument0[[ring]] = address;
    if code != Fault_None then
        SetCurrentACR(ring);
        WriteTPC(TrapVectorEntry(ring, address));
    end;
end;

func SetFault(code: FaultCode, address: Word)
begin
    SetFaultWithCause(code, address, Zeros{24});
end;

func RaiseServiceRequest(request_type: bits(4)) => boolean
begin
    let source_ring = CurrentACR();
    if !ServiceRequestPermitted(source_ring, request_type) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;

    let source_tpc = ReadTPC();
    let resume_tpc = source_tpc + (Zeros{PTO_XLEN} + 4);
    let target_ring = ServiceRequestTarget(source_ring, request_type);
    SaveTrapContext(target_ring, source_ring);
    _TrapContexts[[target_ring]].tpc = resume_tpc;
    let ebarg_tpc_index = ((target_ring * 4096) + 0x0f43)
        as SystemRegisterFileIndex;
    _ExtendedSystemRegisters[[ebarg_tpc_index]] = resume_tpc;

    _LastFault = Fault_ServiceRequest;
    _FaultAddress = source_tpc;
    _ACRTrapAsynchronous[[target_ring]] = FALSE;
    _ACRTrapArgumentValid[[target_ring]] = TRUE;
    _ACRTrapCause[[target_ring]] = ZeroExtend{24}(request_type);
    _ACRTrapNumber[[target_ring]] = Zeros{6} + 6;
    _ACRTrapArgument0[[target_ring]] = source_tpc;
    SetCurrentACR(target_ring);
    WriteTPC(TrapVectorEntry(target_ring, source_tpc));
    return TRUE;
end;

func ClearFault()
begin
    let ring = CurrentACR();
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _ACRTrapAsynchronous[[ring]] = FALSE;
    _ACRTrapArgumentValid[[ring]] = FALSE;
    _ACRTrapCause[[ring]] = Zeros{24};
    _ACRTrapNumber[[ring]] = Zeros{6};
    _ACRTrapArgument0[[ring]] = Zeros{PTO_XLEN};
end;

func RaiseInterrupt(interrupt_id: InterruptID, cause: bits(24))
begin
    let source_ring = CurrentACR();
    let ring = TrapTargetForInterrupt(source_ring);
    SetInterruptPending(ring, interrupt_id);
    if !InterruptEnabled(ring, interrupt_id) then return; end;
    SaveTrapContext(ring, source_ring);
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _ACRTrapAsynchronous[[ring]] = TRUE;
    _ACRTrapArgumentValid[[ring]] = TRUE;
    _ACRTrapCause[[ring]] = cause;
    _ACRTrapNumber[[ring]] = Zeros{6} + 44;
    _ACRTrapArgument0[[ring]] =
        NaturalToWord(interrupt_id as integer {0..262144});
    SetCurrentACR(ring);
    WriteTPC(TrapVectorEntry(ring, ReadTPC()));
end;

readonly func PackTrapStatus(ring: AccessControlRing) => Word
begin
    var value: Word = Zeros{PTO_XLEN};
    value[63] = if _ACRTrapAsynchronous[[ring]] then '1' else '0';
    value[62] = if _ACRTrapArgumentValid[[ring]] then '1' else '0';
    value[24 +: 24] = _ACRTrapCause[[ring]];
    value[0 +: 6] = _ACRTrapNumber[[ring]];
    return value;
end;

func UnpackTrapStatus(ring: AccessControlRing, value: Word)
begin
    _ACRTrapAsynchronous[[ring]] = value[63] == '1';
    _ACRTrapArgumentValid[[ring]] = value[62] == '1';
    _ACRTrapCause[[ring]] = value[24 +: 24];
    _ACRTrapNumber[[ring]] = value[0 +: 6];
end;
```
<!-- GENERATED-ASL-END: unit -->
