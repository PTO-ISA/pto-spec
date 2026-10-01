<!-- GENERATED FROM: asl/scalar/sys/EBREAK.asl -->
# EBREAK

**Normative ASL source:** `asl/scalar/sys/EBREAK.asl`

EBREAK raises software-breakpoint trap 50 with its 4-bit immediate as cause.

## Normative identity {#PTO-INST-SCALAR-EBREAK}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ebreak-purpose role=purpose -->
## EBREAK 的作用

`EBREAK` 引发软件断点。与分支或调用不同，它发布的是故障而不是延续：该次尝试以陷阱号 50 与故障指令地址结束，且编码立即数成为陷阱原因。

<!-- PTO-READER-BLOCK: scalar-ebreak-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_EBREAK` 选择 `ScalarHandler_SoftwareBreakpoint`（`asl/scalar/sys/EBREAK.asl:11`）。派发器解码 4 位 `imm4` 字段，将其零扩展为 5 位，并调用 `SoftwareBreakpoint`（`asl/scalar/model/dispatch/sys.asl:78`）。该辅助函数以当前指令地址和零扩展后的原因引发 `Fault_SoftwareBreakpoint`（`asl/scalar/model/sys/semantics.asl:91`）。

故障类别决定陷阱身份：`Fault_SoftwareBreakpoint` 映射到陷阱号 50（`asl/arch/memory-model/fault-precision.asl:80`）。`InstructionContractBreakpointPublishesTrapCause_EBREAK` 返回 `TRUE`（`asl/scalar/sys/EBREAK.asl:36`），因此立即数作为原因发布，而不是保存在单独的断点寄存器中。

该指令只在活动 SYS 块的块体中适用（`asl/scalar/model/sys/semantics.asl:322`）。

<!-- PTO-READER-BLOCK: scalar-ebreak-inputs-outputs role=inputs-outputs -->
## 输入与输出

`imm4` 是位于指令第 27:24 位的 4 位立即数（`asl/scalar/sys/EBREAK.asl:1`）。它的全部十六个值都已分配，`InstructionContractBreakpointImmediateWidth_EBREAK` 报告宽度为 4（`asl/scalar/sys/EBREAK.asl:30`）。

该指令不写寄存器。它的输出是架构陷阱状态：陷阱原因与故障地址。`imm4` 中的编码零是真实的零原因，不是省略的操作数。

<!-- PTO-READER-BLOCK: scalar-ebreak-effects role=effects -->
## 架构效果

该次尝试为目标环保存指令执行前上下文，把零扩展后的立即数存为陷阱原因，把故障指令地址存为陷阱参数，并把陷阱向量入口写入 `TPC`（`asl/arch/memory-model/fault-precision.asl:63`）。因此新的 `TPC` 来自陷阱向量，而不是对故障地址做递增。

设计要点：立即数在通往陷阱库的路上被零扩展两次，先在派发器处从 4 位扩到 5 位，再进入 24 位原因字段（`asl/arch/memory-model/fault-precision.asl:70`）。每个编码都保持可作为原因区分，并且不会创建并行的断点标签状态。

`EBREAK` 没有内存效果：不执行普通标量内存访问，数据内存也不改变。

<!-- PTO-READER-BLOCK: scalar-ebreak-constraints role=constraints -->
## 位置与拒绝边界

位置检查最先进行。在活动 SYS 块体之外的尝试会引发 `Fault_BundleControl`，永远到不了断点处理程序，因此该断点不会更新陷阱库。

一旦处理程序运行，断点故障本身就是该指令的效果，而不是拒绝。没有保留的立即数值需要拒绝，因为十六个值都已分配；该操作也不受环限制，因此位置正确的 `EBREAK` 总是产生陷阱号 50。

<!-- PTO-READER-BLOCK: scalar-ebreak-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在 SYS 块体内执行 `ebreak 0`。该次尝试通过位置检查，随后陷阱库中保存陷阱号 50、原因 0 以及作为参数的故障指令地址，而 `TPC` 指向陷阱向量入口。执行 `ebreak 15` 行为相同，只是在陷阱库中留下原因 15。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ebreak imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ebreak_32_4f122d1e6be3 | L32 | 32 | 0x0010102b / 0xf0ffffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ebreak_32_4f122d1e6be3 | imm4 | 4 | encoding-defined | [{"instruction_lsb":24,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ebreak_32_4f122d1e6be3 | imm4 | 4 | 0–15 | none | none | 4-bit immediate value | Encoded zero supplies numeric zero for the 4-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm4 | 4-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractOperation_EBREAK()
    => ScalarOperation
begin
    return ScalarOperation_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
EBREAK executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractHandler_EBREAK()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;

pure func InstructionContractRequiresSystemBlock_EBREAK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBreakpointImmediateWidth_EBREAK()
    => integer {4,5}
begin
    return 4;
end;

pure func InstructionContractBreakpointPublishesTrapCause_EBREAK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every 4-bit immediate value is assigned; encoded zero is a real zero cause.

## State effects

- Raise Fault_SoftwareBreakpoint and publish trap number 50.
- Zero-extend the encoded immediate into the 24-bit trap-cause field; no parallel breakpoint-tag state exists.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- After placement and decode, atomically save the pre-instruction context, trap number, zero-extended immediate cause, and faulting-PC argument before vector transfer.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- ebreak imm
