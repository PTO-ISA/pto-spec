<!-- GENERATED FROM: asl/scalar/amo/SW.XOR.asl -->
# SW.XOR

**Normative ASL source:** `asl/scalar/amo/SW.XOR.asl`

SW.XOR atomically replaces the aligned 32-bit memory value with its bitwise XOR with SrcR; it does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SW-XOR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-xor-purpose role=purpose -->
## SW.XOR 的作用

`SW.XOR` 把 `SrcL` 中地址处已对齐的 `4` 字节内存字，原子替换为该字与 `SrcR` 中值的按位异或。

它属于仅存储的原子形式：旧的内存值被丢弃。该编码中根本不存在目的字段。

<!-- PTO-READER-BLOCK: scalar-sw-xor-mechanism role=mechanism -->
## 原子机制

指令契约返回 `ScalarHandler_AtomicReadModifyWrite`，其操作为 `Atomic_XOR`，访问宽度为 `4` 字节。模型随后执行 `AtomicReadModifyWrite`，这是一个固定序列：

1. 对有效地址处的 `4` 字节探测读访问，失败则抛出故障。
2. 对同一地址处的 `4` 字节探测写访问，失败则抛出故障。
3. 要求两次探测翻译到同一地址，否则抛出数据页故障。
4. 载入旧字，与操作数做异或，把结果存回同一位置。
5. 记录一个原子内存事件，其中包含旧值、新值和所选排序。

`SrcL` 与 `SrcR` 在任何内存效果之前就被快照，因此操作数值不会在读取与写入之间改变。

设计要点：两次探测都在载入之前完成，因此一个不允许写入的形式会在完全没有读取该位置的情况下抛出故障。

<!-- PTO-READER-BLOCK: scalar-sw-xor-inputs-outputs role=inputs-outputs -->
## 输入与效果

`SrcL` 承载 Reg5 原子地址源；`SrcR` 承载 Reg5 原子操作数源；`far` 承载平坦地址路由提示；`rl` 承载释放排序位。

`SrcL` 与 `SrcR` 的全部 `32` 个编码都已分配：`SrcL` 与 `SrcR` 的编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`。任一源编码为零时读取架构零寄存器。

`rl=0` 以宽松排序记录原子事件，`rl=1` 以释放排序记录。该编码没有获取位。`far=1` 只是路由提示：参考配置档在两种情况下都计算出相同的架构地址和相同的原子结果。

设计要点：本应承载目的选择子的字段被改为用于排序位和路由提示，因此该编码即使软件想要，也无法命名旧值目的。返回旧值的形式是 `LW.XOR`。

<!-- PTO-READER-BLOCK: scalar-sw-xor-effects role=effects -->
## 效果与排序

成功时该指令恰好执行一个原子内存事件，更新内存，并保持 `SrcL` 与 `SrcR` 不变，因为标量源不会被消耗。

该写入不发布任何目的值，也不发布任何数值状态标志。`TPC` 前进 `4` 字节，即 `32` 位形式的长度。

完成的写入在与 `64` 字节保留粒度重叠时使本地保留失效，在不同粒度上则保留该保留。

发生故障时不记录任何内容：没有内存事件，没有保留变化，也没有 `TPC` 前进。陷入入口会保存 `TPC`，因此该指令可以重新执行。

<!-- PTO-READER-BLOCK: scalar-sw-xor-constraints role=constraints -->
## 合法性与故障顺序

有效地址必须按 `4` 字节对齐。

派发按固定顺序执行检查：先解码，再操作数合法性，再标量源可用性，最后是读探测与写探测。对齐、翻译和权限失败按该顺序抛出，并报告原始地址。

预检失败不会发布内存事件、不会更新保留，也不会产生退役效果。被选中但不可用的 `T` 或 `U` 源会在地址被探测之前以 `Fault_IllegalInstruction` 拒绝。

设计要点：由于每条失败路径都不改动内存和 `TPC`，恢复处理程序可以重新执行同一条指令，得到相同的访问检查，而不是一个部分生效的更新。

<!-- PTO-READER-BLOCK: scalar-sw-xor-example role=example -->
## 非规范示例

取 `a0 = 1024`、`a1 = 9`，并令地址 `1024` 处的 `4` 字节字存放 `5`。

`sw.xor [a0], a1` 使地址 `1024` 处的字存放 `12`，并使 `a0` 仍存放 `1024`、`a1` 仍存放 `9`。

旧值 `5` 不会被写到任何地方。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw.xor [SrcL], SrcR
sw.xor.rl [SrcL], SrcR
sw.xor.f [SrcL], SrcR
sw.xor.rlf [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_xor_32_874c32572226 | L32 | 32 | 0x3000300b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_xor_32_874c32572226 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_xor_32_874c32572226 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_xor_32_874c32572226 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sw_xor_32_874c32572226 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_xor_32_874c32572226 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sw_xor_32_874c32572226 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sw_xor_32_874c32572226 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sw_xor_32_874c32572226 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| far | flat-address routing hint |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.XOR.asl -->
```asl
readonly func InstructionContractOperation_SW_XOR() => ScalarOperation
begin
    return ScalarOperation_SW_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.XOR.asl -->
```asl
readonly func InstructionContractHandler_SW_XOR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SW_XOR()
    => AtomicOperation
begin
    return Atomic_XOR;
end;

pure func InstructionContractAtomicSizeBytes_SW_XOR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_SW_XOR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required Reg5 sources. Encoded zero reads the architectural zero register.
- rl=0 selects relaxed ordering; rl=1 selects release ordering.
- far=0 selects the default flat-address route. far=1 is a routing hint and does not change the architectural address or atomic operation in the reference profile.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- The effective address must be aligned to 4 bytes. SrcL, SrcR, far, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SW.XOR computes the bitwise XOR of the old value and operand at 32-bit width and stores that value; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the bitwise XOR, and write one 4-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sw.xor [a0], a1
- sw.xor.rl [t#1], u#1
- sw.xor.f [sp], a0
