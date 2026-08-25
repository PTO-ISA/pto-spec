<!-- GENERATED FROM: asl/scalar/amo/LW.XOR.asl -->
# LW.XOR

**Normative ASL source:** `asl/scalar/amo/LW.XOR.asl`

LW.XOR atomically stores the width-sized bitwise XOR and publishes the prior memory value.

## Normative identity {#PTO-INST-SCALAR-LW-XOR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lw-xor-purpose role=purpose -->
## LW.XOR 的作用

`LW.XOR` 对一个字原子执行按位异或、存储结果，并发布先前的内存值。

<!-- PTO-READER-BLOCK: scalar-lw-xor-mechanism role=mechanism -->
## 原子机制

ASL DOC 契约选择 `ScalarHandler_AtomicReadModifyWrite`，访问宽度为 `4` 字节。

只有读取与写入访问都完成预检后，同一位置的原子读改写才能提交。

<!-- PTO-READER-BLOCK: scalar-lw-xor-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 承载 Reg5 原子地址源；`SrcR` 承载 Reg5 原子操作数源；`RegDst` 承载 Reg5 旧值目的地；`aq` 承载获取排序位；`rl` 承载释放排序位；`far` 承载平坦地址路由提示。

`aq` 与 `rl` 选择宽松、获取、释放或获取-释放排序；`far` 是配置档路由提示，在参考配置档中不改变架构结果。

<!-- PTO-READER-BLOCK: scalar-lw-xor-effects role=effects -->
## 效果与排序

只有读改写提交后才会发布旧内存值；任何目的地效果之前都会先捕获源别名。

完成的写入会使重叠的本地 64 字节缓存行保留失效，保留不重叠的保留，并让 `TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-lw-xor-constraints role=constraints -->
## 合法性与精确故障

有效地址必须按 `4` 字节对齐。对齐、地址翻译和权限检查都先于架构效果。

预检失败时不会发布目的值、内存事件、保留更新或退役效果；保存的原始 `TPC` 支持完整重新执行。

<!-- PTO-READER-BLOCK: scalar-lw-xor-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

初次阅读可从 `lw.xor [SrcL], SrcR, ->Rd` 开始，再只改变上文说明的排序或路由修饰位。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lw.xor [SrcL], SrcR, ->Rd
lw.xor.aq [SrcL], SrcR, ->Rd
lw.xor.rl [SrcL], SrcR, ->Rd
lw.xor.f [SrcL], SrcR, ->Rd
lw.xor.aqrl [SrcL], SrcR, ->Rd
lw.xor.aqf [SrcL], SrcR, ->Rd
lw.xor.rlf [SrcL], SrcR, ->Rd
lw.xor.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lw_xor_32_4d4aa82c676a | L32 | 32 | 0x3000200b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lw_xor_32_4d4aa82c676a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lw_xor_32_4d4aa82c676a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lw_xor_32_4d4aa82c676a | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lw_xor_32_4d4aa82c676a | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lw_xor_32_4d4aa82c676a | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lw_xor_32_4d4aa82c676a | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lw_xor_32_4d4aa82c676a | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the published old value. |
| lw_xor_32_4d4aa82c676a | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| lw_xor_32_4d4aa82c676a | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| lw_xor_32_4d4aa82c676a | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lw_xor_32_4d4aa82c676a | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lw_xor_32_4d4aa82c676a | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LW.XOR.asl -->
```asl
readonly func InstructionContractOperation_LW_XOR() => ScalarOperation
begin
    return ScalarOperation_LW_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LW.XOR.asl -->
```asl
readonly func InstructionContractHandler_LW_XOR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LW_XOR()
    => AtomicOperation
begin
    return Atomic_XOR;
end;

pure func InstructionContractAtomicSizeBytes_LW_XOR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_LW_XOR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LW_XOR()
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
- LW.XOR computes the bitwise XOR at 32-bit width and publishes the prior memory value only after a successful atomic commit.
- The published old value is sign-extended from 32 bits to XLEN.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the width-sized bitwise XOR, and write one 4-byte result to the same location.
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

- lw.xor [a0], a1, ->a2
- lw.xor.aqrl [t#1], u#1, ->t
- lw.xor.f [sp], a0, ->u
