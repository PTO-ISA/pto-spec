<!-- GENERATED FROM: asl/scalar/amo/CASD.asl -->
# CASD

**Normative ASL source:** `asl/scalar/amo/CASD.asl`

CASD atomically compares and conditionally replaces one doubleword, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-CASD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-casd-purpose role=purpose -->
## CASD 的作用

`CASD` 是 8 字节的比较并交换：它读取 `SrcL` 指向地址处的双字，把全部 `64` 位与 `SrcR` 比较，仅当两个双字完全相同时才把 `SrcD` 写入该地址。

匹配与不匹配都会把原来的双字发布到 `RegDst`。`CASD` 是一个 32 位编码形式，成功执行使 `TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-casd-mechanism role=mechanism -->
## 比较整个双字

分发逻辑以 `size_bytes = 8` 调用 `CompareAndSwap`，因此读探测和写探测各覆盖 `8` 字节，并且只要地址不是 `8` 的倍数，两者都无法通过对齐检查。

`LoadTranslatedUnsigned` 从内存填满 `64` 位，而 `NormalizeAtomicUnsigned` 与 `NormalizeAtomicReturn` 都原样返回 `8` 字节值，因此载入的双字与发布的双字之间不存在扩展或截断步骤。

设计要点：宽度 `8` 在两个规范化函数中都是恒等情况，所以 `SrcR` 的每一位都参与比较，`SrcD` 的每一位都可被写入。高半部写错的期望值会匹配失败；较窄的形式则不同，它们在比较前就丢弃了那些位。

设计要点：`StoreTranslated` 逐字节写入 `SrcD` 的低 `8` 字节，而原子事件携带 `NormalizeAtomicUnsigned(desired, 8)`，即 `SrcD` 原值。因此事件中的新值与写入提交的字节是同一个值。

<!-- PTO-READER-BLOCK: scalar-casd-inputs-outputs role=inputs-outputs -->
## 字段、排序与选择器

该形式把 `SrcL` 编码在指令位 `15`，`SrcR` 在第 `20` 位，`SrcD` 在第 `27` 位，`RegDst` 在第 `7` 位，各宽 `5` 位，另有第 `25` 位的 `rl` 和第 `26` 位的 `aq`。

四种设置是 relaxed（`aq=0,rl=0`）、acquire（`aq=1,rl=0`）、release（`aq=0,rl=1`）和 acquire-release（`aq=1,rl=1`）；记录的原子事件在匹配与不匹配时携带相同的设置。

`SrcL`、`SrcR` 和 `SrcD` 接受全部 Reg5 源选择器，包括 T 与 U 选择器，读取它们不会消费队列条目。`RegDst` 接受全部 Reg5 目的选择器。

设计要点：编码为零的源读取架构零寄存器，因此 `casd` 在 `SrcR` 与 `SrcD` 都编码为零时，只与全零双字匹配，并在匹配时写入零。

<!-- PTO-READER-BLOCK: scalar-casd-effects role=effects -->
## 架构效果

匹配时把 `SrcD` 写入该地址，并记录一个 `write_performed=true` 的原子事件；不匹配时不写入任何内容，并记录一个 `write_performed=false` 的原子事件。

设计要点：在这一组里，只有这个宽度的发布值既不做零扩展也不做符号扩展。`RegDst` 收到的是内存中原有的 `64` 位，因此软件可以把目的值直接与全宽期望值比较。

设计要点：两条路径都会记录事件，而且即使 `write_performed=false`，事件中的新值仍是待写双字；事件读者既能看出提议写入的内容，也能看出内存中原有的内容。

两种无故障结果都会使 `TPC` 前进 `4` 字节；匹配时，若访问的 `8` 字节与保留的 64 字节粒度重叠，还会清除保留状态。

<!-- PTO-READER-BLOCK: scalar-casd-constraints role=constraints -->
## 对齐、访问与故障顺序

地址必须是 `8` 的倍数。`ProbeDataAccess` 在地址转换之前、以及在报告 `Fault_DataPage` 的权限检查之前执行该测试。

读探测先于写探测求值，并且在载入任何字节之前，两次转换后的地址必须一致。

发生故障时辅助函数立即返回：不载入、不写入、不记录原子事件、不改变保留状态、不写目的寄存器，也不前进 `TPC`，因此整个比较并交换可以重新执行。

报告的故障携带原始 `SrcL` 地址。解码失败，或所选 `T#1` 到 `T#4`、`U#1` 到 `U#4` 源不可用，会在处理函数运行之前抛出 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-casd-example role=example -->
## 一个匹配的双字

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

```asm
casd [a0], a1, a2, ->a3
```

假设该地址处的双字为 `0x0123456789abcdef`，`SrcR` 为 `0x0123456789abcdef`，`SrcD` 为 `0xffffffffffffffff`。全部 `64` 位都相等，于是 `CASD` 写入 `0xffffffffffffffff`，在 `RegDst` 中发布 `0x0123456789abcdef`，并记录一个 `write_performed=true` 的原子事件。

如果 `SrcR` 改为 `0x0123456789abcdee`，比较会在最后一位失败：内存保持 `0x0123456789abcdef`，记录的事件为 `write_performed=false`，`RegDst` 仍然收到 `0x0123456789abcdef`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
casd [SrcL], SrcR, SrcD, ->Rd
casd.aq [SrcL], SrcR, SrcD, ->Rd
casd.rl [SrcL], SrcR, SrcD, ->Rd
casd.aqrl [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| casd_32_5852c57277a6 | L32 | 32 | 0x0000301b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| casd_32_5852c57277a6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| casd_32_5852c57277a6 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| casd_32_5852c57277a6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| casd_32_5852c57277a6 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| casd_32_5852c57277a6 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| casd_32_5852c57277a6 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| casd_32_5852c57277a6 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| casd_32_5852c57277a6 | SrcD | 5 | 0–31 | none | none | Reg5 desired doubleword source | Encoded zero supplies numeric zero as the desired value. |
| casd_32_5852c57277a6 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| casd_32_5852c57277a6 | SrcR | 5 | 0–31 | none | none | Reg5 expected doubleword source | Encoded zero supplies numeric zero as the expected value. |
| casd_32_5852c57277a6 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| casd_32_5852c57277a6 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected doubleword source |
| SrcD | Reg5 desired doubleword source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASD.asl -->
```asl
readonly func InstructionContractOperation_CASD() => ScalarOperation
begin
    return ScalarOperation_CASD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASD.asl -->
```asl
readonly func InstructionContractHandler_CASD() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractHasFarField_CASD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_CASD()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcD, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- The short form has no far field and therefore uses the default flat-address route.

## Legality

- All 32 SrcL, SrcR, and SrcD Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq and rl combinations are assigned; the short form has implicit far zero.
- The effective address must be aligned to 8 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 64-bit old value is published unchanged.
- Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 8-byte doubleword and compare it with SrcR truncated to 8 bytes.
- On equality, store SrcD truncated to 8 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 64-bit old value is published unchanged.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- The short form always uses the default flat-address route.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- casd [a0], a1, a2, ->a3
- casd.aqrl [t#1], u#1, a0, ->u
