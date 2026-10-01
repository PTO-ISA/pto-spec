<!-- GENERATED FROM: asl/scalar/sys/HL.SSRSET.asl -->
# HL.SSRSET

**Normative ASL source:** `asl/scalar/sys/HL.SSRSET.asl`

HL.SSRSET writes the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-HL-SSRSET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ssrset-purpose role=purpose -->
## HL.SSRSET 的作用

`HL.SSRSET` 是系统寄存器写入的宽地址形式。它把 Reg5 源的完整 XLEN 值存入由 24 位地址指名的系统寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_HL_SSRSET` 选择 `ScalarHandler_ExecuteSystemRegisterSet`（`asl/scalar/sys/HL.SSRSET.asl:18`），`InstructionContractSystemAddressWidth_HL_SSRSET` 把地址宽度固定为 24（`asl/scalar/sys/HL.SSRSET.asl:36`）。48 位汇编形式把地址携带为两个 12 位片段，派发器在调用之前把它们重新组合（`asl/scalar/model/dispatch/sys.asl:96`）。

该辅助函数先预检写权限，然后才读取源，因此无法存储的尝试不会消耗源（`asl/scalar/model/sys/registers.asl:160`）。

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 是来自 R0..R23、T#1..T#4 或 U#1..U#4 的 Reg5 源，`SSR_ID` 是 24 位寄存器地址（`asl/scalar/sys/HL.SSRSET.asl:1`）。没有目的地操作数。

`InstructionContractPushesTemporaryT_HL_SSRSET` 返回 `FALSE`（`asl/scalar/sys/HL.SSRSET.asl:42`），且该指令没有目的地操作数，因此不写任何临时队列。`SrcL` 中的编码零命名架构零 GPR，它是已分配的值，也是写零的合法方式。

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-effects role=effects -->
## 架构效果

成功的尝试把源值存入被寻址寄存器，并按 48 位形式的长度推进 `TPC`。当地址是 0x0000 这样的基指针寄存器时，存储落入该寄存器；当它是 `CORE_STATE` 时，存储还会用第 3:0 位更新当前访问环（`asl/scalar/model/sys/semantics.asl:63`）。

设计要点：对只读或未知地址的存储会在读取源之前出错，因此被拒绝的宽写入让源寄存器与目标寄存器都保持原样。更宽的地址字段完全不改变这一顺序。

该指令不执行普通标量内存访问。

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-constraints role=constraints -->
## 位置与拒绝边界

该次尝试必须位于活动 SYS 块体内，否则会在任何地址处理之前引发 `Fault_BundleControl`。随后写入路径在当前环对该地址缺少权限，或访问类别为未知或只读时以 `Fault_IllegalInstruction` 拒绝（`asl/scalar/model/sys/registers.asl:105`）。

设计要点：权限规则以地址的低 12 位为依据，因此低位索引低于 0x0F00 的 24 位地址仍然对每个环开放，而上下文与调试系列仍仅限 ACR0。多出的地址位并不会产生第二条特权规则。

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

`hl.ssrset SrcL, SSR_ID` 在 `SSR_ID` 为 0x0001 时把源值存入全局指针寄存器。改用 `SSR_ID` 0x0C00 会被 `Fault_IllegalInstruction` 拒绝，因为 `CYCLE` 只读，源读取从不发生。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ssrset SrcL, SSR_ID
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ssrset_48_dd25753307c2 | HL48 | 48 | 0x0000103b000e / 0x00007fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ssrset_48_dd25753307c2 | SSR_ID | 24 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |
| hl_ssrset_48_dd25753307c2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ssrset_48_dd25753307c2 | SSR_ID | 24 | 0–16777215 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |
| hl_ssrset_48_dd25753307c2 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SSR_ID | system-register identifier |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/HL.SSRSET.asl -->
```asl
readonly func InstructionContractOperation_HL_SSRSET()
    => ScalarOperation
begin
    return ScalarOperation_HL_SSRSET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
HL.SSRSET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/HL.SSRSET.asl -->
```asl
readonly func InstructionContractHandler_HL_SSRSET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSet;
end;

pure func InstructionContractRequiresSystemBlock_HL_SSRSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_HL_SSRSET()
    => bits(2)
begin
    return '01';
end;

pure func InstructionContractSystemAddressWidth_HL_SSRSET()
    => integer {5,12,24}
begin
    return 24;
end;

pure func InstructionContractPushesTemporaryT_HL_SSRSET()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.

## State effects

- Write the complete XLEN source to the selected writable system register.
- A rejected write preserves the source and target register except for ordinary trap entry.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Preflight the complete address, current-ACR permission, and writable access class before reading SrcL.
- Snapshot SrcL, perform the register write, and then advance TPC.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- hl.ssrset SrcL, SSR_ID
