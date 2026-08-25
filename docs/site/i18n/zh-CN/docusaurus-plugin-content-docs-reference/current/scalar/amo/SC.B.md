<!-- GENERATED FROM: asl/scalar/amo/SC.B.asl -->
# SC.B

**Normative ASL source:** `asl/scalar/amo/SC.B.asl`

SC.B conditionally stores one byte when the local 64-byte-line reservation matches.

## Normative identity {#PTO-INST-SCALAR-SC-B}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sc-b-purpose role=purpose -->
## SC.B 的作用

`SC.B` 在本地 64 字节缓存行保留匹配时有条件地存储一个字节，成功发布状态零，未命中发布状态一。

<!-- PTO-READER-BLOCK: scalar-sc-b-mechanism role=mechanism -->
## 原子机制

ASL DOC 契约选择 `ScalarHandler_StoreConditional`，访问宽度为 `1` 字节。

每次尝试都会清除保留。保留未命中不会进行探测；匹配尝试则在内存或目的地效果之前执行写入预检。

<!-- PTO-READER-BLOCK: scalar-sc-b-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 承载 Reg5 字节存储值源；`SrcR` 承载 Reg5 存储地址源；`RegDst` 承载 Reg5 成功状态目的地；`aq` 承载获取排序位；`rl` 承载释放排序位；`far` 承载平坦地址路由提示。

`aq` 与 `rl` 选择宽松、获取、释放或获取-释放排序；`far` 是配置档路由提示，在参考配置档中不改变架构结果。

<!-- PTO-READER-BLOCK: scalar-sc-b-effects role=effects -->
## 效果与排序

匹配且无故障时，操作会存储源的低位部分并发出一个带排序属性的存储事件；未命中保持内存不变且不发出事件。

成功、未命中和缓存行匹配故障都会清除保留；成功或未命中会让 `TPC` 前进 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-sc-b-constraints role=constraints -->
## 合法性与精确故障

每个字节地址都天然对齐。对齐、地址翻译和权限检查都先于架构效果。

保留未命中不会进行探测。缓存行匹配故障会清除保留，但不发布状态、事件、内存更新或 `TPC` 前进；恢复后若没有新的 LR，重新执行会未命中。

<!-- PTO-READER-BLOCK: scalar-sc-b-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

初次阅读可从 `sc.b SrcL, [SrcR], ->Rd` 开始，再只改变上文说明的排序或路由修饰位。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sc.b SrcL, [SrcR], ->Rd
sc.b.aq SrcL, [SrcR], ->Rd
sc.b.rl SrcL, [SrcR], ->Rd
sc.b.f SrcL, [SrcR], ->Rd
sc.b.aqrl SrcL, [SrcR], ->Rd
sc.b.aqf SrcL, [SrcR], ->Rd
sc.b.rlf SrcL, [SrcR], ->Rd
sc.b.aqrlf SrcL, [SrcR], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sc_b_32_baf609e1d5c3 | L32 | 32 | 0x0000100b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sc_b_32_baf609e1d5c3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sc_b_32_baf609e1d5c3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sc_b_32_baf609e1d5c3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sc_b_32_baf609e1d5c3 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| sc_b_32_baf609e1d5c3 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sc_b_32_baf609e1d5c3 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sc_b_32_baf609e1d5c3 | RegDst | 5 | 0–31 | none | none | Reg5 success-status destination | Encoded zero discards the success status. |
| sc_b_32_baf609e1d5c3 | SrcL | 5 | 0–31 | none | none | Reg5 byte store-value source | Encoded zero supplies numeric zero as the store value. |
| sc_b_32_baf609e1d5c3 | SrcR | 5 | 0–31 | none | none | Reg5 store-address source | Encoded zero reads the architectural zero register as the store address. |
| sc_b_32_baf609e1d5c3 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| sc_b_32_baf609e1d5c3 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sc_b_32_baf609e1d5c3 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 byte store-value source |
| SrcR | Reg5 store-address source |
| RegDst | Reg5 success-status destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SC.B.asl -->
```asl
readonly func InstructionContractOperation_SC_B() => ScalarOperation
begin
    return ScalarOperation_SC_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SC.B.asl -->
```asl
readonly func InstructionContractHandler_SC_B() => ScalarSemanticHandler
begin
    return ScalarHandler_StoreConditional;
end;

pure func InstructionContractStoreSizeBytes_SC_B()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractReservationGranuleBytes_SC_B()
    => integer {1..262144}
begin
    return PTO_RESERVATION_GRANULE_BYTES;
end;

pure func InstructionContractSuccessStatus_SC_B() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractMissStatus_SC_B() => Word
begin
    return Zeros{PTO_XLEN} + 1;
end;

pure func InstructionContractMissIsProbeFree_SC_B()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the status.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same address and reservation comparison.

## Legality

- All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned. Reservation match is based only on the containing 64-byte line; LR byte address and width do not narrow it.
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL and SrcR before reservation, memory, or destination effects, including repeated GPR and same-queue aliases.
- Publish status zero after a nonfaulting matching store and status one after a reservation miss. A line-matched fault publishes no status.
- Clear the local reservation for success, miss, and line-matched fault before any possible trap.
- Successful or miss completion advances TPC by four bytes. A line-matched fault saves the original TPC; recovery restores it, and reissue without a new LR completes as a miss.

## Memory effects and ordering

### Memory effects

- A matching reservation is cleared before access preflight. After successful preflight, store SrcL bits 7:0 as one 1-byte little-endian byte, emit one ordered store event, and publish status zero.
- A missing or different-line reservation is cleared and publishes status one without alignment, translation, permission, bounded-memory probe, memory event, or memory access.
- The reservation is cleared by every attempt. A line-matched access fault leaves memory and destination unchanged; after recovery, reissue without a new LR is a probe-free miss.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release on a successful store.
- A reservation miss emits no memory event. far changes only the route hint in the reference profile.

## Exceptions

- Every byte address is naturally aligned. On a line-matched attempt, alignment, translation, and write permission are checked after reservation clear and before memory or destination effects.
- A line-matched access fault reports the original address, emits no event, preserves memory and destination, and enters the ordinary trap envelope. Recovery restores the original TPC.
- A reservation miss is probe-free even for a misaligned or inaccessible address and therefore does not raise a data-access fault.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- sc.b a0, [a1], ->a2
- sc.b.aqrl t#1, [u#1], ->u
- sc.b.f zero, [sp], ->t
