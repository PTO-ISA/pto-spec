<!-- GENERATED FROM: asl/scalar/amo/HL.CASH.asl -->
# HL.CASH

**Normative ASL source:** `asl/scalar/amo/HL.CASH.asl`

HL.CASH atomically compares and conditionally replaces one halfword, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-HL-CASH}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-cash-purpose role=purpose -->
## `HL.CASH` 做什么

`HL.CASH` 把 `SrcL` 中地址处的 16 位值与 `SrcR` 的低半字比较，并且只在两者相等时用 `SrcD` 的低半字替换它。无论结果如何，它都会把内存原先持有的值以零扩展补齐到 64 位 `PTO_XLEN` 宽度后，通过 `RegDst` 命名的目的地发布。

该形式由匹配值 `0x1000600b000e` 与掩码 `0xf000707ff83f` 选出。它的访问宽度为 `2` 字节，因此分派器以宽度 `2` 调用 `ExecuteDecodedCompareAndSwap`，并且两次预检都要求地址是 `2` 的倍数。

<!-- PTO-READER-BLOCK: scalar-hl-cash-mechanism role=mechanism -->
## 读取、比较，然后才可能写入

`CompareAndSwap` 先为读访问预检该地址，再为写访问预检。每次预检都测试 `UInt(address) MOD 2`，地址为奇数时报出 `Fault_DataAlignment`；对齐通过后，边界测试可能报出 `Fault_DataPage`。随后它比较两个翻译后的地址，不一致时报出 `Fault_DataPage`。

只有到这时它才读取那两个字节，与归一化后的期望半字比较，并在比较成功时存入期望的半字。一个原子事件记录由 `aq` 与 `rl` 选定的排序，以及只在匹配路径上为真的 `write_performed` 标志。

设计要点：`HL.CASH` 是 48 位形式，分派器按 `length_bits DIV 8` 推进 `TPC`，这里等于 6。由本条指令地址推算下一条指令地址的代码必须加 6；发生故障的 `HL.CASH` 不推进 `TPC`，因此重试会重新执行同样的 6 字节。

<!-- PTO-READER-BLOCK: scalar-hl-cash-inputs-outputs role=inputs-outputs -->
## 操作数与内存中的两个字节

