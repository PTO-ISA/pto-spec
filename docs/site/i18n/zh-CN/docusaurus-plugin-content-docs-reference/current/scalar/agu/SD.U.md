<!-- GENERATED FROM: asl/scalar/agu/SD.U.asl -->
# SD.U

**Normative ASL source:** `asl/scalar/agu/SD.U.asl`

SD.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-SD-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sd-u-purpose role=purpose -->
## `SD.U` 做什么

`SD.U` 把 `SrcD` 的低 `8` 字节写入由 `SrcL` 基址加经过转换的 `SrcR` 寄存器偏移量形成的地址。其规范汇编是 `sd.u SrcD, [SrcL, SrcR<{.sw,.uw}>]`。

设计要点：`.u` 标记去掉了元素大小的缩放。`SD` 把偏移量乘以 `8`，而 `SD.U` 原样相加，因此同一个偏移寄存器值在 `SD` 下到达的位置比在 `SD.U` 下远 `8` 倍。

<!-- PTO-READER-BLOCK: scalar-sd-u-mechanism role=mechanism -->
## `SD.U` 如何形成地址并完成存储

`SrcL` 提供基址。`SrcR` 由 `SrcRType` 转换——`0` 保留完整的 `64` 位值，`1` 符号扩展低 `32` 位，`2` 零扩展低 `32` 位——固定缩放 `1` 使它不被移位。基址与偏移量按 `2^PTO_XLEN` 取模相加。

写入该地址的值是 `SrcD` 的低 `8` 字节，最低有效字节位于最低地址。本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：偏移量不缩放时，只要基址满足 `8` 字节对齐，偏移 `1` 对 `8` 字节访问就是未对齐的。在 `SD` 中同样的偏移 `1` 会乘以 `8` 并保持对齐，因此 `.u` 形式把对齐责任转移到了偏移值上。

<!-- PTO-READER-BLOCK: scalar-sd-u-inputs role=inputs-outputs -->
## 编码字段与存储消费的内容

- `SrcD`、`SrcL` 与 `SrcR` 是 `5` 位 Reg5 源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `SrcRType` 的 `0`、`1`、`2` 均已分配；原始值 `3` 为保留值。本形式没有 `shamt` 字段，因此偏移量的缩放固定为 `1`。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：三个寄存器字段都在访问之前校验，因此命名不可用 `T`/`U` 槽位的偏移量会在任何地址运算之前被拒绝，与不可用的基址或数据源完全相同。

<!-- PTO-READER-BLOCK: scalar-sd-u-effects role=effects -->
## 影响、顺序与完成

两个源都在内存效果之前被读取，因此写入的字节是 `SrcD` 在执行前的值。

成功执行会完成一次 relaxed `8` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：本形式无法发布更新后的地址，因此需要连续指针的软件必须用另一条指令重新计算。存储本身不改变 `SrcL` 与 `SrcR`。

<!-- PTO-READER-BLOCK: scalar-sd-u-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配、`SrcRType` 取保留值 `3`，或所选 `T`/`U` 源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

因为访问宽 `8` 字节，预检检查有效地址的低 `3` 位。未对齐的值会在翻译之前引发 `Fault_DataAlignment`；对齐但未通过权限或有界内存测试的地址会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：缩放为 `1` 时，对齐由两个操作数共同决定：对某个基址对齐的偏移寄存器，换一个基址就可能未对齐。本形式适合字节偏移已经算好的程序。

<!-- PTO-READER-BLOCK: scalar-sd-u-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sd.u 6, [2, 3]`，设 GPR2 = `0x1000`，GPR3 = `1`，GPR6 = `0x0123456789ABCDEF`。
- 偏移量按编码直接使用，因此有效地址是 `0x1001`。
- `0x1001` 不是 `8` 的倍数，因此预检引发 `Fault_DataAlignment`，没有任何字节被写入。
- 同样的操作数改用 `sd` 时，偏移量是 `1` 乘 `8`，地址为 `0x1008`，`8` 字节 `EF CD AB 89 67 45 23 01` 会被写入该处。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sd.u SrcD, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_u_32_1602c58c2031 | L32 | 32 | 0x00007049 / 0x00007fff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_u_32_1602c58c2031 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sd_u_32_1602c58c2031 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_u_32_1602c58c2031 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sd_u_32_1602c58c2031 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sd_u_32_1602c58c2031 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sd_u_32_1602c58c2031 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sd_u_32_1602c58c2031 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sd_u_32_1602c58c2031 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `sd_u_32_1602c58c2031.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SD.U.asl -->
```asl
readonly func InstructionContractOperation_SD_U() => ScalarOperation
begin
    return ScalarOperation_SD_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SD.U.asl -->
```asl
readonly func InstructionContractHandler_SD_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SD_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SD_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SD_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_SD_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SD_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SD_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SD_U()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- sd.u SrcD, [SrcL, SrcR<{.sw,.uw}>]
