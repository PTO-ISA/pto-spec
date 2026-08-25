<!-- GENERATED FROM: asl/scalar/sys/ACRE.asl -->
# ACRE

**Normative ASL source:** `asl/scalar/sys/ACRE.asl`

ACRE atomically commits the active SYS block and recovers one validated architecture context.

## Normative identity {#PTO-INST-SCALAR-ACRE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-acre-purpose role=purpose -->
## ACRE 的作用

`ACRE` 提交活动 SYS 块，并原子恢复一个已验证的架构上下文。

<!-- PTO-READER-BLOCK: scalar-acre-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_ArchitectureEnterRequest`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-acre-inputs-outputs role=inputs-outputs -->
## 输入与输出

`RRA_Type` 承载返回地址记录类型。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-acre-effects role=effects -->
## 架构效果

完整的已保存上下文先在不修改状态的情况下验证；活动 SYS 块提交后，恢复再原子消费并还原该上下文。

验证或块提交失败时，已保存上下文保持有效，也不会暴露部分恢复。

<!-- PTO-READER-BLOCK: scalar-acre-constraints role=constraints -->
## 位置与拒绝边界

请求值 `0` 与 `1` 是别名；值 `2` 到 `15` 为保留值。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-acre-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `acre rra_type` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
acre rra_type
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| acre_32_54b80944d32d | L32 | 32 | 0x0100302b / 0xff0fffff | [{"field":"RRA_Type","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| acre_32_54b80944d32d | RRA_Type | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| acre_32_54b80944d32d | RRA_Type | 4 | 0–1 | none | 2–15 | return-address record type | Encoded zero selects value zero of the return-address record type. |

- `acre_32_54b80944d32d.RRA_Type` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RRA_Type | return-address record type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ACRE.asl -->
```asl
readonly func InstructionContractOperation_ACRE()
    => ScalarOperation
begin
    return ScalarOperation_ACRE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
ACRE executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ACRE.asl -->
```asl
readonly func InstructionContractHandler_ACRE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureEnterRequest;
end;

pure func InstructionContractRequiresSystemBlock_ACRE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRequestTypeLegal_ACRE(
    request_type: bits(4)) => boolean
begin
    return request_type == '0000' || request_type == '0001';
end;

pure func InstructionContractIsImplicitBlockStop_ACRE()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Request values 0 and 1 are exact aliases; values 2 through 15 are reserved.
- ACRE is the implicit stop and terminating scalar instruction of the active SYS block.

## State effects

- On success, retire the SYS block, restore the complete validated context, consume its validity, record the request type, and increment the request epoch.
- Failed validation or commit preserves the saved context and performs no partial recovery.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Validate the complete recovery context without mutation before committing the current SYS block.
- Commit the block successfully, then consume and restore the saved context atomically.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- acre rra_type
