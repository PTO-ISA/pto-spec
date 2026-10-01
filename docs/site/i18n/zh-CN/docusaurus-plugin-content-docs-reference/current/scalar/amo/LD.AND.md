<!-- GENERATED FROM: asl/scalar/amo/LD.AND.asl -->
# LD.AND

**Normative ASL source:** `asl/scalar/amo/LD.AND.asl`

LD.AND atomically stores the width-sized bitwise AND and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LD-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-and-purpose role=purpose -->
## LD.AND 的作用

`LD.AND` 把某个内存地址上的 8 字节双字替换为该双字与一个 64 位操作数的按位与，并发布被替换的双字。地址读自 `SrcL`，操作数读自 `SrcR`，被替换的值通过 `RegDst` 发布。它是独立的编码形式，成功执行后让 `TPC` 前进 4 字节。

<!-- PTO-READER-BLOCK: scalar-ld-and-mechanism role=mechanism -->
## 掩码如何就地生效

该形式绑定语义处理器 `ScalarHandler_AtomicReadModifyWrite`、访问宽度 `8` 和原子操作 `Atomic_AND`。读取预检与写入预检都在触碰任何字节之前完成；随后才加载旧双字、与操作数按位与、写回同一位置，并记录一个 `write_performed` 为 true 的原子事件。

按位与覆盖全部 64 位。存储结果中的某位为 `1` 要求旧双字与操作数在该位都为 `1`，因此结果是两个输入按位意义上的子集：存放 `0xf0f0f0f0f0f0f0f0` 的位置与 `SrcR = 0x0ff00ff00ff00ff0` 相与后存放 `0x00f000f000f000f0`。

设计要点：访问宽度 `8` 的规范化是恒等映射，因此 `SrcR` 完全按寄存器提供的形式使用。按位与之前不发生字截断、符号扩展或掩码处理，而 `0xffffffffffffffff` 这类操作数无法改变任何存储位。

设计要点：存储是无条件的。即使操作数没有改变双字，它仍会写入同样的 8 字节、仍会记录 `write_performed` 为 true 的事件，并且仍会使与写入范围重叠的保留失效。

<!-- PTO-READER-BLOCK: scalar-ld-and-inputs-outputs role=inputs-outputs -->
## 字段与操作数角色

`RegDst` 是位于指令位 `7..11` 的 `5` 位字段，`SrcL` 位于位 `15..19`，`SrcR` 位于位 `20..24`，`rl` 位于位 `25`，`aq` 位于位 `26`，`far` 位于位 `27`。

- `SrcL` 提供原子地址，接受全部 Reg5 源选择子。
- `SrcR` 提供掩码；被选中的 T 或 U 项必须有效，读取时不会被消耗。
- `RegDst` 接收旧双字；编码 0 与编码 24..29 丢弃它，编码 30 压入 U，编码 31 压入 T。
- `aq` 与 `rl` 为原子事件选择宽松、获取、释放或获取-释放排序。
- `far` 作为路由提示被译码进地址路径。

设计要点：`AtomicAddress` 原样返回其参数，因此 `far` 不会改变访问位置；在参考模型中，`.f` 写法与普通写法读写同一个双字。

<!-- PTO-READER-BLOCK: scalar-ld-and-effects role=effects -->
## 效果

一次完成的执行写入 8 字节、记录一个 `write_performed` 为 true 的原子事件、发布执行前的双字，并让 `TPC` 前进 4 字节。

设计要点：目的地承载的是掩码之前的取值，因此把它与存储后的双字比较就能看出按位与清除了哪些位；指令本身不报告位数，也不写任何状态标志。

<!-- PTO-READER-BLOCK: scalar-ld-and-constraints role=constraints -->
## 合法性与故障

地址必须是 8 的倍数。

- 地址不是 8 的倍数时报告 `Fault_DataAlignment`，在加载之前、以原始地址报告。
- 地址超出允许区域时报告 `Fault_DataPage`。
- 译码失败或所选 T 或 U 源不可用时报告 `Fault_IllegalInstruction`，在任何效果之前引发。

设计要点：两次预检都在加载之前完成，因此发生故障的 `LD.AND` 不改变内存、不发布任何值、不记录原子事件、不清除保留，并让 `TPC` 停在保存的值上以便重新执行。

<!-- PTO-READER-BLOCK: scalar-ld-and-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

`ld.and [a0], a1, ->a2` 在 `a0` 存放 8 字节对齐地址时就地执行按位与。若 `[a0]` 存放 `0xf0f0f0f0f0f0f0f0` 且 `a1` 存放 `0x0ff00ff00ff00ff0`，该位置得到 `0x00f000f000f000f0`，`a2` 得到 `0xf0f0f0f0f0f0f0f0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld.and [SrcL], SrcR, ->Rd
ld.and.aq [SrcL], SrcR, ->Rd
ld.and.rl [SrcL], SrcR, ->Rd
ld.and.f [SrcL], SrcR, ->Rd
ld.and.aqrl [SrcL], SrcR, ->Rd
ld.and.aqf [SrcL], SrcR, ->Rd
ld.and.rlf [SrcL], SrcR, ->Rd
ld.and.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_and_32_2a46b3003480 | L32 | 32 | 0x1000400b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_and_32_2a46b3003480 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_and_32_2a46b3003480 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_and_32_2a46b3003480 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_and_32_2a46b3003480 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| ld_and_32_2a46b3003480 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| ld_and_32_2a46b3003480 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_and_32_2a46b3003480 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| ld_and_32_2a46b3003480 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| ld_and_32_2a46b3003480 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| ld_and_32_2a46b3003480 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| ld_and_32_2a46b3003480 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| ld_and_32_2a46b3003480 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LD.AND.asl -->
```asl
readonly func InstructionContractOperation_LD_AND() => ScalarOperation
begin
    return ScalarOperation_LD_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LD.AND.asl -->
```asl
readonly func InstructionContractHandler_LD_AND()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_AND()
    => AtomicOperation
begin
    return Atomic_AND;
end;

pure func InstructionContractAtomicSizeBytes_LD_AND()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_AND()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_AND()
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
- LD.AND computes the bitwise AND at 64-bit width and publishes the prior memory value only after a successful atomic commit.
- The published result is the unchanged 64-bit old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the width-sized bitwise AND, and write one 8-byte result to the same location.
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

- ld.and [a0], a1, ->a2
- ld.and.aqrl [t#1], u#1, ->t
- ld.and.f [sp], a0, ->u
