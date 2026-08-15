<!-- GENERATED FROM: asl/arch/programming-model/execution-context.asl -->
# Execution Context

**Normative ASL source:** `asl/arch/programming-model/execution-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT}

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
