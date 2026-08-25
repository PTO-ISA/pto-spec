<!-- GENERATED FROM: asl/arch/programming-model/execution-context.asl -->
# Execution Context

**Normative ASL source:** `asl/arch/programming-model/execution-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-execution-context-purpose-scope role=purpose-scope -->
## 用途与范围

执行上下文是 PTO 执行期间主要架构可见标量、控制、故障、内存、维护、扩展系统寄存器和陷阱上下文存储的中央所有者。

一个 Core 有四组私有标量寄存器文件。指令携带一个绝对 GPR 选择器，但每个 PE 都在自己的寄存器文件中解析这个选择器。

<!-- PTO-READER-BLOCK: arch-execution-context-concepts-state role=concepts-state -->
## 概念与状态族

- `PTO-STATE-ARCH-GPR` 拥有 PE 私有寄存器文件；`PTO-STATE-ARCH-TEMPORARY-QUEUES` 拥有 T、U 值队列及其逐项有效位。
- `PTO-STATE-ARCH-PROGRAM-CONTROL` 拥有 `PC`、`BPC`、指令束活动状态、返回值、提交值和谓词寄存器；`PTO-STATE-ARCH-FAULT` 拥有最近一次故障及其地址。
- `PTO-STATE-ARCH-MEMORY` 拥有建模的字节、保留状态、屏障选择器、捕获的内存事件和当前内存主体。
- 维护纪元、扩展系统寄存器、按 ACR 索引的陷阱元数据、保存的陷阱上下文和当前 ACR，分别属于本单元中显式声明的状态族。

<!-- PTO-READER-BLOCK: arch-execution-context-rules-interactions role=rules-interactions -->
## 队列规则与交互

`ReadTemporaryQueue` 在 `use_t_queue` 为真时选择 T 队列，否则选择 U 队列，并返回所请求相对索引处的值。

`TemporaryQueueSourceAvailable` 对有效位快照采用相同的 T 或 U 选择，并返回所请求相对索引处的有效位。压入操作移动某个值时，会把对应的有效位与该值一起移动。

`PushTemporaryQueue` 把新值插入索引 `0`，将该项标记为有效，并把所选队列索引 `0` 至 `2` 的值和有效位一起移到索引 `1` 至 `3`。

<!-- PTO-READER-BLOCK: arch-execution-context-boundaries role=boundaries -->
## 边界

T 和 U 是相互独立的队列：向其中一个队列压入数据，不会修改另一个队列的值或有效位快照。

一次压入会保留所选队列中最新的四项。当索引 `0` 至 `2` 上移时，之前的索引 `3` 项会被替换。

本单元声明上述架构存储，但不单独定义这些存储上的每一种状态转换。内存排序、复位、系统寄存器行为和陷阱恢复仍由各自专门的 ASL 所有者定义。

<!-- PTO-READER-BLOCK: arch-execution-context-example-usage role=example-usage -->
## 非规范队列演示

假设复位后 T 队列的所有相对索引都不可用。压入 `0x11` 后，T 索引 `0` 变为可用，值为 `0x11`；再压入 `0x22` 后，索引 `0` 保存 `0x22`，索引 `1` 保存较早的 `0x11`，并且两项都可用。

随后把 `0x33` 压入 U 队列，只会改变 U 索引 `0`。上一步中的 T 值仍留在各自的 T 相对位置。

<!-- PTO-READER-BLOCK: arch-execution-context-related-owners role=related-owners-navigation -->
## 相关所有者

- [系统寄存器寻址](../system-registers/addressing.md)是执行上下文单元声明的依赖项。
- [内存排序](../memory-model/ordering.md)解释这里保存的内存事件。
- [参考配置档](../profile/reference-profile.md)为 PTO v0 配置档提供具体的访问与陷阱上下文行为。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/execution-context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","surface":"arch","classification":["programming-model","execution-context"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-GPR","classification":["architecture","scalar","gpr"],"scope":"pe","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_PEGPRs"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-TEMPORARY-QUEUES","classification":["architecture","temporary-queues"],"scope":"bundle","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_TQueue","_TQueueValid","_UQueue","_UQueueValid"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-PROGRAM-CONTROL","classification":["architecture","program-control"],"scope":"core","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_PC","_BPC","_BundleActive","_BundleBodyActive","_ReturnAddress","_CommitArgument","_PredicateRegisters"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-FAULT","classification":["architecture","fault"],"scope":"core","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_LastFault","_FaultAddress"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-MEMORY","classification":["architecture","memory"],"scope":"system","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_Memory","_ReservationValid","_ReservationAddress","_ReservationSize","_LastFencePredecessor","_LastFenceSuccessor","_MemoryEvents","_MemoryEventCount","_MemoryEventCaptureEnabled","_CurrentMemoryAgent"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-MAINTENANCE","classification":["architecture","maintenance"],"scope":"system","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_DataCacheEpoch","_InstructionCacheEpoch","_BundleCacheEpoch","_TLBEpoch","_LastMaintenanceOperation","_LastMaintenanceOperand","_BundleHintEpoch","_ArchitectureRequestEpoch","_LastControlRequest","_ControlRequestOperand"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS","classification":["architecture","extended-system-registers"],"scope":"system","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_ExtendedSystemRegisters","_CurrentACR"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-TRAP-CONTEXT","classification":["architecture","trap-context"],"scope":"acr","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_ACRTrapAsynchronous","_ACRTrapArgumentValid","_ACRTrapCause","_ACRTrapNumber","_ACRTrapArgument0","_TrapContexts"],"depends_on":[]}

// NDF-BEGIN: PTO-REQ-STATE-001
// ndf: kind=contract level=L1 layer=state status=accepted
// Architecture-visible execution state MUST be the state defined by
// [[PTO-STATE-ARCH-GPR]], [[PTO-STATE-ARCH-TEMPORARY-QUEUES]],
// [[PTO-STATE-ARCH-PROGRAM-CONTROL]], [[PTO-STATE-ARCH-FAULT]],
// [[PTO-STATE-ARCH-MEMORY]], [[PTO-STATE-ARCH-MAINTENANCE]],
// [[PTO-STATE-ARCH-SYSTEM-REGISTERS]],
// [[PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS]], and
// [[PTO-STATE-ARCH-TRAP-CONTEXT]].
// NDF-END: PTO-REQ-STATE-001

// Requirement references: PTO-REQ-PROFILE-001, PTO-REQ-MEMORY-TSO-001.

// A core owns four private scalar register files.  An encoded absolute GPR
// selector is shared by the instruction, but each PE resolves that selector
// in its own file.
var _PEGPRs : array [[PTO_MODEL_MEMORY_AGENTS]] of PERegisterFile;
var _TQueue : TemporaryQueueSnapshot;
var _TQueueValid : TemporaryQueueValiditySnapshot;
var _UQueue : TemporaryQueueSnapshot;
var _UQueueValid : TemporaryQueueValiditySnapshot;
var _PC : Word;
var _BPC : Word;
var _BundleActive : boolean;
var _BundleBodyActive : boolean;
var _ReturnAddress : Word;
var _CommitArgument : Word;
var _PredicateRegisters : PredicateSnapshot;
var _LastFault : FaultCode;
var _FaultAddress : Word;
var _Memory : array [[PTO_MODEL_MEMORY_BYTES]] of Byte;
var _ReservationValid : boolean;
var _ReservationAddress : Word;
var _ReservationSize : integer {1,2,4,8};
var _LastFencePredecessor : bits(4);
var _LastFenceSuccessor : bits(4);
var _MemoryEvents : array [[PTO_MODEL_MEMORY_EVENTS]] of MemoryEvent;
var _MemoryEventCount : integer {0..PTO_MODEL_MEMORY_EVENTS};
var _MemoryEventCaptureEnabled : boolean;
var _CurrentMemoryAgent : MemoryAgentId;
var _DataCacheEpoch : integer;
var _InstructionCacheEpoch : integer;
var _BundleCacheEpoch : integer;
var _TLBEpoch : integer;
var _LastMaintenanceOperation : MaintenanceOperation;
var _LastMaintenanceOperand : Word;
var _BundleHintEpoch : integer;
var _ArchitectureRequestEpoch : integer;
var _LastControlRequest : ExecutionControlRequest;
var _ControlRequestOperand : Word;
var _ExtendedSystemRegisters : array [[65536]] of Word;
var _ACRTrapAsynchronous : array [[PTO_ACR_COUNT]] of boolean;
var _ACRTrapArgumentValid : array [[PTO_ACR_COUNT]] of boolean;
var _ACRTrapCause : array [[PTO_ACR_COUNT]] of bits(24);
var _ACRTrapNumber : array [[PTO_ACR_COUNT]] of TrapNumber;
var _ACRTrapArgument0 : array [[PTO_ACR_COUNT]] of Word;
var _TrapContexts : array [[PTO_ACR_COUNT]] of TrapContext;
var _CurrentACR : AccessControlRing;

readonly func ReadTemporaryQueue(use_t_queue: boolean,
                                 index: TemporaryQueueIndex) => Word
begin
    return if use_t_queue then _TQueue[[index]] else _UQueue[[index]];
end;

readonly func TemporaryQueueSourceAvailable(
    use_t_queue: boolean,
    index: TemporaryQueueIndex) => boolean
begin
    return if use_t_queue then
        _TQueueValid[[index]]
    else
        _UQueueValid[[index]];
end;

func PushTemporaryQueue(use_t_queue: boolean, value: Word)
begin
    if use_t_queue then
        _TQueue[[3]] = _TQueue[[2]];
        _TQueueValid[[3]] = _TQueueValid[[2]];
        _TQueue[[2]] = _TQueue[[1]];
        _TQueueValid[[2]] = _TQueueValid[[1]];
        _TQueue[[1]] = _TQueue[[0]];
        _TQueueValid[[1]] = _TQueueValid[[0]];
        _TQueue[[0]] = value;
        _TQueueValid[[0]] = TRUE;
    else
        _UQueue[[3]] = _UQueue[[2]];
        _UQueueValid[[3]] = _UQueueValid[[2]];
        _UQueue[[2]] = _UQueue[[1]];
        _UQueueValid[[2]] = _UQueueValid[[1]];
        _UQueue[[1]] = _UQueue[[0]];
        _UQueueValid[[1]] = _UQueueValid[[0]];
        _UQueue[[0]] = value;
        _UQueueValid[[0]] = TRUE;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
