<!-- GENERATED FROM: asl/scalar/model/sys/semantics.asl -->
# Semantics

**Normative ASL source:** `asl/scalar/model/sys/semantics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-SYS-SEMANTICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the scalar system behavior that is not a register transfer by address. It covers:

- the start of each instruction attempt and architectural time;
- base system-register read and write;
- data and instruction fences;
- cache and TLB maintenance;
- assertions, software breakpoints, and control requests;
- access-ring close and enter requests;
- the applicability rules that decide where a scalar operation may run;
- the bundle commit-target setters.

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-concepts role=concepts-state -->
## Concepts and visible state

Architectural time is `_SystemRegisters.cycle`. `BeginArchitecturalInstructionAttempt` clears `_LastFault` and `_FaultAddress` and adds one to the cycle count. `TIME` and `CYCLE` both read that count.

Base registers live in `_SystemRegisters`. Only four are writable: `THREAD_PTR`, `GLOBAL_PTR`, `CORE_STATE`, and `CORE_FEATURE_ENABLE`. Writing `CORE_STATE` also sets the current access ring from bits 3:0.

Maintenance and fences advance epoch counters instead of modeling caches: `_DataCacheEpoch`, `_InstructionCacheEpoch`, `_BundleCacheEpoch`, and `_TLBEpoch`.

Applicability is the rule that decides whether an operation may execute in the current bundle state. `ScalarOperationApplicable` computes it.

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-rules role=rules-interactions -->
## Rules and interactions

`ScalarOperationApplicable` returns FALSE for every operation while a System-block terminal request is pending. Otherwise:

- `SETC.*` setters need an active conditional bundle body whose condition is not yet set.
- `ACRC` and the System-block operations, such as `SSRGET`, `FENCE.D`, and `DC.CVA`, need an active System bundle body.
- `SETC.TGT` needs an active Standard or Floating bundle; `C.SETC.TGT` also needs the target unset.
- `LSRGET` needs any active bundle body.
- All other operations are always applicable.

Design point: top-level dispatch checks applicability after it enters a pending bundle body and before operand legality and the handler. An operation outside its required bundle raises `Fault_BundleControl` before its handler runs, so it has none of its own effects; the body-entry transition and the attempt's cycle increment remain.

`FenceData` clears the reservation, records the two 4-bit masks, records a fence event, and advances the instruction-cache epoch if bit 3 of either mask is set. `FenceInstruction` clears the reservation and advances the instruction-cache epoch.

`ExecuteMaintenance` first checks privilege: TLB operations need ACR0. It then checks the operand. `TLB.IV` and `TLB.IAV` need a canonical 48-bit address, or raise `Fault_DataPage`. `TLB.IA` needs bits 63:16 clear, or raises `Fault_IllegalInstruction`. On success it advances the epoch and records the operation and operand.

Design point: privilege is checked before operand validity, and the last operation and operand are recorded only when no fault was raised. A rejected maintenance operation therefore leaves the previous record unchanged.

`ArchitectureEnterRequest` accepts request types 0 and 1 as aliases. It validates the saved trap context and completes the bundle before it restores the context. If a check fails, it keeps the saved context.

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-boundaries role=boundaries -->
## Architectural boundaries

`ExecuteControlRequest` records the request and operand and advances `_ArchitectureRequestEpoch`. The ASL comment states that PTO v0 treats `BSE`, `BWE`, `BWI`, and `BWT` as a nonblocking handoff; suspension adds no visible state here.

`SwapSystemRegister`, a swap by `SystemRegister` enumeration, has no caller in the ASL tree. Decoded `SSRSWAP` uses `SwapSystemRegisterAddress` in [system registers](registers.md).

Cache maintenance operands are recorded but not interpreted. This model does not describe a cache topology.

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-example role=example-usage -->
## Non-normative reading example

Assume the current ring is ACR1 inside a System bundle body.

| Instruction | Operand | Result |
| --- | --- | --- |
| `DC.CVA` | 0x1234 | data-cache epoch advances; operation and operand recorded |
| `TLB.IV` | 0x1234 | `Fault_IllegalInstruction`, since ACR1 is not ACR0 |
| `FENCE.D` | masks 0x8 and 0x1 | reservation cleared; instruction-cache epoch advances |
| `ASSERT` | 0 | `Fault_Assert` at the current TPC |

Each attempt also adds one to the cycle count, including the two that fault.

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-related role=related-owners-navigation -->
## Related owners

- [System registers](registers.md) owns SSR addressing and permission.
- [SYS dispatch](../dispatch/sys.md) decodes the operands for these helpers.
- [BARG state](../../../block/model/state/barg.md) owns the bundle state read by applicability.
- [Trap context](../../../arch/state/trap-context.md) owns trap save and recovery.
- [Execution context](../../../arch/programming-model/execution-context.md) declares the epoch counters and the last maintenance record.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/sys/semantics.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-SYS-SEMANTICS","surface":"scalar","classification":["model","sys","semantics"],"depends_on":["PTO-SCALAR-MODEL-AMO-SEMANTICS","PTO-BLOCK-MODEL-STATE-BARG"]}
// PTO-REQ-SCALAR-SYS-001, PTO-REQ-MEMORY-RC-001: PTO base SSR access,
// architectural time, and data/instruction fences.

func ReadMonotonicTime() => Word
begin
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
    SetFaultWithCause(
        Fault_SoftwareBreakpoint,
        ReadPC(),
        ZeroExtend{24}(tag));
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

func ExecuteLocalStateRegisterGet(destination: Reg5Selector,
                                  identifier: bits(12))
begin
    if !CurrentBARGWordApplicable(identifier) then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    let value = ReadCurrentBARGWord(identifier);
    WriteScalarDestination(destination, value);
end;

func BundleTransformHint()
begin
    _BundleHintEpoch = _BundleHintEpoch + 1;
end;

func ArchitectureCloseRequest(request_type: bits(4))
begin
    if !ServiceRequestPermitted(CurrentACR(), request_type) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    _SystemBlockTerminalPending = TRUE;
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
        return;
    end;
    let target = CurrentACR();
    let recovery_context = _TrapContexts[[target]];
    if !TrapContextRecoverable(target) then
        SetFault(Fault_ExecutionStateCheck, ReadPC());
        if recovery_context.valid then
            _TrapContexts[[target]] = recovery_context;
        end;
        return;
    end;
    if !CompleteBundleAt(_BundleSequentialPC) then
        _TrapContexts[[target]] = recovery_context;
        return;
    end;
    let recovered = RecoverTrapContext(target);
    assert recovered;
    _ArchitectureRequestEpoch = _ArchitectureRequestEpoch + 1;
    _ControlRequestOperand[3:0] = request_type;
end;

readonly func IsSystemBlockScalarOperation(operation: ScalarOperation)
    => boolean
begin
    case operation of
        when ScalarOperation_ACRC, ScalarOperation_ACRE,
             ScalarOperation_ASSERT,
             ScalarOperation_BC_IALL, ScalarOperation_BC_IVA,
             ScalarOperation_BSE, ScalarOperation_BWE,
             ScalarOperation_BWI, ScalarOperation_BWT,
             ScalarOperation_C_EBREAK, ScalarOperation_C_SSRGET,
             ScalarOperation_DC_CISW, ScalarOperation_DC_CIVA,
             ScalarOperation_DC_CSW, ScalarOperation_DC_CVA,
             ScalarOperation_DC_IALL, ScalarOperation_DC_ISW,
             ScalarOperation_DC_IVA, ScalarOperation_DC_ZVA,
             ScalarOperation_EBREAK,
             ScalarOperation_FENCE_D, ScalarOperation_FENCE_I,
             ScalarOperation_HL_SSRGET, ScalarOperation_HL_SSRSET,
             ScalarOperation_IC_IALL, ScalarOperation_IC_IVA,
             ScalarOperation_SSRGET, ScalarOperation_SSRSET,
             ScalarOperation_SSRSWAP,
             ScalarOperation_TLB_IA, ScalarOperation_TLB_IALL,
             ScalarOperation_TLB_IAV, ScalarOperation_TLB_IV =>
            return TRUE;
        otherwise =>
            return FALSE;
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

readonly func BundleCommitTargetWritable() => boolean
begin
    return _BundleActive &&
           (_BARG.block_type == BundleKind_Standard ||
            _BARG.block_type == BundleKind_Floating);
end;

readonly func IsCommitConditionSetter(operation: ScalarOperation)
    => boolean
begin
    case operation of
        when ScalarOperation_C_SETC_EQ, ScalarOperation_C_SETC_NE,
             ScalarOperation_SETC_EQ, ScalarOperation_SETC_NE,
             ScalarOperation_SETC_LT, ScalarOperation_SETC_GE,
             ScalarOperation_SETC_LTU, ScalarOperation_SETC_GEU,
             ScalarOperation_SETC_EQI, ScalarOperation_SETC_NEI,
             ScalarOperation_SETC_LTI, ScalarOperation_SETC_GEI,
             ScalarOperation_SETC_LTUI, ScalarOperation_SETC_GEUI,
             ScalarOperation_SETC_AND, ScalarOperation_SETC_OR,
             ScalarOperation_SETC_ANDI, ScalarOperation_SETC_ORI,
             ScalarOperation_HL_SETC_EQI, ScalarOperation_HL_SETC_NEI,
             ScalarOperation_HL_SETC_LTI, ScalarOperation_HL_SETC_GEI,
             ScalarOperation_HL_SETC_LTUI, ScalarOperation_HL_SETC_GEUI,
             ScalarOperation_HL_SETC_ANDI, ScalarOperation_HL_SETC_ORI =>
            return TRUE;
        otherwise =>
            return FALSE;
    end;
end;

readonly func ScalarOperationApplicable(operation: ScalarOperation)
    => boolean
begin
    if _SystemBlockTerminalPending then
        return FALSE;
    end;
    if IsCommitConditionSetter(operation) then
        return _BundleActive &&
               _BundleBodyActive &&
               _BARG.transfer_type == BundleTransfer_Conditional &&
               !_BundleConditionSet;
    end;
    case operation of
        when ScalarOperation_ACRC =>
            // Operation-level applicability cannot inspect RST_Type.  Require
            // the selected block-placement policy here; the decoded handler
            // applies the request-1 Standard-bundle marker exception.
            return _BundleActive &&
                   (_BundleBodyActive && _BARG.block_type == BundleKind_System);
        when ScalarOperation_C_SETC_TGT =>
            return BundleCommitTargetWritable() &&
                   !_BundleCommitTargetSet;
        when ScalarOperation_SETC_TGT =>
            return BundleCommitTargetWritable();
        when ScalarOperation_LSRGET =>
            return _BundleActive && _BundleBodyActive;
        otherwise =>
            if IsSystemBlockScalarOperation(operation) then
                return _BundleActive &&
                       (_BundleBodyActive && _BARG.block_type == BundleKind_System);
            else
                return TRUE;
            end;
    end;
end;

func SetCommitTarget(value: Word)
begin
    if !BundleCommitTargetWritable() then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    _BARG.bpcn = value;
end;

func SetCompressedCommitTarget(value: Word)
begin
    if !BundleCommitTargetWritable() || _BundleCommitTargetSet then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    _BARG.bpcn = value;
    _BundleCommitTargetSet = TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
