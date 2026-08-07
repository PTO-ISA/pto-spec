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

type BaseSystemRegisterState of record {
    thread_ptr: Word,
    global_ptr: Word,
    core_state: Word,
    core_id: Word,
    thread_id: Word,
    vendor: Word,
    version: Word,
    core_feature: Word,
    core_feature_enable: Word,
    tile_capacity: Word,
    blocknum: Word,
    blockid: Word,
    cycle: Word
};

var _SystemRegisters : BaseSystemRegisterState;

impdef func ResetProfileState()
begin
    // Overridden by the active concrete profile.
    _CurrentACR = 0;
    _SystemRegisters.cycle = Zeros{PTO_XLEN};
end;

readonly func CurrentACR() => AccessControlRing
begin
    return _CurrentACR;
end;

func SetCurrentACR(ring: AccessControlRing)
begin
    _CurrentACR = ring;
    _SystemRegisters.core_state[3:0] = Zeros{4} + ring;
end;

pure func TrapTargetForFault(source: AccessControlRing) => AccessControlRing
begin
    if source == 0 then return 0; else return 1; end;
end;

pure func TrapTargetForInterrupt(source: AccessControlRing) => AccessControlRing
begin
    return TrapTargetForFault(source);
end;

pure func ServiceRequestPermitted(source: AccessControlRing,
                                  request_type: bits(4)) => boolean
begin
    if source == 1 then
        return request_type == '0000' || request_type == '0010';
    elsif source >= 2 then
        return UInt(request_type) <= 2;
    else
        return FALSE;
    end;
end;

pure func ServiceRequestTarget(source: AccessControlRing,
                               request_type: bits(4)) => AccessControlRing
begin
    assert ServiceRequestPermitted(source, request_type);
    if request_type == '0001' then return 1; else return 0; end;
end;

readonly func TrapVectorEntry(target: AccessControlRing,
                              fault_address: Word) => Word
begin
    let index = ((target * 4096) + 0x0f01) as SystemRegisterFileIndex;
    let vector_base = _ExtendedSystemRegisters[[index]];
    if vector_base == Zeros{PTO_XLEN} then return fault_address;
    else return vector_base;
    end;
end;

pure func ContextRegisterIndex(ring: AccessControlRing,
                               low_index: integer {0..4095})
    => SystemRegisterFileIndex
begin
    return ((ring * 4096) + low_index) as SystemRegisterFileIndex;
end;

pure func TimerInterruptId(ring: AccessControlRing) => InterruptID
begin
    return if ring == 0 then 1 else 3;
end;

func RefreshTopPendingInterrupt(ring: AccessControlRing)
begin
    let pending = _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, 0x0f08)]];
    var found = FALSE;
    var top: InterruptID = 0;
    for interrupt_id = 0 to 63 do
        if !found && pending[interrupt_id] == '1' then
            top = interrupt_id as InterruptID;
            found = TRUE;
        end;
    end;
    _ExtendedSystemRegisters[[ContextRegisterIndex(ring, 0x0f09)]] =
        NaturalToWord(top as integer {0..262144});
end;

func SetInterruptPending(ring: AccessControlRing,
                         interrupt_id: InterruptID)
begin
    let index = ContextRegisterIndex(ring, 0x0f08);
    _ExtendedSystemRegisters[[index]][interrupt_id] = '1';
    RefreshTopPendingInterrupt(ring);
end;

func ClearInterruptPending(ring: AccessControlRing,
                           interrupt_id: InterruptID)
begin
    let index = ContextRegisterIndex(ring, 0x0f08);
    _ExtendedSystemRegisters[[index]][interrupt_id] = '0';
    RefreshTopPendingInterrupt(ring);
end;

readonly func InterruptEnabled(ring: AccessControlRing,
                               interrupt_id: InterruptID) => boolean
begin
    let interrupt_config = _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, 0x0f07)]];
    if interrupt_id == TimerInterruptId(ring) then
        return interrupt_config[1] == '1';
    else return interrupt_config[0] == '1';
    end;
end;

