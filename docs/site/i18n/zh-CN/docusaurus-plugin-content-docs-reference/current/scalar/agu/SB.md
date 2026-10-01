<!-- GENERATED FROM: asl/scalar/agu/SB.asl -->
# SB

**Normative ASL source:** `asl/scalar/agu/SB.asl`

SB snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-SB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sb-purpose role=purpose -->
## `SB` 做什么

`SB` 把 `SrcD` 的低 `8` 位写入由 `SrcL` 基址加经过转换的 `SrcR` 寄存器偏移量形成的地址。其规范汇编是 `sb SrcD, [SrcL, SrcR<{.sw,.uw}>]`。

设计要点：寄存器偏移存储形式没有移位字段，因此 `SB` 使用固定缩放 `1`，原样相加偏移量。以字节为单位的索引寄存器无需任何准备，而 `SW` 与 `SD` 期望索引按其各自的元素大小计数。

<!-- PTO-READER-BLOCK: scalar-sb-mechanism role=mechanism -->
## `SB` 如何形成地址并完成存储

`SrcL` 提供基址。`SrcR` 由 `SrcRType` 转换——`0` 保留完整的 `64` 位值，`1` 符号扩展低 `32` 位，`2` 零扩展低 `32` 位——缩放 `1` 使它不被移位。基址与偏移量按 `2^PTO_XLEN` 取模相加。

写入该地址的字节是 `SrcD` 的低字节，在存储之前读取。本形式没有目的端字段，因此不写任何寄存器或队列槽位，也不更新基址。

设计要点：由于偏移量不做缩放，有效地址的对齐同时取决于偏移寄存器的低位与基址的低位。奇数 `SrcR` 给出奇数地址，`1` 字节访问接受它；同样的值在 `SH` 中会先被加倍。

<!-- PTO-READER-BLOCK: scalar-sb-inputs role=inputs-outputs -->
## 编码字段与值的去向

- `SrcD`、`SrcL` 与 `SrcR` 是 `5` 位 Reg5 源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `SrcRType` 的 `0`、`1`、`2` 均已分配；原始值 `3` 为保留值。本形式没有 `shamt` 字段，因此偏移量的缩放固定为 `1`。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：`SrcD` 的可用性校验与地址源完全相同，因此 `sb 24, [2, 3]` 需要一个有效的 `T#1` 条目，而从未被压入的条目会让整条指令非法。

<!-- PTO-READER-BLOCK: scalar-sb-effects role=effects -->
## 影响、顺序与完成

三个源都在内存效果之前被读取，因此写入的字节是 `SrcD` 在执行前的值。

成功执行会完成一次 relaxed `1` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废，因此落在该粒度区内的任何存储都会清除它；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：数据读取与内存效果是本形式仅有的架构事件，因此写入的字节正是尝试开始时 `SrcD` 所持有的低字节；后续指令覆盖 `SrcD` 无法改变已存储的内容。

<!-- PTO-READER-BLOCK: scalar-sb-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配、`SrcRType` 取保留值 `3`，或所选 `T`/`U` 源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

`1` 字节访问天然对齐，因此对本形式而言 `Fault_DataAlignment` 不可达。预检仍会执行对齐测试，随后执行权限与有界内存测试，后者失败会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：`SrcRType=3` 在编码检查阶段就被拒绝，而不会被映射成其他转换，因此 `SB` 的任何编码都不会悄悄算出三种已分配修饰符不会产生的地址。

<!-- PTO-READER-BLOCK: scalar-sb-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sb 6, [2, 3<.sw>]`，设 GPR2 = `0x1001`，GPR3 = `0xFFFFFFFF`，GPR6 = `0x00000000000000CD`。
- `SrcRType=1` 符号扩展低 `32` 位，因此偏移量是 `-1`，固定缩放 `1` 使它保持不变。
- 有效地址是 `0x1001` 减 `1`，即 `0x1000`。
- 字节 `0xCD` 被写入 `0x1000`，`TPC` 前移 `4` 字节，且没有寄存器变化。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sb SrcD, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sb_32_43c106ae3749 | L32 | 32 | 0x00000049 / 0x00007fff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sb_32_43c106ae3749 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sb_32_43c106ae3749 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sb_32_43c106ae3749 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sb_32_43c106ae3749 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sb_32_43c106ae3749 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sb_32_43c106ae3749 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sb_32_43c106ae3749 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sb_32_43c106ae3749 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `sb_32_43c106ae3749.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SB.asl -->
```asl
readonly func InstructionContractOperation_SB() => ScalarOperation
begin
    return ScalarOperation_SB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SB.asl -->
```asl
readonly func InstructionContractHandler_SB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SB()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SB()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_SB()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SB()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SB()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SB()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sb SrcD, [SrcL, SrcR<{.sw,.uw}>]
