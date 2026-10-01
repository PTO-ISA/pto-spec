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

`ACRE` 是上下文进入请求。它通过提交活动 SYS 块来结束该块，并恢复一个先前保存的架构上下文，同时携带一个 4 位返回地址记录类型。

它既是终止标量操作，也是所在块的隐式停止，因此不需要单独的停止指令来关闭该块。

<!-- PTO-READER-BLOCK: scalar-acre-mechanism role=mechanism -->
## 指令如何放置与执行

本指令是活动 SYS 块体中的一个标量操作。标量分派器先检查是否存在活动指令束，以及其块体是否活动且块类型为 System；处于这种块之外的 SYS 形式会以 `Fault_BundleControl` 被拒绝，这发生在任何编码字段检查之前，也发生在任何架构效果之前。

随后检查编码合法性与源可用性，之后处理程序才运行。

`RRA_Type` 是一个 4 位字段。只有取值 `0` 和 `1` 被接受，架构把它们视为完全别名：它们选择同一份保存的快照和同一次完整恢复。取值 `2` 到 `15` 为保留值，会在任何恢复效果之前以 `Fault_IllegalInstruction` 被拒绝。

被接受的请求随后按三个有序步骤执行。首先在不改动任何东西的前提下校验当前环的已保存上下文。如果它不可恢复，处理程序引发 `Fault_ExecutionStateCheck` 并把已保存上下文原样写回，因此没有任何东西被消费。如果它可恢复，则提交该块；当提交失败时，已保存上下文同样保持不动，块也不退休。只有两个步骤都成功之后，已保存上下文才被恢复、被标记为不再有效，并记录请求类型。

被恢复的状态包括程序计数器、核心状态字、指令束参数与提交参数、`T` 与 `U` 队列内容及其有效性、谓词寄存器，以及取自被恢复核心状态的当前环。

<!-- PTO-READER-BLOCK: scalar-acre-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RRA_Type` 是唯一的编码操作数：4 位返回地址记录类型。编码零是已分配取值，选择两个被接受别名之一；它绝不是省略。
- 取值 `0` 和 `1` 是已分配编码；`2` 到 `15` 为保留值。
- 没有目的字段，也没有源字段，因此该指令自身既不读取也不写入任何标量寄存器或队列表项。

<!-- PTO-READER-BLOCK: scalar-acre-effects role=effects -->
## 架构效果

成功时块被退休，已保存上下文被恢复，其保存的有效性被消费，请求类型被记录，架构请求纪元加一。`TPC` 取被恢复上下文中保存的值，而不是前进 `4` 字节。

只有当已保存的上下文被标记为有效、其被恢复的指令束控制字被标记为存在且合法、被恢复的环字段与被恢复的核心状态一致，并且两个被恢复的程序计数器的低位都为零时，块才会提交。校验步骤或提交步骤任一失败都会保留已保存上下文且不进行部分恢复，因此失败的 `ACRE` 可以重复执行。

请求类型是从编码字段记录的，而不是从两个别名记录的，因此记录下来的值能区分 `0` 与 `1`，即使它们选择的恢复完全相同。

<!-- PTO-READER-BLOCK: scalar-acre-constraints role=constraints -->
## 放置与拒绝

无效的块放置首先被拒绝，以 `Fault_BundleControl` 报出，此时连编码字段都还没有被考虑。

保留的 `RRA_Type` 会在恢复效果之前引发 `Fault_IllegalInstruction`。不可恢复的已保存上下文会引发 `Fault_ExecutionStateCheck` 并保留该上下文。提交失败同样会保留该上下文。

这里的「别名」是精确的：两个被接受的请求类型恢复同一份可见快照。希望它们具有不同恢复行为的配置档必须先给它们各自不同的架构身份，因为当前规则无法区分二者。

<!-- PTO-READER-BLOCK: scalar-acre-example role=example -->
## 非规范示例

`acre rra_type` 在 `RRA_Type=0` 时一步提交该块并恢复当前环的已保存上下文，同时把 `0` 记录为请求类型。在 `RRA_Type=2` 时，该指令以 `Fault_IllegalInstruction` 被拒绝，已保存上下文保持原样。
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
