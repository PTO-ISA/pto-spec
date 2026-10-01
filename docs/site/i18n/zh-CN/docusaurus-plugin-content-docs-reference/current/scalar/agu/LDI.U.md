<!-- GENERATED FROM: asl/scalar/agu/LDI.U.asl -->
# LDI.U

**Normative ASL source:** `asl/scalar/agu/LDI.U.asl`

LDI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-LDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ldi-u-purpose role=purpose -->
## `LDI.U` 的作用

`LDI.U` 在距基址寄存器的、不带比例的带符号立即数位移处加载一个 `8` 字节小端单元。立即数以字节计数，因此该字段可以落在任意字节偏移上。

规范汇编是 `ldi.u [SrcL, simm], ->{t, u, Rd}`。

设计要点：`.u` 形式保留 `8` 字节传输但去掉 `8` 字节比例，因此 `simm12` 覆盖 `-2048`..`2047` 字节，并且可以是任意模 `8` 的余数。

<!-- PTO-READER-BLOCK: scalar-ldi-u-mechanism role=mechanism -->
## 地址与传输如何形成

符号扩展后的 `simm12` 不加比例地与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。每个编码单位对应 `1` 字节地址。

预检先检查 `8` 字节对齐，再转换，然后检查权限与有界内存。成功后小端读取 `8` 字节，记录一个 relaxed 加载事件，并原样发布这 `64` 位。

参与地址计算的只有立即数与基址；本形式没有索引寄存器，也没有更新基址的目的端。

设计要点：不带比例的立即数可以是任意模 `8` 的余数，因此本形式可以让本来不对齐的基址变得对齐；但和（而不是仅基址）仍必须是 `8` 的倍数。

<!-- PTO-READER-BLOCK: scalar-ldi-u-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm12` 为带符号数，覆盖 `-2048`..`2047`，且不加比例使用，因此每个单位是一字节。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：按字节细分的窗口比缩放后的 `8` 字节窗口短得多，因此两种形式回答不同的问题：一种用覆盖范围换取更细的步长。

<!-- PTO-READER-BLOCK: scalar-ldi-u-effects role=effects -->
## 效果、顺序与完成

所有源都在内存操作与发布之前取快照，因此读到的值从不依赖本指令执行的写入。

成功时记录一个 relaxed 加载事件，内存与保留状态保持不变，并使 `TPC` 前进 `4` 字节。

设计要点：完整的 `64` 位模式到达 `RegDst`，因此本形式是按字节寻址地取出全宽数值的方式。

<!-- PTO-READER-BLOCK: scalar-ldi-u-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或 `SrcL` 选择子指向不可用的 `T`/`U` 条目，会在任何效果之前引发 `Fault_IllegalInstruction`。
- 不是 `8` 的倍数的和会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布结果，并让 `TPC` 停留在引发故障的指令上，使尝试可以重发。
- 设计要点：`.u` 后缀只改变比例；传输宽度以及由此决定的对齐规则仍然是 `8` 字节。

<!-- PTO-READER-BLOCK: scalar-ldi-u-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x2004`、`simm12` = `4` 时，地址是 `0x2008`，它是 `8` 字节对齐的；不带比例的立即数修正了不对齐的基址。
- 当 `SrcL` = `0x2004`、`simm12` = `1` 时，地址是 `0x2005`，并引发 `Fault_DataAlignment`。
- 与 `LDI` 一样，成功情形把 `8` 字节作为一个 `64` 位值发布，不做扩展。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ldi.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ldi_u_32_111bb521a439 | L32 | 32 | 0x00003029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ldi_u_32_111bb521a439 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ldi_u_32_111bb521a439 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ldi_u_32_111bb521a439 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ldi_u_32_111bb521a439 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| ldi_u_32_111bb521a439 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| ldi_u_32_111bb521a439 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LDI.U.asl -->
```asl
readonly func InstructionContractOperation_LDI_U() => ScalarOperation
begin
    return ScalarOperation_LDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LDI.U.asl -->
```asl
readonly func InstructionContractHandler_LDI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LDI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LDI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LDI_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_LDI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LDI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LDI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LDI_U()
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
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- ldi.u [SrcL, simm], ->{t, u, Rd}
