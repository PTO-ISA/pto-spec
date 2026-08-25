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

`LR.D` 载入一个双字，发布其零扩展值，并把本地保留替换为包含该地址的 64 字节缓存行。

<!-- PTO-READER-BLOCK: scalar-lr-d-mechanism role=mechanism -->
## 原子机制

ASL DOC 契约选择 `ScalarHandler_LoadReserved`，访问宽度为 `8` 字节。

`SrcZero` 是被忽略的 5 位别名字段：全部 32 个编码选择同一操作，并且不会通过该字段消费源。

<!-- PTO-READER-BLOCK: scalar-lr-d-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 承载 Reg5 载入地址源；`SrcZero` 承载被忽略的 5 位别名字段；`RegDst` 承载 Reg5 载入值目的地；`aq` 承载获取排序位；`rl` 承载释放排序位；`far` 承载平坦地址路由提示。

`aq` 与 `rl` 选择宽松、获取、释放或获取-释放排序；`far` 是配置档路由提示，在参考配置档中不改变架构结果。

<!-- PTO-READER-BLOCK: scalar-lr-d-effects role=effects -->
## 效果与排序

载入成功时，会在访问预检完成后发出一个带排序属性的载入事件、发布旧值并建立保留。

载入后，包含该地址的 64 字节缓存行成为本地保留，`TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-lr-d-constraints role=constraints -->
## 合法性与精确故障

有效地址必须按 `8` 字节对齐。对齐、地址翻译和权限检查都先于架构效果。

预检失败时不会发布目的值、内存事件、保留更新或退役效果；保存的原始 `TPC` 支持完整重新执行。

<!-- PTO-READER-BLOCK: scalar-lr-d-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

初次阅读可从 `lr.d [SrcL], ->Rd` 开始，再只改变上文说明的排序或路由修饰位。
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
