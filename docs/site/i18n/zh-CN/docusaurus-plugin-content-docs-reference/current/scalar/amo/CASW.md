<!-- GENERATED FROM: asl/scalar/amo/CASW.asl -->
# CASW

**Normative ASL source:** `asl/scalar/amo/CASW.asl`

CASW atomically compares and conditionally replaces one word, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-CASW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-casw-purpose role=purpose -->
## CASW 的作用

`CASW` 原子读取一个对齐的 4 字节字，将其与期望字比较，按条件写入待写字，并在无故障的匹配或不匹配路径上都发布原内存值。

<!-- PTO-READER-BLOCK: scalar-casw-mechanism role=mechanism -->
## 比较并交换机制

在产生任何效果前，`CASW` 先对地址源 `SrcL`、期望源 `SrcR` 和待写源 `SrcD` 取快照，然后针对同一个转换后位置完成对齐、读写地址转换和权限预检。

比较使用 `SrcR` 的低 4 字节。相等时，指令写入待写源 `SrcD` 的低 4 字节；不相等时，内存保持不变。

两种结果都会发出一个有序原子事件。匹配事件记录 `write_performed=true`；不匹配事件记录 `write_performed=false`，它作为有序原子读参与排序，但不产生一致性写。

原来的 32 位字会在目的发布前符号扩展到 XLEN。

<!-- PTO-READER-BLOCK: scalar-casw-inputs role=inputs-outputs -->
## 输入、排序与输出

- `SrcL`、`SrcR` 和 `SrcD` 接受全部 Reg5 源选择器，包括不消费的 T/U 源；`RegDst` 接受全部 Reg5 目的或丢弃选择器。
- `aq=0,rl=0` 选择 relaxed 排序，`aq=1,rl=0` 选择 acquire，`aq=0,rl=1` 选择 release，`aq=1,rl=1` 选择 acquire-release。

短形式没有远地址字段，始终使用默认平坦地址路径。

<!-- PTO-READER-BLOCK: scalar-casw-effects role=effects -->
## 架构效果

匹配时，`CASW` 写入待写低字，发出一个读写原子事件，并使与写入范围重叠的本地 64 字节粒度保留状态失效。

不匹配时，它保持内存和保留状态不变，但仍发出有序原子读事件。

每个无故障结果都会发布符号扩展后的原字，并让 `TPC` 前进 `4` 字节；故障时不发布目的值。

<!-- PTO-READER-BLOCK: scalar-casw-constraints role=constraints -->
## 对齐与精确故障

有效地址必须按 `4` 字节对齐。对齐、读访问、写访问和转换后地址相等性，都会在内存、目的位置、事件、保留状态或 `TPC` 效果之前完成检查。

发生故障时，陷阱入口保存原始 `TPC`；恢复过程还原该值，使完整指令能够在不保留进度的情况下重新执行。

<!-- PTO-READER-BLOCK: scalar-casw-example role=example -->
## 非规范演示

下面的演示只帮助理解当前契约，并不替代原子操作。

假设内存中的字是 `0x80000001`，期望字与其相等，待写 XLEN 值是 `0x1122334455667788`。`CASW.aqrl` 写入 `0x55667788`，发布符号扩展到 XLEN 的原字，发出一个 `write_performed=true` 的 acquire-release 原子事件，并使重叠的保留状态失效。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
casw [SrcL], SrcR, SrcD, ->Rd
casw.aq [SrcL], SrcR, SrcD, ->Rd
casw.rl [SrcL], SrcR, SrcD, ->Rd
casw.aqrl [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| casw_32_cb29e4287223 | L32 | 32 | 0x0000201b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| casw_32_cb29e4287223 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| casw_32_cb29e4287223 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| casw_32_cb29e4287223 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| casw_32_cb29e4287223 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| casw_32_cb29e4287223 | SrcD | 5 | 0–31 | none | none | Reg5 desired word source | Encoded zero supplies numeric zero as the desired value. |
| casw_32_cb29e4287223 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| casw_32_cb29e4287223 | SrcR | 5 | 0–31 | none | none | Reg5 expected word source | Encoded zero supplies numeric zero as the expected value. |
| casw_32_cb29e4287223 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| casw_32_cb29e4287223 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected word source |
| SrcD | Reg5 desired word source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASW.asl -->
```asl
readonly func InstructionContractOperation_CASW() => ScalarOperation
begin
    return ScalarOperation_CASW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASW.asl -->
```asl
readonly func InstructionContractHandler_CASW() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractHasFarField_CASW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_CASW()
    => boolean
begin
    return TRUE;
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
- The effective address must be aligned to 4 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 32-bit old value is sign-extended to XLEN.
- Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 4-byte word and compare it with SrcR truncated to 4 bytes.
- On equality, store SrcD truncated to 4 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 32-bit old value is sign-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- The short form always uses the default flat-address route.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- casw [a0], a1, a2, ->a3
- casw.aqrl [t#1], u#1, a0, ->u
