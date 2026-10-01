<!-- GENERATED FROM: asl/scalar/agu/SDI.asl -->
# SDI

**Normative ASL source:** `asl/scalar/agu/SDI.asl`

SDI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-SDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sdi-purpose role=purpose -->
## `SDI` 做什么

`SDI` 把 `SrcL` 的低 `8` 字节写入由 `SrcR` 基址加一个有符号立即数形成的地址。其规范汇编是 `sdi SrcL, [SrcR, simm]`。

设计要点：立即数以 `8` 字节元素计数，因此可编码的字节位移是 `-16384` 到 `16376`，全部是 `8` 的倍数。只有基址的低三位可能破坏对齐。

<!-- PTO-READER-BLOCK: scalar-sdi-mechanism role=mechanism -->
## `SDI` 如何形成地址并完成存储

`simm12` 从 `12` 位符号扩展到 `PTO_XLEN`，再左移 `3` 位，即乘以 `8`。缩放后的位移与 `SrcR` 按 `2^PTO_XLEN` 取模相加。

写入该地址的值是 `SrcL` 的低 `8` 字节，最低有效字节位于最低地址。本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：缩放发生在符号扩展之后，因此范围的负端保持为负：编码 `-1` 产生的位移是 `-8`，而不是 `131064`。

<!-- PTO-READER-BLOCK: scalar-sdi-inputs role=inputs-outputs -->
## 编码字段与存储消费的内容

- `SrcL` 提供存储数据，`SrcR` 提供基址。两者都是 `5` 位 Reg5 源：编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm12` 是有符号 `12` 位字段，因此全部 `4096` 个编码都是取值，编码为零提供零位移，并不表示省略。可编码的字节位移是 `-16384` 到 `16376` 字节。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：基址字段是 `SrcR`，数据字段是 `SrcL`。若程序误用加载形式的惯例，就会把错误寄存器的值存到由错误寄存器算出的地址上，而编码不会给出任何警告。

<!-- PTO-READER-BLOCK: scalar-sdi-effects role=effects -->
## 影响、顺序与完成

`SrcL` 与 `SrcR` 在内存效果之前被读取，因此写入的字节是 `SrcL` 在执行前的值。

成功执行会完成一次 relaxed `8` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：存储写入完整的 `64` 位 `SrcL` 值，不做扩展或截断，因此值的低字节落在最低地址，高字节落在最高地址。

<!-- PTO-READER-BLOCK: scalar-sdi-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配，或所选 `T`/`U` 源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

预检检查有效地址的低 `3` 位。由于缩放后的位移总是 `8` 的倍数，该测试等价于检查 `SrcR` 的低三位；失败会在翻译之前引发 `Fault_DataAlignment`，而对齐但未通过权限或有界内存测试的地址会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：在 `8` 字节对齐的基址下，任何合法立即数都不会产生未对齐地址，因此本形式对这样的基址没有对齐失败可报告。无法保证基址对齐的软件必须使用 `SDI.U`，并接受对齐由自己负责。

<!-- PTO-READER-BLOCK: scalar-sdi-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sdi 6, [3, -1]`，设 GPR3 = `0x2008`，GPR6 = `0x0123456789ABCDEF`。
- `simm12=-1` 符号扩展为 `-1`，缩放 `8` 使其左移 `3` 位，得到位移 `-8`。
- 有效地址是 `0x2008` 减 `8`，即 `0x2000`；它是 `8` 的倍数，因此预检通过。
- `8` 字节 `EF CD AB 89 67 45 23 01` 被写入 `0x2000`，`TPC` 前移 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sdi SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sdi_32_fab563230a66 | L32 | 32 | 0x00003059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sdi_32_fab563230a66 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sdi_32_fab563230a66 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sdi_32_fab563230a66 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sdi_32_fab563230a66 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sdi_32_fab563230a66 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sdi_32_fab563230a66 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SDI.asl -->
```asl
readonly func InstructionContractOperation_SDI() => ScalarOperation
begin
    return ScalarOperation_SDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SDI.asl -->
```asl
readonly func InstructionContractHandler_SDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_SDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_SDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SDI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- sdi SrcL, [SrcR, simm]
