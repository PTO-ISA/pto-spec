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

func ExecuteMaintenance(operation: MaintenanceOperation, operand: Word)
begin
    case operation of
        when Maintenance_DC_IALL, Maintenance_DC_IVA, Maintenance_DC_ISW,
             Maintenance_DC_ZVA, Maintenance_DC_CVA, Maintenance_DC_CIVA,
             Maintenance_DC_CSW, Maintenance_DC_CISW =>
            _DataCacheEpoch = _DataCacheEpoch + 1;
        when Maintenance_IC_IALL, Maintenance_IC_IVA =>
            _InstructionCacheEpoch = _InstructionCacheEpoch + 1;
        when Maintenance_BC_IALL, Maintenance_BC_IVA =>
            _BlockCacheEpoch = _BlockCacheEpoch + 1;
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
end;

func ArchitectureAssert(value: Word)
begin
    if IsZero(value) then SetFault(Fault_Assert, ReadPC()); end;
end;

func BlockTransformHint()
begin
    _BlockHintEpoch = _BlockHintEpoch + 1;
end;

func ArchitectureCloseRequest(request_type: bits(4))
begin
    _ArchitectureRequestEpoch = _ArchitectureRequestEpoch + 1;
    _ControlRequestOperand[3:0] = request_type;
end;

func ArchitectureEnterRequest(request_type: bits(4))
begin
    if request_type != '0000' && request_type != '0001' then
        SetFault(Fault_IllegalInstruction, ReadPC());
    else
        let recovered = RecoverTrapContext(CurrentACR());
        _ArchitectureRequestEpoch = _ArchitectureRequestEpoch + 1;
        _ControlRequestOperand[3:0] = request_type;
    end;
end;

func ExecuteControlRequest(request: ExecutionControlRequest, operand: Word)
begin
    _LastControlRequest = request;
    _ControlRequestOperand = operand;
    _ArchitectureRequestEpoch = _ArchitectureRequestEpoch + 1;
end;

func SetCommitTarget(value: Word)
begin
    _CommitArgument = value;
end;
