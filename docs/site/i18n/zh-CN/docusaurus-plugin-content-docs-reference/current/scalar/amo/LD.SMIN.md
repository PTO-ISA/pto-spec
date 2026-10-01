<!-- GENERATED FROM: asl/scalar/amo/LD.SMIN.asl -->
# LD.SMIN

**Normative ASL source:** `asl/scalar/amo/LD.SMIN.asl`

LD.SMIN atomically stores the width-sized signed minimum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-SMIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-smin-purpose role=purpose -->
## LD.SMIN 的作用

`LD.SMIN` 把两个值中较小的那个存储到某个内存地址。已存的双字与 64 位操作数都按二进制补码有符号整数解读，指令执行前内存中的双字通过 `RegDst` 发布。

<!-- PTO-READER-BLOCK: scalar-ld-smin-mechanism role=mechanism -->
## 如何保留较小的有符号值

处理器是 `ScalarHandler_AtomicReadModifyWrite`，访问宽度 `8`，原子操作 `Atomic_SMIN`。读取预检与写入预检通过后，旧双字被加载、与 `SrcR` 比较，较小的有符号值被写回；同时记录一个 `write_performed` 为 true 的原子事件。

设计要点：比较把第 63 位读作符号位。存放 `0x0000000000000005` 的位置与 `SrcR = 0xfffffffffffffffd`（即 `-3`）比较后存放 `0xfffffffffffffffd`，因为 `-3` 小于 `5`。存储的字节是两个输入模式之一，未被改动。

设计要点：两个有符号值相等时，该形式保留操作数。此时它的位模式与旧双字完全相同，因此该位置被写入它本来就持有的字节，而这次执行仍然算作一次已执行的原子写入。

设计要点：只有在没有引发故障时才写目的地，因此被拒绝的 `LD.SMIN` 会让该寄存器保持原有内容，而不会发布一个并非来自内存的值。

<!-- PTO-READER-BLOCK: scalar-ld-smin-inputs-outputs role=inputs-outputs -->
## 字段与操作数角色

`RegDst` 是位于指令位 `7..11` 的 `5` 位字段，`SrcL` 位于位 `15..19`，`SrcR` 位于位 `20..24`，`rl` 位于位 `25`，`aq` 位于位 `26`，`far` 位于位 `27`。`SrcL` 提供原子地址，`SrcR` 提供操作数；全部 Reg5 源选择子都合法，被选中的 T 或 U 项在读取时不会被弹出。

`RegDst` 接收发布值：编码 `0` 与 `24` 到 `29` 丢弃它，编码 `30` 压入 U，编码 `31` 压入 T，编码 `1` 到 `23` 写入所指的 GPR。`aq` 与 `rl` 为所记录的事件编码宽松、获取、释放与获取-释放排序。

设计要点：`far` 被译码并传给 `AtomicAddress`，后者原样返回地址。在参考模型中，带提示的写法与普通写法选中的是同一个双字，因此比较结果完全相同。

<!-- PTO-READER-BLOCK: scalar-ld-smin-effects role=effects -->
## 效果

一次完成的执行存储 8 字节、记录一个 `write_performed` 为 true 的原子事件、发布执行前的双字，并让 `TPC` 前进 4 字节。当写入范围与保留的 64 字节粒度重叠时，该存储会清除本地保留。

<!-- PTO-READER-BLOCK: scalar-ld-smin-constraints role=constraints -->
## 合法性与故障

地址必须是 8 的倍数；未对齐会引发 `Fault_DataAlignment`，超出允许区域的地址会引发 `Fault_DataPage`，两者都以原始地址报告，并且都在加载之前检查。译码失败或所选 T 或 U 源不可用会在任何效果之前引发 `Fault_IllegalInstruction`。发生故障的执行不发布任何值、不写入任何内容、不记录事件，也不推进 `TPC`。

<!-- PTO-READER-BLOCK: scalar-ld-smin-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

`ld.smin [a0], a1, ->a2` 在 `a0` 存放 8 字节对齐地址时就地比较。当 `[a0]` 存放 `0x0000000000000005`、`a1` 存放 `0xfffffffffffffffd` 时，较小的有符号值 `-3` 以 `0xfffffffffffffffd` 存储，`a2` 得到 `0x0000000000000005`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.smin [SrcL], SrcR, ->Rd
ld.smin.aq [SrcL], SrcR, ->Rd
ld.smin.rl [SrcL], SrcR, ->Rd
ld.smin.f [SrcL], SrcR, ->Rd
ld.smin.aqrl [SrcL], SrcR, ->Rd
ld.smin.aqf [SrcL], SrcR, ->Rd
ld.smin.rlf [SrcL], SrcR, ->Rd
ld.smin.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_smin_32_9461d345718f | L32 | 32 | 0x5000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_smin_32_9461d345718f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_smin_32_9461d345718f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_smin_32_9461d345718f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_smin_32_9461d345718f | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_smin_32_9461d345718f | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_smin_32_9461d345718f | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_smin_32_9461d345718f | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_smin_32_9461d345718f | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_smin_32_9461d345718f | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_smin_32_9461d345718f | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_smin_32_9461d345718f | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_smin_32_9461d345718f | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.SMIN.asl -->
```asl
readonly func InstructionContractOperation_LD_SMIN() => ScalarOperation
begin
    return ScalarOperation_LD_SMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.SMIN.asl -->
```asl
readonly func InstructionContractHandler_LD_SMIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_SMIN()
    => AtomicOperation
begin
    return Atomic_SMIN;
end;

pure func InstructionContractAtomicSizeBytes_LD_SMIN()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_SMIN()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_SMIN()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the published old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 Reg5 destination encodings are assigned. Destination code 0 and destination codes 24..29 discard. Destination code 30 pushes U, destination code 31 pushes T, and codes 1..23 write the named absolute GPR.
- The effective address must be aligned to 8 bytes. aq, rl, and far have no reserved combinations.

## State effects

- Snapshot SrcL and SrcR before every memory or destination effect, so GPR and T/U source aliases observe the pre-instruction values.
- LD.SMIN computes the signed minimum at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized signed minimum, and write one 8-byte result to the same location.
- On success, record one atomic memory event. A completed overlapping write invalidates the overlapping local reservation; a nonoverlapping reservation remains valid.
- The published result is the unchanged 64-bit old value.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- Read and write access probes both complete before the memory load or store, and both probes must resolve to the same translated address.
- On a fault, the instruction publishes no destination, performs no load, store, event, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores that TPC for full reissue.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- ld.smin [a0], a1, ->a2
- ld.smin.aqrl [t#1], u#1, ->t
- ld.smin.f [sp], a0, ->u
