<!-- GENERATED FROM: asl/block/lifecycle/BSTART.asl -->
# BSTART

**Normative ASL source:** `asl/block/lifecycle/BSTART.asl`

Initializes the single BARG continuation record after any retiring block commits successfully.

## Normative identity {#PTO-INST-BLOCK-BSTART}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-purpose role=purpose -->
## BSTART 的作用

`BSTART` 是 `标准延续` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
none
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。

<!-- PTO-READER-BLOCK: block-bstart-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `simm25` 提供编码偏移或加数；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART DIRECT, <label>
```

假设前序 Block 退休和目标检查成功，`BSTART DIRECT, <label>` 会打开待处理的 `BSTART` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART DIRECT, <label>
BSTART COND, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_32_7eb93b649748 | L32 | 32 | 0x00000011 / 0x0000007f | [] |
| bstart_32_e11e678a32ac | L32 | 32 | 0x00000021 / 0x0000007f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_32_7eb93b649748 | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |
| bstart_32_e11e678a32ac | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_32_7eb93b649748 | simm25 | 25 | 0–33554431 | none | none | 25-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_32_e11e678a32ac | simm25 | 25 | 0–33554431 | none | none | 25-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm25 | 25-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/BSTART.asl -->
```asl
readonly func InstructionContractMatches_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_32_7eb93b649748) ||
           (operation == CommandOperation_bstart_32_e11e678a32ac);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/BSTART.asl -->
```asl
readonly func InstructionContractHandler_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART()
    => BundleKind
begin
    return BundleKind_Standard;
end;

pure func InstructionContractStartsBundle_BSTART()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- simm25 zero is a real zero displacement, so BARG.BPCN equals the BSTART address P.

## Legality

- The low-seven-bit 0010001 form is DIRECT only; CALL is not an alias.
- The low-seven-bit 0100001 form is COND only.

## State effects

- DIRECT installs BARG.BPC=P, BlockType=STD, BPCN=P+(SignExtend(simm25)<<1), TYPE=DIRECT, TAKEN=1.
- COND installs the same BPC/BlockType/BPCN fields with TYPE=COND and TAKEN=0; SETC.* may update TAKEN and SETC.TGT may update BPCN before commit.
- Neither form selects BPCN at decode; BSTOP or the next BSTART is the continuation boundary.

## Memory effects and ordering

### Memory effects

- Any memory effects of the retiring block complete before the new BARG is installed; BSTART itself performs no memory access.

### Ordering

- Decode and candidate-target validation precede retiring-block commit; successful commit precedes atomic publication of the new BARG.

## Exceptions

- An odd computed BARG.BPCN raises Fault_InstructionPC before changing BARG.
- A failed retiring-block commit preserves the retiring BARG and does not install the candidate BARG.

## Examples

- BSTART DIRECT, <label>
