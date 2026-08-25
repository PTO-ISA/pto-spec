<!-- GENERATED FROM: asl/block/encoding/C.BSTART.asl -->
# C.BSTART

**Normative ASL source:** `asl/block/encoding/C.BSTART.asl`

Starts a compressed standard block with a PC-relative direct or conditional candidate target.

## Normative identity {#PTO-INST-BLOCK-C-BSTART}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-purpose role=purpose -->
## C.BSTART 的作用

`C.BSTART` 打开一个活动 Block 描述符；Block 体在完成前提供所需属性与绑定。

<!-- PTO-READER-BLOCK: block-c-bstart-mechanism role=mechanism -->
## 放置与执行机制

`C.BSTART` 必须位于所属 Block 的起始位置。后续属性、维度与绑定会累积到活动描述符中，直到 `BSTOP` 或下一条已接受的 `BSTART` 完成边界。

已接受载体使用 `C16` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

完成时，只有全部模式与状态预检成功，描述符才会执行所选 Block 操作。

<!-- PTO-READER-BLOCK: block-c-bstart-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`simm12` — 12 位有符号束目标位移。
- 活动前驱成功提交后，该载体打开一个 Standard Block；其头部执行到 `BSTOP` 或下一条 `BSTART` 完成边界。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-c-bstart-effects role=effects -->
## 状态效果与顺序

启动 Block 会记录所选载体，并把操作执行推迟到完成边界。

完成全部预检与计算后，所有启用输出按归属单元规定的原子组发布；除非契约明确消费，成功执行后的数学源仍保持可用。

<!-- PTO-READER-BLOCK: block-c-bstart-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

当前归属单元通过 `Fault_InstructionPC` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

完整模式、绑定、就绪状态、别名、容量与分配预检发生在源快照和所有目的端发布之前。

<!-- PTO-READER-BLOCK: block-c-bstart-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
C.BSTART DIRECT, label
```

起始指令先建立描述符；后续载体按声明模式补充内容，最终完成边界触发验证与操作执行。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTART COND,  label
C.BSTART DIRECT, label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_16_c4e238a9227a | C16 | 16 | 0x0004 / 0x000f | [] |
| c_bstart_16_f833d2a4753c | C16 | 16 | 0x0002 / 0x000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_bstart_16_c4e238a9227a | simm12 | 12 | signed | [{"instruction_lsb":4,"value_lsb":0,"width":12}] |
| c_bstart_16_f833d2a4753c | simm12 | 12 | signed | [{"instruction_lsb":4,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_bstart_16_c4e238a9227a | simm12 | 12 | 0–4095 | none | none | 12-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| c_bstart_16_f833d2a4753c | simm12 | 12 | 0–4095 | none | none | 12-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm12 | 12-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_16_c4e238a9227a) ||
           (operation == CommandOperation_c_bstart_16_f833d2a4753c);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART opens one Standard block. Header commands execute sequentially until BSTOP or the next BSTART commits the new BARG continuation.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.asl -->
```asl
pure func InstructionContractTarget_C_BSTART(
    instruction_pc: Word,
    displacement: bits(12))
    => Word
begin
    return instruction_pc +
        LSL(SignExtend{PTO_XLEN}(displacement), 1);
end;

readonly func InstructionContractHandler_C_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- simm12 is always encoded. Encoded zero computes the candidate target P and is not omission.
- The conditional form initializes BARG.TAKEN to false; the direct form initializes it to true.

## Legality

- Exactly the low-nibble forms 0x2 (DIRECT) and 0x4 (COND) are assigned to C.BSTART.
- simm12 accepts every signed 12-bit value and computes P + (SignExtend(simm12) << 1).

## State effects

- Installs BARG.BPC=P, BlockType=STD, BPCN=the computed candidate target, and TYPE=DIRECT or COND.
- DIRECT installs TAKEN=1; COND installs TAKEN=0 until an applicable SETC operation resolves it. The candidate continuation is selected only at BSTOP or the next BSTART.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode, target calculation, and target alignment checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- An odd computed candidate target raises Fault_InstructionPC before predecessor retirement or new BARG effects.
- If predecessor commit fails, the retiring block remains authoritative and no Standard BARG is installed.

## Examples

- C.BSTART DIRECT, label
- C.BSTART COND, label
