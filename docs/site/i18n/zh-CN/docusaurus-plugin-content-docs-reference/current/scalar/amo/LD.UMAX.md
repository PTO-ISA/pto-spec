<!-- GENERATED FROM: asl/scalar/amo/LD.UMAX.asl -->
# LD.UMAX

**Normative ASL source:** `asl/scalar/amo/LD.UMAX.asl`

LD.UMAX atomically stores the width-sized unsigned maximum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-UMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-umax-purpose role=purpose -->
## LD.UMAX 的作用

`LD.UMAX` 把两个 64 位值中较大的那个写入某个内存地址。比较是无符号的，因此它依据模式的数值大小而不是符号，被替换的双字通过 `RegDst` 发布。

<!-- PTO-READER-BLOCK: scalar-ld-umax-mechanism role=mechanism -->
## 如何选出较大的无符号值

处理器是 `ScalarHandler_AtomicReadModifyWrite`，访问宽度为 `8`，原子操作为 `Atomic_UMAX`。读取与写入预检先确定地址；随后加载旧双字、选出较大的无符号值、把选中的位写回、记录一个 `write_performed` 为 true 的原子事件，并返回旧双字。

存放 `0x0000000000000005` 的位置与 `SrcR = 0x8000000000000000` 比较后存放 `0x8000000000000000`，因为无符号序把该模式读作非常大的值；按有符号解读则会把它当作负数。

设计要点：该形式与 `LD.SMAX` 以不同规则比较同样的两个 64 位模式，因此只有当两个模式中恰好一个的第 `63` 位为 1 时，有符号与无符号两种写法才可能给出不同结果。即使地址与操作数完全相同，选错写法也会改变存储的字节。

设计要点：获胜者保持原有编码。访问宽度 `8` 意味着加载的双字与 `SrcR` 都按未修改的形式使用，因此存储写入的是两个输入模式之一，而绝不是规范化或扩展后的副本。

<!-- PTO-READER-BLOCK: scalar-ld-umax-inputs-outputs role=inputs-outputs -->
## 字段与操作数角色

`RegDst` 是位于指令位 `7..11` 的 `5` 位字段，`SrcL` 位于位 `15..19`，`SrcR` 位于位 `20..24`，`rl` 位于位 `25`，`aq` 位于位 `26`，`far` 位于位 `27`。

对 `SrcL` 与 `SrcR` 而言，全部 Reg5 源选择子都合法：`0` 读取架构零寄存器，`1` 到 `23` 读取 GPR，`24` 到 `27` 读取 `T#1` 到 `T#4`，`28` 到 `31` 读取 `U#1` 到 `U#4`；读取队列项不会改变它。目的地编码 `1` 到 `23` 写入 GPR，`0` 与 `24` 到 `29` 丢弃，`30` 压入 U，`31` 压入 T。

设计要点：`aq` 与 `rl` 为所记录的事件选择宽松、获取、释放或获取-释放排序，而 `far` 通过 `AtomicAddress` 进入地址路径，后者原样返回其参数；因此在参考模型中，选出较大值时该提示位不起作用。

<!-- PTO-READER-BLOCK: scalar-ld-umax-effects role=effects -->
## 效果

一次完成的 `LD.UMAX` 存储 8 字节、记录一个 `write_performed` 为 true 的原子事件、通过 `RegDst` 发布执行前的双字，并让 `TPC` 前进 4 字节。与保留的 64 字节粒度重叠的存储会清除本地保留。

设计要点：写入是无条件的，因此当操作数是较小的无符号值时，执行仍会写入旧的字节、仍把 `write_performed` 报告为 true，并且仍会使重叠的保留失效。

<!-- PTO-READER-BLOCK: scalar-ld-umax-constraints role=constraints -->
## 合法性与故障

地址必须按 8 字节对齐，并且必须通过权限与边界检查；写入预检会重复这两项检查，而且两个翻译地址必须相同。未对齐报告 `Fault_DataAlignment`，边界检查失败报告 `Fault_DataPage`，两者都以原始地址、都在加载之前报告。译码失败或所选 T 或 U 源不可用会最先引发 `Fault_IllegalInstruction`。任何故障之后都不写目的地、内存不变、不记录原子事件、不清除保留，也不推进 `TPC`。

设计要点：两次预检都在加载之前运行，因此被拒绝的执行不需要回滚：除了已报告的故障，内存与寄存器文件与之前完全一致。

<!-- PTO-READER-BLOCK: scalar-ld-umax-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当 `a0` 存放 8 字节对齐的地址时，`ld.umax [a0], a1, ->a2` 就地比较。若 `[a0]` 存放 `0x0000000000000005` 且 `a1` 存放 `0x8000000000000000`，该位置得到 `0x8000000000000000`，`a2` 得到 `0x0000000000000005`。

```text
ld.umax [a0], a1, ->a2
```
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.umax [SrcL], SrcR, ->Rd
ld.umax.aq [SrcL], SrcR, ->Rd
ld.umax.rl [SrcL], SrcR, ->Rd
ld.umax.f [SrcL], SrcR, ->Rd
ld.umax.aqrl [SrcL], SrcR, ->Rd
ld.umax.aqf [SrcL], SrcR, ->Rd
ld.umax.rlf [SrcL], SrcR, ->Rd
ld.umax.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_umax_32_a84af75745d9 | L32 | 32 | 0x6000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_umax_32_a84af75745d9 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_umax_32_a84af75745d9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_umax_32_a84af75745d9 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_umax_32_a84af75745d9 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_umax_32_a84af75745d9 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_umax_32_a84af75745d9 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_umax_32_a84af75745d9 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_umax_32_a84af75745d9 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_umax_32_a84af75745d9 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_umax_32_a84af75745d9 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_umax_32_a84af75745d9 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_umax_32_a84af75745d9 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.UMAX.asl -->
```asl
readonly func InstructionContractOperation_LD_UMAX() => ScalarOperation
begin
    return ScalarOperation_LD_UMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.UMAX.asl -->
```asl
readonly func InstructionContractHandler_LD_UMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_UMAX()
    => AtomicOperation
begin
    return Atomic_UMAX;
end;

pure func InstructionContractAtomicSizeBytes_LD_UMAX()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_UMAX()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_UMAX()
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
- LD.UMAX computes the unsigned maximum at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized unsigned maximum, and write one 8-byte result to the same location.
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

- ld.umax [a0], a1, ->a2
- ld.umax.aqrl [t#1], u#1, ->t
- ld.umax.f [sp], a0, ->u
