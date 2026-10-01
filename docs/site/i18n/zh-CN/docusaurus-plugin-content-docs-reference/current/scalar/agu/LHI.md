<!-- GENERATED FROM: asl/scalar/agu/LHI.asl -->
# LHI

**Normative ASL source:** `asl/scalar/agu/LHI.asl`

LHI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LHI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lhi-purpose role=purpose -->
## `LHI` 的作用

`LHI` 在距基址寄存器的立即数位移处加载一个有符号 `2` 字节半字。立即数按 `2` 缩放，因此每个编码单位命名一个半字槽位。

规范汇编是 `lhi [SrcL, simm], ->{t, u, Rd}`。

设计要点：比例由指令固定，因此 `simm12` 覆盖 `-4096`..`4094` 字节。本指令的 `.u` 形式去掉该比例，改为覆盖 `-2048`..`2047` 字节。

<!-- PTO-READER-BLOCK: scalar-lhi-mechanism role=mechanism -->
## 地址与传输如何形成

`LHI` 把 `simm12` 符号扩展后左移 `1` 位，即地址类型所记录的乘以 `2`，再与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。

预检依次检查 `2` 字节对齐、转换、权限与有界内存。成功后小端读取 `2` 字节并记录一个 relaxed 加载事件。

该半字被符号扩展到 `PTO_XLEN` 并通过 `RegDst` 发布；基址寄存器不回写。

设计要点：按 `2` 缩放使字节位移的最低位恒为 `0`，因此有效地址为偶数当且仅当基址为偶数。`LHI` 无法让奇数基址对齐，会把该和报告为 `Fault_DataAlignment`。

<!-- PTO-READER-BLOCK: scalar-lhi-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm12` 为带符号数，覆盖 `-2048`..`2047` 个单位，并按 `2` 缩放，因此 `0x800` 译码为 `-2048` 个单位，即 `-4096` 字节。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：字节窗口可到达基址下方 `4096` 字节与上方 `4094` 字节，且每个位移都是偶数个字节，因此可以用一个基址寄存器、无需索引寄存器来遍历半字数组。

<!-- PTO-READER-BLOCK: scalar-lhi-effects role=effects -->
## 效果、顺序与完成

基址在内存操作之前取快照，因此本指令写入的任何内容都不会影响它读取的地址。

成功时记录一个 relaxed 加载事件，内存与保留保持不变，发布符号扩展后的半字，并使 `TPC` 前进 `4` 字节。

设计要点：本加载为带符号，因此经 `LHI` 读到的半字 `0xFFFF` 会发布为 `0xFFFFFFFFFFFFFFFF`，而不是 `65535`。

<!-- PTO-READER-BLOCK: scalar-lhi-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或 `SrcL` 选择子指向不可用的 `T`/`U` 队列条目，会在读取基址之前引发 `Fault_IllegalInstruction`。
- 奇数之和会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布目的端值，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：`2` 字节的倍数这种立即数永远无法修正基址的最低位，因此对齐的基址是本形式无法替代的前提。

<!-- PTO-READER-BLOCK: scalar-lhi-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x1000`、`simm12` = `3` 时，字节位移是 `6`，地址是 `0x1006`。
- 该处的字节 `FF FF` 是半字 `0xFFFF`，发布为 `0xFFFFFFFFFFFFFFFF`。
- 同一指令在 `SrcL` = `0x1001` 时得到 `0x1007`，即奇数地址，因此引发 `Fault_DataAlignment` 且不写目的端。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lhi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhi_32_46a45ec7074d | L32 | 32 | 0x00001019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhi_32_46a45ec7074d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhi_32_46a45ec7074d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lhi_32_46a45ec7074d | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lhi_32_46a45ec7074d | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lhi_32_46a45ec7074d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lhi_32_46a45ec7074d | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHI.asl -->
```asl
readonly func InstructionContractOperation_LHI() => ScalarOperation
begin
    return ScalarOperation_LHI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHI.asl -->
```asl
readonly func InstructionContractHandler_LHI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LHI()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHI()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_LHI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 2-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lhi [SrcL, simm], ->{t, u, Rd}