func RefreshTimerPending(ring: AccessControlRing)
begin
    let comparison = _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, 0x0f21)]];
    let interrupt_id = TimerInterruptId(ring);
    if comparison != Zeros{PTO_XLEN} &&
       UInt(_SystemRegisters.cycle) >= UInt(comparison) then
        SetInterruptPending(ring, interrupt_id);
    else
        ClearInterruptPending(ring, interrupt_id);
    end;
end;

func ReadInterruptPending(ring: AccessControlRing) => Word
begin
    RefreshTimerPending(ring);
    return _ExtendedSystemRegisters[[ContextRegisterIndex(ring, 0x0f08)]];
end;

func ReadTopPendingInterrupt(ring: AccessControlRing) => Word
begin
    RefreshTimerPending(ring);
    return _ExtendedSystemRegisters[[ContextRegisterIndex(ring, 0x0f09)]];
end;

func EndOfInterrupt(ring: AccessControlRing, value: Word)
begin
    if value[63:6] == Zeros{58} then
        ClearInterruptPending(ring, UInt(value[5:0]) as InterruptID);
    end;
    _ACRTrapAsynchronous[[ring]] = FALSE;
    _ACRTrapArgumentValid[[ring]] = FALSE;
end;

readonly func ReadGPR(index: GPRIndex) => Word
begin
    if index == 0 then
        return Zeros{PTO_XLEN};
    else
        return _GPR[[index]];
    end;
end;

func WriteGPR(index: GPRIndex, value: Word)
begin
    if index != 0 then
        _GPR[[index]] = value;
    end;
end;

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

readonly func ReadExecutionMask() => Word
begin
    return _ExecutionMask;
end;

func WriteExecutionMask(value: Word)
begin
    _ExecutionMask = value;
end;

readonly func ReadPredicateRegister(index: PredicateIndex) => PredicateWord
begin
    return if index == 0 then Ones{PTO_PREDICATE_WIDTH}
           else _PredicateRegisters[[index]];
end;

func WritePredicateRegister(index: PredicateIndex, value: PredicateWord)
begin
    if index != 0 then
        _PredicateRegisters[[index]] = value;
    end;
end;

pure func PredicateRegisterHasInstructionConsumer(index: PredicateIndex)
        => boolean
begin
    // PTO has no warp-vector execution surface. Machine-body B.Z and
    // B.NZ consume the distinct execution mask, not P0..P7.
    return FALSE;
end;

func SavePortableTrapContext(target: AccessControlRing,
                             source: AccessControlRing)
begin
    _TrapContexts[[target]].valid = TRUE;
    _TrapContexts[[target]].source_acr = source;
    _TrapContexts[[target]].tpc = ReadTPC();
    _TrapContexts[[target]].bpc = ReadBPC();
    _TrapContexts[[target]].core_state = _SystemRegisters.core_state;
    _TrapContexts[[target]].bundle_argument = _BundleArgument;
    _TrapContexts[[target]].commit_argument = _CommitArgument;
    _TrapContexts[[target]].bundle_active = _BundleActive;
    _TrapContexts[[target]].bundle_body_active = _BundleBodyActive;
    _TrapContexts[[target]].bundle_kind = _BundleKind;
    _TrapContexts[[target]].bundle_transfer = _BundleTransfer;
    _TrapContexts[[target]].bundle_condition = _BundleCondition;
    _TrapContexts[[target]].bundle_target = _BundleTarget;
    _TrapContexts[[target]].bundle_fallthrough = _BundleFallthrough;
    _TrapContexts[[target]].bundle_return_target = _BundleReturnTarget;
    _TrapContexts[[target]].return_address = _ReturnAddress;
    _TrapContexts[[target]].bundle_argument_kind = _BundleArgumentKind;
    _TrapContexts[[target]].bundle_body_address = _BundleBodyAddress;
    _TrapContexts[[target]].bundle_operation = _BundleOperation;
    _TrapContexts[[target]].bundle_dimensions = _BundleDimensions;
    _TrapContexts[[target]].bundle_scalar_bindings = _BundleScalarBindings;
    _TrapContexts[[target]].bundle_tile_bindings = _BundleTileBindings;
    _TrapContexts[[target]].bundle_shared_bindings = _BundleSharedBindings;
    _TrapContexts[[target]].bundle_control_attributes =
        _BundleControlAttributes;
    _TrapContexts[[target]].bundle_data_attributes = _BundleDataAttributes;
    _TrapContexts[[target]].t_queue = _TQueue;
    _TrapContexts[[target]].u_queue = _UQueue;
    _TrapContexts[[target]].execution_mask = _ExecutionMask;
    _TrapContexts[[target]].predicates = _PredicateRegisters;
