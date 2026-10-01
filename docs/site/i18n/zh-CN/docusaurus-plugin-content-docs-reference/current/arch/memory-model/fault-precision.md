<!-- GENERATED FROM: asl/arch/memory-model/fault-precision.asl -->
# Fault Precision

**Normative ASL source:** `asl/arch/memory-model/fault-precision.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-fault-precision-purpose role=purpose-scope -->
## 目的与范围

本单元拥有让重试重新执行整个 Tile 内存请求的重放检查点，以及让内存故障成为架构陷阱状态的漏斗。它带有 `PTO-ARCH-MEMORY-MODEL-REPLAY-001` 与 `PTO-ARCH-MEMORY-MODEL-FLUSH-001`，并依赖 `PTO-ARCH-STATE-TRAP-CONTEXT`。

主体写入 `_MemoryReplayState`、陷阱库数组、`_LastFault`、`_FaultAddress`、`TPC` 以及一个 `_ExtendedSystemRegisters` 条目。

<!-- PTO-READER-BLOCK: arch-fault-precision-concepts role=concepts-state -->
## 重放检查点与陷阱库

- `_MemoryReplayState` 是定义在 `asl/arch/data-types/memory-model.asl` 中的四字段记录：`active`、`request`、`committed_event_count` 与 `epoch`。
- `BeginMemoryReplay(request)` 把 `active` 置真、存入 `request`、把 `_MemoryEventCount` 拷入 `committed_event_count` 并递增 `epoch`。
- `CommitMemoryReplayEffect` 把 `committed_event_count` 提升到 `_MemoryEventCount`，但仅在 `active` 为真时。
- `FlushMemoryReplay` 把 `_MemoryEventCount` 回退到 `committed_event_count` 并清除 `active`；`CompleteMemoryReplay` 提升它并清除 `active`。
- 陷阱库是五个按 ring 索引的数组：`_ACRTrapAsynchronous`、`_ACRTrapArgumentValid`、类型为 `bits(24)` 的 `_ACRTrapCause`、类型为 `TrapNumber` 的 `_ACRTrapNumber`，以及类型为 `Word` 的 `_ACRTrapArgument0`。

<!-- PTO-READER-BLOCK: arch-fault-precision-rules role=rules-interactions -->
## 每个入口写入什么

- `SetFaultWithCause(code, address, cause)` 只对非零 `code` 调用 `SaveTrapContext(ring, source_ring)` 并写入 `TPC`；此时 `ring = TrapTargetForFault(CurrentACR())`，否则为源 ring。
- 它把 `code` 记入 `_LastFault`、把 `address` 记入 `_FaultAddress`、把 `cause` 记入 `_ACRTrapCause`，并按 `code != Fault_None` 设置 `_ACRTrapArgumentValid[[ring]]`。
- `case code of` 语句给 `Fault_None` 与 `Fault_ExecutionStateCheck` 陷阱号 `0`，给 `Fault_IllegalInstruction` `4`，给四个 tile 与 bundle 编号共享的 `5`，给 `Fault_ServiceRequest` `6`，其余指令、数据与调试故障得到 `32` 到 `52` 之间各自不同的编号。
- 对非零 `code`，它调用 `SetCurrentACR(ring)` 与 `WriteTPC(TrapVectorEntry(ring, address))`；非零时 `TrapVectorEntry` 返回 `EVBASE`，否则返回 `address`。
- `ClearFault` 把当前 ring 的陷阱库重置为 `Fault_None`、零 cause、零陷阱号与零实参、假标志，并且也会清除 `_FaultAddress`。
- `RaiseServiceRequest(request_type)` 检查 `ServiceRequestPermitted(source_ring, request_type)`：被拒绝时在 `ReadTPC()` 处引发 `Fault_IllegalInstruction` 并返回假；成功时为 `ServiceRequestTarget` 保存上下文、从源 TPC 之后 `4` 字节处恢复，并经 `TrapVectorEntry` 以陷阱号 `6` 与实参 `source_tpc` 进入。
- `RaiseInterrupt(interrupt_id, cause)` 标记该中断为 pending，并在 `InterruptEnabled` 为真时保存上下文、以陷阱号 `44` 异步进入目标 ring。
- `PackTrapStatus(ring)` 组装一个 `Word`：位 `63` 为异步、位 `62` 为实参有效、`value[24 +: 24]` 为 cause、`value[0 +: 6]` 为陷阱号；`UnpackTrapStatus` 恢复这四个字段。

设计要点：`FlushMemoryReplay` 只重写 `_MemoryEventCount`，别的什么都不动，所以它无法撤销一次 GM 写入或一个 tile 载荷元素：那些是调用者在记录事件之前写下的。检查点之上的记录仍留在 `_MemoryEvents` 中但不可达：读取者都以 `_MemoryEventCount` 为界，而 `AddMemoryEvent` 下一次就会覆写该槽。

设计要点：`MemoryReplayCanRetryWholeRequest` 要求重放状态不活动，并且已保存的请求等于传入的 `request`，或者已保存的请求为 `Zeros{PTO_XLEN}`。已保存的零是接受任意传入请求的通配值；传入零不能绕过一个非零的已保存请求。`FlushMemoryReplay` 和 `CompleteMemoryReplay` 清除 `active`，复位也以不活动状态和零的已保存请求开始。

设计要点：`SetFaultWithCause` 在 `case` 之前就写入传入的 `address` 和 `cause`，即使编号是 `Fault_None` 也一样。该编号使实参有效标志为假、陷阱号为 `0`，但 `_FaultAddress` 变为传入地址，当前陷阱库保存传入的 cause。`ClearFault` 则把故障地址和陷阱库的 cause 归零。

<!-- PTO-READER-BLOCK: arch-fault-precision-boundaries role=boundaries -->
## 边界

`Fault_BundlePostCommit` 是成功边界而不是失败的指令：它与 tile 与 bundle 故障共享陷阱号 `5`，而它在 ASL 中唯一的产生者是 `asl/block/model/lifecycle/enter-stop.asl` 中的 `SetFault(Fault_BundlePostCommit, next_pc)`。

`RaiseInterrupt` 不被任何 ASL 单元调用，只有测试调用；`RaiseServiceRequest` 例如被 `asl/scalar/model/sys/semantics.asl` 中的 `ArchitectureCloseRequest` 调用。`PTO-ARCH-MEMORY-MODEL-REPLAY-001` 条款把出错指令称为重启点，但本单元写入的是陷阱向量入口，对服务请求则是该指令之后 `4` 字节的地址。

冲刷不写任何故障状态，故障入口除上下文副本之外也不写任何重放状态，因此不调用 `FlushMemoryReplay` 的故障会让 `active` 保持为真。

<!-- PTO-READER-BLOCK: arch-fault-precision-example role=example-usage -->
## 非规范性重放示例

一次 Tile 加载在 `_MemoryEventCount` 为 `4` 时用 `BeginMemoryReplay(ReadBPC())` 打开记录，提交两个事件并到达检查点 `6`。当后续某个元素探测失败时，`FlushMemoryReplay` 把 `_MemoryEventCount` 退回 `6`，而已提交事件与 GM 写入都留在原处。

本示例仅作为阅读辅助：先应用上面的规则，再到规范性 ASL 拥有者中确认结果。它不增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-fault-precision-related role=related-owners-navigation -->
## 相关拥有者

- `PTO-ARCH-STATE-TRAP-CONTEXT` 拥有 `_TrapContexts` 与 `SaveTrapContext`。
- `PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL` 拥有 `CurrentACR`、`TrapTargetForFault`、`ServiceRequestPermitted`、`ServiceRequestTarget` 与 `TrapVectorEntry`。
- [内存事件](memory-events.md) 拥有 `_MemoryEventCount` 与事件数组。
- `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT` 声明 `_MemoryReplayState` 与陷阱库数组。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/fault-precision.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","surface":"arch","classification":["memory-model","fault-precision"],"depends_on":["PTO-ARCH-STATE-TRAP-CONTEXT"]}
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-REPLAY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A scalar fault is precise: effects committed by older instructions remain,
// the faulting instruction is the restart point, and younger work has no
// architectural effect.  A Tile memory request is precise at its Block
// boundary; completed TLOAD/TSTORE beats remain visible, while retrying a
// fault re-executes the whole logical request and never exposes an internal
// lane or cursor as architectural state.
// NDF-END: PTO-ARCH-MEMORY-MODEL-REPLAY-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-FLUSH-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A replay flush discards only uncommitted event records and younger pending
// work.  It MUST NOT roll back committed GM writes, committed Tile payload
// elements, or a memory event already admitted before the fault.  Recovery
// retries from the saved instruction/request template.
// NDF-END: PTO-ARCH-MEMORY-MODEL-FLUSH-001

func BeginMemoryReplay(request: Word)
begin
    _MemoryReplayState.active = TRUE;
    _MemoryReplayState.request = request;
    _MemoryReplayState.committed_event_count = _MemoryEventCount;
    _MemoryReplayState.epoch = _MemoryReplayState.epoch + 1;
end;

func CommitMemoryReplayEffect()
begin
    if _MemoryReplayState.active then
        _MemoryReplayState.committed_event_count = _MemoryEventCount;
    end;
end;

func FlushMemoryReplay()
begin
    if _MemoryReplayState.active then
        // Event records after the last committed effect are speculative and
        // are removed.  Architectural memory and Tile state are not undone.
        _MemoryEventCount = _MemoryReplayState.committed_event_count;
        _MemoryReplayState.active = FALSE;
    end;
end;

func CompleteMemoryReplay()
begin
    if _MemoryReplayState.active then
        _MemoryReplayState.committed_event_count = _MemoryEventCount;
        _MemoryReplayState.active = FALSE;
    end;
end;

readonly func MemoryReplayCanRetryWholeRequest(request: Word) => boolean
begin
    return !_MemoryReplayState.active &&
           (_MemoryReplayState.request == request ||
            _MemoryReplayState.request == Zeros{PTO_XLEN});
end;
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
