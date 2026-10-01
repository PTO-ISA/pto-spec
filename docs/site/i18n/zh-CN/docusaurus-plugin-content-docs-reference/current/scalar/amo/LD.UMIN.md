<!-- GENERATED FROM: asl/scalar/amo/LD.UMIN.asl -->
# LD.UMIN

**Normative ASL source:** `asl/scalar/amo/LD.UMIN.asl`

LD.UMIN atomically stores the width-sized unsigned minimum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-UMIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-umin-purpose role=purpose -->
## LD.UMIN 的作用

`LD.UMIN` 把两个 64 位模式中较小的那个存储到某个内存地址，并按无符号整数为它们排序。操作数来自 `SrcR`，地址来自 `SrcL`，被替换的双字通过 `RegDst` 发布。

参与比较的是完整的 8 字节访问宽度，因此两个值的任何部分都不会被截断或重新解读。

<!-- PTO-READER-BLOCK: scalar-ld-umin-mechanism role=mechanism -->
## 如何保留较小的无符号值

该形式绑定 `ScalarHandler_AtomicReadModifyWrite`、访问宽度 `8` 和原子操作 `Atomic_UMIN`。两次访问预检先运行；随后旧双字被加载、与 `SrcR` 按无符号值比较，较小的一个被写回，并记录一个 `write_performed` 为 true 的原子事件。

在无符号序下，最高位置位会让模式的数值变得很大。存放 `0x8000000000000000` 的位置与 `SrcR = 0x0000000000000005` 比较后保留 `5`，因为 `0x8000000000000000` 是更大的无符号数；同样的两个模式在 `LD.SMIN` 下则会保留第 63 位为 1 的那个模式，而它按有符号解读是负数。

设计要点：相等时存储操作数。当两个无符号值相等时，操作数的模式已经是旧双字的模式，因此目标字节不发生变化，而这次执行仍然算作一次已执行的原子写入。

设计要点：操作数不会被转换。访问宽度 `8` 对应恒等规范化，因此高位置位的 `SrcR` 会作为完整的 64 位值参与比较，而不是作为低位字。

<!-- PTO-READER-BLOCK: scalar-ld-umin-inputs-outputs role=inputs-outputs -->
## 字段与操作数角色

`RegDst` 是位于指令位 `7..11` 的 `5` 位字段，`SrcL` 位于位 `15..19`，`SrcR` 位于位 `20..24`，`rl` 位于位 `25`，`aq` 位于位 `26`，`far` 位于位 `27`。

- `SrcL` 读取原子地址；选择子 `0` 读取架构零寄存器。
- `SrcR` 读取被比较的值；T 或 U 选择子必须指向有效项，并且不会消耗该项。
- `RegDst` 接收发布值；目的地编码 `0` 与编码 `24` 到 `29` 丢弃它，编码 `30` 压入 U，编码 `31` 压入 T。

设计要点：`aq` 与 `rl` 为原子事件选择宽松、获取、释放或获取-释放排序，而 `far` 被译码并传给 `AtomicAddress`，后者原样返回其参数，因此在参考模型中该提示位不影响地址、比较和发布值。

<!-- PTO-READER-BLOCK: scalar-ld-umin-effects role=effects -->
## 效果

一次完成的执行写入 8 字节、记录一个 `write_performed` 为 true 的原子事件、发布执行前的双字，并让 `TPC` 前进 4 字节。若写入范围与保留的 64 字节粒度重叠，本地保留会被清除。

<!-- PTO-READER-BLOCK: scalar-ld-umin-constraints role=constraints -->
## 合法性与故障

地址必须是 8 的倍数。读取预检对未对齐的地址引发 `Fault_DataAlignment`，对超出允许区域的地址引发 `Fault_DataPage`，两者都在加载之前、都以原始地址报告；写入预检重复这些检查，并且两个翻译地址必须相同。对于译码失败或所选 T 或 U 源不可用，`Fault_IllegalInstruction` 先于上述一切引发。发生故障的执行没有部分效果，也不推进 `TPC`。

设计要点：故障时不发布任何值，因此目的地寄存器保持原有内容，之后读取它得到的是原有内容而不是某次比较的结果。

<!-- PTO-READER-BLOCK: scalar-ld-umin-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

`ld.umin [a0], a1, ->a2` 在 `a0` 存放 8 字节对齐地址时把已存双字与 `a1` 比较。当 `[a0]` 存放 `0x8000000000000000`、`a1` 存放 `0x0000000000000005` 时，该位置得到 `0x0000000000000005`，`a2` 得到 `0x8000000000000000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.umin [SrcL], SrcR, ->Rd
ld.umin.aq [SrcL], SrcR, ->Rd
ld.umin.rl [SrcL], SrcR, ->Rd
ld.umin.f [SrcL], SrcR, ->Rd
ld.umin.aqrl [SrcL], SrcR, ->Rd
ld.umin.aqf [SrcL], SrcR, ->Rd
ld.umin.rlf [SrcL], SrcR, ->Rd
ld.umin.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_umin_32_4bf2f357eff3 | L32 | 32 | 0x7000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_umin_32_4bf2f357eff3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_umin_32_4bf2f357eff3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_umin_32_4bf2f357eff3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_umin_32_4bf2f357eff3 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_umin_32_4bf2f357eff3 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_umin_32_4bf2f357eff3 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_umin_32_4bf2f357eff3 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_umin_32_4bf2f357eff3 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_umin_32_4bf2f357eff3 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_umin_32_4bf2f357eff3 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_umin_32_4bf2f357eff3 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_umin_32_4bf2f357eff3 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.UMIN.asl -->
```asl
readonly func InstructionContractOperation_LD_UMIN() => ScalarOperation
begin
    return ScalarOperation_LD_UMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.UMIN.asl -->
```asl
readonly func InstructionContractHandler_LD_UMIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_UMIN()
    => AtomicOperation
begin
    return Atomic_UMIN;
end;

pure func InstructionContractAtomicSizeBytes_LD_UMIN()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_UMIN()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_UMIN()
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
- LD.UMIN computes the unsigned minimum at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized unsigned minimum, and write one 8-byte result to the same location.
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

- ld.umin [a0], a1, ->a2
- ld.umin.aqrl [t#1], u#1, ->t
- ld.umin.f [sp], a0, ->u
