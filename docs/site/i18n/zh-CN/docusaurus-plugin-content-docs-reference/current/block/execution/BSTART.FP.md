<!-- GENERATED FROM: asl/block/execution/BSTART.FP.asl -->
# BSTART.FP

**Normative ASL source:** `asl/block/execution/BSTART.FP.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-FP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-fp-purpose role=purpose -->
## BSTART.FP 的作用

`BSTART.FP` 关闭当前活动的指令束，并把下一个指令束作为 Floating 指令束打开。它有六种编码拼写：`BSTART.FP FALL`、`BSTART.FP DIRECT, <label>`、`BSTART.FP COND, <label>`、`BSTART.FP CALL, <label>`、`BSTART.FP IND` 与 `BSTART.FP RET`。`InstructionContractBundleKind_BSTART_FP` 返回 `BundleKind_Floating`，因此该命令选择的是指令束种类与转移规则，而不是一个 Tile 操作。

只有 `DIRECT`、`COND` 与 `CALL` 携带载荷：指令第 31 至 15 位中的有符号 17 位 `simm17` 标签位移。`FALL` 把该字段固定为零，而 `IND` 与 `RET` 完全没有字段。

设计要点：`BSTART.FP` 与 `BSTART.STD` 接受同样的六种转移和同样的目标规则，二者的差别在于安装的指令束种类，即 `BundleKind_Floating`（编码 `0001`）对 `BundleKind_Standard`（编码 `0000`）。该差别在新指令束主体内可观察：`LSRGET` 标识符 2 返回的打包 BARG 控制字在其低四位中携带该种类。

<!-- PTO-READER-BLOCK: block-bstart-fp-mechanism role=mechanism -->
## 位置与机制

命令先被译码，其描述符由 `BundleOperationDescriptorLegal` 检查，转移取自形式或取自描述符的分支类型。候选目标随后由该转移决定：`FALL` 在下一个字继续；`DIRECT`、`COND` 与 `CALL` 计算 `PC + 2 * simm17`；`IND` 读取正在退役指令束的 `BARG.BPCN`；`RET` 读取架构返回地址。

只有在这些检查之后，该启动才通过 `CompleteBundleAtWithAcceptedApplicabilityRules` 提交活动的先行指令束。仅当该提交把程序计数器留在本指令处时，取到的 `BSTART.FP` 才会被安装，因此位于未选中路径上的 `BSTART.FP` 不安装任何东西。

设计要点：`IND` 与 `RET` 使用的是先行指令束仍然拥有的状态，即 `BARG.BPCN` 与返回地址，而 `start.asl` 在退役该指令束之前把两者快照到局部值中。因此提交失败的先行指令束无法破坏它自己选出的延续。

<!-- PTO-READER-BLOCK: block-bstart-fp-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `simm17` 是 `DIRECT`、`COND` 与 `CALL` 第 31 至 15 位中的有符号 17 位指令束目标位移；字节目标为 `PC + 2 * simm17`，编码零提供零位移。
- `FALL` 携带的同一字段固定为零，因此 `FALL` 的目标是顺序字。
- `IND` 与 `RET` 不携带编码字段；它们的延续来自正在退役指令束的 `BARG.BPCN` 以及返回地址。

<!-- PTO-READER-BLOCK: block-bstart-fp-effects role=effects -->
## 待处理状态与完成

成功的启动把 `BSTART.FP` 的地址记入 `BARG.BPC`，把 `BARG.BlockType` 置为 `BundleKind_Floating`，把转移存入 `BARG.TYPE`，把候选目标存入 `BARG.BPCN`，并且只对 `COND` 把 `BARG.TAKEN` 置为假。随后 header 执行在顺序字处继续。

候选目标还不是下一个程序计数器。只有当 `BSTOP` 或下一个 `BSTART` 提交本指令束，并且 `BARGSelectsBPCN` 对记录的转移成立时，`BARG.BPCN` 才成为延续。

设计要点：`CALL` 还会发布返回地址，由于该形式没有 `uimm5` 字段，返回地址就是顺序字，而调用目标留在 `BARG.BPCN` 中。两次发布属于同一个启动转换，因此适用性检查失败的 `CALL` 既不留目标，也不留返回地址。

<!-- PTO-READER-BLOCK: block-bstart-fp-constraints role=constraints -->
## 合法性与故障边界

- 恰好接受 `FALL`、`DIRECT`、`COND`、`CALL`、`IND` 与 `RET`；非零的 `FALL` 载荷、保留的分支类型以及不受支持的形式在先行指令束退役之前引发 `Fault_IllegalInstruction`。
- `IND` 在缺少活动的正在退役 Standard 或 Floating 指令束时，在本指令处引发 `Fault_BundleControl`，早于任何目标或指令束效果。
- 计算目标的最低位置位时引发 `Fault_InstructionPC`。
- 若先行指令束提交失败，旧指令束及其延续保持权威，且不安装任何 Floating 指令束。

<!-- PTO-READER-BLOCK: block-bstart-fp-example role=example -->
## 非规范示例

该演算示例是非规范的；它说明当前 owner，而不替代它。

```asm
BSTART.FP CALL, target
```

`BSTART.FP CALL, target` 关闭活动指令束，并打开一个 Floating 指令束，其候选延续为 `PC + 2 * simm17`，返回地址为 `PC + 4`。此后关闭新指令束的 `BSTART.FP RET` 会把返回地址记为自己的候选延续，而 `BSTART.FP IND` 则会从正在退役指令束的 `BARG.BPCN` 取目标，而不是从编码位移取目标。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.FP RET
BSTART.FP COND, <label>
BSTART.FP IND
BSTART.FP DIRECT, <label>
BSTART.FP FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_fp_32_0c671a644214 | L32 | 32 | 0x00007101 / 0xffffffff | [] |
| bstart_fp_32_58ad7954fb49 | L32 | 32 | 0x00003101 / 0x00007fff | [] |
| bstart_fp_32_7978795a29a1 | L32 | 32 | 0x00005101 / 0xffffffff | [] |
| bstart_fp_32_d00a708a81f0 | L32 | 32 | 0x00002101 / 0x00007fff | [] |
| bstart_fp_32_face4f238d84 | L32 | 32 | 0x00001101 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |
| bstart_fp_32_dd7bc8dd694c | L32 | 32 | 0x00004101 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_fp_32_58ad7954fb49 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_d00a708a81f0 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_face4f238d84 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_dd7bc8dd694c | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_fp_32_58ad7954fb49 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_fp_32_d00a708a81f0 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_fp_32_face4f238d84 | simm17 | 17 | 0 | none | 1–131071 | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_fp_32_dd7bc8dd694c | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_fp_32_face4f238d84.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | 17-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_fp_32_0c671a644214) ||
           (operation == CommandOperation_bstart_fp_32_58ad7954fb49) ||
           (operation == CommandOperation_bstart_fp_32_7978795a29a1) ||
           (operation == CommandOperation_bstart_fp_32_d00a708a81f0) ||
           (operation == CommandOperation_bstart_fp_32_dd7bc8dd694c) ||
           (operation == CommandOperation_bstart_fp_32_face4f238d84);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.FP retires any active predecessor block, then opens one FP block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.
COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractHandler_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_FP()
    => BundleKind
begin
    return BundleKind_Floating;
end;

pure func InstructionContractStartsBundle_BSTART_FP()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.FP FALL encodes simm17=0; nonzero values in that family are extension-reserved.

## Legality

- Exactly FALL, DIRECT, COND, CALL, IND, and RET are accepted.
- The FALL form accepts only simm17=0; every nonzero FALL payload is extension-reserved.
- Bare ICALL forms are deleted.

## State effects

- On success BPC records the BSTART address; BARG.BlockType becomes FP; BARG.TYPE records FALL, DIRECT, COND, IND, or RET; BARG.BPCN records the candidate target; and BARG.TAKEN is false only for COND until SETC resolves it.
- Header execution continues at the sequential PC. BSTOP or the next BSTART commits the candidate continuation selected by BARG.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All target, descriptor, and form checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- A nonzero FALL simm17, deleted bare ICALL encoding, reserved BrType, odd target, or unsupported form raises before predecessor retirement or new BARG effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no FP block is installed.

## Examples

- BSTART.FP FALL
- BSTART.FP DIRECT, target
- BSTART.FP COND, target
- BSTART.FP IND
- BSTART.FP RET
