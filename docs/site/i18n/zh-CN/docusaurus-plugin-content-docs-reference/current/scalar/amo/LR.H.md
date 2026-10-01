<!-- GENERATED FROM: asl/scalar/amo/LR.H.asl -->
# LR.H

**Normative ASL source:** `asl/scalar/amo/LR.H.asl`

LR.H loads one halfword, establishes a 64-byte-line reservation, and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-LR-H}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lr-h-purpose role=purpose -->
## LR.H 的作用

`LR.H` 从 `SrcL` 中的地址载入一个半字，通过 `RegDst` 发布它，并在被载入的位置上建立保留。成功执行会把 `TPC` 前进 `4` 字节。

设计要点：载入的两个字节落在目标的低半部分，高 `48` 位被清零，因此半字 `0x8000` 永远不会被发布为负的 XLEN 值。

<!-- PTO-READER-BLOCK: scalar-lr-h-mechanism role=mechanism -->
## 半字载入如何排序

分派把该形式交给 `ExecuteDecodedLoadReserved(instruction, form, 2)`。该辅助函数快照 `SrcL`，用 `ScalarDecodedMemoryOrder` 把 `aq` 与 `rl` 转换为内存顺序，并调用 `LoadReserved(address, 2, order)`；在无故障返回时，它把 `NormalizeAtomicReturn(old_value, 2)` 写入 `RegDst`。

在 `LoadReserved` 内部，`LoadWithOrder` 执行访问：先用 `ProbeDataAccess(address, 2, 2, FALSE)` 做对齐、翻译与读权限检查，然后进行两字节小端读取，再在翻译后的地址记录一个载入事件。只有在故障标志保持清零时才会写入保留。

设计要点：`ProbeDataAccess` 在调用 `TranslateDataAddress` 之前先检查 `UInt(address) MOD alignment_bytes`，因此奇数地址在这里报告 `Fault_DataAlignment`，该地址的边界检查根本不会被查询。

<!-- PTO-READER-BLOCK: scalar-lr-h-inputs-outputs role=inputs-outputs -->
## 字段、源与目标

`SrcL@15:5` 提供载入地址，`RegDst@7:5` 接收发布的半字，`SrcZero@20:5`、`rl@25:1`、`aq@26:1` 与 `far@27:1` 补全编码；每项都给出指令中的低位与字段宽度。

`SrcL` 接受所有 Reg5 源选择子：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，读取队列项不会弹出它。`RegDst` 接受所有目标选择子：`1..23` 写入该 GPR，`0` 与 `24..29` 丢弃，`30` 压入 `U`，`31` 压入 `T`。`aq` 与 `rl` 选择载入排序，`far` 是路由提示，不改变地址。

设计要点：没有任何代码路径读取 `SrcZero`，因此该字段的 `32` 个位模式选择同一条指令，而且该字段没有汇编写法；`LR.H` 无法通过它获得操作数。

<!-- PTO-READER-BLOCK: scalar-lr-h-effects role=effects -->
## 效果与排序

成功载入会读取一个小端半字，在内存事件捕获启用时按 `aq` 与 `rl` 选定的顺序在翻译后的地址记录一个载入事件，通过 `RegDst` 发布零扩展后的 `16` 位，并把本地保留更新为原始地址、宽度 `2`。随后 `TPC` 前进 `4` 字节。

设计要点：发布规则跟随访问宽度，而不是目标寄存器宽度。半字 `0x8000` 发布为 `0x0000000000008000`，而 `LR.W` 对字 `0x80000000` 发布 `0xffffffff80000000`，因此同样的最高位在这个宽度上得到零扩展值，在字宽度上得到负值。

<!-- PTO-READER-BLOCK: scalar-lr-h-constraints role=constraints -->
## 合法性与精确故障

访问预检在任何效果之前运行：先按 `2` 字节对齐，再翻译，然后检查读权限与边界。被拒绝的地址报告原始架构地址，在参考模型中 `TranslateDataAddress` 原样返回该地址。

发生故障时不会发布任何内容、不会记录载入事件、较早的保留得到保留，`TPC` 停在出错指令上。译码失败或所选 T/U 源不可用会在此前引发 `Fault_IllegalInstruction`。

设计要点：奇数地址无法通过对齐检查，因此 `LR.H` 为它报告 `Fault_DataAlignment`，永远不会到达边界检查；而它上面紧邻的字节地址是偶数，确实会到达该检查。

<!-- PTO-READER-BLOCK: scalar-lr-h-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当被寻址的半字为 `0x8000` 时，`lr.h [a0], ->a1` 在 `a1` 中发布 `0x0000000000008000`，保留覆盖包含该半字的 `64` 字节粒度。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lr.h [SrcL], ->Rd
lr.h.aq [SrcL], ->Rd
lr.h.rl [SrcL], ->Rd
lr.h.f [SrcL], ->Rd
lr.h.aqrl [SrcL], ->Rd
lr.h.aqf [SrcL], ->Rd
lr.h.rlf [SrcL], ->Rd
lr.h.aqrlf [SrcL], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lr_h_32_f936df218d63 | L32 | 32 | 0x1000000b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lr_h_32_f936df218d63 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lr_h_32_f936df218d63 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lr_h_32_f936df218d63 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lr_h_32_f936df218d63 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lr_h_32_f936df218d63 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lr_h_32_f936df218d63 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lr_h_32_f936df218d63 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination | Encoded zero discards the loaded value. |
| lr_h_32_f936df218d63 | SrcL | 5 | 0–31 | none | none | Reg5 load address source | Encoded zero reads the architectural zero register as the load address. |
| lr_h_32_f936df218d63 | SrcZero | 5 | 0–31 | none | none | ignored 5-bit alias field | Encoded zero is one of 32 ignored aliases and supplies no operand. |
| lr_h_32_f936df218d63 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| lr_h_32_f936df218d63 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| lr_h_32_f936df218d63 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.H.asl -->
```asl
readonly func InstructionContractOperation_LR_H() => ScalarOperation
begin
    return ScalarOperation_LR_H;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.H.asl -->
```asl
readonly func InstructionContractHandler_LR_H() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;

pure func InstructionContractLoadSizeBytes_LR_H()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractIgnoresSrcZero_LR_H()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsResult_LR_H()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsResult_LR_H()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractReservationGranuleBytes_LR_H()
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
- The effective address must be aligned to 2 bytes.

## State effects

- Snapshot SrcL before any memory, reservation, or destination effect. SrcZero is not read.
- On success, publish the halfword old value only after the load completes and establish the 64-byte-line reservation.
- The 16-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by four bytes. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.

## Memory effects and ordering

### Memory effects

- Read one 2-byte little-endian halfword after complete access preflight and record one ordered load event at the translated address.
- After a successful load, replace any prior local reservation with the original address and width 2; SC matching uses the containing 64-byte reservation granule.
- The 16-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile and does not change the address, event order, loaded value, or reservation.

## Exceptions

- The effective address must be aligned to 2 bytes. Alignment, translation, and read permission are checked before effects and report the original address.
- On a fault, no destination or queue value is published, no memory event is emitted, the prior reservation is preserved, and TPC does not advance. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. SrcZero, aq, rl, far, and all Reg5 values have no reserved encodings.

## Examples

- lr.h [a0], ->a1
- lr.h.aqrl [t#1], ->u
- lr.h.f [sp], ->t
