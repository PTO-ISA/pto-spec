<!-- GENERATED FROM: asl/scalar/amo/SW.SMIN.asl -->
# SW.SMIN

**Normative ASL source:** `asl/scalar/amo/SW.SMIN.asl`

SW.SMIN atomically replaces the aligned 32-bit memory value with its signed minimum with SrcR; it does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SW-SMIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-smin-purpose role=purpose -->
## SW.SMIN 的作用
`SW.SMIN` 原子地更新一个对齐的 4 字节内存值并写回结果。它不发布旧值，也不写任何寄存器或临时队列。
其记录的摘要为：SW.SMIN atomically replaces the aligned 32-bit memory value with its signed minimum with SrcR; it does not publish the old value. `SW` 前缀标明宽度：每次操作 4 字节内存；写操作需要它替换掉的值，而该读取发生在同一次原子访问中。

<!-- PTO-READER-BLOCK: scalar-sw-smin-mechanism role=mechanism -->
## 原子机制
指令契约以宽度 `4` 选择 `ScalarHandler_AtomicReadModifyWrite`，并把该操作映射到 `Atomic_SMIN`。标量分派调用 `AtomicReadModifyWrite`：对同一地址做两次预检，然后读取、合并、写回；其返回值被丢弃。
`Atomic_SMIN` 比较 `SInt(old_value)` 与 `SInt(operand)`，返回较小者。
该辅助函数会返回内存旧值，但分派传入的 `write_result` 为 `FALSE`，且该形式没有目的字段，因此不会发布任何值。
设计要点：`SW` 操作按 32 位定义，因此只使用操作数寄存器的低 32 位。第 `32` 位及更高位不会进入内存，写回的 4 字节值是结果的低 32 位。

<!-- PTO-READER-BLOCK: scalar-sw-smin-inputs-outputs role=inputs-outputs -->
## 输入与结果
`SrcL` 提供原子地址。`SrcR` 提供原子操作数，写入的值来自该地址原有的值，按二进制补码有符号整数比较并保留较小者。
`rl` 是释放位：`rl=0` 以宽松排序记录原子事件，`rl=1` 以释放排序记录。该形式没有获取位，因此不能记录获取或获取-释放排序。`far` 只是路由提示：`AtomicAddress` 原样返回其 `address` 参数，既不改变地址，也不改变排序或结果。
全部 32 个 Reg5 源编码都已分配：`0`..`23` 命名 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。该形式没有目的字段，因此旧值既不到达 GPR，也不到达队列。

<!-- PTO-READER-BLOCK: scalar-sw-smin-effects role=effects -->
## 效果与排序
成功执行时先读出旧值，选出较小的有符号值，再把结果写回同一翻译地址，并以所选排序记录一个原子内存事件。`SW` 不记录数值状态。
完成的写入会使与写入范围重叠的本地保留失效，而不会影响不重叠的保留；该判定发生在 `StoreTranslated` 内部，并以 64 字节保留粒度为依据。成功执行随后使 `TPC` 前进 `4` 字节。
设计要点：宽度固定为 32 位，只有被寻址位置的低 32 位参与运算，因此在该地址保存更宽值的程序必须把该操作视为只更新其低半部分。

<!-- PTO-READER-BLOCK: scalar-sw-smin-constraints role=constraints -->
## 合法性与精确故障
有效地址必须按 `4` 字节对齐。`ProbeDataAccess` 在查询地址翻译之前先按访问宽度比较地址，因此对齐错误先于翻译或权限故障被报告，且失败的预检报告原始架构地址。
任一预检失败时什么都不会发生：不加载、不存储、不记录内存事件、不更新保留、不发布结果、不推进 `TPC`。还存在另一种结果：两次预检都通过但解析到不同的翻译地址，此时辅助函数以原始地址置 `Fault_DataPage`，且不改动内存。
当没有任何形式能解码该 32 位模式时（本形式在掩码 `0xf4007fff` 下匹配 `0x5000300b`），以及当某个具名源选择了当前无效的临时队列项时，都会在任何效果之前触发 `Fault_IllegalInstruction`。`SrcL` 的编码零读取架构零寄存器作为地址，`SrcR` 的编码零提供数值零作为操作数。
设计要点：未对齐地址与无法翻译的地址属于不同陷入，而对齐先被检查，因此调试器无需重建访问宽度即可区分二者。
设计要点：两个源都在结果被写入前读出，而 `SrcL` 与 `SrcR` 可以是同一寄存器；此时操作数仍是执行前的值。

<!-- PTO-READER-BLOCK: scalar-sw-smin-example role=example -->
## 非规范示例
本示例说明当前的 ASL 归属，不替代规范操作。
该操作接受的四种写法如下；`.rl`、`.f` 与 `.rlf` 只选择排序或路由。
```text
sw.smin [SrcL], SrcR
sw.smin.rl [SrcL], SrcR
sw.smin.f [SrcL], SrcR
sw.smin.rlf [SrcL], SrcR
```
对齐地址处的 4 字节值为 `0xffffffff`（按 32 位有符号整数读作 -1），`SrcR` 命名的寄存器中存放 `1`。
有符号最小值为 `0xffffffff`，该值被写回。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw.smin [SrcL], SrcR
sw.smin.rl [SrcL], SrcR
sw.smin.f [SrcL], SrcR
sw.smin.rlf [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_smin_32_773e7d83b011 | L32 | 32 | 0x5000300b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_smin_32_773e7d83b011 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_smin_32_773e7d83b011 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_smin_32_773e7d83b011 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sw_smin_32_773e7d83b011 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_smin_32_773e7d83b011 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sw_smin_32_773e7d83b011 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sw_smin_32_773e7d83b011 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sw_smin_32_773e7d83b011 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| far | flat-address routing hint |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.SMIN.asl -->
```asl
readonly func InstructionContractOperation_SW_SMIN() => ScalarOperation
begin
    return ScalarOperation_SW_SMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.SMIN.asl -->
```asl
readonly func InstructionContractHandler_SW_SMIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SW_SMIN()
    => AtomicOperation
begin
    return Atomic_SMIN;
end;

pure func InstructionContractAtomicSizeBytes_SW_SMIN()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_SW_SMIN()
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
- SW.SMIN compares both values as two's-complement signed integers and selects the smaller value at 32-bit width and stores that value; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the signed minimum, and write one 4-byte result to the same location.
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

- sw.smin [a0], a1
- sw.smin.rl [t#1], u#1
- sw.smin.f [sp], a0
