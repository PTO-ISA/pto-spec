<!-- GENERATED FROM: asl/scalar/amo/LR.W.asl -->
# LR.W

**Normative ASL source:** `asl/scalar/amo/LR.W.asl`

LR.W loads one word, establishes a 64-byte-line reservation, and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-LR-W}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lr-w-purpose role=purpose -->
## LR.W 的作用

`LR.W` 从 `SrcL` 中的地址载入一个 `4` 字节的字，通过 `RegDst` 发布它，并在被载入的位置上建立保留。成功执行会把 `TPC` 前进 `4` 字节。

设计要点：载入的 `32` 位被符号扩展到 `PTO_XLEN`，因此发布的值不是原始内存字。字 `0x80000000` 发布为 `0xffffffff80000000`，需要无符号字的程序必须对发布的值做掩码。

<!-- PTO-READER-BLOCK: scalar-lr-w-mechanism role=mechanism -->
## 字载入如何排序

分派为该助记符选择 `ExecuteDecodedLoadReserved(instruction, form, 4)`。该辅助函数读取 `SrcL`，从 `aq` 与 `rl` 译出排序，并调用 `LoadReserved(address, 4, order)`；当故障标志清零时，它把 `NormalizeAtomicReturn(old_value, 4)` 写入 `RegDst`。

`LoadWithOrder` 探测 `4` 字节对齐、翻译与读权限，读取四个小端字节，并在翻译后的地址记录一个载入事件。随后 `LoadReserved` 置保留有效标志、原始地址与宽度 `4`。

设计要点：保留匹配基于粒度，因此保存的宽度 `4` 不会限制它。在成功的 `lr.w [0x1004], ->a1` 之后，保留覆盖从 `0x1000` 开始的 `64` 字节，对 `0x1000` 的条件存储仍然匹配，尽管该地址与载入地址不同。

<!-- PTO-READER-BLOCK: scalar-lr-w-inputs-outputs role=inputs-outputs -->
## 字段、源与目标

编码为 `RegDst@7:5`、`SrcL@15:5`、`SrcZero@20:5`、`rl@25:1`、`aq@26:1` 与 `far@27:1`；每项是指令中的低位与字段宽度。

`SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。`RegDst` 是 Reg5 目标：`1..23` 写入该 GPR，`0` 与 `24..29` 丢弃，`30` 压入 `U`，`31` 压入 `T`。

设计要点：`far` 被译码并传给 `AtomicAddress`，而后者原样返回其参数，因此在参考模型中 `lr.w [a0], ->a1` 与 `lr.w.f [a0], ->a1` 产生相同的地址、相同的载入值和相同的保留。

<!-- PTO-READER-BLOCK: scalar-lr-w-effects role=effects -->
## 效果与排序

成功载入会读取一个小端字，在内存事件捕获启用时按 `aq` 与 `rl` 选定的顺序在翻译后的地址记录一个载入事件，通过 `RegDst` 发布符号扩展后的字，并使保留在原始地址上保持有效。随后 `TPC` 前进 `4` 字节。

发布的值是 `SignExtend{PTO_XLEN}(old_value[31:0])`，因此载入字的位 `31` 决定目标的高 `32` 位。

设计要点：只有在故障标志清零时才发布，因此发生故障的字载入会让 `RegDst` 保持指令执行前的值；当目标是 `T` 或 `U` 压入时，该压入也不会发生。

<!-- PTO-READER-BLOCK: scalar-lr-w-constraints role=constraints -->
## 合法性与精确故障

先检查对齐，再翻译，然后检查读权限与边界，全部在任何效果之前。该形式要求 `4` 字节对齐，因此不是 `4` 的倍数的地址报告 `Fault_DataAlignment`，未通过边界检查的地址报告 `Fault_DataPage`，并携带原始地址。

发生故障时不会发布任何内容、不会记录载入事件、较早的保留得到保留，`TPC` 不前进。无法译码的形式或所选 T/U 源不可用会在内存检查之前引发 `Fault_IllegalInstruction`。

设计要点：只有无故障载入之后才写入保留，因此较早成功载入建立的保留会在随后发生故障的 `lr.w` 中存活；较早的保留不会被替换或清除。

<!-- PTO-READER-BLOCK: scalar-lr-w-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当被寻址的字为 `0x80000000` 时，`lr.w [a0], ->a1` 在 `a1` 中发布 `0xffffffff80000000`；在 `lr.w [0x1004], ->a1` 之后，对 `0x1000` 的条件存储仍然匹配该保留。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lr.w [SrcL], ->Rd
lr.w.aq [SrcL], ->Rd
lr.w.rl [SrcL], ->Rd
lr.w.f [SrcL], ->Rd
lr.w.aqrl [SrcL], ->Rd
lr.w.aqf [SrcL], ->Rd
lr.w.rlf [SrcL], ->Rd
lr.w.aqrlf [SrcL], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lr_w_32_efecc735bb75 | L32 | 32 | 0x2000000b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lr_w_32_efecc735bb75 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lr_w_32_efecc735bb75 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lr_w_32_efecc735bb75 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lr_w_32_efecc735bb75 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lr_w_32_efecc735bb75 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lr_w_32_efecc735bb75 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lr_w_32_efecc735bb75 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination | Encoded zero discards the loaded value. |
| lr_w_32_efecc735bb75 | SrcL | 5 | 0–31 | none | none | Reg5 load address source | Encoded zero reads the architectural zero register as the load address. |
| lr_w_32_efecc735bb75 | SrcZero | 5 | 0–31 | none | none | ignored 5-bit alias field | Encoded zero is one of 32 ignored aliases and supplies no operand. |
| lr_w_32_efecc735bb75 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lr_w_32_efecc735bb75 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lr_w_32_efecc735bb75 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 load address source |
| SrcZero | ignored 5-bit alias field |
| RegDst | Reg5 loaded-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.W.asl -->
```asl
readonly func InstructionContractOperation_LR_W() => ScalarOperation
begin
    return ScalarOperation_LR_W;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.W.asl -->
```asl
readonly func InstructionContractHandler_LR_W() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;

pure func InstructionContractLoadSizeBytes_LR_W()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractIgnoresSrcZero_LR_W()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsResult_LR_W()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsResult_LR_W()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractReservationGranuleBytes_LR_W()
    => integer {1..262144}
begin
    return PTO_RESERVATION_GRANULE_BYTES;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the loaded value.
- SrcZero is an ignored alias field. Every encoding 0..31 selects the same operation and no register or queue is read through SrcZero.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and reservation behavior.

## Legality

- All 32 SrcL Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All 32 SrcZero encodings are ignored aliases. All aq, rl, and far combinations are assigned.
- The effective address must be aligned to 4 bytes.

## State effects

- Snapshot SrcL before any memory, reservation, or destination effect. SrcZero is not read.
- On success, publish the word old value only after the load completes and establish the 64-byte-line reservation.
- The 32-bit old value is sign-extended to XLEN.
- Successful execution advances TPC by four bytes. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Read one 4-byte little-endian word after complete access preflight and record one ordered load event at the translated address.
- After a successful load, replace any prior local reservation with the original address and width 4; SC matching uses the containing 64-byte reservation granule.
- The 32-bit old value is sign-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change the address, event order, loaded value, or reservation.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, translation, and read permission are checked before effects and report the original address.
- On a fault, no destination or queue value is published, no memory event is emitted, the prior reservation is preserved, and TPC does not advance. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. SrcZero, aq, rl, far, and all Reg5 values have no reserved encodings.

## Examples

- lr.w [a0], ->a1
- lr.w.aqrl [t#1], ->u
- lr.w.f [sp], ->t
