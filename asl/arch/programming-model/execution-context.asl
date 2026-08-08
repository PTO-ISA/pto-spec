// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","surface":"arch","classification":["programming-model","execution-context"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING"]}
// PTO-REQ-STATE-001, PTO-REQ-PROFILE-001, PTO-REQ-MEMORY-TSO-001:
// architecture-visible scalar, memory, access-control-ring, reset-profile,
// concurrency-candidate, and fault state.

var _GPR : array [[PTO_ABSOLUTE_GPR_COUNT]] of Word;
var _TQueue : TemporaryQueueSnapshot;
var _UQueue : TemporaryQueueSnapshot;
var _PC : Word;
var _BPC : Word;
var _BundleActive : boolean;
var _BundleBodyActive : boolean;
var _ReturnAddress : Word;
var _CommitArgument : Word;
// The comparison architecture's bundle-body EXEC mask `p` is independent of
// the per-warp P0..P7 register file.
var _ExecutionMask : Word;
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
var _BreakpointTag : bits(5);
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

func PushTemporaryQueue(use_t_queue: boolean, value: Word)
begin
    if use_t_queue then
        _TQueue[[3]] = _TQueue[[2]];
        _TQueue[[2]] = _TQueue[[1]];
        _TQueue[[1]] = _TQueue[[0]];
        _TQueue[[0]] = value;
    else
        _UQueue[[3]] = _UQueue[[2]];
        _UQueue[[2]] = _UQueue[[1]];
        _UQueue[[1]] = _UQueue[[0]];
        _UQueue[[0]] = value;
    end;
end;
