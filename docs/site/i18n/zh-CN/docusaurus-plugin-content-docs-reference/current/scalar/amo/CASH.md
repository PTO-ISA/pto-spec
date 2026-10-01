<!-- GENERATED FROM: asl/scalar/amo/CASH.asl -->
# CASH

**Normative ASL source:** `asl/scalar/amo/CASH.asl`

CASH atomically compares and conditionally replaces one halfword, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-CASH}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cash-purpose role=purpose -->
## CASH 的作用

`CASH` 把 `SrcL` 指向地址处的 2 字节半字与 `SrcR` 的低 `2` 字节比较，仅当两个半字相等时才把 `SrcD` 的低 `2` 字节写入该地址。

匹配与不匹配都会把原来的半字零扩展到 XLEN 后发布到 `RegDst`。`CASH` 是一个 32 位编码形式，成功执行使 `TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-cash-mechanism role=mechanism -->
## 读取、比较与条件写入

分发逻辑把 `SrcL`、`SrcR`、`SrcD` 以及访问宽度 `2` 传给共享的 `CompareAndSwap` 辅助函数。该函数先对同样的 2 字节做读探测，再做写探测；当两次探测转换出的地址不同时，它不会继续执行。

`LoadTranslatedUnsigned` 从 `Zeros{PTO_XLEN}` 构造载入值，并从内存填入第 `15:0` 位，因此比较中内存一侧本身已经零扩展。期望一侧用同样的方式规范化，写入则取 `SrcD` 的低 `2` 字节。

设计要点：比较的两侧都由 `16` 位零扩展而来，所以 `SrcR` 的第 `16` 到第 `63` 位被忽略。`SrcR` 为 `0xffffffffffff1234` 时仍与内存半字 `0x1234` 匹配，因为高位不参与比较。

设计要点：写探测重复同样的 `2` 字节宽度，因而对同一地址做同样的对齐检查；于是奇数地址会在读探测中就抛出 `Fault_DataAlignment`，此时尚未载入或写入任何字节。

<!-- PTO-READER-BLOCK: scalar-cash-inputs-outputs role=inputs-outputs -->
## 字段、排序与选择器

| 字段 | 指令低位 | 宽度 | 作用 |
| --- | --- | --- | --- |
| `SrcL` | `15` | `5` | 原子地址源 |
| `SrcR` | `20` | `5` | 期望半字源 |
| `SrcD` | `27` | `5` | 待写半字源 |
| `RegDst` | `7` | `5` | 原半字目的地 |
| `rl` | `25` | `1` | 释放排序位 |
| `aq` | `26` | `1` | 获取排序位 |

`aq=0,rl=0` 选择 relaxed 排序，`aq=1,rl=0` 为 acquire，`aq=0,rl=1` 为 release，`aq=1,rl=1` 为 acquire-release。记录的事件在匹配与不匹配时携带相同的排序设置。

设计要点：源选择器 `24` 到 `27` 读取 `T#1` 到 `T#4`，选择器 `28` 到 `31` 读取 `U#1` 到 `U#4`，且不消费该条目；因此某条形式可以从队列取用期望半字，并让该条目留给下一条指令。

<!-- PTO-READER-BLOCK: scalar-cash-effects role=effects -->
## 指令产生的改变

匹配的 `CASH` 写入 `SrcD` 的低 `2` 字节；不匹配的 `CASH` 不写入任何内容。两种情况都会记录一个原子事件，其 `write_performed` 等于比较结果。

任何无故障执行之后 `RegDst` 都会收到 `ZeroExtend{PTO_XLEN}(old_value[15:0])`，所以内存半字 `0xabcd` 发布为 `0x000000000000abcd`。

设计要点：寄存器结果与内存结果各自独立地规范化。`NormalizeAtomicReturn` 为 `RegDst` 拓宽这个 `16` 位值，而 `StoreTranslated` 对 `2` 个字节中的每一个写入 `desired[(byte_index * 8) +: 8]`，因此发布的寄存器值是 `64` 位宽，而内存只保留 `2` 字节。

匹配时，若写入的 `2` 字节与保留的 64 字节粒度重叠，还会清除保留状态；成功执行使 `TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-cash-constraints role=constraints -->
## 对齐与故障顺序

`CASH` 要求地址为偶数：当 `UInt(address) MOD 2` 非零时，`ProbeDataAccess` 报告 `Fault_DataAlignment`，而该检查先于地址转换，也先于权限检查。

读探测先被求值，因此先报告它的故障。若读探测通过，写探测重复同样的宽度与对齐检查，随后两次转换后的地址必须相等，否则抛出 `Fault_DataPage`。

故障携带原始 `SrcL` 地址。辅助函数在载入之前返回，因此不会写入任何内容，不会记录原子事件，保留状态不变，`RegDst` 保持原值。

`TPC` 停在出错指令上，因此整个比较并交换可以重新执行。解码失败，或所选 `T#1` 到 `T#4`、`U#1` 到 `U#4` 源不可用，会在处理函数运行之前抛出 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-cash-example role=example -->
## 一个匹配的半字

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

设内存半字为 `0x1234`，`SrcR` 的低 `2` 字节为 `0x1234`，`SrcD` 为 `0xabcd`。比较成功，于是 `CASH` 把 `0xabcd` 写入该地址，在 `RegDst` 中发布 `0x0000000000001234`，并记录一个 `write_performed=true` 的原子事件。

如果 `SrcR` 的低 `2` 字节改为 `0x1235`，比较失败：内存保持 `0x1234`，记录的事件为 `write_performed=false`，`RegDst` 仍然收到 `0x0000000000001234`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cash [SrcL], SrcR, SrcD, ->Rd
cash.aq [SrcL], SrcR, SrcD, ->Rd
cash.rl [SrcL], SrcR, SrcD, ->Rd
cash.aqrl [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cash_32_cb1315ff6cb5 | L32 | 32 | 0x0000101b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cash_32_cb1315ff6cb5 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cash_32_cb1315ff6cb5 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| cash_32_cb1315ff6cb5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cash_32_cb1315ff6cb5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| cash_32_cb1315ff6cb5 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| cash_32_cb1315ff6cb5 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cash_32_cb1315ff6cb5 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| cash_32_cb1315ff6cb5 | SrcD | 5 | 0–31 | none | none | Reg5 desired halfword source | Encoded zero supplies numeric zero as the desired value. |
| cash_32_cb1315ff6cb5 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| cash_32_cb1315ff6cb5 | SrcR | 5 | 0–31 | none | none | Reg5 expected halfword source | Encoded zero supplies numeric zero as the expected value. |
| cash_32_cb1315ff6cb5 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| cash_32_cb1315ff6cb5 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected halfword source |
| SrcD | Reg5 desired halfword source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASH.asl -->
```asl
readonly func InstructionContractOperation_CASH() => ScalarOperation
begin
    return ScalarOperation_CASH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASH.asl -->
```asl
readonly func InstructionContractHandler_CASH() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASH()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractHasFarField_CASH()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_CASH()
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
- The effective address must be aligned to 2 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 16-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 2-byte halfword and compare it with SrcR truncated to 2 bytes.
- On equality, store SrcD truncated to 2 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 16-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- The short form always uses the default flat-address route.

## Exceptions

- The effective address must be aligned to 2 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- cash [a0], a1, a2, ->a3
- cash.aqrl [t#1], u#1, a0, ->u
