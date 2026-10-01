<!-- GENERATED FROM: asl/scalar/amo/LW.ADD.asl -->
# LW.ADD

**Normative ASL source:** `asl/scalar/amo/LW.ADD.asl`

LW.ADD atomically stores the modular 32-bit sum and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LW-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lw-add-purpose role=purpose -->
## LW.ADD 的作用

`LW.ADD` 把一个操作数加到一个 4 字节内存字上，把和的低 32 位写回同一个字，并发布指令执行前该处的字。地址来自 `SrcL`，操作数来自 `SrcR`，发布值来自执行前的内存内容。

<!-- PTO-READER-BLOCK: scalar-lw-add-mechanism role=mechanism -->
## 如何累加进一个 32 位字

该形式绑定 `ScalarHandler_AtomicReadModifyWrite`、访问宽度 `4` 和原子操作 `Atomic_ADD`。读取预检与写入预检都覆盖同样的 4 字节；随后该字被加载、截断到低 32 位、与 `SrcR` 的低 32 位相加，32 位结果被写回。同时记录一个 `write_performed` 为 true 的原子事件。

运算在 32 位上取模。存放 `0x7fffffff` 的字加上 `SrcR = 0x0000000000000001` 后存储 `0x80000000`；存放 `0xffffffff` 的字加上同一操作数后存储 `0x0`。

设计要点：截断发生在加法之前，第 31 位的进位被丢弃，因此 `SrcR` 的高 32 位绝不会影响存储的字。访问宽度 `4` 同时决定对齐规则：地址必须是 4 的倍数。

设计要点：发布值遵循与存储字节不同的规则。`RegDst` 接收的是符号扩展到 `XLEN` 的旧字，因此存放 `0xffffffff` 的字会发布 `0xffffffffffffffff`，而存储写入的是 `0x0`；把目的地按有符号 64 位值读取即可还原被替换的字。

<!-- PTO-READER-BLOCK: scalar-lw-add-inputs-outputs role=inputs-outputs -->
## 字段与操作数角色

`RegDst` 是位于指令位 `7..11` 的 `5` 位字段，`SrcL` 位于位 `15..19`，`SrcR` 位于位 `20..24`，`rl` 位于位 `25`，`aq` 位于位 `26`，`far` 位于位 `27`。

`SrcL` 提供地址，`SrcR` 提供操作数；两者都接受全部 Reg5 源选择子，被选中的 T 或 U 项必须有效且不会被消耗。`RegDst` 接收发布值：编码 `0` 与编码 `24` 到 `29` 丢弃它，编码 `30` 压入 U，编码 `31` 压入 T，编码 `1` 到 `23` 写入所指的 GPR。

设计要点：`aq` 与 `rl` 为原子事件选择宽松、获取、释放或获取-释放排序，而 `far` 被译码并传给 `AtomicAddress`，后者原样返回地址，因此在参考模型中 `lw.add` 与 `lw.add.f` 访问同一个字。

<!-- PTO-READER-BLOCK: scalar-lw-add-effects role=effects -->
## 效果

一次完成的 `LW.ADD` 写入 4 字节、记录一个 `write_performed` 为 true 的原子事件、发布符号扩展后的执行前字，并让 `TPC` 前进 4 字节。若写入的 4 字节与保留的 64 字节粒度重叠，本地保留会被清除。

设计要点：只有目标字发生变化。即使加法在第 31 位产生进位，同一个 8 字节双字中相邻的 4 字节仍保持原内容，因为存储宽度固定为 4 字节。

<!-- PTO-READER-BLOCK: scalar-lw-add-constraints role=constraints -->
## 合法性与故障

地址必须是 4 的倍数。读取预检对未对齐的地址报告 `Fault_DataAlignment`，对超出允许区域的地址报告 `Fault_DataPage`，两者都在加载之前、都以原始地址报告；写入预检重复这些检查，并且两个翻译地址必须相同。译码失败或所选 T 或 U 源不可用会在任何效果之前引发 `Fault_IllegalInstruction`。发生故障时不发布任何值、内存不变、不记录原子事件、保留不变，`TPC` 也不变。

设计要点：两次预检都在加载之前完成，而参考模型的读写判定来自同一个边界检查，因此被拒绝的访问不会触及该字，且报告的故障携带的是程序提供的地址，而不是任何翻译后的形式。

<!-- PTO-READER-BLOCK: scalar-lw-add-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当 `a0` 存放 4 字节对齐的地址时，`lw.add [a0], a1, ->a2` 把 `a1` 的低 32 位加到 `[a0]` 处的字上。若该字存放 `0x7fffffff` 且 `a1` 存放 `0x0000000000000001`，该位置得到 `0x80000000`，`a2` 得到 `0x000000007fffffff`。

若该字存放 `0xffffffff` 且 `a1` 存放 `0x0000000000000001`，该位置得到 `0x0`，`a2` 得到 `0xffffffffffffffff`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lw.add [SrcL], SrcR, ->Rd
lw.add.aq [SrcL], SrcR, ->Rd
lw.add.rl [SrcL], SrcR, ->Rd
lw.add.f [SrcL], SrcR, ->Rd
lw.add.aqrl [SrcL], SrcR, ->Rd
lw.add.aqf [SrcL], SrcR, ->Rd
lw.add.rlf [SrcL], SrcR, ->Rd
lw.add.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lw_add_32_5be3ad1ad081 | L32 | 32 | 0x0000200b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lw_add_32_5be3ad1ad081 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lw_add_32_5be3ad1ad081 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lw_add_32_5be3ad1ad081 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lw_add_32_5be3ad1ad081 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lw_add_32_5be3ad1ad081 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lw_add_32_5be3ad1ad081 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lw_add_32_5be3ad1ad081 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| lw_add_32_5be3ad1ad081 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| lw_add_32_5be3ad1ad081 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| lw_add_32_5be3ad1ad081 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lw_add_32_5be3ad1ad081 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lw_add_32_5be3ad1ad081 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LW.ADD.asl -->
```asl
readonly func InstructionContractOperation_LW_ADD() => ScalarOperation
begin
    return ScalarOperation_LW_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LW.ADD.asl -->
```asl
readonly func InstructionContractHandler_LW_ADD() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LW_ADD()
    => AtomicOperation
begin
    return Atomic_ADD;
end;

pure func InstructionContractAtomicSizeBytes_LW_ADD()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_LW_ADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LW_ADD()
    => boolean
begin
    return TRUE;
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
- The effective address must be aligned to 4 bytes. aq, rl, and far have no reserved combinations.

## State effects

- Snapshot SrcL and SrcR before every memory or destination effect, so GPR and T/U source aliases observe the pre-instruction values.
- LW.ADD computes the modular sum at 32-bit width and publishes the prior memory value only after a successful atomic commit.
- The published old value is sign-extended from 32 bits to XLEN.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the modular 32-bit sum, and write one 4-byte result to the same location.
- On success, record one atomic memory event. A completed overlapping write invalidates the overlapping local reservation; a nonoverlapping reservation remains valid.
- The published old value is sign-extended from 32 bits to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- Read and write access probes both complete before the memory load or store, and both probes must resolve to the same translated address.
- On a fault, the instruction publishes no destination, performs no load, store, event, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores that TPC for full reissue.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- lw.add [a0], a1, ->a2
- lw.add.aqrl [t#1], u#1, ->t
- lw.add.f [sp], a0, ->u
