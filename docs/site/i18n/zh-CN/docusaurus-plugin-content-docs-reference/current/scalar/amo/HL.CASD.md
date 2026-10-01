<!-- GENERATED FROM: asl/scalar/amo/HL.CASD.asl -->
# HL.CASD

**Normative ASL source:** `asl/scalar/amo/HL.CASD.asl`

HL.CASD atomically compares and conditionally replaces one doubleword, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-HL-CASD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-casd-purpose role=purpose -->
## `HL.CASD` 做什么

`HL.CASD` 有条件地替换 `SrcL` 中地址处的 64 位双字。它把该双字与 `SrcR` 比较，并且只在两者相等时存入 `SrcD`。无论结果如何，内存原先持有的值都会通过 `RegDst` 发布；由于访问宽度是 `8` 字节，发布值就是完整的 64 位旧值，不做任何扩展。

该形式由匹配值 `0x3000600b000e` 与掩码 `0xf000707ff83f` 选出。它的访问宽度为 `8` 字节，因此两次预检都要求地址是 `8` 的倍数，处理程序是 `ScalarHandler_CompareAndSwap`。

<!-- PTO-READER-BLOCK: scalar-hl-casd-mechanism role=mechanism -->
## 八个字节经历了什么

分派器通过 `ScalarDecodedAtomicAddress` 解析地址，后者读取 `SrcL` 选中的寄存器与 `far` 位，然后调用 `AtomicAddress`。`CompareAndSwap` 以 `8` 字节宽度工作：

- 读预检测试 `UInt(address) MOD 8`，再检查边界；写预检重复这两项测试，两个翻译后的地址不一致时抛出 `Fault_DataPage`。
- `LoadTranslatedUnsigned` 把这八个字节读成一个 64 位值。
- 比较是 `old_value == NormalizeAtomicUnsigned(SrcR, 8)`，在尺寸 `8` 下就是把整个 `SrcR` 与整个读出的值比较。
- 相等时 `StoreTranslated` 写入 `SrcD` 的全部 `8` 个字节；一个原子事件记录由 `aq` 与 `rl` 得到的排序，并把 `write_performed` 置为比较结果。

设计要点：在宽度 `8` 下，`NormalizeAtomicUnsigned` 与 `NormalizeAtomicReturn` 都不改变其参数，因此比较使用 `SrcR` 的每一位，发布返回旧值的每一位。这一形式没有截断或扩展步骤：只有 `SrcR` 与内存中的双字完全一致，交换才会发生。

<!-- PTO-READER-BLOCK: scalar-hl-casd-inputs-outputs role=inputs-outputs -->
## 操作数、排序与 `far`

