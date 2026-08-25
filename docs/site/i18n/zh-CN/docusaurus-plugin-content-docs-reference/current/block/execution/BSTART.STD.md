<!-- GENERATED FROM: asl/block/execution/BSTART.STD.asl -->
# BSTART.STD

**Normative ASL source:** `asl/block/execution/BSTART.STD.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-STD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-std-purpose role=purpose -->
## BSTART.STD 的作用

`BSTART.STD` 是 `STD` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-std-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
BSTART.STD retires any active predecessor block, then opens one standard block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.
COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement.
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。

<!-- PTO-READER-BLOCK: block-bstart-std-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `simm17` 提供编码偏移或加数；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-std-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-std-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-std-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.STD COND, <label>
```

假设前序 Block 退休和目标检查成功，`BSTART.STD COND, <label>` 会打开待处理的 `BSTART.STD` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.STD COND, <label>
BSTART.STD FALL
BSTART.STD RET
BSTART.STD IND
BSTART.STD DIRECT, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_std_32_1ef99c4cedcb | L32 | 32 | 0x00003001 / 0x00007fff | [] |
| bstart_std_32_441ad677fffe | L32 | 32 | 0x00001001 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |
| bstart_std_32_816dfa76cc4a | L32 | 32 | 0x00007001 / 0xffffffff | [] |
| bstart_std_32_986b7ee2cf6a | L32 | 32 | 0x00005001 / 0xffffffff | [] |
| bstart_std_32_c1de85e06878 | L32 | 32 | 0x00002001 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_std_32_1ef99c4cedcb | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_441ad677fffe | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_c1de85e06878 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_std_32_1ef99c4cedcb | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_441ad677fffe | simm17 | 17 | 0 | none | 1–131071 | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_c1de85e06878 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_std_32_441ad677fffe.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | 17-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_std_32_1ef99c4cedcb) ||
           (operation == CommandOperation_bstart_std_32_441ad677fffe) ||
           (operation == CommandOperation_bstart_std_32_816dfa76cc4a) ||
           (operation == CommandOperation_bstart_std_32_986b7ee2cf6a) ||
           (operation == CommandOperation_bstart_std_32_c1de85e06878);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.STD retires any active predecessor block, then opens one standard block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.
COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_BSTART_STD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_STD()
    => BundleKind
begin
    return BundleKind_Standard;
end;

pure func InstructionContractStartsBundle_BSTART_STD()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.STD FALL encodes simm17=0; nonzero values in that family are extension-reserved.

## Legality

- Exactly FALL, DIRECT, COND, IND, and RET are accepted.
- The FALL form accepts only simm17=0; every nonzero FALL payload is extension-reserved.
- Bare CALL and ICALL forms are deleted.

## State effects

- On success BPC records the BSTART address; BARG.BlockType becomes STD; BARG.TYPE records FALL, DIRECT, COND, IND, or RET; BARG.BPCN records the candidate target; and BARG.TAKEN is false only for COND until SETC resolves it.
- Header execution continues at the sequential PC. BSTOP or the next BSTART commits the candidate continuation selected by BARG.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All target, descriptor, and form checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- A nonzero FALL simm17, deleted bare CALL/ICALL encoding, reserved BrType, odd target, or unsupported form raises before predecessor retirement or new BARG effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no standard block is installed.

## Examples

- BSTART.STD FALL
- BSTART.STD DIRECT, target
- BSTART.STD COND, target
- BSTART.STD IND
- BSTART.STD RET
