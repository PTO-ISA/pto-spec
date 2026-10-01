<!-- GENERATED FROM: asl/scalar/amo/DMA.asl -->
# DMA

**Normative ASL source:** `asl/scalar/amo/DMA.asl`

DMA performs an exact 64-byte copy, validates both ranges before effects, snapshots the source so overlap has memmove semantics, and guarantees that any fault leaves memory unchanged for precise full reissue.

## Normative identity {#PTO-INST-SCALAR-DMA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dma-purpose role=purpose -->
## DMA 的作用

`DMA` 把 `SrcL` 中的字节地址处的恰好 `64` 字节复制到 `SrcR` 中的字节地址处。该形式没有目标寄存器，因此没有任何 GPR 或队列项接收结果：唯一的架构结果是内存中的目的范围。

成功执行会提交整个复制并把 `TPC` 前进 `4` 字节；发生故障时不提交任何内容，`TPC` 停在出错指令上。

设计要点：复制长度属于助记符而不属于编码。`InstructionContractCopySizeBytes_DMA` 返回 `64`，两个预检都请求 `64` 字节，因此没有任何字段取值能选择其他长度。

<!-- PTO-READER-BLOCK: scalar-dma-mechanism role=mechanism -->
## 复制如何排序

分派把该形式交给 `asl/scalar/model/amo/semantics.asl` 中的 `ExecuteScalarDMACopy64`。两个 `ReadDecodedScalarRegister` 参数都在该调用之前求值，因此在第一次预检之前两个地址都已快照。

随后各步骤按固定顺序执行：

- 以 1 字节对齐探测完整的 `64` 字节源范围的读访问；
- 以 1 字节对齐探测完整的 `64` 字节目的范围的写访问；
- 把全部 `64` 个源字节读入一个快照，并记录 `8` 个 relaxed 载入事件；
- 把该快照写入目的范围，并记录 `8` 个 relaxed 存储事件。

设计要点：快照在写入第一个目的字节之前读取，因此重叠范围表现为 `memmove`：当目的地址比源地址高 `8` 字节时，出现在 `source+8 .. source+71` 的字节就是原来的 `source+0 .. source+63`。

设计要点：源预检先于目的预检，因此当两个范围都不可用时，报告的故障属于源范围，此时根本不会探测目的范围。

<!-- PTO-READER-BLOCK: scalar-dma-inputs-outputs role=inputs-outputs -->
## 输入与结果

`SrcL` 是位于指令位 `15..19` 的 `5` 位字段，提供源字节地址；`SrcR` 是位于位 `20..24` 的 `5` 位字段，提供目的字节地址。两者都是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。

读取队列项不会消费它，因此 `dma [t#1], u#1` 读取 `T#1` 和 `U#1`，两个队列的深度都保持不变。

指令匹配把位 `31:25` 固定为零，因此该形式没有排序字段、没有路由提示、也没有尺寸修饰位：既没有 `far` 位，也没有 `.aq`、`.rl` 或尺寸后缀可编码。对齐要求为 1 字节，因此每个字节地址都能通过 `ProbeDataAccess` 中的对齐检查；该范围仍必须通过权限与边界检查。

设计要点：由于对齐要求是 1 字节，`ProbeDataAccess` 的对齐分支在这里不会触发，因此该形式唯一会引发的数据访问故障是 `Fault_DataPage`。

<!-- PTO-READER-BLOCK: scalar-dma-effects role=effects -->
## 效果与排序

成功执行先在翻译后的源地址加偏移 `0, 8, ... 56` 处记录 `8` 个 `8` 字节的载入事件，然后把快照的全部 `64` 字节写入目的范围，再在翻译后的目的地址加相同偏移处记录 `8` 个 `8` 字节的存储事件。每个事件都使用 relaxed 排序，且只有在内存事件捕获启用时才会被捕获。

当保留有效且 `64` 字节的目的范围与保留的 `64` 字节粒度重叠时，目的存储会使本地保留失效；不重叠的保留保持不变。GPR 与队列项都不变。

设计要点：每个记录的存储事件取值都来自该快照，而不是再次读取源，因此事件轨迹描述的是指令开始之前源字节的状态。

<!-- PTO-READER-BLOCK: scalar-dma-constraints role=constraints -->
## 合法性与精确故障

在读取或写入任何字节之前，两个完整范围都必须通过预检，并且第一个失败的探测决定结果。故障携带原始架构地址；在参考模型中，地址转换会原样返回该地址。

