<!-- GENERATED FROM: asl/arch/programming-model/execution-context.asl -->
# Execution Context

**Normative ASL source:** `asl/arch/programming-model/execution-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-execution-context-purpose-scope role=purpose-scope -->
## Purpose and scope

The execution context declares most of the storage that PTO execution reads and writes: scalar registers, temporary queues, program control, fault records, memory, maintenance epochs, extended system registers, and trap contexts. It also defines the three operations on the T and U temporary queues.

A Core has four private scalar register files, one per PE. An instruction carries one absolute GPR selector, but each PE resolves that selector in its own register file.

<!-- PTO-READER-BLOCK: arch-execution-context-concepts-state role=concepts-state -->
## Concepts and state families

- `PTO-STATE-ARCH-GPR` owns the PE-private register files, while `PTO-STATE-ARCH-TEMPORARY-QUEUES` owns the T and U value queues together with per-entry validity.
- `PTO-STATE-ARCH-PROGRAM-CONTROL` owns `PC`, `BPC`, bundle activity, return and commit values, and predicate registers; `PTO-STATE-ARCH-FAULT` owns the last fault and its address.
- `PTO-STATE-ARCH-MEMORY` owns modeled bytes, reservation state, fence selectors, captured memory events, and the current memory agent.
- Maintenance epochs, extended system registers, ACR-indexed trap metadata, saved trap contexts, and the current ACR belong to their explicitly declared state families in this unit.

A temporary queue is a four-entry list of 64-bit values. Scalar selectors `24` through `27` read T positions `T#1` through `T#4`, and selectors `28` through `31` read U positions `U#1` through `U#4`. Position `#1`, index `0` in the ASL, is always the newest value.

Design point: a result pushed to a queue does not overwrite any GPR. Compressed binary ALU forms and compressed AGU loads write their result through `WriteCompressedTResult`, which always pushes to T. An ordinary destination selector `31` pushes to T and `30` pushes to U.

<!-- PTO-READER-BLOCK: arch-execution-context-rules-interactions role=rules-interactions -->
## Queue rules and interactions

`ReadTemporaryQueue` selects the T queue when `use_t_queue` is true and the U queue otherwise, returning the value at the requested relative index.

`TemporaryQueueSourceAvailable` applies the same T-or-U selection to the validity snapshots and returns the validity entry at the requested relative index.

`PushTemporaryQueue` inserts the new value at index `0`, marks that entry valid, and shifts both values and validity from indices `0` through `2` into indices `1` through `3` of the selected queue.

Design point: each entry carries a validity bit that moves with its value. Scalar operand checking uses it: reading a queue position that has never been written is an illegal source and raises `Fault_IllegalInstruction` before execution, instead of returning a stale or reset value.

<!-- PTO-READER-BLOCK: arch-execution-context-boundaries role=boundaries -->
## Boundaries

T and U are independent queues: a push to one queue does not modify the value or validity snapshot of the other queue.

A push retains the four newest entries of the selected queue. The previous index `3` entry is discarded when indices `0` through `2` shift upward.

This unit declares shared architectural storage, but it does not by itself define every transition over that storage. Memory ordering, reset, system-register behavior, and trap recovery remain in their dedicated ASL owners. For example, reset clears every queue value to zero and every validity bit to false, and trap capture saves both queues with their validity.

<!-- PTO-READER-BLOCK: arch-execution-context-example-usage role=example-usage -->
## Non-normative queue walkthrough

After reset, the T queue is unavailable at every relative index. Pushing `0x11` makes T index `0` available with value `0x11`; pushing `0x22` next makes index `0` hold `0x22` and index `1` hold the older `0x11`, with both entries available.

Pushing `0x33` to U then changes only U index `0`. The T values from the previous step remain in their T-relative positions.

<!-- PTO-READER-BLOCK: arch-execution-context-related-owners role=related-owners-navigation -->
## Related owners

- [System-register addressing](../system-registers/addressing.md) is the declared dependency and owns the reset that clears this state.
- [Scalar operands](../../scalar/model/types/operands.md) maps scalar selectors onto GPRs and queue positions.
- [Memory ordering](../memory-model/ordering.md) interprets the memory events stored here.
- [Trap context](../state/trap-context.md) provides the concrete access and trap-context behavior.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/execution-context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","surface":"arch","classification":["programming-model","execution-context"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-GPR","classification":["architecture","scalar","gpr"],"scope":"pe","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_PEGPRs"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-TEMPORARY-QUEUES","classification":["architecture","temporary-queues"],"scope":"bundle","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_TQueue","_TQueueValid","_UQueue","_UQueueValid"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-PROGRAM-CONTROL","classification":["architecture","program-control"],"scope":"core","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_PC","_BPC","_BundleActive","_BundleBodyActive","_ReturnAddress","_CommitArgument","_PredicateRegisters"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-FAULT","classification":["architecture","fault"],"scope":"core","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_LastFault","_FaultAddress"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-MEMORY","classification":["architecture","memory"],"scope":"system","owner":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","members":["_Memory","_ReservationValid","_ReservationAddress","_ReservationSize","_LastFencePredecessor","_LastFenceSuccessor","_MemoryEvents","_MemoryEventCount","_MemoryEventCaptureEnabled","_CurrentMemoryAgent","_MemoryReplayState"],"depends_on":[]}
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

// Requirement references: PTO-REQ-RESET-001, PTO-REQ-MEMORY-RC-001.

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
var _MemoryReplayState : MemoryReplayState;
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
