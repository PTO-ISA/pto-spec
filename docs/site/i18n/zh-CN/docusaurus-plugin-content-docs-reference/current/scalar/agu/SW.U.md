<!-- GENERATED FROM: asl/scalar/agu/SW.U.asl -->
# SW.U

**Normative ASL source:** `asl/scalar/agu/SW.U.asl`

SW.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-SW-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-u-purpose role=purpose -->
## `SW.U` 做什么

`SW.U` 把 `SrcD` 的低 `4` 字节写入由 `SrcL` 基址加经过转换的 `SrcR` 寄存器偏移量形成的地址。其规范汇编是 `sw.u SrcD, [SrcL, SrcR<{.sw,.uw}>]`。

设计要点：`.u` 标记使偏移量成为字节计数而不是元素索引。`SW` 会把同一偏移量乘以 `4`，因此同一个偏移寄存器值在不同助记符下指向相距 `4` 字节的两个位置。

<!-- PTO-READER-BLOCK: scalar-sw-u-mechanism role=mechanism -->
## `SW.U` 如何形成地址并完成存储

`SrcL` 提供基址。`SrcR` 由 `SrcRType` 转换——`0` 保留完整的 `64` 位值，`1` 符号扩展低 `32` 位，`2` 零扩展低 `32` 位——固定缩放 `1` 使它不被移位。基址与偏移量按 `2^PTO_XLEN` 取模相加。

写入该地址的值是 `SrcD` 的低 `4` 字节，最低有效字节位于最低地址。本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：对齐是和的性质。`4` 字节对齐基址加偏移 `1` 会被拒绝，而低两位为 `3` 的基址加同一偏移会落在 `4` 的倍数上并被接受。

<!-- PTO-READER-BLOCK: scalar-sw-u-inputs role=inputs-outputs -->
## 编码字段与存储消费的内容

- `SrcD`、`SrcL` 与 `SrcR` 是 `5` 位 Reg5 源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `SrcRType` 的 `0`、`1`、`2` 均已分配；原始值 `3` 为保留值。本形式没有 `shamt` 字段，因此偏移量的缩放固定为 `1`。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：`SrcD` 提供被存储值的低 `32` 位，因此在本形式下，两个在第 `32` 位以下相同的寄存器即使高半部分不同，也会产生相同的内存内容。

<!-- PTO-READER-BLOCK: scalar-sw-u-effects role=effects -->
## 影响、顺序与完成

两个源都在内存效果之前被读取，因此写入的字节是 `SrcD` 在执行前的值。

成功执行会完成一次 relaxed `4` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：存储事件恰好覆盖被访问的 `4` 字节。有效保留因与 `64` 字节粒度区重叠而被作废，因此事件大小与粒度区大小是彼此独立的量。

<!-- PTO-READER-BLOCK: scalar-sw-u-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配、`SrcRType` 取保留值 `3`，或所选 `T`/`U` 源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

因为访问宽 `4` 字节，预检检查有效地址的低 `2` 位。非零值会在翻译之前引发 `Fault_DataAlignment`；对齐但未通过权限或有界内存测试的地址会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：非缩放的 `4` 字节存储让程序完全控制字节地址，代价是必须自己满足对齐规则。`SW` 能从对齐基址保证对齐，但无法表达字节粒度的偏移。

<!-- PTO-READER-BLOCK: scalar-sw-u-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sw.u 6, [2, 3]`，设 GPR2 = `0x1000`，GPR3 = `1`，GPR6 = `0x00000000DEADBEEF`。
- 偏移量按编码直接使用，因此有效地址是 `0x1001`。
- `0x1001` 不是 `4` 的倍数，因此预检引发 `Fault_DataAlignment`：没有字节被写入，`TPC` 停在指令上。
- 改用 `sw` 时，偏移量是 `1` 乘 `4`，地址为 `0x1004`，`4` 字节 `EF BE AD DE` 会被写入该处。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw.u SrcD, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_u_32_718a61f75d33 | L32 | 32 | 0x00006049 / 0x00007fff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_u_32_718a61f75d33 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sw_u_32_718a61f75d33 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_u_32_718a61f75d33 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_u_32_718a61f75d33 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_u_32_718a61f75d33 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sw_u_32_718a61f75d33 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sw_u_32_718a61f75d33 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sw_u_32_718a61f75d33 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `sw_u_32_718a61f75d33.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SW.U.asl -->
```asl
readonly func InstructionContractOperation_SW_U() => ScalarOperation
begin
    return ScalarOperation_SW_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SW.U.asl -->
```asl
readonly func InstructionContractHandler_SW_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SW_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SW_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SW_U()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SW_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SW_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SW_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SW_U()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- sw.u SrcD, [SrcL, SrcR<{.sw,.uw}>]
