<!-- GENERATED FROM: asl/scalar/amo/LD.OR.asl -->
# LD.OR

**Normative ASL source:** `asl/scalar/amo/LD.OR.asl`

LD.OR atomically stores the width-sized bitwise OR and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-or-purpose role=purpose -->
## LD.OR 的作用

`LD.OR` 在一个 8 字节内存双字中置位：64 位操作数中为 `1` 的每一位在存储值中都变为 `1`，而指令执行前该处的双字通过 `RegDst` 发布。

地址是 `SrcL`，操作数是 `SrcR`。该形式宽 32 位，完成时让 `TPC` 前进 4 字节。

<!-- PTO-READER-BLOCK: scalar-ld-or-mechanism role=mechanism -->
## 操作数如何与已存双字结合

处理器是 `ScalarHandler_AtomicReadModifyWrite`，访问宽度 `8`，原子操作 `Atomic_OR`。读取预检与写入预检就同一个翻译地址达成一致后，旧双字被加载、与操作数按位或、写回同一位置，并记录为一个 `write_performed` 为 true 的原子事件。

由于按位或只能把 `0` 变成 `1`，存储值是旧双字的按位超集：存放 `0x00000000000000f0` 的位置与 `SrcR = 0x0000000000000f00` 相或后存放 `0x0000000000000ff0`。

设计要点：该形式无法清除任何已存储的位，而且该操作是幂等的，因此同一个操作数执行两次会在两次都存储相同的位。需要清除位的程序要使用 AND 形式，并在寄存器中保存其补码。

设计要点：`SrcL` 在目的地被写入之前读取，因此 `RegDst` 可以与 `SrcL` 是同一个寄存器而不改变所访问的位置；发布的旧双字只是落到了原本提供地址的那个寄存器里。

<!-- PTO-READER-BLOCK: scalar-ld-or-inputs-outputs role=inputs-outputs -->
## 字段与操作数角色

`RegDst` 是位于指令位 `7..11` 的 `5` 位字段，`SrcL` 位于位 `15..19`，`SrcR` 位于位 `20..24`，`rl` 位于位 `25`，`aq` 位于位 `26`，`far` 位于位 `27`。

源操作数通过 Reg5 选择子读取：`0` 读取架构零寄存器，`1` 到 `23` 读取绝对 GPR，`24` 到 `27` 读取 `T#1` 到 `T#4`，`28` 到 `31` 读取 `U#1` 到 `U#4` 且不消耗队列项。`aq` 与 `rl` 为所记录的事件选择宽松、获取、释放或获取-释放排序。

设计要点：`far` 会到达 `AtomicAddress`，而后者原样返回地址，因此在参考模型中 `.f` 写法不会改变访问位置；该位选择的是参考模型并不据此行动的配置档路由提示。

<!-- PTO-READER-BLOCK: scalar-ld-or-effects role=effects -->
## 效果

一次完成的执行在目标地址存储 8 字节、记录一个 `write_performed` 为 true 的原子事件、在 `RegDst` 不是丢弃型目的地时通过它发布执行前的双字，并让 `TPC` 前进 4 字节。与保留的 64 字节粒度重叠的写入会清除本地保留。

设计要点：由于目的地承载执行前的取值，一次执行同时暴露两个结果：内存中是新的位，而 `RegDst` 中是旧的位。该操作不写任何状态标志。

<!-- PTO-READER-BLOCK: scalar-ld-or-constraints role=constraints -->
## 合法性与故障

两次预检守护该访问，写入预检会为写权限重复这些检查。未对齐的地址在加载之前以原始地址引发 `Fault_DataAlignment`；超出允许区域的地址引发 `Fault_DataPage`。所选 T 或 U 源不可用或译码失败会更早引发 `Fault_IllegalInstruction`。任何故障之后都不发布值、内存不变、不记录原子事件、不清除保留，且 `TPC` 停在保存的值上。

设计要点：两次预检都在加载之前完成，而参考模型的读写访问判定来自同一个边界检查，因此任一次预检都可能报告 `Fault_DataPage`，且报告的始终是原始地址。

<!-- PTO-READER-BLOCK: scalar-ld-or-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

`ld.or [a0], a1, ->a2` 在 `a0` 存放 8 字节对齐地址时就地置位。当 `[a0]` 存放 `0x00000000000000f0`、`a1` 存放 `0x0000000000000f00` 时，该位置得到 `0x0000000000000ff0`，`a2` 得到 `0x00000000000000f0`。

```text
ld.or [a0], a1, ->a2
```
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.or [SrcL], SrcR, ->Rd
ld.or.aq [SrcL], SrcR, ->Rd
ld.or.rl [SrcL], SrcR, ->Rd
ld.or.f [SrcL], SrcR, ->Rd
ld.or.aqrl [SrcL], SrcR, ->Rd
ld.or.aqf [SrcL], SrcR, ->Rd
ld.or.rlf [SrcL], SrcR, ->Rd
ld.or.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_or_32_456d270cfc7d | L32 | 32 | 0x2000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_or_32_456d270cfc7d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_or_32_456d270cfc7d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_or_32_456d270cfc7d | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_or_32_456d270cfc7d | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_or_32_456d270cfc7d | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_or_32_456d270cfc7d | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_or_32_456d270cfc7d | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_or_32_456d270cfc7d | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_or_32_456d270cfc7d | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_or_32_456d270cfc7d | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_or_32_456d270cfc7d | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_or_32_456d270cfc7d | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.OR.asl -->
```asl
readonly func InstructionContractOperation_LD_OR() => ScalarOperation
begin
    return ScalarOperation_LD_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.OR.asl -->
```asl
readonly func InstructionContractHandler_LD_OR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_OR()
    => AtomicOperation
begin
    return Atomic_OR;
end;

pure func InstructionContractAtomicSizeBytes_LD_OR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_OR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_OR()
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
- LD.OR computes the bitwise OR at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized bitwise OR, and write one 8-byte result to the same location.
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

- ld.or [a0], a1, ->a2
- ld.or.aqrl [t#1], u#1, ->t
- ld.or.f [sp], a0, ->u
