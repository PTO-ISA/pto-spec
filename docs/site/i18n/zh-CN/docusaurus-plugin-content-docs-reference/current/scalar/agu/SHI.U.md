<!-- GENERATED FROM: asl/scalar/agu/SHI.U.asl -->
# SHI.U

**Normative ASL source:** `asl/scalar/agu/SHI.U.asl`

SHI.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-SHI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-shi-u-purpose role=purpose -->
## `SHI.U` 做什么

`SHI.U` 把 `SrcL` 的低 `2` 字节写入由 `SrcR` 基址加一个有符号立即数形成的地址。其规范汇编是 `shi.u SrcL, [SrcR, simm]`。

设计要点：`SrcR` 是基址，`SrcL` 提供被存储的半字，`.u` 标记使立即数不缩放。因此 `12` 位字段以字节计数，可以直接指向奇数地址。

<!-- PTO-READER-BLOCK: scalar-shi-u-mechanism role=mechanism -->
## `SHI.U` 如何形成地址并完成存储

`simm12` 从 `12` 位符号扩展到 `PTO_XLEN`，得到 `-2048`..`2047` 字节的位移，并与 `SrcR` 按 `2^PTO_XLEN` 取模相加。中间值不做任何缩放。

写入该地址的值是 `SrcL` 的低 `2` 字节，最低有效字节位于最低地址。本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：位移范围是 `-2048` 到 `2047` 字节，小于缩放形式 `SHI` 的 `-4096` 到 `4094`。对同一个编码字段，两种形式用可达范围换取字节粒度。

<!-- PTO-READER-BLOCK: scalar-shi-u-inputs role=inputs-outputs -->
## 编码字段与存储消费的内容

- `SrcL` 提供存储数据，`SrcR` 提供基址。两者都是 `5` 位 Reg5 源：编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm12` 是有符号 `12` 位字段，因此全部 `4096` 个编码都是取值，编码为零提供零位移，并不表示省略。可编码的字节位移是 `-2048` 到 `2047` 字节。
- 本形式没有目的端字段：编码中没有任何部分选择要写入的寄存器或队列槽位，因此存储永不发布结果，也不更新基址。

设计要点：只有 `SrcL` 的低 `16` 位进入内存。对每个 `SrcL` 编码存储都有定义，包括编码 `0`，它存储一个零半字。

<!-- PTO-READER-BLOCK: scalar-shi-u-effects role=effects -->
## 影响、顺序与完成

`SrcL` 与 `SrcR` 在内存效果之前被读取，因此写入的字节是 `SrcL` 在执行前的值。

成功执行会完成一次 relaxed `2` 字节存储并记录一个存储事件。若存储的字节范围与包含有效保留的 `64` 字节保留粒度区重叠，该保留即被作废；粒度区之外的存储则保持其有效。 随后 `TPC` 前移 `4` 字节。

设计要点：基址寄存器只被读取用于地址计算，从不回写，因此存储循环必须用另一条指令推进其指针。编码中没有任何部分能表达更新。

<!-- PTO-READER-BLOCK: scalar-shi-u-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配，或所选 `T`/`U` 源因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

因为访问宽 `2` 字节，预检检查有效地址的最低位。未对齐的值会在翻译之前引发 `Fault_DataAlignment`；偶数地址若未通过权限或有界内存测试，会在原始地址引发 `Fault_DataPage`。

故障不写任何内存字节、不记录存储事件，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检以及存储。

设计要点：对 `2` 字节存储而言，奇偶性就是全部对齐规则，因此只要字节位移也是奇数，奇数基址在这里是可以接受的。这种自由在 `SHI` 中不复存在，其偶数位移会使奇数基址永远无法对齐。

<!-- PTO-READER-BLOCK: scalar-shi-u-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `shi.u 5, [3, 1]`，设 GPR3 = `0x2000`，GPR5 = `0x0000000000001234`。
- 位移是 `1` 字节，因此有效地址是 `0x2001`。
- `0x2001` 是奇数，因此预检引发 `Fault_DataAlignment`：没有字节被写入、没有事件被记录，`TPC` 停在指令上。
- 若 `simm12=2`，地址会是 `0x2002`；`2` 字节 `34 12` 被写入该处，`TPC` 前移 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
shi.u SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| shi_u_32_caaf3ed72a8f | L32 | 32 | 0x00005059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| shi_u_32_caaf3ed72a8f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| shi_u_32_caaf3ed72a8f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| shi_u_32_caaf3ed72a8f | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| shi_u_32_caaf3ed72a8f | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| shi_u_32_caaf3ed72a8f | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| shi_u_32_caaf3ed72a8f | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SHI.U.asl -->
```asl
readonly func InstructionContractOperation_SHI_U() => ScalarOperation
begin
    return ScalarOperation_SHI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SHI.U.asl -->
```asl
readonly func InstructionContractHandler_SHI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SHI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SHI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SHI_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_SHI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SHI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SHI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SHI_U()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- shi.u SrcL, [SrcR, simm]
