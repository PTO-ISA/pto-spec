<!-- GENERATED FROM: asl/scalar/amo/SWAPH.asl -->
# SWAPH

**Normative ASL source:** `asl/scalar/amo/SWAPH.asl`

SWAPH atomically replaces one halfword and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-SWAPH}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-swaph-purpose role=purpose -->
## SWAPH 的作用

`SWAPH` 用 `SrcR` 原子替换一个半字，并发布先前的 16 位值。

<!-- PTO-READER-BLOCK: scalar-swaph-mechanism role=mechanism -->
## 原子机制

ASL DOC 契约选择 `ScalarHandler_AtomicReadModifyWrite`，访问宽度为 `2` 字节。

原子交换提交之前，读取与写入探测必须解析到同一个翻译后位置。

<!-- PTO-READER-BLOCK: scalar-swaph-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 承载 Reg5 原子地址源；`SrcR` 承载 Reg5 半字替换值源；`RegDst` 承载 Reg5 旧值目的地；`aq` 承载获取排序位；`rl` 承载释放排序位；`far` 承载平坦地址路由提示。

`aq` 与 `rl` 选择宽松、获取、释放或获取-释放排序；`far` 是配置档路由提示，在参考配置档中不改变架构结果。

<!-- PTO-READER-BLOCK: scalar-swaph-effects role=effects -->
## 效果与排序

成功时，一个原子事件记录此次交换，旧值只会在内存更新提交后发布。

完成的写入会使重叠的本地 64 字节缓存行保留失效，保留不重叠的保留，并让 `TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-swaph-constraints role=constraints -->
## 合法性与精确故障

有效地址必须按 `2` 字节对齐。对齐、地址翻译和权限检查都先于架构效果。

预检失败时不会发布目的值、内存事件、保留更新或退役效果；保存的原始 `TPC` 支持完整重新执行。

<!-- PTO-READER-BLOCK: scalar-swaph-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

初次阅读可从 `swaph [SrcL], SrcR, ->Rd` 开始，再只改变上文说明的排序或路由修饰位。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
swaph [SrcL], SrcR, ->Rd
swaph.aq [SrcL], SrcR, ->Rd
swaph.rl [SrcL], SrcR, ->Rd
swaph.f [SrcL], SrcR, ->Rd
swaph.aqrl [SrcL], SrcR, ->Rd
swaph.aqf [SrcL], SrcR, ->Rd
swaph.rlf [SrcL], SrcR, ->Rd
swaph.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swaph_32_8c2d4a28bf25 | L32 | 32 | 0x1000600b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swaph_32_8c2d4a28bf25 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| swaph_32_8c2d4a28bf25 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swaph_32_8c2d4a28bf25 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swaph_32_8c2d4a28bf25 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| swaph_32_8c2d4a28bf25 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| swaph_32_8c2d4a28bf25 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| swaph_32_8c2d4a28bf25 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| swaph_32_8c2d4a28bf25 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| swaph_32_8c2d4a28bf25 | SrcR | 5 | 0–31 | none | none | Reg5 halfword replacement source | Encoded zero supplies numeric zero as the replacement. |
| swaph_32_8c2d4a28bf25 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| swaph_32_8c2d4a28bf25 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| swaph_32_8c2d4a28bf25 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 halfword replacement source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SWAPH.asl -->
```asl
readonly func InstructionContractOperation_SWAPH() => ScalarOperation
begin
    return ScalarOperation_SWAPH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SWAPH.asl -->
```asl
readonly func InstructionContractHandler_SWAPH() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SWAPH()
    => AtomicOperation
begin
    return Atomic_SWAP;
end;

pure func InstructionContractAtomicSizeBytes_SWAPH()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractZeroExtendsOldValue_SWAPH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_SWAPH()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result.

## Legality

- All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned.
- The effective address must be aligned to 2 bytes.

## State effects

- Snapshot SrcL and SrcR before any memory or destination effect.
- Publish the prior value only after successful atomic commit.
- The 16-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by four bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 2-byte halfword, store SrcR truncated to 2 bytes, and emit one ordered atomic event.
- A successful overlapping write invalidates the local 64-byte-line reservation; a nonoverlapping write preserves it.
- The 16-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 2 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- swaph [a0], a1, ->a2
- swaph.aqrl [t#1], u#1, ->u
- swaph.f [sp], zero, ->t
