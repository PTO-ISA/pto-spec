<!-- GENERATED FROM: asl/arch/state/program-counter.asl -->
# Program Counter

**Normative ASL source:** `asl/arch/state/program-counter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-PROGRAM-COUNTER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-program-counter-purpose-scope role=purpose-scope -->
## 用途与范围

`asl/arch/state/program-counter.asl` 拥有六个小型访问函数。`ReadPC`、`ReadTPC` 和 `ReadBPC` 是返回 `Word` 的 `readonly` 函数；`WritePC`、`WriteTPC` 和 `WriteBPC` 各接受一个 `Word` 参数。`Word` 是 `bits(PTO_XLEN)`，其中 `PTO_XLEN` 为 `64`，所以每个访问函数搬运的都是完整的 64 位值。

本单元只管理两个程序计数器的存储访问。指令定序、故障进入、向量选择与恢复资格仍由执行这些步骤的所有者拥有。

<!-- PTO-READER-BLOCK: arch-program-counter-concepts-state role=concepts-state -->
## 两个存储对象，三个名称

`ReadPC` 和 `ReadTPC` 都 `return _PC`，`WritePC` 和 `WriteTPC` 都赋值给 `_PC`。因此 `PC` 与 `TPC` 是同一个已存储 `Word` 的两个访问名称，而不是两个计数器。`ReadBPC` 和 `WriteBPC` 使用独立对象 `_BPC`。

`_PC` 与 `_BPC` 在 `asl/arch/programming-model/execution-context.asl` 中声明为 `var _PC : Word;` 和 `var _BPC : Word;`。它们属于作用域为 `core` 的状态对象 `PTO-STATE-ARCH-PROGRAM-CONTROL`，其所有者是 `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT`。`asl/arch/system-registers/addressing.asl` 中的 `ResetProfileState` 把两者都置为 `Zeros{PTO_XLEN}`。

Design point：由于 `WriteTPC` 赋值给 `WritePC` 所赋的同一对象，陷阱重定向会立刻通过普通 PC 访问函数可见。`asl/arch/memory-model/fault-precision.asl` 中的 `SetFaultWithCause` 执行 `WriteTPC(TrapVectorEntry(ring, address))` 之后，随后的 `ReadPC()` 返回的就是该向量入口。此时传给故障路径的地址保存在已保存字段 `_TrapContexts[[ring]].tpc`、`_FaultAddress` 与 `_ACRTrapArgument0[[ring]]` 中，因此需要故障地址的处理程序读取这些状态，而不是依赖 `ReadPC`。

<!-- PTO-READER-BLOCK: arch-program-counter-rules-interactions role=rules-interactions -->
## 谁读写这些计数器

`SetFaultWithCause` 中的故障进入用 `TrapTargetForFault` 选择目标环，保存上下文，用 `SetCurrentACR` 选中该环，并把向量入口安装为新的 TPC。

`RaiseServiceRequest` 中的服务请求把 `resume_tpc` 计算为 `source_tpc + (Zeros{PTO_XLEN} + 4)`，为目标环保存上下文，用 `resume_tpc` 覆盖已保存的 `tpc` 字段和上下文寄存器 `0x0f43`，然后把活动计数器重定向到 `TrapVectorEntry(target_ring, source_tpc)`，因此该请求会在一个 4 字节步之后恢复执行。`RaiseInterrupt` 以 `WriteTPC(TrapVectorEntry(ring, ReadTPC()))` 结束。

分支在 `asl/scalar/model/bru/semantics.asl` 中用 `ReadPC()` 或 `ReadTPC()` 计算目标，并用 `WritePC(...)` 提交；那里的顺序步进是 `ReadPC() + 4`，半字偏移用 `LSL(halfword_offset, 1)` 缩放。Tile 内存重放路径把束计数器当作请求标识：`asl/tile/model/memory/load-store.asl` 中的 `BeginMemoryReplay(ReadBPC())`。

Design point：`_BPC` 只由 `WriteBPC` 写入，因此陷阱重定向无法改变内存重放请求所记录的值。`asl/arch/state/trap-context.asl` 中的恢复门 `PortableTrapContextRecoverable` 与 `TrapContextRecoverable` 分别测试已保存 BPC 和已保存 TPC 的位 `0`；由于两个值来自独立对象，改变其中一个的该位不会影响另一个。

<!-- PTO-READER-BLOCK: arch-program-counter-boundaries role=boundaries -->
## 架构边界

六个函数体各自只包含一个 `return` 或一个赋值。它们不含断言、不含故障调用，也不做对齐检查：`WriteTPC` 原样存储交给它的 `Word`，任何访问函数都不会自行推进计数器。

对这些值的位级测试位于陷阱上下文恢复门中。`PortableTrapContextRecoverable` 要求已保存的 `bpc[0]` 与 `tpc[0]` 位为 `'0'`，而 `TrapContextRecoverable` 对从上下文寄存器 `0x0f41` 和 `0x0f43` 读回的值重复这两项测试。

Design point：把顺序步进留在访问函数之外，才使陷阱路径能够直接替换计数器。`SetFaultWithCause` 安装的向量入口与先前值之间不存在任何固定增量关系，而普通分支通过 `WritePC` 加上 `4` 或一个缩放后的半字偏移。

<!-- PTO-READER-BLOCK: arch-program-counter-example-usage role=example-usage -->
## 阅读示例

从复位后的核开始，此时 `ResetProfileState` 已把两个对象都置为 `Zeros{PTO_XLEN}`。`WriteTPC(Zeros{PTO_XLEN} + 4096)` 把 `4096` 存入 `_PC`，所以 `ReadPC()` 与 `ReadTPC()` 都返回 `4096`；随后执行 `WriteBPC(Zeros{PTO_XLEN} + 4096)` 只会改变 `ReadBPC()`。

如果 `SavePortableTrapContext` 对该状态做快照，已保存的 `bpc[0]` 与 `tpc[0]` 位都是 `'0'`，因此对一个有效槽位 `PortableTrapContextRecoverable` 为 `TRUE`。若先用 `WriteTPC` 存入 `4097`，`tpc[0]` 变为 `'1'`，同一个门随后返回 `FALSE`，即使该槽位仍被标记为有效。

<!-- PTO-READER-BLOCK: arch-program-counter-related-owners role=related-owners-navigation -->
## 相关所有者

- [标量寄存器](../programming-model/scalar-registers.md)是第 1 行给出的依赖，并拥有 `_PEGPRs`。
- [执行上下文](../programming-model/execution-context.md)声明 `_PC` 与 `_BPC`，并拥有程序控制状态对象。
- [陷阱上下文](trap-context.md)对这两个计数器做快照与恢复。
- [故障精确性](../memory-model/fault-precision.md)在故障、服务请求与中断进入时重定向计数器。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/program-counter.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-PROGRAM-COUNTER","surface":"arch","classification":["state","program-counter"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
readonly func ReadPC() => Word
begin
    return _PC;
end;

readonly func ReadTPC() => Word
begin
    return _PC;
end;

readonly func ReadBPC() => Word
begin
    return _BPC;
end;

func WritePC(value: Word)
begin
    _PC = value;
end;

func WriteTPC(value: Word)
begin
    _PC = value;
end;

func WriteBPC(value: Word)
begin
    _BPC = value;
end;
```
<!-- GENERATED-ASL-END: unit -->
