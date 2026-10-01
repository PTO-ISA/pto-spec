<!-- GENERATED FROM: asl/scalar/agu/SH.U.asl -->
# SH.U

**Normative ASL source:** `asl/scalar/agu/SH.U.asl`

SH.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-SH-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sh-u-purpose role=purpose -->
## `SH.U` 做什么

`SH.U` 把 `SrcD` 的低 `2` 字节写入由 `SrcL` 基址加经过转换的 `SrcR` 寄存器偏移量形成的地址。其规范汇编是 `sh.u SrcD, [SrcL, SrcR<{.sw,.uw}>]`。

设计要点：`.u` 标记去掉了访问宽度的缩放，因此偏移量以字节计数。`SH` 会把同一偏移量乘以 `2`，因此对同一个偏移值，两种形式访问的位置相差 `2` 倍。

<!-- PTO-READER-BLOCK: scalar-sh-u-mechanism role=mechanism -->
## `SH.U` 如何形成地址并完成存储

`SrcL` 提供基址。`SrcR` 由 `SrcRType` 转换——`0` 保留完整的 `64` 位值，`1` 符号扩展低 `32` 位，`2` 零扩展低 `32` 位——固定缩放 `1` 使它不被移位。基址与偏移量按 `2^PTO_XLEN` 取模相加。

写入该地址的值是 `SrcD` 的低 `2` 字节，最低有效字节位于最低地址。本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：对齐由基址与偏移量之和决定，而不是由其中单独一个决定。奇数基址加奇数偏移得到偶数地址并成功，而同一偏移量配偶数基址得到奇数地址并引发 `Fault_DataAlignment`。

<!-- PTO-READER-BLOCK: scalar-sh-u-inputs role=inputs-outputs -->
## 编码字段与存储消费的内容

- `SrcD`、`SrcL` 与 `SrcR` 是 `5` 位 Reg5 源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `SrcRType` 的 `0`、`1`、`2` 均已分配；原始值 `3` 为保留值。本形式没有 `shamt` 字段，因此偏移量的缩放固定为 `1`。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：`SrcD` 只贡献其低 `16` 位。寄存器的上 `48` 位被本形式忽略，因此低半部分相同的两个寄存器会产生完全相同的内存内容。

<!-- PTO-READER-BLOCK: scalar-sh-u-effects role=effects -->
## 影响、顺序与完成

两个源都在内存效果之前被读取，因此写入的字节是 `SrcD` 在执行前的值。

成功执行会完成一次 relaxed `2` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：成功的存储若与某个保留共享同一个 `64` 字节粒度区，即使被保留的字节本身未被触及，该保留也会被作废，因为比较使用的是粒度区而不是所存范围。

<!-- PTO-READER-BLOCK: scalar-sh-u-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配、`SrcRType` 取保留值 `3`，或所选 `T`/`U` 源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

因为访问宽 `2` 字节，预检检查有效地址的最低位。非零值会在翻译之前引发 `Fault_DataAlignment`；偶数地址若未通过权限或有界内存测试，会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：由于偏移量不缩放，奇数偏移是合法且有用的，只有结果地址的奇偶性才重要。当字节偏移已经算好时选本形式，当偏移是元素索引时选 `SH`。

<!-- PTO-READER-BLOCK: scalar-sh-u-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sh.u 6, [2, 3<.sw>]`，设 GPR2 = `0x1001`，GPR3 = `0xFFFFFFFF`，GPR6 = `0x000000000000ABCD`。
- `SrcRType=1` 把低 `32` 位符号扩展为 `-1`，缩放 `1` 使偏移量保持不变。
- 有效地址是 `0x1001` 减 `1`，即 `0x1000`；它是偶数，预检通过，`2` 字节 `CD AB` 被写入该处。
- 没有寄存器变化，`TPC` 前移 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sh.u SrcD, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_u_32_fa87afbf8f24 | L32 | 32 | 0x00005049 / 0x00007fff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_u_32_fa87afbf8f24 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sh_u_32_fa87afbf8f24 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_u_32_fa87afbf8f24 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sh_u_32_fa87afbf8f24 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sh_u_32_fa87afbf8f24 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sh_u_32_fa87afbf8f24 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sh_u_32_fa87afbf8f24 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sh_u_32_fa87afbf8f24 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `sh_u_32_fa87afbf8f24.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SH.U.asl -->
```asl
readonly func InstructionContractOperation_SH_U() => ScalarOperation
begin
    return ScalarOperation_SH_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SH.U.asl -->
```asl
readonly func InstructionContractHandler_SH_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SH_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SH_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SH_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_SH_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SH_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SH_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SH_U()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- sh.u SrcD, [SrcL, SrcR<{.sw,.uw}>]
