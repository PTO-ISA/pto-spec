<!-- GENERATED FROM: asl/scalar/agu/SDI.U.asl -->
# SDI.U

**Normative ASL source:** `asl/scalar/agu/SDI.U.asl`

SDI.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-SDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sdi-u-purpose role=purpose -->
## `SDI.U` 做什么

`SDI.U` 把 `SrcL` 的低 `8` 字节写入由 `SrcR` 基址加一个有符号立即数形成的地址。其规范汇编是 `sdi.u SrcL, [SrcR, simm]`。

设计要点：基址是 `SrcR`，存储数据是 `SrcL`，与加载形式的字段用法相反；`.u` 标记再去掉 `SDI` 对同一立即数字段施加的 `8` 字节缩放。

<!-- PTO-READER-BLOCK: scalar-sdi-u-mechanism role=mechanism -->
## `SDI.U` 如何形成地址并完成存储

`simm12` 从 `12` 位符号扩展到 `PTO_XLEN`，得到 `-2048`..`2047` 字节的位移，并与 `SrcR` 按 `2^PTO_XLEN` 取模相加。中间值不做任何缩放。

写入该地址的值是 `SrcL` 的低 `8` 字节，最低有效字节位于最低地址。本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：非缩放的 `8` 字节存储只有在基址加位移是 `8` 的倍数时才能成功，因此 `8` 字节对齐的基址每 `8` 个位移中只接受一个。程序必须自己保证字节计数是对齐的。

<!-- PTO-READER-BLOCK: scalar-sdi-u-inputs role=inputs-outputs -->
## 编码字段与存储消费的内容

- `SrcL` 提供存储数据，`SrcR` 提供基址。两者都是 `5` 位 Reg5 源：编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm12` 是有符号 `12` 位字段，因此全部 `4096` 个编码都是取值，编码为零提供零位移，并不表示省略。可编码的字节位移是 `-2048` 到 `2047` 字节。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：`12` 位字段在相加之前先做符号扩展，因此可编码的字节位移是 `-2048` 到 `2047`，而不是 `0` 到 `4095`。

<!-- PTO-READER-BLOCK: scalar-sdi-u-effects role=effects -->
## 影响、顺序与完成

`SrcL` 与 `SrcR` 在内存效果之前被读取，因此写入的字节是 `SrcL` 在执行前的值。

成功执行会完成一次 relaxed `8` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：该指令只改变内存，可能还有保留状态，别的都不变。`SrcL` 与 `SrcR` 都不被写入，因此它不会扰动程序保存在基址中的指针。

<!-- PTO-READER-BLOCK: scalar-sdi-u-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配，或所选 `T`/`U` 源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

因为访问宽 `8` 字节，预检检查有效地址的低 `3` 位。未对齐的值会在翻译之前引发 `Fault_DataAlignment`；对齐但未通过权限或有界内存测试的地址会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：由于位移不缩放，只要基址低三位不为零，`Fault_DataAlignment` 就可达。缩放形式 `SDI` 从构造上消除了该风险，因此两种形式之间的选择就是由谁保证对齐的选择。

<!-- PTO-READER-BLOCK: scalar-sdi-u-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `sdi.u 6, [3, 4]`，设 GPR3 = `0x2000`，GPR6 = `0x0123456789ABCDEF`。
- 位移是 `4` 字节，因此有效地址是 `0x2004`。
- `0x2004` 是 `4` 的倍数但不是 `8` 的倍数，因此预检引发 `Fault_DataAlignment`，即使基址本身满足 `8` 字节对齐，也没有字节被写入。
- 改用 `sdi` 时，同一字段会乘以 `8`，地址变为 `0x2020`，那 `8` 字节会被存储在那里。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sdi.u SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sdi_u_32_cba5a4a04e7b | L32 | 32 | 0x00007059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sdi_u_32_cba5a4a04e7b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sdi_u_32_cba5a4a04e7b | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sdi_u_32_cba5a4a04e7b | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sdi_u_32_cba5a4a04e7b | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sdi_u_32_cba5a4a04e7b | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sdi_u_32_cba5a4a04e7b | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SDI.U.asl -->
```asl
readonly func InstructionContractOperation_SDI_U() => ScalarOperation
begin
    return ScalarOperation_SDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SDI.U.asl -->
```asl
readonly func InstructionContractHandler_SDI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SDI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SDI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SDI_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_SDI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SDI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SDI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SDI_U()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- sdi.u SrcL, [SrcR, simm]
