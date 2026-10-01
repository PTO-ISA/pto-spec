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

`BSTART.ICALL` 是融合的间接调用。它退役当前活动的指令束，把该指令束的 `BARG.BPCN` 快照为调用目标，打开一个新的 Standard 间接调用指令束，并把一个独立的返回目标发布到 `ra`。调用目标完全没有编码在本命令中；只有返回地址是编码的。

唯一接受的拼写是 `BSTART.ICALL <rt_label>, ->ra`，一个 32 位字，在掩码 `0xf83fffff` 下匹配 `0x50166001`。该掩码固定了高位判别位与第 21 至 0 位，并让无符号 5 位 `uimm5` 显露在第 26 至 22 位。`InstructionContractTransfer_BSTART_ICALL` 返回 `BundleTransfer_IndirectCall`，`InstructionContractWritesReturnAddress_BSTART_ICALL` 返回 TRUE。

设计要点：`BSTART.STD CALL, <label>` 与 `BSTART.FP CALL, <label>` 从 `simm17` 取目标、从顺序字取返回地址。`BSTART.ICALL` 把这一分工颠倒过来：目标来自正在退役指令束的 `BARG.BPCN`，返回目标来自 `uimm5`。可观察的后果是，调用方可以调用一个关闭中的指令束仅以其自身候选延续形式知道的目的地。

<!-- PTO-READER-BLOCK: block-bstart-icall-mechanism role=mechanism -->
## 位置与机制

启动先译码该字，检查其描述符，并要求 `RetiringBundleBPCNAvailable`：指令束必须处于活动状态，且其 `BARG.BlockType` 必须是 Standard 或 Floating。否则在本指令处引发 `Fault_BundleControl`，早于任何目标或返回地址效果。在接受路径上，调用目标是正在退役的 `BARG.BPCN` 的快照，返回目标是 `P + 2 + 2 * uimm5`。

设计要点：只有当先行指令束提交后程序计数器仍停留在本指令地址时，新指令束才会被安装。提交选中了其他延续的先行指令束保留该延续并且不安装任何调用状态，`ra` 也保持它此前的值。

<!-- PTO-READER-BLOCK: block-bstart-icall-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `uimm5` 是第 26 至 22 位中的无符号 5 位返回地址位移。它是相对嵌入的高位 `C.SETRET` 半字的位移，因此编码零是真正的零，选择 `P + 2`，而 `uimm5` 为 3 时选择 `P + 8`。
- 正在退役指令束的 `BARG.BPCN` 提供调用目标。该值的最低位必须为零，且正在退役的指令束必须是 Standard 或 Floating。
- `ra` 在新指令束安装时接收返回目标；`ra` 是 GPR 10，同一个值也保留为架构返回地址。

<!-- PTO-READER-BLOCK: block-bstart-icall-effects role=effects -->
## 待处理状态与完成

成功时，新指令束把 `BSTART.ICALL` 的地址记入 `BARG.BPC`，把 `BARG.BlockType` 置为 STD，把正在退役的 `BARG.BPCN` 快照存入 `BARG.BPCN`，把 ICALL 记入 `BARG.TYPE`，把 `BARG.TAKEN` 置为 1，并把返回目标发布到 `ra`。只有当 `BSTOP` 或下一个 `BSTART` 提交新指令束时，调用目标才成为下一个 PC。

正在退役指令束的任何内存效果都在间接调用 `BARG` 与 `ra` 发布之前完成，而 `BSTART.ICALL` 本身不进行任何内存访问。若正在退役指令束的提交失败，则保留 `ra` 与该 `BARG`，且不安装任何候选 `BARG`。

设计要点：由于 `ra` 只在安装步骤中写入，任何更早的失败都会让此前的 `ra` 保持完整。因此 handler 仅凭 `ra` 就能判断调用是否已安装，同一指令的重试也从同一快照开始。

<!-- PTO-READER-BLOCK: block-bstart-icall-constraints role=constraints -->
## 合法性与故障边界

- 该融合形式是唯一被接受的间接调用拼写；裸 `BSTART.* ICALL` 形式已被删除。
- System 正在退役指令束会引发 `Fault_BundleControl`，因为 System `BARG` 没有可选择目标的 `BPCN`。
- 奇数的正在退役 `BARG.BPCN` 在退役指令束效果之前引发 `Fault_InstructionPC`。
- 译码、适用性、目标或退役提交失败都会保留 `ra` 与正在退役的 `BARG`，并且不安装任何候选 `BARG`。

<!-- PTO-READER-BLOCK: block-bstart-icall-example role=example -->
## 非规范示例

该演算示例是非规范的；它说明当前 owner，而不替代它。

```asm
BSTART.ICALL <rt_label>, ->ra
```

假设所在指令束由 `BSTART.STD DIRECT, callee` 打开，因此其 `BARG.BPCN` 保存 `callee`。关闭该指令束的 `BSTART.ICALL` 随后调用 `callee`，并在 `uimm5` 为 0 时把 `P + 2` 写入 `ra`，在 `uimm5` 为 3 时写入 `P + 8`。被调方中相应的 `BSTART.STD RET` 最终在 `ra` 保存的值处继续。
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
