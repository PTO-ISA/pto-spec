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

`ACRC` 请求关闭架构上下文，并把活动 SYS 块标为终结。

<!-- PTO-READER-BLOCK: scalar-acrc-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_ArchitectureCloseRequest`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-acrc-inputs-outputs role=inputs-outputs -->
## 输入与输出

`RST_Type` 承载返回栈记录类型。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-acrc-effects role=effects -->
## 架构效果

获准的关闭请求会发布服务请求陷阱和请求类型、递增请求纪元，并在进入陷阱前把 SYS 块标为终结。

恢复后只有 `BSTOP` 或后续 `BSTART` 可以提交；其他指令会在产生效果前被拒绝。

<!-- PTO-READER-BLOCK: scalar-acrc-constraints role=constraints -->
## 位置与拒绝边界

改变终结标记之前，必须先确认路由和当前 ACR 权限。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-acrc-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `acrc rst_type` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
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
