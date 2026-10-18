<!-- GENERATED FROM: asl/scalar/amo/SH.ADD.asl -->
# SH.ADD

**Normative ASL source:** `asl/scalar/amo/SH.ADD.asl`

SH.ADD atomically applies width-sized modular add and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SH-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sh-add-purpose role=purpose -->
## SH.ADD 的用途
`SH.ADD` 对一个对齐半字执行只存储的原子加法。当程序需要不可分割的 16 位更新，但不需要返回被替换值时，它提供所需操作。

<!-- PTO-READER-BLOCK: scalar-sh-add-mechanism role=mechanism -->
## 更新机制
指令先快照 `SrcL` 和 `SrcR`，完成读写预检，读取两个小端字节，加上操作数的低 16 位，再写回和的低 16 位。运算按模 2^16 进行。内部读取的旧半字会被丢弃，因为该形式没有目的操作数。

<!-- PTO-READER-BLOCK: scalar-sh-add-inputs-outputs role=inputs-outputs -->
## 输入与输出
`SrcL` 提供地址，`SrcR` 提供加数。Reg5 编码 `0` 命名架构零寄存器，`1`..`23` 命名其他 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。唯一输出是更新后的两字节内存值；旧值既不会到达 GPR，也不会到达临时队列。

<!-- PTO-READER-BLOCK: scalar-sh-add-effects role=effects -->
## 效果与排序
成功时，`SH.ADD` 记录一个原子事件，使重叠的本地保留失效，并使 `TPC` 前进四个字节。`rl=0` 选择宽松排序，`rl=1` 选择释放排序。该指令没有获取或获取-释放写法。

<!-- PTO-READER-BLOCK: scalar-sh-add-constraints role=constraints -->
## 约束与故障
地址必须按两字节对齐。对齐先于翻译或权限检查，两次预检还必须解析到同一翻译地址。任何失败都发生在加载或存储之前，并为精确重启保留内存、内存事件、保留、寄存器、队列和 `TPC`。

<!-- PTO-READER-BLOCK: scalar-sh-add-example role=example -->
## 示例
```text
sh.add.rl [a0], a1
```
若对齐半字为 `0xffff`，且 `a1` 的低 16 位为 `0x0001`，则写回结果回绕为 `0x0000`。`.rl` 后缀记录释放排序，但不会返回 `0xffff`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sh.add [SrcL], SrcR
sh.add.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_add_32_op5_v0587 | L32 | 32 | 0x8000500b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_add_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_add_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sh_add_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sh_add_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sh_add_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sh_add_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SH.ADD.asl -->
```asl
readonly func InstructionContractOperation_SH_ADD() => ScalarOperation
begin
    return ScalarOperation_SH_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SH.ADD.asl -->
```asl
readonly func InstructionContractHandler_SH_ADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SH_ADD()
    => AtomicOperation
begin
    return Atomic_ADD;
end;

pure func InstructionContractAtomicSizeBytes_SH_ADD()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractPublishesOldValue_SH_ADD()
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
- SH.ADD stores the 16-bit modular sum; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 2-byte little-endian value, compute the 16-bit modular sum, and write one 2-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sh.add [a0], a1
- sh.add.rl [t#1], u#1
