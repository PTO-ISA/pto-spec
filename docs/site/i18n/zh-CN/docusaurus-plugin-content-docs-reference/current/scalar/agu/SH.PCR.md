<!-- GENERATED FROM: asl/scalar/agu/SH.PCR.asl -->
# SH.PCR

**Normative ASL source:** `asl/scalar/agu/SH.PCR.asl`

SH.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-SH-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sh-pcr-purpose role=purpose -->
## `SH.PCR` 做什么

`SH.PCR` 把 `SrcL` 的低 `2` 字节写入一个 PC 相对地址。它没有基址寄存器字段：地址是当前 `TPC` 加一个有符号 `17` 位字位移。其规范汇编是 `sh.pcr SrcL, [symbol]`。

设计要点：基址满足 `4` 字节对齐，位移是 `4` 的倍数，因此本形式能产生的每个地址都是偶数。`2` 字节访问只需要偶数地址，因此这里 `Fault_DataAlignment` 不可达。

<!-- PTO-READER-BLOCK: scalar-sh-pcr-mechanism role=mechanism -->
## `SH.PCR` 如何形成地址并完成存储

基址是执行前的 `TPC` 并把位 `1`:`0` 清零，偏移量是符号扩展后的 `simm` 字段左移 `2` 位。两个值按 `2^PTO_XLEN` 取模相加。

写入该地址的值是 `SrcL` 的低 `2` 字节，最低有效字节位于最低地址，并在存储之前读取。本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：存储的值是 `SrcL` 的低 `16` 位，最低有效字节写在较低地址。若软件希望把 `32` 位值的高半部分放入内存，必须在存储之前先把它移下来。

<!-- PTO-READER-BLOCK: scalar-sh-pcr-inputs role=inputs-outputs -->
## 编码字段与存储消费的内容

- `SrcL` 是 `5` 位 Reg5 存储数据源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm` 是有符号 `17` 位字位移，因此全部 `131072` 个编码都是取值。字节位移是 `-262144` 到 `262140` 之间 `4` 的倍数。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：尽管访问宽 `2` 字节，位移仍按 `4` 缩放，因为本族的所有 PC 相对形式共用同一缩放。缩放并不等于访问宽度，可达字节范围是 `-262144` 到 `262140`。

<!-- PTO-READER-BLOCK: scalar-sh-pcr-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在内存效果之前被读取，而 `TPC` 前移是最后一步，因此地址从不依赖该指令自身的退休。

成功执行会完成一次 relaxed `2` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：只有在未记录故障时，`TPC` 才会在存储事件之后前移，因此发生故障的尝试既不改变内存，也不改变 `TPC`。存储与退休是一个全有或全无的步骤。

<!-- PTO-READER-BLOCK: scalar-sh-pcr-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配，或所选 `T`/`U` 数据源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

`2` 字节访问需要偶数地址，而本形式产生的每个地址都是 `4` 的倍数，因此 `Fault_DataAlignment` 不可达。预检仍会执行对齐测试，随后执行权限与有界内存测试，后者失败会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：对齐结果由编码固定，因此本形式唯一可用的数据故障是 `Fault_DataPage`。程序无法用任何一对编码操作数从 `SH.PCR` 触发对齐故障。

<!-- PTO-READER-BLOCK: scalar-sh-pcr-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sh.pcr 5, [symbol]`，执行时 `TPC` = `0x1010`，`simm` 等于 `-1`，GPR5 = `0x0000000000001234`。
- 基址是 `0x1010`，位移是 `-1` 乘 `4`，即 `-4`，因此有效地址是 `0x100C`。
- `0x100C` 是偶数，预检通过，`2` 字节 `34 12` 被写入该处，低字节在前。
- GPR5 不变，`TPC` 变为 `0x1014`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sh.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_pcr_32_14ba505eb3c2 | L32 | 32 | 0x00001069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_pcr_32_14ba505eb3c2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_pcr_32_14ba505eb3c2 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sh_pcr_32_14ba505eb3c2 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sh_pcr_32_14ba505eb3c2 | simm | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SH.PCR.asl -->
```asl
readonly func InstructionContractOperation_SH_PCR() => ScalarOperation
begin
    return ScalarOperation_SH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SH.PCR.asl -->
```asl
readonly func InstructionContractHandler_SH_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SH_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SH_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_SH_PCR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_SH_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SH_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SH_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SH_PCR()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sh.pcr SrcL, [symbol]
