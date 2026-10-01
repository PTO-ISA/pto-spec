<!-- GENERATED FROM: asl/scalar/amo/LD.SMAX.asl -->
# LD.SMAX

**Normative ASL source:** `asl/scalar/amo/LD.SMAX.asl`

LD.SMAX atomically stores the width-sized signed maximum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-SMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-smax-purpose role=purpose -->
## LD.SMAX 的作用

`LD.SMAX` 用该 8 字节内存双字与一个 64 位操作数中较大的一个替换该双字，两者都按有符号二进制补码解读。指令执行前内存中的值通过 `RegDst` 发布。

<!-- PTO-READER-BLOCK: scalar-ld-smax-mechanism role=mechanism -->
## 如何选出较大的有符号值

该形式经由 `ScalarHandler_AtomicReadModifyWrite` 运行，访问宽度 `8`，原子操作 `Atomic_SMAX`：读取预检、写入预检、加载、有符号比较、存储获胜者、记录一个 `write_performed` 为 true 的原子事件，并返回旧双字以供发布。

负数模式会输给一个小的正数。存放 `0xfffffffffffffffd`（即 `-3`）的位置与 `SrcR = 0x0000000000000005` 比较后存放 `0x0000000000000005`。

设计要点：符号位决定比较结果。若按 `LD.UMAX` 的无符号规则比较同样的两个模式，反而会保留 `0xfffffffffffffffd`，因为无符号序把它读作极大的数；这两个形式接受相同的操作数，区别只在于如何解读它们。

设计要点：只写入获胜者的字节。在访问宽度 `8` 下取值按加载时的形式使用，因此存储的双字要么是旧模式、要么是操作数，绝不会是转换后的形式。

<!-- PTO-READER-BLOCK: scalar-ld-smax-inputs-outputs role=inputs-outputs -->
## 字段与操作数角色

`RegDst` 是位于指令位 `7..11` 的 `5` 位字段，`SrcL` 位于位 `15..19`，`SrcR` 位于位 `20..24`，`rl` 位于位 `25`，`aq` 位于位 `26`，`far` 位于位 `27`。

`SrcL` 是地址源，`SrcR` 是操作数源。编码为零的源读取架构零寄存器；选择子 `24` 到 `27` 读取 `T#1` 到 `T#4`，`28` 到 `31` 读取 `U#1` 到 `U#4`，且不消耗队列项。编码为零的目的地丢弃发布值，编码 `24` 到 `29` 也同样丢弃；编码 `30` 压入 U，编码 `31` 压入 T。

设计要点：`far` 只是路由提示。它被译码并传给 `AtomicAddress`，后者原样返回地址，因此在参考模型中 `.f` 写法无法把比较重定向到另一个双字。

<!-- PTO-READER-BLOCK: scalar-ld-smax-effects role=effects -->
## 效果

一次完成的 `LD.SMAX` 向目标地址写入 8 字节、记录一个 `write_performed` 为 true 的原子事件、发布执行前的双字，并让 `TPC` 前进 4 字节。与保留的 64 字节粒度重叠的写入会清除本地保留。

设计要点：该存储不是有条件的。当操作数是较小值时，旧双字被原样写回，`write_performed` 仍为 true，重叠的保留也仍会被清除。

<!-- PTO-READER-BLOCK: scalar-ld-smax-constraints role=constraints -->
## 合法性与故障

地址必须按 8 字节对齐。对齐先于翻译检查，翻译先于权限与边界检查；写入预检会为写访问重复这一顺序，而且两个翻译地址必须相同。`Fault_DataAlignment` 与 `Fault_DataPage` 都在原始地址上报告，译码失败或所选 T 或 U 源不可用则更早引发 `Fault_IllegalInstruction`。发生故障时不发布任何值、不加载或存储任何字节、不记录原子事件、不改变保留，也不推进 `TPC`。

<!-- PTO-READER-BLOCK: scalar-ld-smax-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当 `a0` 存放 8 字节对齐的地址时，`ld.smax [a0], a1, ->a2` 就地比较。若 `[a0]` 存放 `0xfffffffffffffffd` 且 `a1` 存放 `0x0000000000000005`，该位置得到 `0x0000000000000005`，`a2` 得到 `0xfffffffffffffffd`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.smax [SrcL], SrcR, ->Rd
ld.smax.aq [SrcL], SrcR, ->Rd
ld.smax.rl [SrcL], SrcR, ->Rd
ld.smax.f [SrcL], SrcR, ->Rd
ld.smax.aqrl [SrcL], SrcR, ->Rd
ld.smax.aqf [SrcL], SrcR, ->Rd
ld.smax.rlf [SrcL], SrcR, ->Rd
ld.smax.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_smax_32_a3aad6120226 | L32 | 32 | 0x4000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_smax_32_a3aad6120226 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_smax_32_a3aad6120226 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_smax_32_a3aad6120226 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_smax_32_a3aad6120226 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_smax_32_a3aad6120226 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_smax_32_a3aad6120226 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_smax_32_a3aad6120226 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_smax_32_a3aad6120226 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_smax_32_a3aad6120226 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_smax_32_a3aad6120226 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_smax_32_a3aad6120226 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_smax_32_a3aad6120226 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.SMAX.asl -->
```asl
readonly func InstructionContractOperation_LD_SMAX() => ScalarOperation
begin
    return ScalarOperation_LD_SMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.SMAX.asl -->
```asl
readonly func InstructionContractHandler_LD_SMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_SMAX()
    => AtomicOperation
begin
    return Atomic_SMAX;
end;

pure func InstructionContractAtomicSizeBytes_LD_SMAX()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_SMAX()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_SMAX()
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
- LD.SMAX computes the signed maximum at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized signed maximum, and write one 8-byte result to the same location.
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

- ld.smax [a0], a1, ->a2
- ld.smax.aqrl [t#1], u#1, ->t
- ld.smax.f [sp], a0, ->u
