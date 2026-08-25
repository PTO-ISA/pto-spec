<!-- GENERATED FROM: asl/block/execution/BSTART.CALL.asl -->
# BSTART.CALL

**Normative ASL source:** `asl/block/execution/BSTART.CALL.asl`

Atomically retires the old block, installs a direct-call BARG, and writes the independent return target to ra.

## Normative identity {#PTO-INST-BLOCK-BSTART-CALL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-call-purpose role=purpose -->
## BSTART.CALL 的作用

`BSTART.CALL` 是 `CALL` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-call-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
none
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。 只有起始形式适用、目标检查和前序 Block 退休全部成功后，返回地址结果才会发布。

<!-- PTO-READER-BLOCK: block-bstart-call-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `simm12` 提供编码偏移或加数；其确切分配域仍以下方生成契约为准。
- `uimm5` 提供编码偏移或加数；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-call-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-call-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-call-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.CALL <br_label>, <rt_label>, ->ra
```

假设前序 Block 退休和目标检查成功，`BSTART.CALL <br_label>, <rt_label>, ->ra` 会打开待处理的 `BSTART.CALL` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.CALL <br_label>, <rt_label>, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_call_32_9404418d1ae5 | L32 | 32 | 0x50160002 / 0xf83f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_call_32_9404418d1ae5 | simm12 | 12 | signed | [{"instruction_lsb":4,"value_lsb":0,"width":12}] |
| bstart_call_32_9404418d1ae5 | uimm5 | 5 | unsigned | [{"instruction_lsb":22,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_call_32_9404418d1ae5 | simm12 | 12 | 0–4095 | none | none | 12-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_call_32_9404418d1ae5 | uimm5 | 5 | 0–31 | none | none | unsigned return-address displacement | Encoded zero supplies a zero displacement or zero immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm12 | 12-bit signed bundle target displacement |
| uimm5 | unsigned return-address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.CALL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_CALL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_call_32_9404418d1ae5);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.CALL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_CALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractTransfer_BSTART_CALL()
    => BundleTransfer
begin
    return BundleTransfer_Call;
end;

pure func InstructionContractWritesReturnAddress_BSTART_CALL()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- simm12 and uimm5 are both present; encoded zero is a real zero displacement for that field.

## Legality

- All bit patterns not excluded by the form decode are assigned by this instruction contract.

## State effects

- Installs BARG.BPC=P, BlockType=STD, BPCN=call_target, TYPE=DIRECT, TAKEN=1, and writes return_target to ra.
- The call target is selected only when the new block later commits.

## Memory effects and ordering

### Memory effects

- Any memory effects of the retiring block complete before the call BARG and ra are published; BSTART.CALL itself performs no memory access.

### Ordering

- Validate both targets, successfully commit the retiring block, then atomically install the new STD BARG and write ra.

## Exceptions

- An odd call target raises Fault_InstructionPC before retiring-block effects.
- Decode, applicability, target, or retiring-commit failure preserves ra and the retiring BARG and installs no candidate BARG.

## Examples

- BSTART.CALL <br_label>, <rt_label>, ->ra
