<!-- GENERATED FROM: asl/scalar/model/dispatch/amo.asl -->
# AMO

**Normative ASL source:** `asl/scalar/model/dispatch/amo.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-AMO}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-purpose role=purpose-scope -->
## 用途与范围

本单元执行每个已译码的标量原子形式。`ExecuteDecodedAMOForm` 从助记符选择访问宽度和运算，读取操作数，并调用[AMO 语义](../amo/semantics.md)中的辅助函数。

| 助记符 | 辅助函数 | 宽度 |
| --- | --- | --- |
| `LR.B`、`LR.H`、`LR.W`、`LR.D` | `ExecuteDecodedLoadReserved` | 1、2、4、8 |
| `SC.B`、`SC.H`、`SC.W`、`SC.D` | `ExecuteDecodedStoreConditional` | 1、2、4、8 |
| `SWAPB` 到 `SWAPD`、`LW.*`、`LD.*` | 带结果的 RMW | 1 到 8 |
| `SW.*`、`SD.*` | 不带结果的 RMW | 4、8 |
| `CASB` 到 `CASD` 以及 `HL.CAS*` | `ExecuteDecodedCompareAndSwap` | 1 到 8 |
| `DMA` | `ExecuteScalarDMACopy64` | 64 字节 |

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-concepts role=concepts-state -->
## 概念与可见状态

内存序通过 `ScalarDecodedMemoryOrder` 由 `aq` 和 `rl` 位得出：两者都不置位为宽松，只有 `aq` 为获取，只有 `rl` 为释放，两者都置位为获取-释放。未编码某一位的形式把该位读作 0。

对于 LR、SC、RMW 和 CAS，地址来自 `ScalarDecodedAtomicAddress`，它读取一个 Reg5 寄存器，并把它连同已译码的 `far` 位传给 `AtomicAddress`；在本模型中地址保持不变。`DMA` 直接读取其两个地址。

各族的操作数角色不同：

- LR：地址在 `SrcL` 中。
- SC：数据在 `SrcL` 中，地址在 `SrcR` 中。
- RMW：地址在 `SrcL` 中，操作数在 `SrcR` 中。
- CAS：地址在 `SrcL` 中，期望值在 `SrcR` 中，期望写入值在 `SrcD` 中。
- `DMA`：源地址在 `SrcL` 中，目标地址在 `SrcR` 中。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-rules role=rules-interactions -->
## 规则与交互

每个处理函数读取其寄存器并把值传给语义辅助函数。随后，仅当 `_LastFault` 为 `Fault_None` 时才写入目标。

设计要点：所有操作数读取都发生在内存事务之前，目标写入发生在其后且仅在成功时进行。发生故障的原子操作不写任何寄存器或内存。命中保留后发生故障的 SC 仍已清除该保留（见[AMO 语义](../amo/semantics.md)）。

LR、带结果的 RMW 和 CAS 写入旧值经 `NormalizeAtomicReturn` 处理后的结果。它对字节和半字值做零扩展，对字值做符号扩展，双字值保持不变。

SC 写入状态：成功为 0，保留未命中为 1。

`SW.*` 和 `SD.*` 把 `write_result` 传为 FALSE。它们像 `LW.*` 和 `LD.*` 一样更新内存，但没有目标字段。

`DMA` 没有目标，也没有内存序位；其事件为宽松序。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-boundaries role=boundaries -->
## 架构边界

`ScalarAtomicOperationForOperation` 把 `LW`、`LD`、`SW` 和 `SD` 的后缀（ADD、AND、OR、XOR、SMIN、SMAX、UMIN、UMAX）映射为 `AtomicOperation`。任何其他运算都是 `unreachable`。

LR 形式带有 `SrcZero` 字段。LR 处理函数从不读取它。

本单元不推进 TPC，也不检查操作数合法性；两者都由顶层分派完成。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-example role=example-usage -->
## 非规范阅读示例

取 32 位字 0x2403028B。它匹配 `LR.W`（掩码 0xF000707F，匹配值 0x2000000B）。

| 字段 | 位 | 原始值 | 含义 |
| --- | --- | --- | --- |
| `RegDst` | 11:7 | 5 | GPR 5 |
| `SrcL` | 19:15 | 6 | 地址取自 GPR 6 |
| `rl` | 25 | 0 | 无释放 |
| `aq` | 26 | 1 | 获取 |
| `far` | 27 | 0 | 近地址提示 |

若 GPR 6 持有 0x100，且 0x100 处的字为 0x80000000，处理函数执行一次 4 字节的获取加载。它在 0x100 处记录保留，并把 0xFFFFFFFF80000000 写入 GPR 5，因为字结果做符号扩展。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-related role=related-owners-navigation -->
## 相关所有者

- [AMO 语义](../amo/semantics.md)拥有 LR/SC、RMW、CAS 和 DMA 事务。
- [标量译码辅助函数](decode.md)拥有 `ScalarDecodedMemoryOrder` 和 `ScalarDecodedAtomicAddress`。
- [标量内存](../agu/memory.md)拥有预检和故障。
- [内存排序](../../../arch/memory-model/ordering.md)拥有各内存序的含义。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/amo.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-AMO","surface":"scalar","classification":["model","dispatch","amo"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-AMO-SEMANTICS","PTO-SCALAR-CASB","PTO-SCALAR-CASD","PTO-SCALAR-CASH","PTO-SCALAR-CASW","PTO-SCALAR-DMA","PTO-SCALAR-HL-CASB","PTO-SCALAR-HL-CASD","PTO-SCALAR-HL-CASH","PTO-SCALAR-HL-CASW","PTO-SCALAR-LD-ADD","PTO-SCALAR-LD-AND","PTO-SCALAR-LD-OR","PTO-SCALAR-LD-SMAX","PTO-SCALAR-LD-SMIN","PTO-SCALAR-LD-UMAX","PTO-SCALAR-LD-UMIN","PTO-SCALAR-LD-XOR","PTO-SCALAR-LR-B","PTO-SCALAR-LR-D","PTO-SCALAR-LR-H","PTO-SCALAR-LR-W","PTO-SCALAR-LW-ADD","PTO-SCALAR-LW-AND","PTO-SCALAR-LW-OR","PTO-SCALAR-LW-SMAX","PTO-SCALAR-LW-SMIN","PTO-SCALAR-LW-UMAX","PTO-SCALAR-LW-UMIN","PTO-SCALAR-LW-XOR","PTO-SCALAR-SC-B","PTO-SCALAR-SC-D","PTO-SCALAR-SC-H","PTO-SCALAR-SC-W","PTO-SCALAR-SD-ADD","PTO-SCALAR-SD-AND","PTO-SCALAR-SD-OR","PTO-SCALAR-SD-SMAX","PTO-SCALAR-SD-SMIN","PTO-SCALAR-SD-UMAX","PTO-SCALAR-SD-UMIN","PTO-SCALAR-SD-XOR","PTO-SCALAR-SW-ADD","PTO-SCALAR-SW-AND","PTO-SCALAR-SW-OR","PTO-SCALAR-SW-SMAX","PTO-SCALAR-SW-SMIN","PTO-SCALAR-SW-UMAX","PTO-SCALAR-SW-UMIN","PTO-SCALAR-SW-XOR","PTO-SCALAR-SWAPB","PTO-SCALAR-SWAPD","PTO-SCALAR-SWAPH","PTO-SCALAR-SWAPW"]}
pure func ScalarAtomicOperationForOperation(operation: ScalarOperation)
        => AtomicOperation
begin
    case operation of
        when ScalarOperation_LD_ADD, ScalarOperation_LW_ADD,
             ScalarOperation_SD_ADD, ScalarOperation_SW_ADD =>
            return Atomic_ADD;
        when ScalarOperation_LD_AND, ScalarOperation_LW_AND,
             ScalarOperation_SD_AND, ScalarOperation_SW_AND =>
            return Atomic_AND;
        when ScalarOperation_LD_OR, ScalarOperation_LW_OR,
             ScalarOperation_SD_OR, ScalarOperation_SW_OR =>
            return Atomic_OR;
        when ScalarOperation_LD_XOR, ScalarOperation_LW_XOR,
             ScalarOperation_SD_XOR, ScalarOperation_SW_XOR =>
            return Atomic_XOR;
        when ScalarOperation_LD_SMIN, ScalarOperation_LW_SMIN,
             ScalarOperation_SD_SMIN, ScalarOperation_SW_SMIN =>
            return Atomic_SMIN;
        when ScalarOperation_LD_SMAX, ScalarOperation_LW_SMAX,
             ScalarOperation_SD_SMAX, ScalarOperation_SW_SMAX =>
            return Atomic_SMAX;
        when ScalarOperation_LD_UMIN, ScalarOperation_LW_UMIN,
             ScalarOperation_SD_UMIN, ScalarOperation_SW_UMIN =>
            return Atomic_UMIN;
        when ScalarOperation_LD_UMAX, ScalarOperation_LW_UMAX,
             ScalarOperation_SD_UMAX, ScalarOperation_SW_UMAX =>
            return Atomic_UMAX;
        otherwise => unreachable;
    end;
end;

func ExecuteDecodedLoadReserved(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    size_bytes: integer {1,2,4,8})
begin
    let old_value = LoadReserved(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcL),
        size_bytes, ScalarDecodedMemoryOrder(instruction, form));
    if _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            NormalizeAtomicReturn(old_value, size_bytes));
    end;
end;

func ExecuteDecodedStoreConditional(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    size_bytes: integer {1,2,4,8})
begin
    let status = StoreConditional(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcR),
        size_bytes,
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        ScalarDecodedMemoryOrder(instruction, form));
    if _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst), status);
    end;
end;

func ExecuteDecodedAtomicReadModifyWrite(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: AtomicOperation, size_bytes: integer {1,2,4,8},
    write_result: boolean)
begin
    let old_value = AtomicReadModifyWrite(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcL),
        size_bytes, operation,
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedMemoryOrder(instruction, form));
    if write_result && _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            NormalizeAtomicReturn(old_value, size_bytes));
    end;
end;

func ExecuteDecodedCompareAndSwap(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    size_bytes: integer {1,2,4,8})
begin
    let old_value = CompareAndSwap(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcL),
        size_bytes,
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcD),
        ScalarDecodedMemoryOrder(instruction, form));
    if _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            NormalizeAtomicReturn(old_value, size_bytes));
    end;
end;

func ExecuteDecodedAMOForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_DMA =>
            ExecuteScalarDMACopy64(
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR));
        when ScalarOperation_LR_B =>
            ExecuteDecodedLoadReserved(instruction, form, 1);
        when ScalarOperation_LR_H =>
            ExecuteDecodedLoadReserved(instruction, form, 2);
        when ScalarOperation_LR_W =>
            ExecuteDecodedLoadReserved(instruction, form, 4);
        when ScalarOperation_LR_D =>
            ExecuteDecodedLoadReserved(instruction, form, 8);

        when ScalarOperation_SC_B =>
            ExecuteDecodedStoreConditional(instruction, form, 1);
        when ScalarOperation_SC_H =>
            ExecuteDecodedStoreConditional(instruction, form, 2);
        when ScalarOperation_SC_W =>
            ExecuteDecodedStoreConditional(instruction, form, 4);
        when ScalarOperation_SC_D =>
            ExecuteDecodedStoreConditional(instruction, form, 8);

        when ScalarOperation_SWAPB =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 1, TRUE);
        when ScalarOperation_SWAPH =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 2, TRUE);
        when ScalarOperation_SWAPW =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 4, TRUE);
        when ScalarOperation_SWAPD =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 8, TRUE);

        when ScalarOperation_CASB, ScalarOperation_HL_CASB =>
            ExecuteDecodedCompareAndSwap(instruction, form, 1);
        when ScalarOperation_CASH, ScalarOperation_HL_CASH =>
            ExecuteDecodedCompareAndSwap(instruction, form, 2);
        when ScalarOperation_CASW, ScalarOperation_HL_CASW =>
            ExecuteDecodedCompareAndSwap(instruction, form, 4);
        when ScalarOperation_CASD, ScalarOperation_HL_CASD =>
            ExecuteDecodedCompareAndSwap(instruction, form, 8);

        when ScalarOperation_LW_ADD, ScalarOperation_LW_AND,
             ScalarOperation_LW_OR, ScalarOperation_LW_XOR,
             ScalarOperation_LW_SMIN, ScalarOperation_LW_SMAX,
             ScalarOperation_LW_UMIN, ScalarOperation_LW_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 4, TRUE);
        when ScalarOperation_LD_ADD, ScalarOperation_LD_AND,
             ScalarOperation_LD_OR, ScalarOperation_LD_XOR,
             ScalarOperation_LD_SMIN, ScalarOperation_LD_SMAX,
             ScalarOperation_LD_UMIN, ScalarOperation_LD_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 8, TRUE);
        when ScalarOperation_SW_ADD, ScalarOperation_SW_AND,
             ScalarOperation_SW_OR, ScalarOperation_SW_XOR,
             ScalarOperation_SW_SMIN, ScalarOperation_SW_SMAX,
             ScalarOperation_SW_UMIN, ScalarOperation_SW_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 4, FALSE);
        when ScalarOperation_SD_ADD, ScalarOperation_SD_AND,
             ScalarOperation_SD_OR, ScalarOperation_SD_XOR,
             ScalarOperation_SD_SMIN, ScalarOperation_SD_SMAX,
             ScalarOperation_SD_UMIN, ScalarOperation_SD_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 8, FALSE);

        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
