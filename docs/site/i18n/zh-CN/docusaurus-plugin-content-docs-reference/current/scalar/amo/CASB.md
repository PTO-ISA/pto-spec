<!-- GENERATED FROM: asl/scalar/amo/CASB.asl -->
# CASB

**Normative ASL source:** `asl/scalar/amo/CASB.asl`

CASB atomically compares and conditionally replaces one byte, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-CASB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-casb-purpose role=purpose -->
## CASB 的作用

`CASB` 把 `SrcL` 指向地址处的字节与 `SrcR` 的低字节比较，并在两个字节相等时把 `SrcD` 的低字节写回该地址。不相等时内存保持不变。

两种无故障结果都会把指令执行前内存中的字节发布到 `RegDst`。`CASB` 是一个 32 位编码形式，成功执行使 `TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-casb-mechanism role=mechanism -->
## 字节比较并交换的执行过程

分发逻辑读取 `SrcL`、`SrcR` 和 `SrcD`，然后以 `1` 字节的访问宽度调用共享的 `CompareAndSwap` 辅助函数。该函数先探测地址的读访问，再探测同一地址的写访问，并要求两次探测给出同一个转换后地址。

随后它从该转换后地址载入字节，并与期望值比较。相等时写入待写字节；不相等时不写入任何内容。两种情况下都会记录一个原子事件，其 `write_performed` 标志等于比较结果。

设计要点：`NormalizeAtomicUnsigned` 只扩展 `value[7:0]`，因此 `SrcR` 的第 `8` 到第 `63` 位不会进入比较。期望值为 `0xffffffffffffff7f` 时仍能与内存字节 `0x7f` 匹配，所以 `SrcR` 中未做掩码的机器字按原样生效。

设计要点：读探测要求 `1` 字节对齐，而 `ProbeDataAccess` 只在 `UInt(address) MOD 1` 非零时报告 `Fault_DataAlignment`。该余数恒为零，因此对 `CASB` 来说对齐故障不可达；它能抛出的第一个地址故障是权限与边界检查给出的 `Fault_DataPage`。

<!-- PTO-READER-BLOCK: scalar-casb-inputs-outputs role=inputs-outputs -->
## 编码字段与选择器

该形式把 `SrcL` 编码在指令位 `15`，`SrcR` 在第 `20` 位，`SrcD` 在第 `27` 位，`RegDst` 在第 `7` 位，各宽 `5` 位，另有第 `25` 位的 `rl` 和第 `26` 位的 `aq`。

`aq=0,rl=0` 记录 relaxed 排序，`aq=1,rl=0` 为 acquire，`aq=0,rl=1` 为 release，`aq=1,rl=1` 为 acquire-release；匹配与不匹配都记录同样的排序。

`SrcL`、`SrcR` 和 `SrcD` 接受全部 Reg5 源选择器，读取 T 或 U 条目不会把它从队列中取出。`RegDst` 接受全部 Reg5 目的选择器。

设计要点：这个 32 位形式没有 `far` 位，所以编码无法请求路由提示。缺失字段解码为零，而 `AtomicAddress` 原样返回其参数，因此 `SrcL` 指向的字节就是指令访问的字节。

<!-- PTO-READER-BLOCK: scalar-casb-effects role=effects -->
## 指令产生的改变

匹配时写入 `SrcD` 的低字节并记录一个 `write_performed=true` 的原子事件；不匹配时记录一个 `write_performed=false` 的原子事件，内存保持不变。

两条无故障路径上 `RegDst` 都会收到 `ZeroExtend{PTO_XLEN}(old_value[7:0])`，所以无论比较结果如何都会报告原来的字节。匹配时，如果写入的字节与保留的 64 字节粒度重叠，还会清除保留状态。

设计要点：由 `8` 位零扩展得到的值不可能是负数。写入字节 `0x80` 发布的是 `0x0000000000000080`，而不是 `0xffffffffffffff80`，所以需要带符号字节的软件必须自行对第 `7` 位做符号扩展。

成功执行使 `TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-casb-constraints role=constraints -->
## 对齐、故障与重新执行

`CASB` 在访问内存之前完成读探测、写探测和转换后地址相等性检查，因此失败的访问不会留下部分效果。

报告的故障携带原始 `SrcL` 地址。发生故障后辅助函数在载入之前返回：没有原子事件、没有保留状态改变、也没有目的写入，因为分发逻辑只在 `_LastFault` 为 `Fault_None` 时才发布。

`TPC` 不会前进，因此整个比较并交换可以重新执行。解码失败，或所选 `T#1` 到 `T#4`、`U#1` 到 `U#4` 源不可用，会在处理函数运行之前抛出 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-casb-example role=example -->
## 一个匹配的字节

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

假设该地址处的字节为 `0x7f`，`SrcR` 在低字节给出 `0x7f`，`SrcD` 给出 `0x80`。比较成功：`CASB` 写入 `0x80`，记录一个 `write_performed=true` 的原子事件，并在 `RegDst` 中发布 `0x000000000000007f`。

如果 `SrcR` 的低字节改为 `0x00`，那么内存仍保持 `0x7f`，事件记录 `write_performed=false`，`RegDst` 仍然收到 `0x000000000000007f`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
casb [SrcL], SrcR, SrcD, ->Rd
casb.aq [SrcL], SrcR, SrcD, ->Rd
casb.rl [SrcL], SrcR, SrcD, ->Rd
casb.aqrl [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| casb_32_7e529b871832 | L32 | 32 | 0x0000001b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| casb_32_7e529b871832 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| casb_32_7e529b871832 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| casb_32_7e529b871832 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| casb_32_7e529b871832 | SrcD | 5 | 0–31 | none | none | Reg5 desired byte source | Encoded zero supplies numeric zero as the desired value. |
| casb_32_7e529b871832 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| casb_32_7e529b871832 | SrcR | 5 | 0–31 | none | none | Reg5 expected byte source | Encoded zero supplies numeric zero as the expected value. |
| casb_32_7e529b871832 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| casb_32_7e529b871832 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected byte source |
| SrcD | Reg5 desired byte source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASB.asl -->
```asl
readonly func InstructionContractOperation_CASB() => ScalarOperation
begin
    return ScalarOperation_CASB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASB.asl -->
```asl
readonly func InstructionContractHandler_CASB() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractHasFarField_CASB()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_CASB()
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
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 8-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 1-byte byte and compare it with SrcR truncated to 1 bytes.
- On equality, store SrcD truncated to 1 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 8-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- The short form always uses the default flat-address route.

## Exceptions

- Every byte address is naturally aligned. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- casb [a0], a1, a2, ->a3
- casb.aqrl [t#1], u#1, a0, ->u
