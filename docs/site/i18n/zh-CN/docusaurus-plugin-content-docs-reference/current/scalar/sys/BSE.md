<!-- GENERATED FROM: asl/scalar/sys/BSE.asl -->
# BSE

**Normative ASL source:** `asl/scalar/sys/BSE.asl`

BSE publishes the SendEvent nonblocking execution-control request.

## Normative identity {#PTO-INST-SCALAR-BSE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bse-purpose role=purpose -->
## BSE 的作用

`BSE` 使用快照得到的标量操作数发布所分配的非阻塞执行控制请求。

<!-- PTO-READER-BLOCK: scalar-bse-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_ExecuteControlRequest`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-bse-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 承载 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-bse-effects role=effects -->
## 架构效果

快照得到的 `SrcL` 值与 `ExecutionControl_SendEvent` 一同发布；架构请求纪元递增后，`TPC` 才前进。

该请求在可移植模型中是非阻塞的，不会创建独立的休眠、邮箱、超时计数器或待唤醒状态。

<!-- PTO-READER-BLOCK: scalar-bse-constraints role=constraints -->
## 位置与拒绝边界

每个已分配的 Reg5 选择器都遵循通用标量源规则。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-bse-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `bse SrcL` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bse SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bse_32_883b5167edbc | L32 | 32 | 0x0000002b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bse_32_883b5167edbc | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bse_32_883b5167edbc | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractOperation_BSE()
    => ScalarOperation
begin
    return ScalarOperation_BSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSE executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractHandler_BSE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;

pure func InstructionContractRequiresSystemBlock_BSE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractControlRequest_BSE()
    => ExecutionControlRequest
begin
    return ExecutionControl_SendEvent;
end;

pure func InstructionContractControlRequestIsNonblocking_BSE()
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
- Every assigned Reg5 source selector follows the common scalar-source availability rule.

## State effects

- Snapshot SrcL, publish ExecutionControl_SendEvent and the exact XLEN operand, increment the architecture-request epoch, then advance TPC.
- PTO defines no additional asleep, mailbox, timeout-counter, or pending-wake state for this nonblocking request.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- bse SrcL
