<!-- GENERATED FROM: asl/scalar/alu/C.SRLI.asl -->
# C.SRLI

**Normative ASL source:** `asl/scalar/alu/C.SRLI.asl`

C.SRLI snapshots the pre-instruction T#1 value, logically shifts it right by uimm5, and pushes the XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-SRLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-srli-purpose role=purpose -->
## C.SRLI 的作用

`C.SRLI` 把指令执行前的 `T#1` 值逻辑右移，并把 XLEN 结果压入 `T`。源和目标都由助记符固定；16 位形式只编码移位量。

设计要点：压缩编码既没有源字段也没有目标字段，因此每条 `c.srli` 都读取 `T#1` 并替换最新的 `T` 项。需要把移位结果放进 GPR 的程序必须之后再用一条搬移指令，因为这个形式无法指定 GPR。

<!-- PTO-READER-BLOCK: scalar-c-srli-mechanism role=mechanism -->
## 结果形成方式

`uimm5` 被零扩展到 XLEN，作为共享逻辑右移规则的右操作数。移出位 0 以下的位被丢弃，空出的高位填零。

设计要点：共享移位规则从右操作数的低六位取移位量，因此五位字段最多只能达到 `0..31`。32 位的 `SRLI` 用六位存放 `shamt`，可以达到 `0..63`；压缩形式做不到。

设计要点：编码零是真正的零位移，而不是省略操作数，因此 `c.srli t#1, 0, ->t` 把不变的值作为新的 `T` 项发布。队列仍然移动：副本成为 `T#1`，原 `T#4` 被丢弃。

<!-- PTO-READER-BLOCK: scalar-c-srli-inputs role=inputs-outputs -->
## 输入与目标

- `T#1` 是固定源，作为完整的 XLEN 值读取，并在压入之前快照。
- `uimm5` 是唯一被编码的字段：无符号五位移位量，取值 `0` 至 `31`。
- 目标固定为 `T`：每次成功执行恰好一个 XLEN 结果。

相对读取不消费队列项，因此该指令读到的值对后续指令仍然可用。

<!-- PTO-READER-BLOCK: scalar-c-srli-effects role=effects -->
## 效果与顺序

旧 `T#1` 在目标压入之前快照，因此该指令不会移位自己的结果。压入把队列向更旧的索引方向移动，新值成为 `T#1`。

压入之后，`TPC` 前进 `2` 字节。不会写任何 GPR，`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、谓词和其他控制状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-srli-constraints role=constraints -->
## 合法性与故障边界

`0` 至 `31` 的每个 `uimm5` 取值都已分配，规范形式的固定编码位必须完全匹配。逻辑移位是全域定义的，任何移位量都不会引发算术异常。

未初始化的 `T#1` 会在压入之前、`TPC` 前进之前以及任何其他效果之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：`T#1` 是隐式源，因此它的可用性由隐式源规则检查，而不是由编码源选择器检查，而这个形式本来也没有可检查的编码源选择器。形式约束、编码寄存器操作数和隐式源三项预检都在操作之前运行，所以缺少 `T#1` 不会留下部分效果。

<!-- PTO-READER-BLOCK: scalar-c-srli-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `T#1` 保存 `16` 时，编码 `c.srli t#1, 2, ->t` 压入 `4`，并把旧的 `16` 留在 `T#2`。规范示例 `c.srli t#1, 31, ->t` 压入 `0` 或 `1`，即旧值的第 `31` 位。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.srli t#1, uimm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_srli_16_b411862f7820 | C16 | 16 | 0x182c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_srli_16_b411862f7820 | uimm5 | 5 | unsigned | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_srli_16_b411862f7820 | uimm5 | 5 | 0–31 | none | none | unsigned five-bit logical right-shift amount | Encoded zero republishes the unchanged pre-instruction T#1 value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned five-bit logical right-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SRLI.asl -->
```asl
readonly func InstructionContractOperation_C_SRLI() => ScalarOperation
begin
    return ScalarOperation_C_SRLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SRLI.asl -->
```asl
readonly func InstructionContractHandler_C_SRLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_SRLI(
    old_t1: Word,
    encoded_amount: bits(5))
    => Word
begin
    return ScalarBinary(
        ScalarBinary_SRL,
        old_t1,
        ZeroExtend{PTO_XLEN}(encoded_amount));
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- T#1 is the fixed source and T is the fixed destination; neither is encoded or omittable in canonical assembly.
- uimm5 is required and directly encodes a shift amount from 0 through 31.

## Legality

- Every uimm5 value 0..31 is assigned. Fixed encoding bits must match the canonical form.
- The fixed T#1 source must be initialized before execution.

## State effects

- Logically shift the complete XLEN old T#1 value right by UInt(uimm5); shifted-out bits are discarded and vacated bits are zero-filled.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices and the former T#4 is discarded.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot old T#1 before the destination push, so the instruction cannot read its own result.
- Push the shifted result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- The logical shift is total and raises no arithmetic exception.
- If T#1 is unavailable, Fault_IllegalInstruction is raised before the T push, before TPC advances, and before any other effect.

## Examples

- c.srli t#1, 31, ->t
