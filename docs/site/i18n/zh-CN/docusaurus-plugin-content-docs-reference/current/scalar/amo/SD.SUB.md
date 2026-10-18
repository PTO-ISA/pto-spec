<!-- GENERATED FROM: asl/scalar/amo/SD.SUB.asl -->
# SD.SUB

**Normative ASL source:** `asl/scalar/amo/SD.SUB.asl`

SD.SUB atomically applies width-sized modular sub and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SD-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sd-sub-purpose role=purpose -->
## SD.SUB 的用途
`SD.SUB` 从一个对齐的 64 位内存双字中原子减去操作数并存储结果。当程序只需要不可分割的更新、不需要旧内存值时，它避免了不必要的目的操作数。

<!-- PTO-READER-BLOCK: scalar-sd-sub-mechanism role=mechanism -->
## 更新机制
指令快照 `SrcL` 和 `SrcR`，预检读写访问，读取八个小端字节，计算 `old_value - operand`，再写回 64 位差。运算按模 2^64 进行。原子辅助函数在内部返回旧双字，但只存储分派会将其丢弃。

<!-- PTO-READER-BLOCK: scalar-sd-sub-inputs-outputs role=inputs-outputs -->
## 输入与输出
`SrcL` 命名原子访问地址，`SrcR` 提供 64 位减数。Reg5 编码 `0` 命名架构零寄存器，`1`..`23` 选择其他 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`。更新后的八字节内存值是唯一输出；旧值不会写入 GPR 或临时队列。

<!-- PTO-READER-BLOCK: scalar-sd-sub-effects role=effects -->
## 效果与排序
成功执行会记录一个原子事件，使重叠的本地保留失效，并使 `TPC` 前进四个字节。`rl=0` 记录宽松排序，`rl=1` 记录释放排序。该形式没有获取语义。

<!-- PTO-READER-BLOCK: scalar-sd-sub-constraints role=constraints -->
## 约束与故障
地址必须按八字节对齐。对齐检查先于翻译和权限检查，两次预检还必须在读取内存前识别出同一翻译地址。失败时，内存、事件、保留、寄存器、队列和 `TPC` 均不改变，并通过精确故障路径报告原始架构地址。

<!-- PTO-READER-BLOCK: scalar-sd-sub-example role=example -->
## 示例
```text
sd.sub [a0], a1
```
若对齐双字包含 `0x0000000000000003`，且 `a1` 包含 `0x0000000000000005`，则写回的模差为 `0xfffffffffffffffe`。旧值 `3` 不会被返回。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sd.sub [SrcL], SrcR
sd.sub.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_sub_32_op5_v0587 | L32 | 32 | 0x4000500b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_sub_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_sub_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sd_sub_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sd_sub_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sd_sub_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sd_sub_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.SUB.asl -->
```asl
readonly func InstructionContractOperation_SD_SUB() => ScalarOperation
begin
    return ScalarOperation_SD_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.SUB.asl -->
```asl
readonly func InstructionContractHandler_SD_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SD_SUB()
    => AtomicOperation
begin
    return Atomic_SUB;
end;

pure func InstructionContractAtomicSizeBytes_SD_SUB()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_SD_SUB()
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
- The effective address must be aligned to 8 bytes. SrcL, SrcR, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SD.SUB stores the 64-bit modular difference; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the 64-bit modular difference, and write one 8-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sd.sub [a0], a1
- sd.sub.rl [t#1], u#1
