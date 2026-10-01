<!-- GENERATED FROM: asl/scalar/sys/C.EBREAK.asl -->
# C.EBREAK

**Normative ASL source:** `asl/scalar/sys/C.EBREAK.asl`

C.EBREAK raises software-breakpoint trap 50 with its 5-bit immediate as cause.

## Normative identity {#PTO-INST-SCALAR-C-EBREAK}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-ebreak-purpose role=purpose -->
## C.EBREAK 的作用

`C.EBREAK` 引发软件断点陷阱。陷阱编号是 `50`，编码立即数成为陷阱原因。

它是压缩形式的软件断点：原因随指令本身一起传递，而不是放在寄存器里。

<!-- PTO-READER-BLOCK: scalar-c-ebreak-mechanism role=mechanism -->
## 指令如何放置与执行

本指令是活动 SYS 块体中的一个标量操作。标量分派器先检查是否存在活动指令束，以及其块体是否活动且块类型为 System；处于这种块之外的 SYS 形式会以 `Fault_BundleControl` 被拒绝，这发生在任何编码字段检查之前，也发生在任何架构效果之前。

随后检查编码合法性与源可用性，之后处理程序才运行。

处理程序取出 5 位立即数字段，把它零扩展到 24 位陷阱原因字段，并在请求发生处引发 `Fault_SoftwareBreakpoint`。陷阱上下文在向量转移之前被保存，因此指令执行前状态、陷阱编号、零扩展后的原因以及故障地址参数被一起记录。

设计要点：原因是零扩展而不是符号扩展的，并且不写任何断点标签寄存器。这使立即数成为一个普通的无符号原因值，陷阱处理程序无需知道编码宽度即可比较；同时它把断点身份完全保留在陷阱记录内部。

<!-- PTO-READER-BLOCK: scalar-c-ebreak-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `imm5` 是唯一的编码操作数：一个 5 位立即数值。
- 每个 5 位取值都是已分配编码，因此编码零是真实的零原因，不是被省略的操作数。
- 没有目的字段，因此该指令绝不写 GPR，也绝不压入 `T` 或 `U`；也没有源字段，因此不读取任何寄存器或队列表项。

<!-- PTO-READER-BLOCK: scalar-c-ebreak-effects role=effects -->
## 架构效果

该指令引发 `Fault_SoftwareBreakpoint` 并发布陷阱编号 `50`。陷阱原因字段收到零扩展后的立即数，因此 `imm5=0` 产生原因 `0`，`imm5=31` 产生原因 `31`。

`TPC` 不按该压缩形式通常的 `2` 字节步进前进：陷阱把请求发生处记录为故障地址，控制权经陷阱向量转移。该指令本身不改变任何标量寄存器、队列表项或内存位置。

<!-- PTO-READER-BLOCK: scalar-c-ebreak-constraints role=constraints -->
## 放置与拒绝

无效的块放置首先被拒绝，以 `Fault_BundleControl` 报出，此时连编码字段都还没有被考虑。

没有任何 `imm5` 取值是保留的，因此原因字段绝不可能是拒绝的原因。没有需要校验的源选择器，也没有需要校验的目的位置。

由于立即数被零扩展进 `5` 位断点标签，软件断点能产生的原因最大是 `31`。

<!-- PTO-READER-BLOCK: scalar-c-ebreak-example role=example -->
## 非规范示例

`c.break imm` 在 `imm5=7` 时引发编号为 `50`、原因为 `7` 的软件断点陷阱。在 `imm5=0` 时引发同一个陷阱但原因为 `0`；零原因是真实的编码请求，绝不会被当作缺失的操作数。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.break imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_ebreak_16_7f9c245fa13c | C16 | 16 | 0xc02c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_ebreak_16_7f9c245fa13c | imm5 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_ebreak_16_7f9c245fa13c | imm5 | 5 | 0–31 | none | none | 5-bit immediate value | Encoded zero supplies numeric zero for the 5-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm5 | 5-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/C.EBREAK.asl -->
```asl
readonly func InstructionContractOperation_C_EBREAK()
    => ScalarOperation
begin
    return ScalarOperation_C_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
C.EBREAK executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/C.EBREAK.asl -->
```asl
readonly func InstructionContractHandler_C_EBREAK()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;

pure func InstructionContractRequiresSystemBlock_C_EBREAK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBreakpointImmediateWidth_C_EBREAK()
    => integer {4,5}
begin
    return 5;
end;

pure func InstructionContractBreakpointPublishesTrapCause_C_EBREAK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every 5-bit immediate value is assigned; encoded zero is a real zero cause.

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

- c.break imm
