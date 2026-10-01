<!-- GENERATED FROM: asl/scalar/sys/ACRC.asl -->
# ACRC

**Normative ASL source:** `asl/scalar/sys/ACRC.asl`

ACRC requests context close and marks the final scalar position of the active SYS block.

## Normative identity {#PTO-INST-SCALAR-ACRC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-acrc-purpose role=purpose -->
## ACRC 的作用

`ACRC` 是上下文关闭请求。它携带一个 4 位记录类型；当当前访问控制环允许该请求类型时，它标记活动 SYS 块的结束，并通过服务请求陷阱把控制权交给架构。

它不返回值，也不写任何目的位置。在请求被接受时，它的全部效果就是它发布的那次请求，以及它在块上设置的末位标记。

<!-- PTO-READER-BLOCK: scalar-acrc-mechanism role=mechanism -->
## 指令如何放置与执行

本指令是活动 SYS 块体中的一个标量操作。标量分派器先检查是否存在活动指令束，以及其块体是否活动且块类型为 System；处于这种块之外的 SYS 形式会以 `Fault_BundleControl` 被拒绝，这发生在任何编码字段检查之前，也发生在任何架构效果之前。

随后检查编码合法性与源可用性，之后处理程序才运行。

`RST_Type` 是一个 4 位字段，它的每个取值都是已分配编码。处理程序不直接测试编码值；它把该值交给架构的关闭请求规则，由后者询问访问控制表：当前环是否允许发出这种请求类型。

当请求被允许时，处理程序先设置块的终止标记，然后进入服务请求陷阱。陷阱保存目标环的指令执行前上下文，把请求类型记录为陷阱原因，把陷阱编号设为 `6`，把故障地址设为请求发生处，并把当前环切换为陷阱目标。请求类型 `0` 与 `1` 的区别只在于目标环。

设计要点：终止标记是在进入陷阱之前设置的，而不是之后。这正是让末位规则在陷阱之后仍然成立的原因：陷阱返回后，块仍然知道自己最后一个标量位置已被消耗，因此不会悄悄继续执行更多标量操作。

<!-- PTO-READER-BLOCK: scalar-acrc-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RST_Type` 是唯一的编码操作数：4 位返回栈记录类型。全部十六个取值都是已分配编码；编码零是真实的请求类型，不是省略。
- 没有目的字段，因此该指令绝不压入 `T` 或 `U`，也绝不写 GPR。
- 没有源字段，因此不读取任何标量寄存器或队列表项。

<!-- PTO-READER-BLOCK: scalar-acrc-effects role=effects -->
## 架构效果

在请求被允许时，发布的效果是服务请求陷阱、被记录的请求类型，以及架构请求纪元加一。当前环变为陷阱目标，`TPC` 取该环的陷阱向量入口，因此通常的 `4` 字节前进不适用。

恢复之后，块的终止标记仍然处于设置状态。只要它处于设置状态，既不是指令束停止也不是指令束启动的命令指令会以 `Fault_BundleControl` 被拒绝，标量指令也以同样方式被拒绝。只有指令束停止或其后的指令束启动才能提交该块。

如果请求未被允许，处理程序会在设置终止标记之前以 `Fault_IllegalInstruction` 故障，因此被拒绝的请求让块保持完全可用：不发布请求，纪元不前进，也不记录陷阱原因。

<!-- PTO-READER-BLOCK: scalar-acrc-constraints role=constraints -->
## 放置与拒绝

无效的块放置首先被拒绝，以 `Fault_BundleControl` 报出，此时连编码字段都还没有被考虑。活动 SYS 块体之外的 SYS 操作属于这一类。

该指令是一个终止标量位置：它必须是所在块最后一个标量操作。

决定指令本地是否接受的是权限表，它在终止标记被设置之前被查询。在根环上没有任何请求类型被允许。在环 `1` 上只允许请求类型 `0` 和 `2`。在环 `2` 到 `15` 上允许请求类型 `0`、`1` 和 `2`。其他每个四位取值在每个环上都被拒绝。因此同一个 `RST_Type` 编码在不同环上会得到不同结果：只有在根环上才是每个取值都被拒绝。

<!-- PTO-READER-BLOCK: scalar-acrc-example role=example -->
## 非规范示例

`acrc rst_type` 通过 `RST_Type` 字段指名请求。在非根环上取 `RST_Type=0` 时请求被接受：终止标记被设置，服务请求陷阱把当前环切换为陷阱目标。在根环上，同一条指令在终止标记被设置之前引发 `Fault_IllegalInstruction`，块继续执行。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
acrc rst_type
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| acrc_32_a9c0e33f9904 | L32 | 32 | 0x0000302b / 0xff0fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| acrc_32_a9c0e33f9904 | RST_Type | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| acrc_32_a9c0e33f9904 | RST_Type | 4 | 0–15 | none | none | return-stack record type | Encoded zero selects value zero of the return-stack record type. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RST_Type | return-stack record type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractOperation_ACRC()
    => ScalarOperation
begin
    return ScalarOperation_ACRC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
ACRC executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractHandler_ACRC()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureCloseRequest;
end;

pure func InstructionContractRequiresSystemBlock_ACRC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRequestWidth_ACRC()
    => integer {4}
begin
    return 4;
end;

pure func InstructionContractIsTerminalScalar_ACRC()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- All four-bit request values are encoded; manager routing and current-ACR permission determine instruction-local acceptance.

## State effects

- A permitted request publishes the service-request trap, request type, and architecture-request epoch.
- After recovery, only BSTOP or a following BSTART may commit the block; another instruction raises Illegal Block Exception before effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Preflight request routing before setting the terminal marker or entering the service-request trap.
- On permission success, set the SYS terminal marker before trap entry so recovery preserves the final-position rule.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- acrc rst_type
