<!-- GENERATED FROM: asl/scalar/amo/SB.SUB.asl -->
# SB.SUB

**Normative ASL source:** `asl/scalar/amo/SB.SUB.asl`

SB.SUB atomically applies width-sized modular sub and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SB-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sb-sub-purpose role=purpose -->
## SB.SUB 的用途
`SB.SUB` 对一个字节执行只存储的原子减法。它支持不可分割的字节宽度递减，同时刻意不生成加载并返回旧值的原子形式所具有的旧值结果。

<!-- PTO-READER-BLOCK: scalar-sb-sub-mechanism role=mechanism -->
## 更新机制
指令先快照 `SrcL` 和 `SrcR`，对同一地址完成读写预检，读取一个字节，从旧字节减去操作数的低 8 位，再写回差的低 8 位。运算按模 2^8 进行，因此下溢会回绕。旧字节不会成为架构结果。

<!-- PTO-READER-BLOCK: scalar-sb-sub-inputs-outputs role=inputs-outputs -->
## 输入与输出
`SrcL` 命名原子访问地址，`SrcR` 提供减数。全部 Reg5 编码均已分配：`0` 命名架构零寄存器，`1`..`23` 选择其他 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`。更新后的内存字节是唯一输出；被替换值不会写入 GPR 或临时队列。

<!-- PTO-READER-BLOCK: scalar-sb-sub-effects role=effects -->
## 效果与排序
成功时，`SB.SUB` 记录一个原子内存事件，并使与写入字节重叠的本地保留失效。`rl=0` 选择宽松排序，`rl=1` 选择释放排序；该编码没有获取位。成功执行后，`TPC` 前进四个字节。

<!-- PTO-READER-BLOCK: scalar-sb-sub-constraints role=constraints -->
## 约束与故障
单字节访问没有额外对齐约束。任何内存效果发生前，两次访问预检必须成功并解析到同一翻译地址。预检失败、翻译地址不一致、临时队列源无效或指令字无法解码时，内存、事件、保留、结果状态和 `TPC` 保持不变，然后进入精确陷入处理。

<!-- PTO-READER-BLOCK: scalar-sb-sub-example role=example -->
## 示例
```text
sb.sub [a0], a1
```
若 `a0` 命名的字节为 `0x00`，且 `a1` 的低字节为 `0x01`，则写回的模差为 `0xff`。指令不会发布原来的 `0x00`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sb.sub [SrcL], SrcR
sb.sub.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sb_sub_32_op5_v0587 | L32 | 32 | 0xc000300b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sb_sub_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sb_sub_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sb_sub_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sb_sub_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sb_sub_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sb_sub_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SB.SUB.asl -->
```asl
readonly func InstructionContractOperation_SB_SUB() => ScalarOperation
begin
    return ScalarOperation_SB_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SB.SUB.asl -->
```asl
readonly func InstructionContractHandler_SB_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SB_SUB()
    => AtomicOperation
begin
    return Atomic_SUB;
end;

pure func InstructionContractAtomicSizeBytes_SB_SUB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractPublishesOldValue_SB_SUB()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required Reg5 sources. Encoded zero reads the architectural zero register.
- rl=0 selects relaxed ordering; rl=1 selects release ordering.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- The effective address must be aligned to 1 byte. SrcL, SrcR, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SB.SUB stores the 8-bit modular difference; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 1-byte little-endian value, compute the 8-bit modular difference, and write one 1-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sb.sub [a0], a1
- sb.sub.rl [t#1], u#1
