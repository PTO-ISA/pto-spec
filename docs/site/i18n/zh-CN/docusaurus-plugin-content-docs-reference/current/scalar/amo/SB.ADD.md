<!-- GENERATED FROM: asl/scalar/amo/SB.ADD.asl -->
# SB.ADD

**Normative ASL source:** `asl/scalar/amo/SB.ADD.asl`

SB.ADD atomically applies width-sized modular add and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SB-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sb-add-purpose role=purpose -->
## SB.ADD 的用途
`SB.ADD` 对一个字节执行只存储的原子加法。当多个代理更新字节宽度的计数器或标志字段，且程序要求更新不可分割、又不需要取得被替换值时，可以使用它。

<!-- PTO-READER-BLOCK: scalar-sb-add-mechanism role=mechanism -->
## 更新机制
指令先快照 `SrcL` 和 `SrcR`，对同一地址完成读写预检，读取一个字节，加上操作数的低 8 位，再写回和的低 8 位。运算按模 2^8 进行，因此溢出会回绕。旧字节只在内部参与计算；由于该形式没有目的操作数，旧值会被丢弃。

<!-- PTO-READER-BLOCK: scalar-sb-add-inputs-outputs role=inputs-outputs -->
## 输入与输出
`SrcL` 命名原子访问地址，`SrcR` 提供操作数。全部 Reg5 编码均已分配：`0` 命名架构零寄存器，`1`..`23` 选择其他 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`。唯一的架构输出是内存中更新后的字节；旧值不会写入 GPR 或临时队列。

<!-- PTO-READER-BLOCK: scalar-sb-add-effects role=effects -->
## 效果与排序
成功时，`SB.ADD` 记录一个原子内存事件，并使与写入字节重叠的本地保留失效。`rl=0` 记录宽松排序，`rl=1` 记录释放排序；该形式没有获取语义。成功执行后，`TPC` 前进四个字节。

<!-- PTO-READER-BLOCK: scalar-sb-add-constraints role=constraints -->
## 约束与故障
单字节访问不要求比字节地址更强的对齐。加载或存储发生前，读写预检都必须成功并解析到同一翻译地址。预检失败、翻译地址不一致、临时队列源无效或指令字无法解码时，内存、事件、保留、结果和 `TPC` 均不改变；随后按精确故障与重启路径处理。

<!-- PTO-READER-BLOCK: scalar-sb-add-example role=example -->
## 示例
```text
sb.add.rl [a0], a1
```
若 `a0` 命名的字节为 `0xff`，且 `a1` 的低字节为 `0x01`，则写回结果为 `0x00`。`.rl` 后缀只改变排序，不改变模运算，也不会返回原来的 `0xff`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sb.add [SrcL], SrcR
sb.add.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sb_add_32_op5_v0587 | L32 | 32 | 0x8000300b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sb_add_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sb_add_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sb_add_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sb_add_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sb_add_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sb_add_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SB.ADD.asl -->
```asl
readonly func InstructionContractOperation_SB_ADD() => ScalarOperation
begin
    return ScalarOperation_SB_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SB.ADD.asl -->
```asl
readonly func InstructionContractHandler_SB_ADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SB_ADD()
    => AtomicOperation
begin
    return Atomic_ADD;
end;

pure func InstructionContractAtomicSizeBytes_SB_ADD()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractPublishesOldValue_SB_ADD()
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
- SB.ADD stores the 8-bit modular sum; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 1-byte little-endian value, compute the 8-bit modular sum, and write one 1-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sb.add [a0], a1
- sb.add.rl [t#1], u#1
