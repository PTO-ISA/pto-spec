<!-- GENERATED FROM: asl/scalar/agu/LW.asl -->
# LW

**Normative ASL source:** `asl/scalar/agu/LW.asl`

LW snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lw-purpose role=purpose -->
## `LW` 做什么

`LW` 从基址寄存器加经过转换并移位的寄存器偏移量处加载一个小端 `4` 字节字，再把加载到的 `32` 位符号扩展到 `PTO_XLEN`，之后才到达 `RegDst`。其规范汇编是 `lw [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`。

设计要点：`LW` 与 `LWU` 共用同一套寻址操作，只是扩展规则不同。字节 `FF FF FF FF` 经 `LW` 发布为 `0xFFFFFFFFFFFFFFFF`，经 `LWU` 发布为 `0x00000000FFFFFFFF`，因此助记符决定了目的端位 `63`:`32` 的内容。

<!-- PTO-READER-BLOCK: scalar-lw-mechanism role=mechanism -->
## `LW` 如何形成地址并完成访问

`SrcL` 作为基址被读取。`SrcR` 由 `SrcRType` 转换——`0` 保留完整的 `64` 位值，`1` 符号扩展低 `32` 位，`2` 零扩展低 `32` 位——随后按编码的 `shamt` 左移。基址与偏移量按 `2^PTO_XLEN` 取模相加。

该和被一次小端 `4` 字节加载使用；此形式没有基址回写，也没有第二个目的端。只有在加载报告无故障时，结果才被符号扩展并通过 `RegDst` 写入。

设计要点：转换先于移位，因此负的字索引在缩放中保持符号。`SrcRType=1` 且 `SrcR` = `0xFFFFFFFE`、`shamt=3` 时得到偏移量 `-16`。若颠倒这两个步骤，就会改为对零扩展后的值缩放。

<!-- PTO-READER-BLOCK: scalar-lw-inputs role=inputs-outputs -->
## 编码字段与值的去向

- `SrcL` 与 `SrcR` 是 `5` 位 Reg5 源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `SrcRType` 的 `0`、`1`、`2` 均已分配；原始值 `3` 为保留值。`shamt` 的全部 `32` 个值 `0`..`31` 均已分配，编码为零时不缩放转换后的偏移量。
- `RegDst` 是 `5` 位目的端：编码 `1`..`23` 写绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 与 `24`..`29` 丢弃加载值。

设计要点：`shamt` 占用的正是 `SB`、`SW`、`SD` 用作 `SrcD` 存储数据字段的那 `5` 位。`LW` 可以把索引按 `1` 到 `2^31` 之间的任意 2 的幂缩放；寄存器偏移存储形式只能用其助记符固定的缩放。

<!-- PTO-READER-BLOCK: scalar-lw-effects role=effects -->
## 影响、顺序与完成

两个源都在任何内存或目的端效果之前被读取，因此与基址同名的目的端仍使用指令执行前的值：`lw [1, 2<<<1], ->1` 用旧的 `1` 作为基址。

成功执行会完成一次 relaxed `4` 字节加载并记录一个加载事件。内存字节不变，保留状态得以保持。随后 `TPC` 前移 `4` 字节，即本编码的长度。

设计要点：编码 `30` 与 `31` 通过与 GPR 目的端相同的受门控写入来压入队列项。因此发生故障的 `LW` 什么也不压入，队列内容与有效性标志保持原样。

<!-- PTO-READER-BLOCK: scalar-lw-constraints role=constraints -->
## 合法性、故障与重启

当固定编码比特不匹配、`SrcRType` 取保留值 `3`，或所选 `T`/`U` 源槽位因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

预检检查有效地址的低 `2` 位，非零值会在翻译之前、权限测试之前引发 `Fault_DataAlignment`。对齐但未通过权限或有界内存测试的地址会在原始地址引发 `Fault_DataPage`；PTO v0 的翻译是恒等函数，因此不存在单独的翻译故障。

故障不记录加载事件、不写目的端，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检、加载以及发布。

设计要点：对齐测试先于权限测试，因此既未对齐又超出区域的地址会报告 `Fault_DataAlignment`；只有对齐的地址才会得到 `Fault_DataPage`。

<!-- PTO-READER-BLOCK: scalar-lw-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `lw [2, 3<.sw><<<3], ->4`，设 GPR2 = `0x2000`，GPR3 = `0xFFFFFFFE`。
- `SrcRType=1` 符号扩展低 `32` 位，因此偏移源提供 `0xFFFFFFFFFFFFFFFE`，即 `-2`。
- `shamt=3` 把它左移 `3` 位，得 `-16`；有效地址是 `0x2000` 减 `16`，即 `0x1FF0`。
- `0x1FF0` 满足 `4` 字节对齐，预检通过。该指令读取 `0x1FF0` 到 `0x1FF3` 的 `4` 字节，符号扩展后写入 GPR4，并使 `TPC` 前移 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lw [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lw_32_3a77ffafcb34 | L32 | 32 | 0x00002009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lw_32_3a77ffafcb34 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lw_32_3a77ffafcb34 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lw_32_3a77ffafcb34 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lw_32_3a77ffafcb34 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lw_32_3a77ffafcb34 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lw_32_3a77ffafcb34 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lw_32_3a77ffafcb34 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lw_32_3a77ffafcb34 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| lw_32_3a77ffafcb34 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| lw_32_3a77ffafcb34 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `lw_32_3a77ffafcb34.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LW.asl -->
```asl
readonly func InstructionContractOperation_LW() => ScalarOperation
begin
    return ScalarOperation_LW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LW.asl -->
```asl
readonly func InstructionContractHandler_LW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LW()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LW()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LW()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LW()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LW()
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
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 4-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lw [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
