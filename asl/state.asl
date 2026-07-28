// PTO-REQ-STATE-001, PTO-REQ-PROFILE-001: architecture-visible scalar,
// memory, privilege, reset-profile, and fault state.

var _GPR : array [[PTO_SCALAR_REGISTER_COUNT]] of Word;
var _PC : Word;
var _ReturnAddress : Word;
var _CommitArgument : Word;
var _PredicateMask : Word;
var _LastFault : FaultCode;
var _FaultAddress : Word;
var _Memory : array [[PTO_MODEL_MEMORY_BYTES]] of Byte;
var _ReservationValid : boolean;
var _ReservationAddress : Word;
var _ReservationSize : integer {1,2,4,8};
var _MemoryAcquireEpoch : integer;
var _MemoryReleaseEpoch : integer;
var _LastFencePredecessor : bits(4);
var _LastFenceSuccessor : bits(4);
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
var _TrapAsynchronous : boolean;
var _TrapArgumentValid : boolean;
var _TrapCause : bits(24);
var _TrapNumber : TrapNumber;
var _TrapArgument0 : Word;
var _CurrentPrivilege : PrivilegeLevel;

type BaseSystemRegisterState of record {
    tp: Word,
    gp: Word,
    cstate: Word,
    core_id: Word,
    vendor: Word,
    version: Word,
    core_feature: Word,
    core_feature_enable: Word,
    blocknum: Word,
    blockid: Word,
    cycle: Word
};

var _SystemRegisters : BaseSystemRegisterState;

impdef func ResetProfileState()
begin
    // Overridden by the active concrete profile.
    _CurrentPrivilege = Privilege_Machine;
    _SystemRegisters.cycle = Zeros{PTO_XLEN};
end;

readonly func CurrentPrivilege() => PrivilegeLevel
begin
    return _CurrentPrivilege;
end;

func SetCurrentPrivilege(level: PrivilegeLevel)
begin
    _CurrentPrivilege = level;
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

func WritePC(value: Word)
begin
    _PC = value;
end;

readonly func ReadPredicateMask() => Word
begin
    return _PredicateMask;
end;

func WritePredicateMask(value: Word)
begin
    _PredicateMask = value;
end;

func SetFault(code: FaultCode, address: Word)
begin
    _LastFault = code;
    _FaultAddress = address;
    _TrapAsynchronous = FALSE;
    _TrapArgumentValid = code != Fault_None;
    _TrapCause = Zeros{24};
    case code of
        when Fault_None => _TrapNumber = Zeros{6};
        when Fault_IllegalInstruction => _TrapNumber = Zeros{6} + 4;
        when Fault_InstructionPC => _TrapNumber = Zeros{6} + 32;
        when Fault_InstructionPage => _TrapNumber = Zeros{6} + 33;
        when Fault_DataAlignment => _TrapNumber = Zeros{6} + 34;
        when Fault_DataPage => _TrapNumber = Zeros{6} + 35;
        when Fault_SoftwareBreakpoint => _TrapNumber = Zeros{6} + 50;
        when Fault_Assert => _TrapNumber = Zeros{6} + 52;
        when Fault_TileLegality => _TrapNumber = Zeros{6} + 5;
    end;
    _TrapArgument0 = address;
end;

func ClearFault()
begin
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _TrapAsynchronous = FALSE;
    _TrapArgumentValid = FALSE;
    _TrapCause = Zeros{24};
    _TrapNumber = Zeros{6};
    _TrapArgument0 = Zeros{PTO_XLEN};
end;

func RaiseInterrupt(interrupt_id: Word, cause: bits(24))
begin
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _TrapAsynchronous = TRUE;
    _TrapArgumentValid = TRUE;
    _TrapCause = cause;
    _TrapNumber = Zeros{6} + 44;
    _TrapArgument0 = interrupt_id;
end;

readonly func PackTrapStatus() => Word
begin
    var value: Word = Zeros{PTO_XLEN};
    value[63] = if _TrapAsynchronous then '1' else '0';
    value[62] = if _TrapArgumentValid then '1' else '0';
    value[24 +: 24] = _TrapCause;
    value[0 +: 6] = _TrapNumber;
    return value;
end;

func UnpackTrapStatus(value: Word)
begin
    _TrapAsynchronous = value[63] == '1';
    _TrapArgumentValid = value[62] == '1';
    _TrapCause = value[24 +: 24];
    _TrapNumber = value[0 +: 6];
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
