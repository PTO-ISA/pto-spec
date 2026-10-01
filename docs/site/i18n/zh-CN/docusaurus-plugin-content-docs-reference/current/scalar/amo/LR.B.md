<!-- GENERATED FROM: asl/scalar/amo/LR.B.asl -->
# LR.B

**Normative ASL source:** `asl/scalar/amo/LR.B.asl`

LR.B loads one byte, establishes a 64-byte-line reservation, and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-LR-B}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lr-b-purpose role=purpose -->
## LR.B 的作用

`LR.B` 从 `SrcL` 中的地址载入一个字节，通过 Reg5 目标 `RegDst` 发布它，并在被载入的位置上建立保留。它是独立编码的 32 位形式，因此成功执行会把 `TPC` 前进 `4` 字节。

设计要点：发布的值是把载入的字节零扩展到 `PTO_XLEN` 位，因此字节 `0x80` 发布为 `0x0000000000000080`。字节载入从不做符号扩展，需要带符号字节的程序必须自行扩展发布的值。

<!-- PTO-READER-BLOCK: scalar-lr-b-mechanism role=mechanism -->
## 载入与保留如何排序

分派调用 `ExecuteDecodedLoadReserved(instruction, form, 1)`，其中 `1` 是该助记符的访问宽度。该辅助函数读取 `SrcL`，把 `aq` 与 `rl` 译码为内存顺序，并调用 `LoadReserved(address, 1, order)`；当没有记录到故障时，它把 `NormalizeAtomicReturn(old_value, 1)` 写入 `RegDst`。

`LoadReserved` 调用 `LoadWithOrder`，后者执行访问预检、读取该字节，并按请求的顺序在翻译后的地址记录一个载入事件。只有在此之后、且 `_LastFault` 为 `Fault_None` 时，`LoadReserved` 才置 `_ReservationValid`，并保存原始地址与宽度 `1`。

设计要点：保留更新位于无故障分支内，因此发生故障的 `lr.b` 会保留较早的保留，而不会替换或清除它；故障后重试时，程序面对的是它原本就有的保留状态。

<!-- PTO-READER-BLOCK: scalar-lr-b-inputs-outputs role=inputs-outputs -->
## 字段、源与目标

编码字段为 `RegDst@7:5`、`SrcL@15:5`、`SrcZero@20:5`、`rl@25:1`、`aq@26:1` 和 `far@27:1`；每项都给出指令中的低位与字段宽度。

`SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。`RegDst` 是 Reg5 目标：`1..23` 写入该 GPR，`0` 与 `24..29` 丢弃该值，`30` 压入 `U`，`31` 压入 `T`。`aq` 与 `rl` 选择 relaxed、acquire、release 或 acquire-release 排序；`far` 是路由提示，无论它取何值，`AtomicAddress` 都原样返回该地址。

设计要点：`SrcZero` 被译码为 5 位字段，但没有任何代码路径读取它。该字段的全部 `32` 个编码选择同一操作，其中没有任何编码被保留，而且该字段不出现在汇编写法 `lr.b [SrcL], ->Rd` 中。

<!-- PTO-READER-BLOCK: scalar-lr-b-effects role=effects -->
## 效果与排序

成功载入会读取一个小端字节，在内存事件捕获启用时于翻译后的地址记录一个载入事件，通过 `RegDst` 发布零扩展后的字节，并使本地保留保持有效，其地址为原始的 `SrcL` 值，记录的宽度为 `1`。随后 `TPC` 前进 `4` 字节。

该保留之后由包含它的 `64` 字节粒度匹配，而不是由被载入的那个字节匹配。

设计要点：`StoreConditional` 只比较包含粒度与保留有效标志，因此记录的宽度从不缩小匹配范围；同一 `64` 字节粒度内的任何条件存储仍然匹配这次字节载入建立的保留。

<!-- PTO-READER-BLOCK: scalar-lr-b-constraints role=constraints -->
## 合法性与精确故障

`LoadWithOrder` 先探测对齐，再探测翻译，然后检查读权限与边界。该形式载入一个字节，因此其对齐要求是 1 字节：每个字节地址都通过对齐检查，`LR.B` 不可能报告 `Fault_DataAlignment`，而被拒绝的地址报告 `Fault_DataPage`。

发生故障时不会发布任何内容、不会记录载入事件、较早的保留得到保留，`TPC` 也不前进。译码失败或所选 T/U 源不可用会在这些检查之前引发 `Fault_IllegalInstruction`。

设计要点：由于故障时不会通过 `RegDst` 发布任何内容，压入队列的目标（编码 `30` 与 `31`）同样不会压入，因此发生故障的字节载入不改变 `T` 与 `U` 队列的深度。

<!-- PTO-READER-BLOCK: scalar-lr-b-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当被寻址的字节为 `0x80` 时，`lr.b [a0], ->a1` 在 `a1` 中发布 `0x0000000000000080`，并建立覆盖包含该字节的 `64` 字节粒度的保留。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lr.b [SrcL], ->Rd
lr.b.aq [SrcL], ->Rd
lr.b.rl [SrcL], ->Rd
lr.b.f [SrcL], ->Rd
lr.b.aqrl [SrcL], ->Rd
lr.b.aqf [SrcL], ->Rd
lr.b.rlf [SrcL], ->Rd
lr.b.aqrlf [SrcL], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lr_b_32_cf80903a761a | L32 | 32 | 0x0000000b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lr_b_32_cf80903a761a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lr_b_32_cf80903a761a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lr_b_32_cf80903a761a | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lr_b_32_cf80903a761a | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lr_b_32_cf80903a761a | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lr_b_32_cf80903a761a | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lr_b_32_cf80903a761a | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination | Encoded zero discards the loaded value. |
| lr_b_32_cf80903a761a | SrcL | 5 | 0–31 | none | none | Reg5 load address source | Encoded zero reads the architectural zero register as the load address. |
| lr_b_32_cf80903a761a | SrcZero | 5 | 0–31 | none | none | ignored 5-bit alias field | Encoded zero is one of 32 ignored aliases and supplies no operand. |
| lr_b_32_cf80903a761a | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lr_b_32_cf80903a761a | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lr_b_32_cf80903a761a | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.B.asl -->
```asl
readonly func InstructionContractOperation_LR_B() => ScalarOperation
begin
    return ScalarOperation_LR_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.B.asl -->
```asl
readonly func InstructionContractHandler_LR_B() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;

pure func InstructionContractLoadSizeBytes_LR_B()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractIgnoresSrcZero_LR_B()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsResult_LR_B()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsResult_LR_B()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractReservationGranuleBytes_LR_B()
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
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL before any memory, reservation, or destination effect. SrcZero is not read.
- On success, publish the byte old value only after the load completes and establish the 64-byte-line reservation.
- The 8-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by four bytes. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Read one 1-byte little-endian byte after complete access preflight and record one ordered load event at the translated address.
- After a successful load, replace any prior local reservation with the original address and width 1; SC matching uses the containing 64-byte reservation granule.
- The 8-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change the address, event order, loaded value, or reservation.

## Exceptions

- Every byte address is naturally aligned. Alignment, translation, and read permission are checked before effects and report the original address.
- On a fault, no destination or queue value is published, no memory event is emitted, the prior reservation is preserved, and TPC does not advance. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. SrcZero, aq, rl, far, and all Reg5 values have no reserved encodings.

## Examples

- lr.b [a0], ->a1
- lr.b.aqrl [t#1], ->u
- lr.b.f [sp], ->t
