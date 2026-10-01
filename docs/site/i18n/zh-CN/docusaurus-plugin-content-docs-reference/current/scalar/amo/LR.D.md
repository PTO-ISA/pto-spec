<!-- GENERATED FROM: asl/scalar/amo/LR.D.asl -->
# LR.D

**Normative ASL source:** `asl/scalar/amo/LR.D.asl`

LR.D loads one doubleword, establishes a 64-byte-line reservation, and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-LR-D}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lr-d-purpose role=purpose -->
## LR.D 的作用

`LR.D` 从 `SrcL` 中的地址载入一个 `8` 字节的双字，通过 `RegDst` 发布它，并在被载入的位置上建立保留。成功执行会把 `TPC` 前进 `4` 字节。

设计要点：载入的 `64` 位原样发布，因此目标中保存的正是内存字。`LR.B`、`LR.H` 与 `LR.W` 会扩展载入的位以填满寄存器，而这个宽度本身已经填满。

<!-- PTO-READER-BLOCK: scalar-lr-d-mechanism role=mechanism -->
## 双字载入如何排序

分派调用 `ExecuteDecodedLoadReserved(instruction, form, 8)`。该辅助函数快照 `SrcL`，从 `aq` 与 `rl` 导出内存顺序，并调用 `LoadReserved(address, 8, order)`；若故障标志清零，它把原样返回其参数的 `NormalizeAtomicReturn(old_value, 8)` 写入 `RegDst`。

`LoadWithOrder` 探测 `8` 字节对齐、翻译与读权限，读取八个小端字节，并按请求的顺序在翻译后的地址记录一个载入事件。只有无故障返回才会置保留有效标志，并保存原始地址与宽度 `8`。

设计要点：`SrcL` 在访问之前只读取一次，同一个值既成为探测地址也成为保留地址；与 `SrcL` 同名的目标在之后才被写入，无法改变已经保留的地址。

<!-- PTO-READER-BLOCK: scalar-lr-d-inputs-outputs role=inputs-outputs -->
## 字段、源与目标

编码字段为 `RegDst@7:5`、`SrcL@15:5`、`SrcZero@20:5`、`rl@25:1`、`aq@26:1` 与 `far@27:1`；每项都给出指令中的低位与字段宽度。

`SrcL` 读取任意 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且队列读取不会弹出该项。`RegDst` 写入任意 Reg5 目标：`1..23` 写入该 GPR，`0` 与 `24..29` 丢弃，`30` 压入 `U`，`31` 压入 `T`。编码零源读取架构零寄存器，因此 `lr.d [zero], ->a1` 寻址 `0`。`aq` 与 `rl` 选择载入排序，`far` 是路由提示，在参考模型中不改变地址。

设计要点：`SrcZero@20:5` 是被忽略的别名，因此这些位的 `32` 个取值都译码为同一个形式；该字段没有任何取值会选择寄存器、队列项或故障。

<!-- PTO-READER-BLOCK: scalar-lr-d-effects role=effects -->
## 效果与排序

成功载入会读取一个小端双字，在内存事件捕获启用时按 `aq` 与 `rl` 选定的顺序在翻译后的地址记录一个载入事件，通过 `RegDst` 原样发布 `64` 个载入位，并使保留在原始地址上保持有效、宽度为 `8`。随后 `TPC` 前进 `4` 字节。

设计要点：保留会记录载入宽度，但 `StoreConditional` 只比较包含它的 `64` 字节粒度与保留有效标志，因此该宽度从不缩小哪些条件存储会匹配。

<!-- PTO-READER-BLOCK: scalar-lr-d-constraints role=constraints -->
## 合法性与精确故障

该形式要求 `8` 字节对齐，因此地址必须是 `8` 的倍数。`LoadWithOrder` 依次检查对齐、翻译、读权限与边界，并报告原始架构地址；在参考模型中翻译原样返回该地址。

发生故障时不会发布任何内容、不会记录载入事件、较早的保留得到保留，`TPC` 停在出错指令上；译码失败或所选 T/U 源不可用会在此前引发 `Fault_IllegalInstruction`。

设计要点：故障置位时会跳过目标写入，因此发生故障的 `lr.d` 不改变 `RegDst`，包括编码 `30` 与 `31`；它们不压入任何内容，队列深度保持原样。

<!-- PTO-READER-BLOCK: scalar-lr-d-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当被寻址的双字为 `0xffffffff00000000` 时，`lr.d [a0], ->a1` 在 `a1` 中原样发布 `0xffffffff00000000`，并在包含它的 `64` 字节粒度上建立保留。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lr.d [SrcL], ->Rd
lr.d.aq [SrcL], ->Rd
lr.d.rl [SrcL], ->Rd
lr.d.f [SrcL], ->Rd
lr.d.aqrl [SrcL], ->Rd
lr.d.aqf [SrcL], ->Rd
lr.d.rlf [SrcL], ->Rd
lr.d.aqrlf [SrcL], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lr_d_32_84d21a553dc1 | L32 | 32 | 0x3000000b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lr_d_32_84d21a553dc1 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lr_d_32_84d21a553dc1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lr_d_32_84d21a553dc1 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lr_d_32_84d21a553dc1 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lr_d_32_84d21a553dc1 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lr_d_32_84d21a553dc1 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lr_d_32_84d21a553dc1 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination | Encoded zero discards the loaded value. |
| lr_d_32_84d21a553dc1 | SrcL | 5 | 0–31 | none | none | Reg5 load address source | Encoded zero reads the architectural zero register as the load address. |
| lr_d_32_84d21a553dc1 | SrcZero | 5 | 0–31 | none | none | ignored 5-bit alias field | Encoded zero is one of 32 ignored aliases and supplies no operand. |
| lr_d_32_84d21a553dc1 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lr_d_32_84d21a553dc1 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lr_d_32_84d21a553dc1 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.D.asl -->
```asl
readonly func InstructionContractOperation_LR_D() => ScalarOperation
begin
    return ScalarOperation_LR_D;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.D.asl -->
```asl
readonly func InstructionContractHandler_LR_D() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;

pure func InstructionContractLoadSizeBytes_LR_D()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractIgnoresSrcZero_LR_D()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsResult_LR_D()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsResult_LR_D()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractReservationGranuleBytes_LR_D()
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
- The effective address must be aligned to 8 bytes.

## State effects

- Snapshot SrcL before any memory, reservation, or destination effect. SrcZero is not read.
- On success, publish the doubleword old value only after the load completes and establish the 64-byte-line reservation.
- The 64-bit old value is published unchanged.
- Successful execution advances TPC by four bytes. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Read one 8-byte little-endian doubleword after complete access preflight and record one ordered load event at the translated address.
- After a successful load, replace any prior local reservation with the original address and width 8; SC matching uses the containing 64-byte reservation granule.
- The 64-bit old value is published unchanged.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change the address, event order, loaded value, or reservation.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, translation, and read permission are checked before effects and report the original address.
- On a fault, no destination or queue value is published, no memory event is emitted, the prior reservation is preserved, and TPC does not advance. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. SrcZero, aq, rl, far, and all Reg5 values have no reserved encodings.

## Examples

- lr.d [a0], ->a1
- lr.d.aqrl [t#1], ->u
- lr.d.f [sp], ->t
