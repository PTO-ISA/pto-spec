<!-- GENERATED FROM: asl/scalar/model/dispatch/sys.asl -->
# SYS

**Normative ASL source:** `asl/scalar/model/dispatch/sys.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-SYS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-purpose role=purpose-scope -->
## 用途与范围

本单元执行每个已译码的标量系统（SYS）形式。`ExecuteDecodedSYSForm` 译码每个运算的操作数，并调用[SYS 语义](../sys/semantics.md)或[系统寄存器](../sys/registers.md)中的辅助函数。

这些形式分为六组：

- 访问环请求：`ACRC` 和 `ACRE`；
- 检查与断点：`ASSERT`、`EBREAK` 和 `C.EBREAK`；
- 缓存与 TLB 维护：`BC.*`、`DC.*`、`IC.*` 和 `TLB.*`；
- 执行控制请求：`BSE`、`BWE`、`BWI` 和 `BWT`；
- 栅栏：`FENCE.D` 和 `FENCE.I`；
- 寄存器转移与提交目标：`SSRGET`、`SSRSET`、`SSRSWAP`、`HL.SSRGET`、`HL.SSRSET`、`C.SSRGET`、`LSRGET`，以及提交目标设置指令 `SETC.TGT`。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-concepts role=concepts-state -->
## 概念与可见状态

每组从特定字段取得操作数：

| 组 | 操作数 |
| --- | --- |
| `ACRC`、`ACRE` | 4 位 `RST_Type` 或 `RRA_Type` |
| `ASSERT`、带操作数的维护、控制请求、`SETC.TGT` | `SrcL` 中的 Reg5 值 |
| `IALL` 维护 | 常数 0 |
| `C.EBREAK`、`EBREAK` | 5 位 `imm5`，或零扩展的 4 位 `imm4` |
| `FENCE.D` | 4 位 `PRED_IMM` 和 `SUCC_IMM` |
| SSR 转移 | `SSR_ID` 或 `SSRID`，作为 24 位地址 |
| `LSRGET` | 12 位 `LSR_ID` |

系统寄存器地址是 24 位值。`ScalarDecodedSystemRegisterAddress` 保留原始字段的低 24 位，因此 12 位 `SSR_ID` 表示地址 0 到 0xFFF。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-rules role=rules-interactions -->
## 规则与交互

`C.SSRGET` 把值压入 T。`SSRGET` 和 `HL.SSRGET` 通过 `RegDst` 写入该值。`SSRSET` 和 `HL.SSRSET` 读取 `SrcL` 并写寄存器。`SSRSWAP` 读取 `SrcL`，写寄存器，并把旧值返回到 `RegDst`。

设计要点：每个转移辅助函数都在读取源或寄存器之前检查权限和访问类别。被拒绝的转移不写目标，也不改变寄存器。对于 `SSRSWAP`，读权限和写权限都先检查，因此被拒绝的交换不会触发读侧效果。

`ASSERT` 在操作数为零时引发 `Fault_Assert`。`EBREAK` 和 `C.EBREAK` 以标签作为原因引发 `Fault_SoftwareBreakpoint`。

设计要点：断点和失败的断言都是普通的同步故障。顶层分派看到 `_LastFault` 已设置，返回拒绝且不推进 TPC；陷阱上下文记录断点指令的 TPC。

维护和控制请求更新纪元并记录其操作数。它们不访问内存。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-boundaries role=boundaries -->
## 架构边界

大多数 SYS 形式只能在活动 System 指令束的体中运行。`ScalarOperationApplicable` 在分派之前检查这一点，因此位置错误的形式在其处理函数执行之前引发 `Fault_BundleControl`；只保留顶层分派所做的指令束体进入转换。`LSRGET` 需要任意活动的指令束体，`SETC.TGT` 需要 Standard 或 Floating 指令束。

字段合法性也在分派之前检查。例如，`ACRE` 只接受 `RRA_Type` 为 0 或 1，`C.SSRGET` 只接受 `SSRID` 为 0、1 或 16。

在 SYS 形式中，只有 `ACRE` 通过 `ScalarHandler_ArchitectureEnterRequest` 被 `ScalarHandlerWritesTPC` 列出，因此顶层分派不会把其长度加到 TPC 上。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-example role=example-usage -->
## 非规范阅读示例

取 32 位字 0x020002BB。它匹配 `SSRGET`（掩码 0x000FF07F，匹配值 0x3B）。

| 字段 | 位 | 原始值 | 含义 |
| --- | --- | --- | --- |
| `RegDst` | 11:7 | 5 | GPR 5 |
| `SSR_ID` | 31:20 | 0x020 | `CORE_STATE` |

在 System 指令束体内，处理函数调用 `ExecuteSystemRegisterGet`。地址 0x020 的低位小于 0xF00，因此每个访问环都可以读取它，其访问类别为读写。GPR 5 接收完整的 `CORE_STATE`，包括位 39:37 中的舍入模式和位 36:32 中的粘滞标志。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-related role=related-owners-navigation -->
## 相关所有者

- [SYS 语义](../sys/semantics.md)拥有栅栏、维护、请求和适用性。
- [系统寄存器](../sys/registers.md)拥有 SSR 权限、访问类别和转移。
- [标量译码辅助函数](decode.md)拥有 `ScalarDecodedSystemRegisterAddress`。
- [执行上下文](../../../arch/programming-model/execution-context.md)声明维护纪元和记录。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/sys.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-SYS","surface":"scalar","classification":["model","dispatch","sys"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-SYS-REGISTERS","PTO-SCALAR-ACRC","PTO-SCALAR-ACRE","PTO-SCALAR-ASSERT","PTO-SCALAR-BC-IALL","PTO-SCALAR-BC-IVA","PTO-SCALAR-BSE","PTO-SCALAR-BWE","PTO-SCALAR-BWI","PTO-SCALAR-BWT","PTO-SCALAR-C-EBREAK","PTO-SCALAR-C-SSRGET","PTO-SCALAR-DC-CISW","PTO-SCALAR-DC-CIVA","PTO-SCALAR-DC-CSW","PTO-SCALAR-DC-CVA","PTO-SCALAR-DC-IALL","PTO-SCALAR-DC-ISW","PTO-SCALAR-DC-IVA","PTO-SCALAR-DC-ZVA","PTO-SCALAR-EBREAK","PTO-SCALAR-FENCE-D","PTO-SCALAR-FENCE-I","PTO-SCALAR-HL-SSRGET","PTO-SCALAR-HL-SSRSET","PTO-SCALAR-IC-IALL","PTO-SCALAR-IC-IVA","PTO-SCALAR-LSRGET","PTO-SCALAR-SETC-TGT","PTO-SCALAR-SSRGET","PTO-SCALAR-SSRSET","PTO-SCALAR-SSRSWAP","PTO-SCALAR-TLB-IA","PTO-SCALAR-TLB-IALL","PTO-SCALAR-TLB-IAV","PTO-SCALAR-TLB-IV"]}
func ExecuteDecodedSYSForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_ACRC =>
            ArchitectureCloseRequest(ScalarDecodedBits4(
                instruction, form, ScalarField_RST_Type));
        when ScalarOperation_ACRE =>
            ArchitectureEnterRequest(ScalarDecodedBits4(
                instruction, form, ScalarField_RRA_Type));
        when ScalarOperation_ASSERT =>
            ArchitectureAssert(ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));

        when ScalarOperation_BC_IALL =>
            ExecuteMaintenance(Maintenance_BC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_BC_IVA =>
            ExecuteMaintenance(Maintenance_BC_IVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_IALL =>
            ExecuteMaintenance(Maintenance_DC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_DC_IVA =>
            ExecuteMaintenance(Maintenance_DC_IVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_ISW =>
            ExecuteMaintenance(Maintenance_DC_ISW, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_ZVA =>
            ExecuteMaintenance(Maintenance_DC_ZVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CVA =>
            ExecuteMaintenance(Maintenance_DC_CVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CIVA =>
            ExecuteMaintenance(Maintenance_DC_CIVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CSW =>
            ExecuteMaintenance(Maintenance_DC_CSW, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CISW =>
            ExecuteMaintenance(Maintenance_DC_CISW, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_IC_IALL =>
            ExecuteMaintenance(Maintenance_IC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_IC_IVA =>
            ExecuteMaintenance(Maintenance_IC_IVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IV =>
            ExecuteMaintenance(Maintenance_TLB_IV, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IAV =>
            ExecuteMaintenance(Maintenance_TLB_IAV, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IA =>
            ExecuteMaintenance(Maintenance_TLB_IA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IALL =>
            ExecuteMaintenance(Maintenance_TLB_IALL, Zeros{PTO_XLEN});

        when ScalarOperation_BSE =>
            ExecuteControlRequest(ExecutionControl_SendEvent,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWE =>
            ExecuteControlRequest(ExecutionControl_WaitEvent,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWI =>
            ExecuteControlRequest(ExecutionControl_WaitInterrupt,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWT =>
            ExecuteControlRequest(ExecutionControl_WaitTimeout,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));

        when ScalarOperation_C_EBREAK =>
            SoftwareBreakpoint(ScalarDecodedBits5(
                instruction, form, ScalarField_imm5));
        when ScalarOperation_EBREAK =>
            SoftwareBreakpoint(ZeroExtend{5}(ScalarDecodedBits4(
                instruction, form, ScalarField_imm4)));
        when ScalarOperation_FENCE_D =>
            FenceData(
                ScalarDecodedBits4(instruction, form, ScalarField_PRED_IMM),
                ScalarDecodedBits4(instruction, form, ScalarField_SUCC_IMM));
        when ScalarOperation_FENCE_I => FenceInstruction();

        when ScalarOperation_C_SSRGET =>
            ExecuteCompressedSystemRegisterGet(
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSRID));
        when ScalarOperation_HL_SSRGET =>
            ExecuteSystemRegisterGet(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_HL_SSRSET =>
            ExecuteSystemRegisterSet(
                ScalarDecodedSelector(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_LSRGET =>
            ExecuteLocalStateRegisterGet(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                DecodeScalarOperandRaw(
                    instruction, form, ScalarField_LSR_ID)[11:0]);
        when ScalarOperation_SSRGET =>
            ExecuteSystemRegisterGet(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SSRSET =>
            ExecuteSystemRegisterSet(
                ScalarDecodedSelector(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SSRSWAP =>
            ExecuteSystemRegisterSwap(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSelector(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SETC_TGT =>
            SetCommitTarget(ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
