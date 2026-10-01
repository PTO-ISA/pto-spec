<!-- GENERATED FROM: asl/scalar/model/sys/semantics.asl -->
# Semantics

**Normative ASL source:** `asl/scalar/model/sys/semantics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-SYS-SEMANTICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-purpose role=purpose-scope -->
## 用途与范围

本单元拥有不属于按地址寄存器转移的标量系统行为。它涵盖：

- 每次指令尝试的开始以及架构时间；
- 基本系统寄存器的读写；
- 数据栅栏和指令栅栏；
- 缓存与 TLB 维护；
- 断言、软件断点和控制请求；
- 访问环关闭与进入请求；
- 决定标量运算可在何处运行的适用性规则；
- 指令束提交目标设置函数。

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-concepts role=concepts-state -->
## 概念与可见状态

架构时间是 `_SystemRegisters.cycle`。`BeginArchitecturalInstructionAttempt` 清除 `_LastFault` 和 `_FaultAddress`，并把周期计数加一。`TIME` 和 `CYCLE` 都读取该计数。

基本寄存器位于 `_SystemRegisters` 中。只有四个可写：`THREAD_PTR`、`GLOBAL_PTR`、`CORE_STATE` 和 `CORE_FEATURE_ENABLE`。写入 `CORE_STATE` 还会根据位 3:0 设置当前访问环。

维护和栅栏推进纪元计数器，而不是对缓存建模：`_DataCacheEpoch`、`_InstructionCacheEpoch`、`_BundleCacheEpoch` 和 `_TLBEpoch`。

适用性是决定某运算能否在当前指令束状态下执行的规则。`ScalarOperationApplicable` 计算它。

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-rules role=rules-interactions -->
## 规则与交互

当 System 块终止请求处于挂起状态时，`ScalarOperationApplicable` 对每个运算都返回 FALSE。否则：

- `SETC.*` 设置指令需要活动的条件指令束体，且其条件尚未设置。
- `ACRC` 以及 System 块运算（例如 `SSRGET`、`FENCE.D` 和 `DC.CVA`）需要活动的 System 指令束体。
- `SETC.TGT` 需要活动的 Standard 或 Floating 指令束；`C.SETC.TGT` 还需要目标尚未设置。
- `LSRGET` 需要任意活动的指令束体。
- 其他所有运算总是适用。

设计要点：顶层分派在进入待进入的指令束体之后、在操作数合法性检查和处理函数之前检查适用性。位于其所需指令束之外的运算在其处理函数执行之前引发 `Fault_BundleControl`，因此不产生自身的任何效果；指令束体进入转换和本次尝试的周期递增仍然保留。

`FenceData` 清除保留，记录两个 4 位掩码，记录一个栅栏事件，并在任一掩码的位 3 置位时推进指令缓存纪元。`FenceInstruction` 清除保留并推进指令缓存纪元。

`ExecuteMaintenance` 先检查特权：TLB 运算需要 ACR0。随后检查操作数。`TLB.IV` 和 `TLB.IAV` 需要规范的 48 位地址，否则引发 `Fault_DataPage`。`TLB.IA` 需要位 63:16 为零，否则引发 `Fault_IllegalInstruction`。成功时推进纪元，并记录运算和操作数。

设计要点：特权先于操作数有效性检查，且只有在未引发故障时才记录最后的运算和操作数。因此被拒绝的维护运算不改变原有记录。

`ArchitectureEnterRequest` 把请求类型 0 和 1 视为别名。它先验证保存的陷阱上下文并完成指令束，然后才恢复上下文。若某项检查失败，它保留已保存的上下文。

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-boundaries role=boundaries -->
## 架构边界

`ExecuteControlRequest` 记录请求和操作数，并推进 `_ArchitectureRequestEpoch`。ASL 注释说明，PTO v0 把 `BSE`、`BWE`、`BWI` 和 `BWT` 视为非阻塞的交接；挂起在此不增加可见状态。

按 `SystemRegister` 枚举交换的 `SwapSystemRegister` 在 ASL 树中没有调用者。已译码的 `SSRSWAP` 使用[系统寄存器](registers.md)中的 `SwapSystemRegisterAddress`。

缓存维护的操作数被记录但不被解释。本模型不描述缓存拓扑。

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-example role=example-usage -->
## 非规范阅读示例

假设当前访问环为 ACR1，且位于 System 指令束体内。

| 指令 | 操作数 | 结果 |
| --- | --- | --- |
| `DC.CVA` | 0x1234 | 数据缓存纪元推进；记录运算和操作数 |
| `TLB.IV` | 0x1234 | `Fault_IllegalInstruction`，因为 ACR1 不是 ACR0 |
| `FENCE.D` | 掩码 0x8 和 0x1 | 清除保留；指令缓存纪元推进 |
| `ASSERT` | 0 | 在当前 TPC 引发 `Fault_Assert` |

每次尝试也会把周期计数加一，包括发生故障的两次。

<!-- PTO-READER-BLOCK: scalar-model-sys-semantics-related role=related-owners-navigation -->
## 相关所有者

- [系统寄存器](registers.md)拥有 SSR 寻址和权限。
- [SYS 分派](../dispatch/sys.md)为这些辅助函数译码操作数。
- [BARG 状态](../../../block/model/state/barg.md)拥有适用性所读取的指令束状态。
- [陷阱上下文](../../../arch/state/trap-context.md)拥有陷阱保存与恢复。
- [执行上下文](../../../arch/programming-model/execution-context.md)声明纪元计数器和最后一次维护记录。
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
