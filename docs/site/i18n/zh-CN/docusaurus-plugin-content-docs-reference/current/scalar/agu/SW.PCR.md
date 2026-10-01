<!-- GENERATED FROM: asl/scalar/agu/SW.PCR.asl -->
# SW.PCR

**Normative ASL source:** `asl/scalar/agu/SW.PCR.asl`

SW.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-SW-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-pcr-purpose role=purpose -->
## `SW.PCR` 做什么

`SW.PCR` 把 `SrcL` 的低 `4` 字节写入一个 PC 相对地址。它没有基址寄存器字段：地址是当前 `TPC` 加一个有符号 `17` 位字位移。其规范汇编是 `sw.pcr SrcL, [symbol]`。

设计要点：缩放 `4` 与 `4` 字节访问完全匹配。因此 `4` 字节对齐的基址加 `4` 的倍数位移总是给出可接受的地址，本形式没有对齐故障可报告。

<!-- PTO-READER-BLOCK: scalar-sw-pcr-mechanism role=mechanism -->
## `SW.PCR` 如何形成地址并完成存储

基址是执行前的 `TPC` 并把位 `1`:`0` 清零，偏移量是符号扩展后的 `simm` 字段左移 `2` 位。两个值按 `2^PTO_XLEN` 取模相加。

写入该地址的值是 `SrcL` 的低 `4` 字节，最低有效字节位于最低地址，并在存储之前读取。本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：写入的 `4` 字节是 `SrcL` 的低 `32` 位，最低有效字节位于最低地址。寄存器的高 `32` 位不会通过本形式进入内存。

<!-- PTO-READER-BLOCK: scalar-sw-pcr-inputs role=inputs-outputs -->
## 编码字段与存储消费的内容

- `SrcL` 是 `5` 位 Reg5 存储数据源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm` 是有符号 `17` 位字位移，因此全部 `131072` 个编码都是取值。字节位移是 `-262144` 到 `262140` 之间 `4` 的倍数。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：`SrcL` 是唯一的寄存器字段，它既是数据源，又通过汇编符号隐含了寻址方式的基址。没有任何寄存器参与地址计算。

<!-- PTO-READER-BLOCK: scalar-sw-pcr-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在内存效果之前被读取，而 `TPC` 前移是最后一步，因此地址从不依赖该指令自身的退休。

成功执行会完成一次 relaxed `4` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：`SW.PCR` 是位置式存储：其目标随代码移动。在它之前插入一条指令就会改变地址，因此它适合与存储之间距离固定的数据槽位。

<!-- PTO-READER-BLOCK: scalar-sw-pcr-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配，或所选 `T`/`U` 数据源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

`4` 字节访问需要 `4` 的倍数地址，而本形式产生的每个地址都是 `4` 的倍数，因此 `Fault_DataAlignment` 不可达。预检仍会执行对齐测试，随后执行权限与有界内存测试，后者失败会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：对齐结果完全由编码决定，因此任何操作数选择都无法触发对齐故障。本族最大的 PC 相对存储 `SD.PCR` 有相同的缩放但更宽的访问，正是这一点使它的对齐故障可达。

<!-- PTO-READER-BLOCK: scalar-sw-pcr-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sw.pcr 5, [symbol]`，执行时 `TPC` = `0x4004`，`simm` 等于 `2`，GPR5 = `0x00000000DEADBEEF`。
- 基址是 `0x4004`，位移是 `2` 乘 `4`，即 `8`，因此有效地址是 `0x400C`。
- `0x400C` 是 `4` 的倍数，预检通过，`4` 字节 `EF BE AD DE` 被写入该处，低字节在前。
- GPR5 不变，`TPC` 变为 `0x4008`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_pcr_32_436677679523 | L32 | 32 | 0x00002069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_pcr_32_436677679523 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_pcr_32_436677679523 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_pcr_32_436677679523 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sw_pcr_32_436677679523 | simm | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SW.PCR.asl -->
```asl
readonly func InstructionContractOperation_SW_PCR() => ScalarOperation
begin
    return ScalarOperation_SW_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SW.PCR.asl -->
```asl
readonly func InstructionContractHandler_SW_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SW_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SW_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_SW_PCR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SW_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SW_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SW_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SW_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- simm assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sw.pcr SrcL, [symbol]
