<!-- GENERATED FROM: asl/scalar/amo/SD.UMIN.asl -->
# SD.UMIN

**Normative ASL source:** `asl/scalar/amo/SD.UMIN.asl`

SD.UMIN atomically replaces the aligned 64-bit memory value with its unsigned minimum with SrcR; it does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SD-UMIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sd-umin-purpose role=purpose -->
## SD.UMIN 的作用
`SD.UMIN` 原子地更新一个对齐的 8 字节内存值并写回结果。它不发布旧值，也不写任何寄存器或临时队列。
其记录的摘要为：SD.UMIN atomically replaces the aligned 64-bit memory value with its unsigned minimum with SrcR; it does not publish the old value. `SD` 前缀标明宽度：每次操作 8 字节内存。替换一个值必须先读出它，而该读取发生在同一次原子访问中。

<!-- PTO-READER-BLOCK: scalar-sd-umin-mechanism role=mechanism -->
## 原子机制
指令契约以宽度 `8` 选择 `ScalarHandler_AtomicReadModifyWrite`，并把该操作映射到 `Atomic_UMIN`。标量分派调用 `AtomicReadModifyWrite`：对同一地址做两次预检，然后读取、合并、写回；其返回值被丢弃。
`Atomic_UMIN` 比较 `UInt(old_value)` 与 `UInt(operand)`，返回较小者。
该辅助函数会返回内存旧值，但标量分派传入的 `write_result` 为 `FALSE`，且元数据辅助函数 `InstructionContractPublishesOldValue_SD_UMIN` 同样返回 `FALSE`，因此不会发布任何值。
设计要点：先构造并检查读取预检，之后才构造写入预检，因此“读取被允许而写入被拒绝”会在任何加载发生之前、内存未被改动时报故障。

<!-- PTO-READER-BLOCK: scalar-sd-umin-inputs-outputs role=inputs-outputs -->
## 输入与结果
`SrcL` 提供原子地址。`SrcR` 提供原子操作数，写入的值来自该地址原有的值，按无符号整数比较并保留较小者。
`rl` 是释放位：`rl=0` 以宽松排序记录原子事件，`rl=1` 以释放排序记录。该形式没有获取位，因此不能记录获取或获取-释放排序。`far` 只是路由提示：`AtomicAddress` 原样返回其 `address` 参数，既不改变地址，也不改变排序或结果。
全部 32 个 Reg5 源编码都已分配：`0`..`23` 命名 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。该形式没有目的字段，因此旧值既不到达 GPR，也不到达队列。

<!-- PTO-READER-BLOCK: scalar-sd-umin-effects role=effects -->
## 效果与排序
成功执行时先读出旧值，选出较小的无符号值，再把结果写回同一翻译地址，并以所选排序记录一个原子内存事件。`SD` 不记录数值状态。
完成的写入会使与写入范围重叠的本地保留失效，而不会影响不重叠的保留；该判定发生在 `StoreTranslated` 内部，并以 64 字节保留粒度为依据。成功执行随后使 `TPC` 前进 `4` 字节。
设计要点：旧值作为原子操作的一部分被读出后即被丢弃，因此需要它的程序必须改用 `SWAPD`、`CASD` 或 `LD` 形式，它们都带有目的字段。只由 `SD` 形式构成的序列无法通过寄存器观察内存先前的内容。

<!-- PTO-READER-BLOCK: scalar-sd-umin-constraints role=constraints -->
## 合法性与精确故障
有效地址必须按 `8` 字节对齐。`ProbeDataAccess` 在查询地址翻译之前先按访问宽度比较地址，因此对齐错误先于翻译或权限故障被报告，且失败的预检报告原始架构地址。
任一预检失败时什么都不会发生：不加载、不存储、不记录内存事件、不更新保留、不发布结果、不推进 `TPC`。还存在另一种结果：两次预检都通过但解析到不同的翻译地址，此时辅助函数以原始地址置 `Fault_DataPage`，且不改动内存。
当没有任何形式能解码该 32 位模式时（本形式在掩码 `0xf4007fff` 下匹配 `0x7000500b`），以及当某个具名源选择了当前无效的临时队列项时，都会在任何效果之前触发 `Fault_IllegalInstruction`。`SrcL` 的编码零读取架构零寄存器作为地址，`SrcR` 的编码零提供数值零作为操作数。
设计要点：被拒绝的地址必须让内存与保留状态保持原样，因为陷入会保存原始 `TPC`，恢复时再还原它，于是该指令被完整重新执行，而不是从操作中间继续。
设计要点：两个源都在结果被写入前读出，而 `SrcL` 与 `SrcR` 可以是同一寄存器；此时操作数仍是执行前的值。

<!-- PTO-READER-BLOCK: scalar-sd-umin-example role=example -->
## 非规范示例
本示例说明当前的 ASL 归属，不替代规范操作。
该操作接受的四种写法如下；`.rl`、`.f` 与 `.rlf` 只选择排序或路由。
```text
sd.umin [SrcL], SrcR
sd.umin.rl [SrcL], SrcR
sd.umin.f [SrcL], SrcR
sd.umin.rlf [SrcL], SrcR
```
内存中存放 `0xffffffffffffffff`，`SrcR` 命名的寄存器中存放 `1`。
按无符号整数比较，第二个值更小，因此写回 `1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sd.umin [SrcL], SrcR
sd.umin.rl [SrcL], SrcR
sd.umin.f [SrcL], SrcR
sd.umin.rlf [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_umin_32_2388cbb378ac | L32 | 32 | 0x7000500b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_umin_32_2388cbb378ac | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_umin_32_2388cbb378ac | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sd_umin_32_2388cbb378ac | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sd_umin_32_2388cbb378ac | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sd_umin_32_2388cbb378ac | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sd_umin_32_2388cbb378ac | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sd_umin_32_2388cbb378ac | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sd_umin_32_2388cbb378ac | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| far | flat-address routing hint |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.UMIN.asl -->
```asl
readonly func InstructionContractOperation_SD_UMIN() => ScalarOperation
begin
    return ScalarOperation_SD_UMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.UMIN.asl -->
```asl
readonly func InstructionContractHandler_SD_UMIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SD_UMIN()
    => AtomicOperation
begin
    return Atomic_UMIN;
end;

pure func InstructionContractAtomicSizeBytes_SD_UMIN()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_SD_UMIN()
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
- The effective address must be aligned to 8 bytes. SrcL, SrcR, far, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SD.UMIN compares both values as unsigned integers and selects the smaller value at 64-bit width and stores that value; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the unsigned minimum, and write one 8-byte result to the same location.
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

- sd.umin [a0], a1
- sd.umin.rl [t#1], u#1
- sd.umin.f [sp], a0
