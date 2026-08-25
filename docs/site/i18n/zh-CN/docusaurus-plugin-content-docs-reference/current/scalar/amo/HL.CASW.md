<!-- GENERATED FROM: asl/scalar/amo/HL.CASW.asl -->
# HL.CASW

**Normative ASL source:** `asl/scalar/amo/HL.CASW.asl`

HL.CASW atomically compares and conditionally replaces one word, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-HL-CASW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-casw-purpose role=purpose -->
## HL.CASW 的作用

`HL.CASW` 把 `SrcL` 指向的字与 `SrcR` 进行原子比较；相等时写入 `SrcD`，而两条路径都会发布先前的 32 位值。

<!-- PTO-READER-BLOCK: scalar-hl-casw-mechanism role=mechanism -->
## 原子机制

ASL DOC 契约选择 `ScalarHandler_CompareAndSwap`，访问宽度为 `4` 字节。

匹配与不匹配都会发出一个带排序属性的原子事件；只有匹配路径会把写入标记为已执行。

<!-- PTO-READER-BLOCK: scalar-hl-casw-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 承载 Reg5 原子地址源；`SrcR` 承载 Reg5 期望字源；`SrcD` 承载 Reg5 目标字源；`RegDst` 承载 Reg5 旧值目的地；`aq` 承载获取排序位；`rl` 承载释放排序位；`far` 承载平坦地址路由提示。

`aq` 与 `rl` 选择宽松、获取、释放或获取-释放排序；`far` 是配置档路由提示，在参考配置档中不改变架构结果。

<!-- PTO-READER-BLOCK: scalar-hl-casw-effects role=effects -->
## 效果与排序

预检成功后，即使比较不匹配也会发布旧值；只有相等时内存才会改变。

完成的写入会使重叠的本地 64 字节缓存行保留失效，保留不重叠的保留，并让 `TPC` 前进 `6` 字节。

<!-- PTO-READER-BLOCK: scalar-hl-casw-constraints role=constraints -->
## 合法性与精确故障

有效地址必须按 `4` 字节对齐。对齐、地址翻译和权限检查都先于架构效果。

预检失败时不会发布目的值、内存事件、保留更新或退役效果；保存的原始 `TPC` 支持完整重新执行。

<!-- PTO-READER-BLOCK: scalar-hl-casw-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

初次阅读可从 `hl.casw [SrcL], SrcR, SrcD, ->Rd` 开始，再只改变上文说明的排序或路由修饰位。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.casw [SrcL], SrcR, SrcD, ->Rd
hl.casw.aq [SrcL], SrcR, SrcD, ->Rd
hl.casw.rl [SrcL], SrcR, SrcD, ->Rd
hl.casw.f [SrcL], SrcR, SrcD, ->Rd
hl.casw.aqrl [SrcL], SrcR, SrcD, ->Rd
hl.casw.aqf [SrcL], SrcR, SrcD, ->Rd
hl.casw.rlf [SrcL], SrcR, SrcD, ->Rd
hl.casw.aqrlf [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_casw_48_a89b3d58d8f0 | HL48 | 48 | 0x2000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_casw_48_a89b3d58d8f0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_casw_48_a89b3d58d8f0 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_casw_48_a89b3d58d8f0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_casw_48_a89b3d58d8f0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_casw_48_a89b3d58d8f0 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_casw_48_a89b3d58d8f0 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_casw_48_a89b3d58d8f0 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_casw_48_a89b3d58d8f0 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| hl_casw_48_a89b3d58d8f0 | SrcD | 5 | 0–31 | none | none | Reg5 desired word source | Encoded zero supplies numeric zero as the desired value. |
| hl_casw_48_a89b3d58d8f0 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| hl_casw_48_a89b3d58d8f0 | SrcR | 5 | 0–31 | none | none | Reg5 expected word source | Encoded zero supplies numeric zero as the expected value. |
| hl_casw_48_a89b3d58d8f0 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| hl_casw_48_a89b3d58d8f0 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| hl_casw_48_a89b3d58d8f0 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected word source |
| SrcD | Reg5 desired word source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASW.asl -->
```asl
readonly func InstructionContractOperation_HL_CASW() => ScalarOperation
begin
    return ScalarOperation_HL_CASW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASW.asl -->
```asl
readonly func InstructionContractHandler_HL_CASW() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractHasFarField_HL_CASW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASW()
    => boolean
begin
    return TRUE;
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
- The effective address must be aligned to 4 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 32-bit old value is sign-extended to XLEN.
- Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 4-byte word and compare it with SrcR truncated to 4 bytes.
- On equality, store SrcD truncated to 4 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 32-bit old value is sign-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 4 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- hl.casw [a0], a1, a2, ->a3
- hl.casw.aqrlf [t#1], u#1, a0, ->u
