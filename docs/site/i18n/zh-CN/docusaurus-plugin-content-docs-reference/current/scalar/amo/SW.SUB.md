<!-- GENERATED FROM: asl/scalar/amo/SW.SUB.asl -->
# SW.SUB

**Normative ASL source:** `asl/scalar/amo/SW.SUB.asl`

SW.SUB atomically applies width-sized modular sub and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SW-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-sub-purpose role=purpose -->
## SW.SUB 的用途
`SW.SUB` 从一个对齐的 32 位内存字中原子减去操作数并存储结果。它属于只存储形式：当更新必须不可分割、但不需要输出被替换值时使用。

<!-- PTO-READER-BLOCK: scalar-sw-sub-mechanism role=mechanism -->
## 更新机制
指令快照两个源，预检读写访问，读取四个小端字节，减去 `SrcR` 的低 32 位，再存储差的低 32 位。运算按模 2^32 进行。原子辅助函数虽然会读取旧字，但由于该形式没有目的操作数，分派会丢弃该值。

<!-- PTO-READER-BLOCK: scalar-sw-sub-inputs-outputs role=inputs-outputs -->
## 输入与输出
`SrcL` 提供原子访问地址，`SrcR` 提供减数。Reg5 编码 `0` 命名架构零寄存器，`1`..`23` 选择其他 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`。更新后的四字节内存字是唯一结果；操作数高位和旧字均不会被发布。

<!-- PTO-READER-BLOCK: scalar-sw-sub-effects role=effects -->
## 效果与排序
成功时，`SW.SUB` 记录一个原子事件，使重叠的本地保留失效，并使 `TPC` 前进四个字节。`rl=0` 选择宽松排序，`rl=1` 选择释放排序。这个只存储编码不能请求获取排序。

<!-- PTO-READER-BLOCK: scalar-sw-sub-constraints role=constraints -->
## 约束与故障
地址必须按四字节对齐。对齐、翻译和权限都在产生效果前检查，且读写预检必须解析到同一翻译地址。任何检查失败时，操作都不执行内存访问、不记录事件、不更新保留、不发布结果、也不推进 `TPC`，因此可以完整重启。

<!-- PTO-READER-BLOCK: scalar-sw-sub-example role=example -->
## 示例
```text
sw.sub.rl [a0], a1
```
若对齐字为 `0x00000000`，且 `a1` 的低 32 位为 `0x00000001`，则写回结果为 `0xffffffff`。指令记录释放排序，同时丢弃原来的内存字。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw.sub [SrcL], SrcR
sw.sub.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_sub_32_op5_v0587 | L32 | 32 | 0x4000300b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_sub_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_sub_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_sub_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_sub_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sw_sub_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sw_sub_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.SUB.asl -->
```asl
readonly func InstructionContractOperation_SW_SUB() => ScalarOperation
begin
    return ScalarOperation_SW_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.SUB.asl -->
```asl
readonly func InstructionContractHandler_SW_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SW_SUB()
    => AtomicOperation
begin
    return Atomic_SUB;
end;

pure func InstructionContractAtomicSizeBytes_SW_SUB()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_SW_SUB()
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
- The effective address must be aligned to 4 bytes. SrcL, SrcR, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SW.SUB stores the 32-bit modular difference; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the 32-bit modular difference, and write one 4-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sw.sub [a0], a1
- sw.sub.rl [t#1], u#1