任一探测发生故障时都不会产生目的字节、内存事件、保留变化或 `TPC` 前进。译码失败或所选 T/U 源不可用会在此之前引发 `Fault_IllegalInstruction`。

设计要点：由于两个探测在复制开始之前覆盖完整范围，故障会让内存保持原样；因此重新执行会执行整个复制，而不是从中途继续。

<!-- PTO-READER-BLOCK: scalar-dma-example role=example -->
## 非规范示例

本示例只展示一种已接受写法；下方生成的契约仍是权威来源。

当 `a0` 保存源地址、`a1` 保存比它高 `8` 字节的地址时，`dma [a0], a1` 会把原来位于 `[a0 .. a0+63]` 的 `64` 字节留在 `[a0+8 .. a0+71]`，捕获的轨迹中有 `8` 个载入事件，随后是 `8` 个存储事件。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dma [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dma_32_a168aeca5fa5 | L32 | 32 | 0x0000700b / 0xfe007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dma_32_a168aeca5fa5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| dma_32_a168aeca5fa5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dma_32_a168aeca5fa5 | SrcL | 5 | 0–31 | none | none | Reg5 source byte-address source | Encoded zero reads the architectural zero register as source byte address zero. |
| dma_32_a168aeca5fa5 | SrcR | 5 | 0–31 | none | none | Reg5 destination byte-address source | Encoded zero reads the architectural zero register as destination byte address zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source byte-address source |
| SrcR | Reg5 destination byte-address source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/DMA.asl -->
```asl
readonly func InstructionContractOperation_DMA()
    => ScalarOperation
begin
    return ScalarOperation_DMA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/DMA.asl -->
```asl
readonly func InstructionContractHandler_DMA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDMACopy64;
end;

pure func InstructionContractCopySizeBytes_DMA()
    => integer {1..262144}
begin
    return 64;
end;

pure func InstructionContractEventChunkSizeBytes_DMA()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractEventChunkCount_DMA()
    => integer {1..16}
begin
    return 8;
end;

pure func InstructionContractSourceProbePrecedesDestination_DMA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourceBeforeCommit_DMA()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required Reg5 source fields. Encoded source zero reads the architectural zero register as byte address zero; no field value denotes omission.
- DMA has no ordering, route, destination, or size modifier. The copy size is always 64 bytes, its alignment requirement is one byte, and every successful memory event is relaxed.

## Legality

- All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- Both complete 64-byte ranges must pass access preflight. The source range is probed before the destination range and the first failing probe wins.
- Every byte address is naturally aligned because DMA requires one-byte alignment. Exact overlap, forward overlap, backward overlap, and disjoint ranges are all legal.

## State effects

- Snapshot both Reg5 address operands before access preflight so repeated GPR selectors and T/U queue sources observe pre-instruction values. DMA has no scalar destination and consumes no queue entry.
- Successful execution advances TPC by four bytes after the complete memory and event commit. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.
- GPRs, T/U queues, unrelated memory, and unrelated architectural state are unchanged. Reservation state changes only for a successful destination range overlapping the reserved 64-byte granule.

## Memory effects and ordering

### Memory effects

- Probe the complete 64-byte source range for read access, then the complete 64-byte destination range for write access, before reading or writing architectural memory.
- All 64 source bytes are snapshotted before the first destination write, giving exact, forward, and backward overlap memmove semantics.
- A successful captured execution emits eight ordered 8-byte relaxed load events followed by eight ordered 8-byte relaxed store events. Each store event value is derived from the corresponding chunk of the single source snapshot.
- The destination store invalidates an overlapping local reservation and preserves a nonoverlapping reservation. Either fault preserves the prior reservation.

### Ordering

- The eight load events precede all eight store events in instruction program order. Every event uses relaxed ordering.
- DMA is one restartable instruction: a fault exposes no event prefix or partial destination update; recovery performs a full reissue and one successful commit.

## Exceptions

- Bits 31:25 are fixed zero by the instruction match. Any other fixed-bit pattern is not DMA and raises Fault_IllegalInstruction before effects when it has no other legal owner.
- The source range is probed before the destination range. The first failing alignment, translation, permission, or bounded-memory check reports the original architectural address.
- A source or destination fault occurs before any source byte read, memory event, destination write, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores it for full reissue.

## Examples

- dma [a0], a1
- dma [t#1], u#1
- dma [zero], sp
