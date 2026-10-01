<!-- GENERATED FROM: asl/scalar/agu/LWU.asl -->
# LWU

**Normative ASL source:** `asl/scalar/agu/LWU.asl`

LWU snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LWU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lwu-purpose role=purpose -->
## `LWU` 做什么

`LWU` 从基址寄存器加经过转换并移位的寄存器偏移量处加载小端 `4` 字节字，再把加载到的 `32` 位零扩展到 `PTO_XLEN`。其规范汇编是 `lwu [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`。

设计要点：`LWU` 结尾的 `U` 描述的是加载值，而不是地址。偏移量按 `SrcRType` 转换、按 `shamt` 移位，与 `LW` 完全相同，只有扩展方式不同。在本族的其他位置，`.u` 标记表示另一类含义：诸如 `LWI.U` 这样的非缩放地址形式。

<!-- PTO-READER-BLOCK: scalar-lwu-mechanism role=mechanism -->
## `LWU` 如何形成地址并完成访问

`SrcL` 提供基址。`SrcR` 由 `SrcRType` 转换——`0` 保留完整的 `64` 位值，`1` 符号扩展低 `32` 位，`2` 零扩展低 `32` 位——随后按编码的 `shamt` 左移。基址与偏移量按 `2^PTO_XLEN` 取模相加。

该和被一次小端 `4` 字节加载使用。此形式没有基址回写，也没有第二个目的端。只有在加载报告无故障时，加载字的位 `31`:`0` 才被零扩展并通过 `RegDst` 写入。

设计要点：零扩展把发布值的位 `63`:`32` 强制置零，与加载到的四个字节无关，因此该值总是落在 `0`..`4294967295` 范围内；与 `LW` 相比，改变的只是目的端高 `32` 位的解释方式。

<!-- PTO-READER-BLOCK: scalar-lwu-inputs role=inputs-outputs -->
## 编码字段与值的去向

- `SrcL` 与 `SrcR` 是 `5` 位 Reg5 源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `SrcRType` 的 `0`、`1`、`2` 均已分配；原始值 `3` 为保留值。`shamt` 的全部 `32` 个值 `0`..`31` 均已分配，编码为零时不执行移位。
- `RegDst` 是 `5` 位目的端：编码 `1`..`23` 写绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 与 `24`..`29` 丢弃加载值。

设计要点：`shamt` 宽 `5` 位，因此它能表达的最大缩放是 `2^31`。更大的步长必须在加载之前通过加到基址或偏移寄存器上来构造。

<!-- PTO-READER-BLOCK: scalar-lwu-effects role=effects -->
## 影响、顺序与完成

两个源都在任何内存或目的端效果之前被读取，因此与目的端同名的偏移寄存器仍然提供其指令执行前的值。

成功执行会完成一次 relaxed `4` 字节加载并记录一个加载事件。内存字节不变，保留状态得以保持。随后 `TPC` 前移 `4` 字节。

设计要点：被丢弃的目的端并不是抑制。当 `RegDst` 编码为 `0` 或 `24`..`29` 时，预检、加载与加载事件都照常发生，只有发布步骤被跳过，因此本形式也可当作一次带检查的探测。

<!-- PTO-READER-BLOCK: scalar-lwu-constraints role=constraints -->
## 合法性、故障与重启

当固定编码比特不匹配、`SrcRType` 取保留值 `3`，或所选 `T`/`U` 源槽位因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

预检检查有效地址的低 `2` 位，非零值会在翻译之前、权限测试之前引发 `Fault_DataAlignment`。对齐但未通过权限或有界内存测试的地址会在原始地址引发 `Fault_DataPage`；PTO v0 的翻译是恒等函数，因此不存在单独的翻译故障。

故障不记录加载事件、不写目的端，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检、加载以及发布。

设计要点：`SrcRType=3` 在编码检查阶段就被拒绝，因此无法进入地址运算。该保留值表现为非法指令，而不是第四种转换方式。

<!-- PTO-READER-BLOCK: scalar-lwu-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `lwu [2, 3<.uw><<<2], ->4`，设 GPR2 = `0x1000`，GPR3 = `0xFFFFFFFE`。
- `SrcRType=2` 零扩展低 `32` 位，`shamt=2` 再把结果左移 `2` 位，得到 `0x00000003FFFFFFF8`。
- 地址是 `0x1000` 加 `0x00000003FFFFFFF8`，即 `0x0000000400000FF8`。它满足 `4` 字节对齐，但远在有界内存区域之外，因此该尝试在那个原始地址引发 `Fault_DataPage`：没有事件、没有目的端写入，`TPC` 原地不动。
- 改用 `<.sw>` 且 `shamt=2` 不变时，GPR3 符号扩展为 `-2`，偏移量变成 `-8`，访问读取 `0x0FF8` 处的 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lwu [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lwu_32_678935925636 | L32 | 32 | 0x00006009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lwu_32_678935925636 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lwu_32_678935925636 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lwu_32_678935925636 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lwu_32_678935925636 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lwu_32_678935925636 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lwu_32_678935925636 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lwu_32_678935925636 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lwu_32_678935925636 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| lwu_32_678935925636 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| lwu_32_678935925636 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `lwu_32_678935925636.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWU.asl -->
```asl
readonly func InstructionContractOperation_LWU() => ScalarOperation
begin
    return ScalarOperation_LWU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWU.asl -->
```asl
readonly func InstructionContractHandler_LWU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LWU()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LWU()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LWU()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LWU()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LWU()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LWU()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LWU()
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
- After a successful 4-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- lwu [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
