<!-- GENERATED FROM: asl/block/execution/BSTART.ICALL.asl -->
# BSTART.ICALL

**Normative ASL source:** `asl/block/execution/BSTART.ICALL.asl`

Atomically retires the old block, snapshots its BARG.BPCN into a new indirect-call BARG, and writes the independent return target to ra.

## Normative identity {#PTO-INST-BLOCK-BSTART-ICALL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-icall-purpose role=purpose -->
## BSTART.ICALL 的作用

`BSTART.ICALL` 是 `ICALL` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-icall-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
BSTART.ICALL retires one active Standard or Floating block whose BARG.BPCN supplies the call target, then atomically opens a new Standard indirect-call block and writes ra.
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。 只有起始形式适用、目标检查和前序 Block 退休全部成功后，返回地址结果才会发布。

<!-- PTO-READER-BLOCK: block-bstart-icall-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `uimm5` 提供编码偏移或加数；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-icall-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-icall-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-icall-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.ICALL <rt_label>, ->ra
```

假设前序 Block 退休和目标检查成功，`BSTART.ICALL <rt_label>, ->ra` 会打开待处理的 `BSTART.ICALL` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.ICALL <rt_label>, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_icall_32_50166001 | L32 | 32 | 0x50166001 / 0xf83fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_icall_32_50166001 | uimm5 | 5 | unsigned | [{"instruction_lsb":22,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_icall_32_50166001 | uimm5 | 5 | 0–31 | none | none | unsigned return-address displacement from the embedded high halfword | Encoded zero selects P+2 as the return target. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned return-address displacement from the embedded high halfword |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.ICALL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_ICALL(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_bstart_icall_32_50166001;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.ICALL retires one active Standard or Floating block whose BARG.BPCN supplies the call target, then atomically opens a new Standard indirect-call block and writes ra.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.ICALL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_ICALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractTransfer_BSTART_ICALL()
    => BundleTransfer
begin
    return BundleTransfer_IndirectCall;
end;

pure func InstructionContractWritesReturnAddress_BSTART_ICALL()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded uimm5 zero is a real zero displacement from the embedded C.SETRET halfword.

## Legality

- This fused form is the only accepted indirect-call spelling; bare BSTART.* ICALL forms are deleted.
- The retiring block must be Standard or Floating because System BARG has no selecting BPCN.

## State effects

- Installs BARG.BPC=P, BlockType=STD, BPCN=the retiring BARG.BPCN snapshot, TYPE=ICALL, TAKEN=1, and writes return_target to ra.
- The indirect target is selected only when the new block later commits.

## Memory effects and ordering

### Memory effects

- Any memory effects of the retiring block complete before the indirect-call BARG and ra are published; BSTART.ICALL itself performs no memory access.

### Ordering

- Snapshot and validate retiring BARG.BPCN, successfully commit the retiring block, then atomically install the new STD BARG and write ra.

## Exceptions

- No active retiring Standard or Floating block raises Fault_BundleControl before target or return-address effects.
- An odd retiring BARG.BPCN raises Fault_InstructionPC before retiring-block effects.
- Decode, applicability, target, or retiring-commit failure preserves ra and the retiring BARG and installs no candidate BARG.

## Examples

- BSTART.ICALL <rt_label>, ->ra
