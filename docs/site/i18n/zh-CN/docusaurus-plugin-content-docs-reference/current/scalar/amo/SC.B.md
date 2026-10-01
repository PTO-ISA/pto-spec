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
`SC.B` 有条件地向内存写入 1 字节值。只有当本地保留仍覆盖存储地址所在的 64 字节缓存行时才会写入；否则 `SC.B` 报告未命中且不改动内存。该形式记录的摘要为：SC.B conditionally stores one byte when the local 64-byte-line reservation matches. 
只有先前的 `LR` 加载才能建立保留，而每次尝试都会清除它，因此 `SC.B` 报告结果而不是无条件更新内存。该结果写入 `RegDst` 命名的 Reg5 目的。

<!-- PTO-READER-BLOCK: scalar-sc-b-mechanism role=mechanism -->
## 原子机制
指令契约以存储宽度 `1` 字节和 `64` 字节保留粒度选择 `ScalarHandler_StoreConditional`，并记录未命中不做探测。
标量分派调用 `StoreConditional`，它先读取 `SrcL` 与 `SrcR`，然后在查看访问之前清除 `_ReservationValid`。存储的粒度地址与 `_ReservationAddress` 不同即为未命中：辅助函数返回 `Zeros + 1`，且从不调用 `ProbeDataAccess`，因此不会发生预检，也不会触发故障。
匹配时会在存储地址处为 `1` 字节构造写入预检。预检失败会触发数据访问故障且不发布任何值；预检通过则写入 `SrcL` 的低 8 位，记录一个有排序的存储事件，并返回 `Zeros`。
设计要点：保留在预检之前而非存储之后被清除，因此每次尝试都消耗它，访问陷入之后若不重新执行 `LR` 加载，就无法获得成功的重试。保留因此表现为一次性令牌，而不是锁存状态。

<!-- PTO-READER-BLOCK: scalar-sc-b-inputs-outputs role=inputs-outputs -->
## 输入与结果
`SrcL` 提供待存值，`SrcR` 提供存储地址。`RegDst` 接收状态：匹配且无故障的存储之后为 `0`，保留未命中之后为 `1`。
`aq` 与 `rl` 选择成功存储所记录的排序。`far` 只是路由提示：`AtomicAddress` 原样返回其 `address` 参数，而保留比较使用同一地址。
全部 32 个源编码都已分配：`0`..`23` 命名 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。全部 32 个目的编码也都合法：`0` 与 `24`..`29` 丢弃状态，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`1`..`23` 写入具名 GPR。

<!-- PTO-READER-BLOCK: scalar-sc-b-effects role=effects -->
## 效果、状态与排序
成功的存储把 1 个字节写入翻译后的地址，以所选排序记录一个存储事件，并发布状态 `Zeros`。未命中发布状态 `Zeros + 1`，且由于没有发生内存访问而不记录内存事件。
三种结果都会清除保留：成功、未命中以及命中同行的访问故障。命中同行的故障不发布状态，且陷入保存原始 `TPC`；恢复时还原它，因此不重新执行 `LR` 的重新执行本身就是一次不做探测的未命中。
成功完成与未命中都会使 `TPC` 前进 `4` 字节。`SC.B` 不记录数值状态。
设计要点：未命中路径刻意跳过对齐与翻译检查，尽管成功存储要求两者，因此陈旧的保留报告的是未命中，而不是关于程序即将写入的地址的故障。

<!-- PTO-READER-BLOCK: scalar-sc-b-constraints role=constraints -->
## 合法性与精确故障
该存储宽度为一个字节，因此每个字节地址都自然对齐，对齐检查总是通过。在命中同行的尝试中，顺序是固定的：先清除保留，再检查对齐、翻译与写权限，最后才执行存储。命中同行的故障报告原始架构地址，不发出事件，且保持内存与目的不变。
不匹配不是故障：未命中路径即使面对未对齐或超出范围的地址也不触发数据访问故障，因为它从不做预检，且由于未命中不做探测，保留比较成为访问内存之前的唯一闸门。
当没有任何形式能解码该 32 位模式时（本形式在掩码 `0xf000707f` 下匹配 `0x0000100b`），以及当某个具名源选择了无效的临时队列项时，都会在任何效果之前触发 `Fault_IllegalInstruction`。`SrcL` 的编码零提供数值零作为待存值，`SrcR` 的编码零读取架构零寄存器作为存储地址。
设计要点：该比较依据整个 64 字节粒度：`LR` 的字节地址与宽度都不会缩小匹配范围。

<!-- PTO-READER-BLOCK: scalar-sc-b-example role=example -->
## 非规范示例
本示例说明当前的 ASL 归属，不替代规范操作。
八种可接受写法由可选的 `.aq`、`.rl` 与 `.f` 后缀组合而成；状态目的也可写作 `->t` 或 `->u`。
```text
sc.b SrcL, [SrcR], ->Rd
sc.b.aq SrcL, [SrcR], ->Rd
sc.b.rl SrcL, [SrcR], ->Rd
sc.b.f SrcL, [SrcR], ->Rd
sc.b.aqrl SrcL, [SrcR], ->Rd
sc.b.aqf SrcL, [SrcR], ->Rd
sc.b.rlf SrcL, [SrcR], ->Rd
sc.b.aqrlf SrcL, [SrcR], ->Rd
```
两条指令即可让两种结果可见。下面的 `LR.W` 把地址 `a1` 处的字加载到 `a3`，从而建立保留；随后该条件存储针对来自 `a1` 的同一缓存行，并把状态发布到 `a2`。
```text
lr.w [a1], ->a3
sc.b a0, [a1], ->a2
```
如果其间没有其他写入改写该缓存行，`SC.B` 完成存储且 `a2` 为 `0`；如果保留已丢失，`a2` 为 `1` 且内存不变。
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
