<!-- GENERATED FROM: asl/scalar/amo/SH.SUB.asl -->
# SH.SUB

**Normative ASL source:** `asl/scalar/amo/SH.SUB.asl`

SH.SUB atomically applies width-sized modular sub and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SH-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sh-sub-purpose role=purpose -->
## SH.SUB 的用途
`SH.SUB` 对一个对齐半字执行只存储的原子减法。它提供不可分割的 16 位递减，而不为旧内存值创建目的操作数。

<!-- PTO-READER-BLOCK: scalar-sh-sub-mechanism role=mechanism -->
## 更新机制
快照 `SrcL` 和 `SrcR` 后，指令预检读写访问，读取两个小端字节，减去操作数的低 16 位，再写回差的低 16 位。计算按模 2^16 进行，因此下溢会回绕。辅助函数返回的旧值会被丢弃。

<!-- PTO-READER-BLOCK: scalar-sh-sub-inputs-outputs role=inputs-outputs -->
## 输入与输出
`SrcL` 提供地址，`SrcR` 提供减数。Reg5 编码 `0` 命名架构零寄存器，`1`..`23` 命名其他 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。只有两字节内存值被更新；寄存器或队列都不会收到被替换的半字。

<!-- PTO-READER-BLOCK: scalar-sh-sub-effects role=effects -->
## 效果与排序
成功的 `SH.SUB` 记录一个原子事件，使重叠的本地保留失效，并使 `TPC` 前进四个字节。`rl=0` 记录宽松排序，`rl=1` 记录释放排序。该形式没有获取位。

<!-- PTO-READER-BLOCK: scalar-sh-sub-constraints role=constraints -->
## 约束与故障
地址必须按两字节对齐。未对齐故障先于翻译和权限故障，两次读写预检还必须得到相同的翻译地址。在原子更新前发生失败时，内存、事件、保留、GPR、临时队列和原始 `TPC` 均被保留，以便完整重发。

<!-- PTO-READER-BLOCK: scalar-sh-sub-example role=example -->
## 示例
```text
sh.sub [a0], a1
```
若对齐半字为 `0x0000`，且 `a1` 的低 16 位为 `0x0001`，则写回的模差为 `0xffff`。原来的 `0x0000` 不会被发布。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sh.sub [SrcL], SrcR
sh.sub.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_sub_32_op5_v0587 | L32 | 32 | 0xc000500b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_sub_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_sub_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sh_sub_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sh_sub_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sh_sub_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sh_sub_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SH.SUB.asl -->
```asl
readonly func InstructionContractOperation_SH_SUB() => ScalarOperation
begin
    return ScalarOperation_SH_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SH.SUB.asl -->
```asl
readonly func InstructionContractHandler_SH_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SH_SUB()
    => AtomicOperation
begin
    return Atomic_SUB;
end;

pure func InstructionContractAtomicSizeBytes_SH_SUB()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractPublishesOldValue_SH_SUB()
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
- The effective address must be aligned to 2 bytes. SrcL, SrcR, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SH.SUB stores the 16-bit modular difference; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 2-byte little-endian value, compute the 16-bit modular difference, and write one 2-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sh.sub [a0], a1
- sh.sub.rl [t#1], u#1