- `SrcL`、`SrcR` 和 `SrcD` 是 Reg5 源选择符，`RegDst` 是目的地选择符：编码 `0`..`23` 命名绝对 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`，且不会移除该条目；作为目的地，`RegDst` 在编码 `1`..`23` 写入 GPR，在编码 `0` 与 `24`..`29` 丢弃该值，在编码 `30` 压入 `U`，在编码 `31` 压入 `T`。
- `aq` 与 `rl` 选择记录的排序：`0` 是 relaxed 排序，`aq` 是 acquire，`rl` 是 release，两者都置位是 acquire-release；匹配与不匹配都是如此。
- `far` 是指令第 43 位的配置档路由提示。`AtomicAddress` 原样返回其参数，因此 `far` 不会移动该双字。

设计要点：该家族四个形式的匹配值只在指令第 45 与第 44 位不同，它们分别是字节形式的 `00`、半字形式的 `01`、字形式的 `10` 和 `HL.CASD` 的 `11`。因此宽度是固定位译码的一部分，位于 `far` 位之上，而不是软件可以在运行时改变的修饰位。

<!-- PTO-READER-BLOCK: scalar-hl-casd-effects role=effects -->
## 效果与完成

匹配会用 `SrcD` 重写该地址的全部 `8` 个字节。不匹配时内存保持不变，但仍会发布旧双字，因此即使交换没有发生，该指令也会报告内存原先持有的内容。

匹配的写入在所存八个字节与保留的 64 字节颗粒重叠时使本地保留失效。不匹配不执行写入，因此保留状态保持不变。

设计要点：该形式长 48 位，分派器按 `length_bits DIV 8` 推进 `TPC`，这里等于 6，因此下一条指令从 `HL.CASD` 之后 6 字节开始。`8` 字节的数据对齐与 `6` 字节的指令步长是两个独立量。发生故障时 `TPC` 仍停在该形式开头，恢复后会重新执行同样的 6 字节。

<!-- PTO-READER-BLOCK: scalar-hl-casd-constraints role=constraints -->
## 合法性与故障

- 每个字段值都已分配：`SrcL`、`SrcR`、`SrcD` 和 `RegDst` 的全部 `32` 个选择符编码，以及 `aq`、`rl` 与 `far` 的全部 `8` 种组合。`T` 或 `U` 条目不可用，或固定位译码失败，都会在任何架构效果之前于 `ReadPC()` 抛出 `Fault_IllegalInstruction`。
- 地址必须是 `8` 的倍数；否则读预检以原始地址报出 `Fault_DataAlignment`，并且不会到达写预检。
- 预检故障不改变内存、不发布目的地值、不记录原子事件、不改变保留状态，也不推进 `TPC`。

<!-- PTO-READER-BLOCK: scalar-hl-casd-example role=example -->
## 替换一个双字

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当 `SrcL` 处的双字等于 `0x0123456789abcdef`、`SrcR` 等于 `0x0123456789abcdef`、`SrcD` 等于 `0xffffffffffffffff` 时，比较匹配：全部 `8` 个字节变成 `0xff`，`RegDst` 收到 `0x0123456789abcdef`，事件报告 `write_performed=true`。

当内存双字不变而 `SrcR` 等于 `0x0123456789abcdee` 时，比较失败：内存保持 `0x0123456789abcdef`，`RegDst` 仍收到 `0x0123456789abcdef`，事件报告 `write_performed=false`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.casd [SrcL], SrcR, SrcD, ->Rd
hl.casd.aq [SrcL], SrcR, SrcD, ->Rd
hl.casd.rl [SrcL], SrcR, SrcD, ->Rd
hl.casd.f [SrcL], SrcR, SrcD, ->Rd
hl.casd.aqrl [SrcL], SrcR, SrcD, ->Rd
hl.casd.aqf [SrcL], SrcR, SrcD, ->Rd
hl.casd.rlf [SrcL], SrcR, SrcD, ->Rd
hl.casd.aqrlf [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_casd_48_fbb5c4256d30 | HL48 | 48 | 0x3000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_casd_48_fbb5c4256d30 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_casd_48_fbb5c4256d30 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_casd_48_fbb5c4256d30 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_casd_48_fbb5c4256d30 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| hl_casd_48_fbb5c4256d30 | SrcD | 5 | 0–31 | none | none | Reg5 desired doubleword source | Encoded zero supplies numeric zero as the desired value. |
| hl_casd_48_fbb5c4256d30 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| hl_casd_48_fbb5c4256d30 | SrcR | 5 | 0–31 | none | none | Reg5 expected doubleword source | Encoded zero supplies numeric zero as the expected value. |
| hl_casd_48_fbb5c4256d30 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| hl_casd_48_fbb5c4256d30 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| hl_casd_48_fbb5c4256d30 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected doubleword source |
| SrcD | Reg5 desired doubleword source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASD.asl -->
```asl
readonly func InstructionContractOperation_HL_CASD() => ScalarOperation
begin
    return ScalarOperation_HL_CASD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASD.asl -->
```asl
readonly func InstructionContractHandler_HL_CASD() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractHasFarField_HL_CASD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASD()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcD, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same address and atomic result.

## Legality

- All 32 SrcL, SrcR, and SrcD Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned.
- The effective address must be aligned to 8 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 64-bit old value is published unchanged.
- Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 8-byte doubleword and compare it with SrcR truncated to 8 bytes.
- On equality, store SrcD truncated to 8 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 64-bit old value is published unchanged.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- hl.casd [a0], a1, a2, ->a3
- hl.casd.aqrlf [t#1], u#1, a0, ->u
