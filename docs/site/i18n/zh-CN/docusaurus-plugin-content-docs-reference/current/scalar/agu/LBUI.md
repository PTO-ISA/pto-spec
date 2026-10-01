<!-- GENERATED FROM: asl/scalar/agu/LBUI.asl -->
# LBUI

**Normative ASL source:** `asl/scalar/agu/LBUI.asl`

LBUI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LBUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lbui-purpose role=purpose -->
## `LBUI` 的作用

`LBUI` 在距基址寄存器的带符号立即数位移处加载一个 `1` 字节单元并做零扩展。它是 `LBU` 的立即数对应形式，窗口与 `LBI` 一样以字节为粒度。

规范汇编是 `lbui [SrcL, simm], ->{t, u, Rd}`。

设计要点：立即数不按访问宽度缩放，因此 `simm12` 可以到达 `-2048`..`2047` 中的任意字节，结果是原始的 `0`..`255` 字节而不是带符号数。

<!-- PTO-READER-BLOCK: scalar-lbui-mechanism role=mechanism -->
## 地址与传输如何形成

位移是符号扩展后的 `simm12`，与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。基址在任何内存效果之前读取，因此之后对同一寄存器的写入无法改变这个地址。

地址经过预检，成功后读取一个小端字节并记录一个 relaxed 加载事件。该字节被零扩展并通过 `RegDst` 发布。

本形式没有更新基址的目的端：该和只作为这次加载的地址使用。

设计要点：权限检查把 `address + 1` 与允许边界比较，因此最后一个允许字节可以访问，而它之后的第一个字节不能。

<!-- PTO-READER-BLOCK: scalar-lbui-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm12` 为带符号数，覆盖 `-2048`..`2047`。除 `SrcL` 之外它是唯一的寻址操作数；本编码没有 `SrcRType`，也没有 `shamt`。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：由于基址可以是任何 Reg5 源，`LBUI` 可以通过同一指令流中先前产生的队列条目读取，无需经过 GPR 中转。

<!-- PTO-READER-BLOCK: scalar-lbui-effects role=effects -->
## 效果、顺序与完成

所有源都在内存操作之前取快照，因此发布的字节不依赖本指令写入的任何内容。

成功时记录一个 relaxed 加载事件，内存与保留状态保持不变，发布零扩展后的字节，并使 `TPC` 前进 `4` 字节。

设计要点：`RegDst` 从不携带符号信息，因此以 `0xFF` 存储、再经 `LBUI` 读回的字节是数值 `255`。

<!-- PTO-READER-BLOCK: scalar-lbui-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或 `SrcL` 选择子指向不可用的 `T`/`U` 队列条目，会在读取任何源值之前引发 `Fault_IllegalInstruction`。
- `1` 字节对齐阶段先于转换与权限；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布值，并让 `TPC` 停留在引发故障的指令上，使整个尝试可以完整重发。
- 设计要点：任何 `LBUI` 编码都无法触及对齐失败，因为 `1` 字节访问只要求地址是 `1` 的倍数。

<!-- PTO-READER-BLOCK: scalar-lbui-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 GPR `6` = `0x1000`、`simm12` = `-1` 时，地址是 `0xFFF`。
- 该处的字节 `0xFF` 发布为 `0xFF`，而同一地址经 `LBI` 会发布 `0xFFFFFFFFFFFFFFFF`。
- 由于和按模 `2^PTO_XLEN` 回绕，负位移不会使 `64` 位地址空间下溢。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lbui [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lbui_32_c39b9aa11f02 | L32 | 32 | 0x00004019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lbui_32_c39b9aa11f02 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lbui_32_c39b9aa11f02 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lbui_32_c39b9aa11f02 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lbui_32_c39b9aa11f02 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lbui_32_c39b9aa11f02 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lbui_32_c39b9aa11f02 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LBUI.asl -->
```asl
readonly func InstructionContractOperation_LBUI() => ScalarOperation
begin
    return ScalarOperation_LBUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LBUI.asl -->
```asl
readonly func InstructionContractHandler_LBUI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LBUI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LBUI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LBUI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LBUI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LBUI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LBUI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LBUI()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lbui [SrcL, simm], ->{t, u, Rd}
