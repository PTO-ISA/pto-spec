// PTO-REQ-SCALAR-SYS-001, PTO-REQ-MEMORY-TSO-001: PTO base SSR access,
// architectural time, and data/instruction fences.

impdef func ReadMonotonicTime() => Word
begin
    // The default executable model uses the monotonically increasing cycle
    // state. Implementations may override this with a nanosecond time source.
    return _SystemRegisters.cycle;
end;

func AdvanceArchitecturalTime()
begin
    // PTO v0 defines one time unit per decoded execution attempt.
    _SystemRegisters.cycle = _SystemRegisters.cycle + 1;
end;

// PTO-REQ-EXECUTION-STATUS-001: each public decoded execution boundary starts
// a fresh result attempt without erasing the visible trap-bank record.
func BeginArchitecturalInstructionAttempt()
begin
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    AdvanceArchitecturalTime();
end;

func ReadSystemRegister(reg: SystemRegister) => Word
begin
    case reg of
        when SystemRegister_THREAD_PTR => return _SystemRegisters.thread_ptr;
        when SystemRegister_GLOBAL_PTR => return _SystemRegisters.global_ptr;
        when SystemRegister_TIME     => return ReadMonotonicTime();
        when SystemRegister_CORE_STATE => return _SystemRegisters.core_state;
        when SystemRegister_CORE_ID  => return _SystemRegisters.core_id;
        when SystemRegister_THREAD_ID => return _SystemRegisters.thread_id;
        when SystemRegister_VENDOR   => return _SystemRegisters.vendor;
        when SystemRegister_VERSION  => return _SystemRegisters.version;
        when SystemRegister_CORE_FEATURE => return _SystemRegisters.core_feature;
        when SystemRegister_CORE_FEATURE_ENABLE =>
            return _SystemRegisters.core_feature_enable;
        when SystemRegister_TILE_CAPACITY => return _SystemRegisters.tile_capacity;
        when SystemRegister_BLOCKNUM => return _SystemRegisters.blocknum;
        when SystemRegister_BLOCKID  => return _SystemRegisters.blockid;
        when SystemRegister_CYCLE    => return _SystemRegisters.cycle;
    end;
end;

func SystemRegisterIsWritable(reg: SystemRegister) => boolean
begin
    return reg == SystemRegister_THREAD_PTR ||
           reg == SystemRegister_GLOBAL_PTR ||
           reg == SystemRegister_CORE_STATE ||
           reg == SystemRegister_CORE_FEATURE_ENABLE;
end;

func WriteSystemRegister(reg: SystemRegister, value: Word)
begin
    if !SystemRegisterIsWritable(reg) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    case reg of
        when SystemRegister_THREAD_PTR => _SystemRegisters.thread_ptr = value;
        when SystemRegister_GLOBAL_PTR => _SystemRegisters.global_ptr = value;
        when SystemRegister_CORE_STATE =>
            _SystemRegisters.core_state = value;
            _CurrentACR = UInt(value[3:0]) as AccessControlRing;
        when SystemRegister_CORE_FEATURE_ENABLE =>
            _SystemRegisters.core_feature_enable = value;
        otherwise => assert FALSE;
    end;
end;

func FenceData(predecessor: bits(4), successor: bits(4))
begin
    _ReservationValid = FALSE;
    _LastFencePredecessor = predecessor;
    _LastFenceSuccessor = successor;
    if predecessor[3] == '1' || successor[3] == '1' then
        _InstructionCacheEpoch = _InstructionCacheEpoch + 1;
    end;
    RecordDataFenceEvent(predecessor, successor);
end;

func FenceInstruction()
begin
    _ReservationValid = FALSE;
    // The executable byte-array model has coherent instruction/data storage.
    // The epoch makes the architectural visibility point explicit.
    _InstructionCacheEpoch = _InstructionCacheEpoch + 1;
end;

func SoftwareBreakpoint(tag: bits(5))
begin
    _BreakpointTag = tag;
    SetFault(Fault_SoftwareBreakpoint, ReadPC());
end;

func SwapSystemRegister(reg: SystemRegister, value: Word) => Word
begin
    let old_value = ReadSystemRegister(reg);
    if SystemRegisterIsWritable(reg) then WriteSystemRegister(reg, value);
    else SetFault(Fault_IllegalInstruction, ReadPC());
    end;
    return old_value;
