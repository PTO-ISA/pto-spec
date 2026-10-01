<!-- GENERATED FROM: asl/scalar/agu/SD.PCR.asl -->
# SD.PCR

**Normative ASL source:** `asl/scalar/agu/SD.PCR.asl`

SD.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-SD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sd-pcr-purpose role=purpose -->
## `SD.PCR` 做什么

`SD.PCR` 把 `SrcL` 的低 `8` 字节写入一个 PC 相对地址。它没有基址寄存器字段：地址是当前 `TPC` 加一个有符号 `17` 位字位移。其规范汇编是 `sd.pcr SrcL, [symbol]`。

设计要点：与本章族中所有 PC 相对形式一样，这里的位移缩放是 `4` 而不是 `8`。基址只满足 `4` 字节对齐，因此 `4` 的奇数倍可以表示，并会产生 `8` 字节访问所拒绝的地址。

<!-- PTO-READER-BLOCK: scalar-sd-pcr-mechanism role=mechanism -->
## `SD.PCR` 如何形成地址并完成存储

基址是执行前的 `TPC` 并把位 `1`:`0` 清零，偏移量是符号扩展后的 `simm` 字段左移 `2` 位。两个值按 `2^PTO_XLEN` 取模相加。

写入该地址的值是 `SrcL` 的低 `8` 字节，最低有效字节位于最低地址，并在存储之前读取。本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：在 `4` 字节对齐的基址与按 `4` 缩放的位移下，有效地址总是 `4` 的倍数。只有 `4` 的偶数倍才适合 `8` 字节访问，因此位移 `4` 会被拒绝，而 `0` 与 `8` 会被接受。

<!-- PTO-READER-BLOCK: scalar-sd-pcr-inputs role=inputs-outputs -->
## 编码字段与存储消费的内容

- `SrcL` 是 `5` 位 Reg5 存储数据源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm` 是有符号 `17` 位字位移，因此全部 `131072` 个编码都是取值。字节位移是 `-262144` 到 `262140` 之间 `4` 的倍数。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：存储数据是完整的 `64` 位寄存器，因此不适用任何扩展规则：写入的 `8` 字节正是 `SrcL` 的各位。

<!-- PTO-READER-BLOCK: scalar-sd-pcr-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在内存效果之前被读取，而 `TPC` 前移是最后一步，因此地址从不依赖该指令自身的退休。

成功执行会完成一次 relaxed `8` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：一个事件覆盖整个 `8` 字节范围：可执行路径记录单个 relaxed 存储事件，而不是两个 `4` 字节事件。

<!-- PTO-READER-BLOCK: scalar-sd-pcr-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配，或所选 `T`/`U` 数据源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

因为访问宽 `8` 字节，预检检查有效地址的低 `3` 位，因此是 `4` 的倍数但不是 `8` 的倍数的地址会在翻译之前引发 `Fault_DataAlignment`。对齐但未通过权限或有界内存测试的地址会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：对齐要求随访问宽度增长，而 PC 相对缩放始终保持 `4`。正是这一不匹配使本形式能够报告 `Fault_DataAlignment`；更小的 PC 相对存储无法做到。

<!-- PTO-READER-BLOCK: scalar-sd-pcr-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sd.pcr 5, [symbol]`，执行时 `TPC` = `0x3000`，`simm` 等于 `1`，GPR5 = `0x0123456789ABCDEF`。
- 基址是 `0x3000`，位移是 `1` 乘 `4`，即 `4`，因此有效地址是 `0x3004`。
- `0x3004` 是 `4` 的倍数但不是 `8` 的倍数，因此预检引发 `Fault_DataAlignment`：没有字节被写入、没有事件被记录，`TPC` 停在 `0x3000`。
- 若 `simm` 等于 `2`，地址会是 `0x3008`；`8` 字节 `EF CD AB 89 67 45 23 01` 被写入该处，`TPC` 变为 `0x3004`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sd.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_pcr_32_2340e0085413 | L32 | 32 | 0x00003069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_pcr_32_2340e0085413 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_pcr_32_2340e0085413 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sd_pcr_32_2340e0085413 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sd_pcr_32_2340e0085413 | simm | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SD.PCR.asl -->
```asl
readonly func InstructionContractOperation_SD_PCR() => ScalarOperation
begin
    return ScalarOperation_SD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SD.PCR.asl -->
```asl
readonly func InstructionContractHandler_SD_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SD_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SD_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_SD_PCR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_SD_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SD_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SD_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SD_PCR()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sd.pcr SrcL, [symbol]
