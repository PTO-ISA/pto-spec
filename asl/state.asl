// PTO-REQ-STATE-001, PTO-REQ-PROFILE-001, PTO-REQ-MEMORY-TSO-001:
// architecture-visible scalar, memory, access-control-ring, reset-profile,
// concurrency-candidate, and fault state.

var _GPR : array [[PTO_ABSOLUTE_GPR_COUNT]] of Word;
var _TQueue : array [[PTO_TEMPORARY_QUEUE_DEPTH]] of Word;
var _UQueue : array [[PTO_TEMPORARY_QUEUE_DEPTH]] of Word;
var _PC : Word;
var _BPC : Word;
var _BlockActive : boolean;
var _BlockBodyActive : boolean;
var _ReturnAddress : Word;
var _CommitArgument : Word;
var _PredicateRegisters : array [[PTO_PREDICATE_REGISTER_COUNT]] of Word;
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
var _DataCacheEpoch : integer;
var _InstructionCacheEpoch : integer;
var _BlockCacheEpoch : integer;
var _TLBEpoch : integer;
var _BlockHintEpoch : integer;
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
var _Accumulator : AccumulatorState;

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
    if source == 2 then return 1; else return 0; end;
end;

pure func TrapTargetForInterrupt(source: AccessControlRing) => AccessControlRing
begin
    return TrapTargetForFault(source);
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

readonly func ReadPredicateRegister(index: PredicateIndex) => Word
begin
    return _PredicateRegisters[[index]];
end;

func WritePredicateRegister(index: PredicateIndex, value: Word)
begin
    _PredicateRegisters[[index]] = value;
end;

impdef func SaveTrapContext(target: AccessControlRing,
                            source: AccessControlRing)
begin
    _TrapContexts[[target]].valid = TRUE;
    _TrapContexts[[target]].source_acr = source;
    _TrapContexts[[target]].tpc = ReadTPC();
    _TrapContexts[[target]].bpc = ReadBPC();
    _TrapContexts[[target]].core_state = _SystemRegisters.core_state;
    _TrapContexts[[target]].block_argument = _CommitArgument;
    _TrapContexts[[target]].commit_argument = _CommitArgument;
    _TrapContexts[[target]].block_active = _BlockActive;
    _TrapContexts[[target]].block_body_active = _BlockBodyActive;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TrapContexts[[target]].t_queue[[index]] = _TQueue[[index]];
        _TrapContexts[[target]].u_queue[[index]] = _UQueue[[index]];
    end;
    _TrapContexts[[target]].accumulator = _Accumulator;
end;

impdef func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    if !_TrapContexts[[target]].valid then
        return FALSE;
    end;
    WriteTPC(_TrapContexts[[target]].tpc);
    WriteBPC(_TrapContexts[[target]].bpc);
    _SystemRegisters.core_state = _TrapContexts[[target]].core_state;
    _CommitArgument = _TrapContexts[[target]].commit_argument;
    _BlockActive = _TrapContexts[[target]].block_active;
    _BlockBodyActive = _TrapContexts[[target]].block_body_active;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = _TrapContexts[[target]].t_queue[[index]];
        _UQueue[[index]] = _TrapContexts[[target]].u_queue[[index]];
    end;
    _Accumulator = _TrapContexts[[target]].accumulator;
    _CurrentACR = _TrapContexts[[target]].source_acr;
    _TrapContexts[[target]].valid = FALSE;
    return TRUE;
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
        when Fault_IllegalInstruction => _ACRTrapNumber[[ring]] = Zeros{6} + 4;
        when Fault_InstructionPC => _ACRTrapNumber[[ring]] = Zeros{6} + 32;
        when Fault_InstructionPage => _ACRTrapNumber[[ring]] = Zeros{6} + 33;
        when Fault_DataAlignment => _ACRTrapNumber[[ring]] = Zeros{6} + 34;
        when Fault_DataPage => _ACRTrapNumber[[ring]] = Zeros{6} + 35;
        when Fault_SoftwareBreakpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 50;
        when Fault_Assert => _ACRTrapNumber[[ring]] = Zeros{6} + 52;
        when Fault_TileLegality => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_TileAllocation => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_BlockControl => _ACRTrapNumber[[ring]] = Zeros{6} + 6;
    end;
    _ACRTrapArgument0[[ring]] = address;
    if code != Fault_None then
        SetCurrentACR(ring);
        WriteTPC(TrapVectorEntry(ring, address));
    end;
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

func RaiseInterrupt(interrupt_id: Word, cause: bits(24))
begin
    let source_ring = CurrentACR();
    let ring = TrapTargetForInterrupt(source_ring);
    SaveTrapContext(ring, source_ring);
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _ACRTrapAsynchronous[[ring]] = TRUE;
    _ACRTrapArgumentValid[[ring]] = TRUE;
    _ACRTrapCause[[ring]] = cause;
    _ACRTrapNumber[[ring]] = Zeros{6} + 44;
    _ACRTrapArgument0[[ring]] = interrupt_id;
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