end;

pure func IsCanonicalAddress48(address: Word) => boolean
begin
    if address[47] == '0' then return address[63:48] == Zeros{16};
    else return address[63:48] == Ones{16};
    end;
end;

pure func MaintenanceAccessPermitted(operation: MaintenanceOperation,
                                     ring: AccessControlRing) => boolean
begin
    // Cache maintenance is a local hint in PTO v0. Translation maintenance is
    // manager state and is therefore restricted to the root access ring.
    case operation of
        when Maintenance_TLB_IV, Maintenance_TLB_IAV,
             Maintenance_TLB_IA, Maintenance_TLB_IALL => return ring == 0;
        otherwise => return TRUE;
    end;
end;

func ExecuteMaintenance(operation: MaintenanceOperation, operand: Word)
begin
    if !MaintenanceAccessPermitted(operation, CurrentACR()) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    case operation of
        when Maintenance_DC_IALL, Maintenance_DC_IVA, Maintenance_DC_ISW,
             Maintenance_DC_ZVA, Maintenance_DC_CVA, Maintenance_DC_CIVA,
             Maintenance_DC_CSW, Maintenance_DC_CISW =>
            _DataCacheEpoch = _DataCacheEpoch + 1;
        when Maintenance_IC_IALL, Maintenance_IC_IVA =>
            _InstructionCacheEpoch = _InstructionCacheEpoch + 1;
        when Maintenance_BC_IALL, Maintenance_BC_IVA =>
            _BundleCacheEpoch = _BundleCacheEpoch + 1;
        when Maintenance_TLB_IV, Maintenance_TLB_IAV =>
            if !IsCanonicalAddress48(operand) then
                SetFault(Fault_DataPage, operand);
            else
                _TLBEpoch = _TLBEpoch + 1;
            end;
        when Maintenance_TLB_IA =>
            if operand[63:16] != Zeros{48} then
                SetFault(Fault_IllegalInstruction, ReadPC());
            else
                _TLBEpoch = _TLBEpoch + 1;
            end;
        when Maintenance_TLB_IALL => _TLBEpoch = _TLBEpoch + 1;
    end;
    if _LastFault == Fault_None then
        // Epochs are the executable PTO-v0 completion effect; retaining the
        // exact operation and operand makes scope-token handling auditable.
        _LastMaintenanceOperation = operation;
        _LastMaintenanceOperand = operand;
    end;
end;

func ArchitectureAssert(value: Word)
begin
    if IsZero(value) then SetFault(Fault_Assert, ReadPC()); end;
end;

func BundleTransformHint()
begin
    _BundleHintEpoch = _BundleHintEpoch + 1;
end;

func ArchitectureCloseRequest(request_type: bits(4))
begin
    if RaiseServiceRequest(request_type) then
        _ArchitectureRequestEpoch = _ArchitectureRequestEpoch + 1;
        _ControlRequestOperand[3:0] = request_type;
    end;
end;

func ArchitectureEnterRequest(request_type: bits(4))
begin
    // Request types 0 and 1 are architectural aliases in PTO v0. Both restore
    // the same complete visible snapshot; a future profile must use a distinct
    // identity before assigning different recovery behavior.
    if request_type != '0000' && request_type != '0001' then
        SetFault(Fault_IllegalInstruction, ReadPC());
    else
        let recovered = RecoverTrapContext(CurrentACR());
        if !recovered then
            SetFault(Fault_ExecutionStateCheck, ReadPC());
        else
            _ArchitectureRequestEpoch = _ArchitectureRequestEpoch + 1;
            _ControlRequestOperand[3:0] = request_type;
        end;
    end;
end;

func ExecuteControlRequest(request: ExecutionControlRequest, operand: Word)
begin
    // PTO v0 exposes a nonblocking scheduling handoff. BSE/BWE/BWI/BWT retire
    // after publishing the exact request and operand; suspension and wakeup do
    // not add architecture-visible state in this reference profile.
    _LastControlRequest = request;
    _ControlRequestOperand = operand;
    _ArchitectureRequestEpoch = _ArchitectureRequestEpoch + 1;
end;

func SetCommitTarget(value: Word)
begin
    _CommitArgument = value;
end;