`SrcL`、`SrcR` 和 `SrcD` 是 Reg5 源选择符，`RegDst` 是目的地选择符：编码 `0`..`23` 命名绝对 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`，且不会移除该条目。作为目的地时，`RegDst` 在编码 `1`..`23` 写入 GPR，在编码 `0` 与 `24`..`29` 丢弃该值，在编码 `30` 压入 `U`，在编码 `31` 压入 `T`。

- `SrcL` 提供该半字的原子地址。
- `SrcR` 在其低 `16` 位提供期望的半字。
- `SrcD` 在其低 `16` 位提供要写入的半字。
- `aq` 与 `rl` 选择记录的排序：`0` 是 relaxed 排序，`aq` 是 acquire，`rl` 是 release，两者都置位是 acquire-release。`far` 是配置档路由提示。

设计要点：该半字由 `SrcL` 与 `SrcL + 1` 处的字节组装而成，前一个成为第 `7:0` 位，后一个成为第 `15:8` 位。因此存入 `0xabcd` 会在 `SrcL` 写入 `0xcd`、在 `SrcL + 1` 写入 `0xab`，逐字节读取的程序可以观察到这一顺序。

<!-- PTO-READER-BLOCK: scalar-hl-cash-effects role=effects -->
## 效果与排序

匹配的 `HL.CASH` 恰好写入两个字节；不匹配则内存保持不变。两条无故障路径都发布 `ZeroExtend(old[15:0])`，所以发布值始终位于 `0` 到 `65535` 之间，半字 `0xffff` 会发布为 `0x000000000000ffff`。

匹配的写入在所存两个字节与保留的 64 字节颗粒重叠时使本地保留失效。不匹配不执行写入，保留保持原样。

<!-- PTO-READER-BLOCK: scalar-hl-cash-constraints role=constraints -->
## 合法性与故障

1. 三个源和 `RegDst` 的全部 `32` 个选择符编码都已分配，`aq`、`rl` 与 `far` 的全部 `8` 种组合都能译码为该形式。
2. `T` 或 `U` 条目不可用，或固定位译码失败，都会在任何架构效果之前于 `ReadPC()` 抛出 `Fault_IllegalInstruction`。
3. 地址必须是 `2` 的倍数；否则读预检以原始地址报出 `Fault_DataAlignment`。
4. 预检故障不发布目的地值、不记录原子事件、不改变保留状态，也不推进 `TPC`。

设计要点：比较只归一化 `SrcR[15:0]`，因此期望寄存器的高 `48` 位永远不影响结果：`0xffffffffffff1234` 与 `0x0000000000001234` 会匹配同一个内存半字。

<!-- PTO-READER-BLOCK: scalar-hl-cash-example role=example -->
## 替换一个半字

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当 `SrcL` 处的半字等于 `0x1234`、`SrcR` 的低半字等于 `0x1234`、`SrcD` 的低半字等于 `0xabcd` 时，比较匹配：`0xabcd` 被写入，`0x0000000000001234` 通过 `RegDst` 发布，事件报告 `write_performed=true`。

当内存半字不变而 `SrcR` 的低半字等于 `0x1235` 时，比较失败：内存保持 `0x1234`，目的地仍收到 `0x0000000000001234`，事件报告 `write_performed=false`。每一种写法都会译出 `far` 位，因此 `hl.cash.aqrlf [a0], a1, a2, ->a3` 到达的地址与结果和 `hl.cash.aqrl [a0], a1, a2, ->a3` 相同。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.cash [SrcL], SrcR, SrcD, ->Rd
hl.cash.aq [SrcL], SrcR, SrcD, ->Rd
hl.cash.rl [SrcL], SrcR, SrcD, ->Rd
hl.cash.f [SrcL], SrcR, SrcD, ->Rd
hl.cash.aqrl [SrcL], SrcR, SrcD, ->Rd
hl.cash.aqf [SrcL], SrcR, SrcD, ->Rd
hl.cash.rlf [SrcL], SrcR, SrcD, ->Rd
hl.cash.aqrlf [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cash_48_eee12c324d97 | HL48 | 48 | 0x1000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cash_48_eee12c324d97 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cash_48_eee12c324d97 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_cash_48_eee12c324d97 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cash_48_eee12c324d97 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_cash_48_eee12c324d97 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_cash_48_eee12c324d97 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_cash_48_eee12c324d97 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cash_48_eee12c324d97 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| hl_cash_48_eee12c324d97 | SrcD | 5 | 0–31 | none | none | Reg5 desired halfword source | Encoded zero supplies numeric zero as the desired value. |
| hl_cash_48_eee12c324d97 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| hl_cash_48_eee12c324d97 | SrcR | 5 | 0–31 | none | none | Reg5 expected halfword source | Encoded zero supplies numeric zero as the expected value. |
| hl_cash_48_eee12c324d97 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| hl_cash_48_eee12c324d97 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| hl_cash_48_eee12c324d97 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected halfword source |
| SrcD | Reg5 desired halfword source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASH.asl -->
```asl
readonly func InstructionContractOperation_HL_CASH() => ScalarOperation
begin
    return ScalarOperation_HL_CASH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASH.asl -->
```asl
readonly func InstructionContractHandler_HL_CASH() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASH()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractHasFarField_HL_CASH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASH()
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
- The effective address must be aligned to 2 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 16-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 2-byte halfword and compare it with SrcR truncated to 2 bytes.
- On equality, store SrcD truncated to 2 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 16-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 2 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- hl.cash [a0], a1, a2, ->a3
- hl.cash.aqrlf [t#1], u#1, a0, ->u