end;

impdef func SaveTrapContext(target: AccessControlRing,
                            source: AccessControlRing)
begin
    SavePortableTrapContext(target, source);
end;

func RecoverPortableTrapContext(target: AccessControlRing) => boolean
begin
    if !_TrapContexts[[target]].valid then
        return FALSE;
    end;
    WriteTPC(_TrapContexts[[target]].tpc);
    WriteBPC(_TrapContexts[[target]].bpc);
    _SystemRegisters.core_state = _TrapContexts[[target]].core_state;
    _BundleArgument = _TrapContexts[[target]].bundle_argument;
    _CommitArgument = _TrapContexts[[target]].commit_argument;
    _BundleActive = _TrapContexts[[target]].bundle_active;
    _BundleBodyActive = _TrapContexts[[target]].bundle_body_active;
    _BundleKind = _TrapContexts[[target]].bundle_kind;
    _BundleTransfer = _TrapContexts[[target]].bundle_transfer;
    _BundleCondition = _TrapContexts[[target]].bundle_condition;
    _BundleTarget = _TrapContexts[[target]].bundle_target;
    _BundleFallthrough = _TrapContexts[[target]].bundle_fallthrough;
    _BundleReturnTarget = _TrapContexts[[target]].bundle_return_target;
    _ReturnAddress = _TrapContexts[[target]].return_address;
    _BundleArgumentKind = _TrapContexts[[target]].bundle_argument_kind;
    _BundleBodyAddress = _TrapContexts[[target]].bundle_body_address;
    _BundleOperation = _TrapContexts[[target]].bundle_operation;
    _BundleDimensions = _TrapContexts[[target]].bundle_dimensions;
    _BundleScalarBindings = _TrapContexts[[target]].bundle_scalar_bindings;
    _BundleTileBindings = _TrapContexts[[target]].bundle_tile_bindings;
    _BundleSharedBindings = _TrapContexts[[target]].bundle_shared_bindings;
    _BundleControlAttributes =
        _TrapContexts[[target]].bundle_control_attributes;
    _BundleDataAttributes = _TrapContexts[[target]].bundle_data_attributes;
    _TQueue = _TrapContexts[[target]].t_queue;
    _UQueue = _TrapContexts[[target]].u_queue;
    _ExecutionMask = _TrapContexts[[target]].execution_mask;
    _PredicateRegisters = _TrapContexts[[target]].predicates;
    _CurrentACR = _TrapContexts[[target]].source_acr;
    _TrapContexts[[target]].valid = FALSE;
    return TRUE;
end;

impdef func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    return RecoverPortableTrapContext(target);
end;

func SetFault(code: FaultCode, address: Word)
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
    _ACRTrapCause[[ring]] = Zeros{24};
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
        when Fault_ServiceRequest => _ACRTrapNumber[[ring]] = Zeros{6} + 6;
    end;
    _ACRTrapArgument0[[ring]] = address;
    if code != Fault_None then
        SetCurrentACR(ring);
        WriteTPC(TrapVectorEntry(ring, address));
    end;
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

readonly func IsModelAddress(address: Word) => boolean
begin
    return UInt(address) < PTO_MODEL_MEMORY_BYTES;
end;

readonly func ReadMemoryByte(address: Word) => Byte
begin
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    return _Memory[[index]];
end;

func WriteMemoryByte(address: Word, value: Byte)
begin
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    _Memory[[index]] = value;
end;
