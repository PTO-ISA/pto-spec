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

`EBREAK` 使用编码立即数原因触发架构软件断点陷阱。

<!-- PTO-READER-BLOCK: scalar-ebreak-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_SoftwareBreakpoint`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-ebreak-inputs-outputs role=inputs-outputs -->
## 输入与输出

`imm4` 承载4 位立即数。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-ebreak-effects role=effects -->
## 架构效果

该操作触发 `Fault_SoftwareBreakpoint`、发布陷阱编号 `50`，并把 4 位立即数零扩展到 24 位原因字段。

转移到陷阱向量之前，陷阱进入会原子保存指令执行前上下文和故障 PC 参数。

<!-- PTO-READER-BLOCK: scalar-ebreak-constraints role=constraints -->
## 位置与拒绝边界

全部 `16` 个立即数编码都已分配，其中零也是实际原因值。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-ebreak-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `ebreak imm` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
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
