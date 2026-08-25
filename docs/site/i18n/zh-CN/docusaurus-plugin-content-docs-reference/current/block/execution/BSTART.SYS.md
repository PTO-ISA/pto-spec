<!-- GENERATED FROM: asl/block/execution/BSTART.SYS.asl -->
# BSTART.SYS

**Normative ASL source:** `asl/block/execution/BSTART.SYS.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-sys-purpose role=purpose -->
## BSTART.SYS 的作用

`BSTART.SYS` 是 `SYS` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-sys-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
BSTART.SYS retires any active predecessor block, then opens one system block whose header commands execute sequentially until BSTOP or the next BSTART.
SYS has no candidate transfer: BPCN, TYPE, and TAKEN are inapplicable and cannot select the next PC.
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。

<!-- PTO-READER-BLOCK: block-bstart-sys-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `simm17` 提供具名选择器或属性字段；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-sys-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-sys-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-sys-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.SYS FALL
```

假设前序 Block 退休和目标检查成功，`BSTART.SYS FALL` 会打开待处理的 `BSTART.SYS` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.SYS FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | L32 | 32 | 0x00001081 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_sys_32_762d9d84a6d8 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_sys_32_762d9d84a6d8 | simm17 | 17 | 0 | none | 1–131071 | fixed-zero fallthrough payload; nonzero values are extension-reserved | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_sys_32_762d9d84a6d8.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | fixed-zero fallthrough payload; nonzero values are extension-reserved |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_sys_32_762d9d84a6d8);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SYS retires any active predecessor block, then opens one system block whose header commands execute sequentially until BSTOP or the next BSTART.
SYS has no candidate transfer: BPCN, TYPE, and TAKEN are inapplicable and cannot select the next PC.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.SYS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_SYS()
    => BundleKind
begin
    return BundleKind_System;
end;

pure func InstructionContractStartsBundle_BSTART_SYS()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The encoded simm17 field is fixed to zero; nonzero values are extension-reserved.

## Legality

- Only simm17=0 is accepted; every nonzero payload is extension-reserved.

## State effects

- On success BPC records the BSTART address and BARG.BlockType becomes SYS. BPCN, TYPE, and TAKEN are inapplicable and are canonicalized to non-selecting values.
- Header execution and the eventual block continuation are sequential.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The fixed-zero payload and form legality are checked before predecessor retirement. New SYS BARG state is installed only after successful retirement.

## Exceptions

- Any nonzero simm17 in the SYS FALL family is extension-reserved and raises before predecessor retirement or new BARG effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no system block is installed.

## Examples

- BSTART.SYS FALL
