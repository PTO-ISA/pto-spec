<!-- GENERATED FROM: asl/scalar/agu/C.LDI.asl -->
# C.LDI

**Normative ASL source:** `asl/scalar/agu/C.LDI.asl`

C.LDI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-C-LDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-ldi-purpose role=purpose -->
## `C.LDI` 做什么

`C.LDI` 是一条 `16` 位压缩加载指令：从内存读取一个小端序 `8` 字节值，并把它压入临时队列成为最新的值。基址来自 `SrcL` 选择子，字节位移是符号扩展后的 `simm5` 字段乘以 `8`，加载得到的 `64` 位模式不做任何扩展就发布。

压缩编码完全没有目的字段，因此加载值总是进入 `T` 队列，本形式的任何编码都无法丢弃它。

设计要点：发布是通过队列压入完成的，而不是写入某个具名寄存器。压入使新值成为 `T#1`，并把原来的 `T#1`、`T#2`、`T#3` 移到 `T#2`、`T#3`、`T#4`，原来的 `T#4` 被丢弃。因此一条 `C.LDI` 会改变四个 `T` 槽位，之后读取 `T#2` 得到的是本指令执行前 `T#1` 里的值。

<!-- PTO-READER-BLOCK: scalar-c-ldi-mechanism role=mechanism -->
## 地址与传输如何形成

地址路径先对 `SrcL` 取快照，对 `simm5` 做符号扩展，左移 `3` 位，再把两者按 `2^PTO_XLEN` 取模相加。

本形式不记录基址回写。算出的地址只用于本次访问，随后即被丢弃，所以无论走哪条路径，包括发生故障的路径，`SrcL` 都保持指令执行前的值。

编码检查与地址预检都通过后，处理程序执行一次对齐的小端序 `8` 字节加载，并保留完整的 `64` 位模式。只有当内存操作报告无故障时，才执行队列压入。

设计要点：缩放因子等于访问大小，因此每个编码位移都是 `8` 的倍数；有符号 `5` 位字段覆盖 `-128` 到 `120` 字节，步长为 `8`。`SrcL` 为 `8` 字节对齐时有效地址也 `8` 字节对齐，因此仅靠位移无法破坏对齐规则。

<!-- PTO-READER-BLOCK: scalar-c-ldi-inputs role=inputs-outputs -->
## 编码字段与结果去向

- `SrcL` 是 `5` 位 Reg5 选择子：编码 `0`..`23` 选择绝对 GPR，编码 `24`..`27` 选择 `T#1`..`T#4`，编码 `28`..`31` 选择 `U#1`..`U#4`。读取 `T` 或 `U` 选择子不会改变该队列。
- `simm5` 是有符号 `5` 位位移，按 `8` 缩放。它的 `32` 个编码全都是取值；该编码没有任何方式把此字段标记为省略。
- 目的位置是隐式 `T#1`。没有字段选择它，也没有字段能抑制它。

设计要点：`SrcL` 编码 `0` 选择架构零 GPR，它读出为零并忽略写入，因此 `c.ldi [0, simm], ->t` 仅靠位移寻址。`simm5` 编码 `0` 给出的是位移零而不是省略，因为 `16` 位形式没有存在位来区分这两者。

<!-- PTO-READER-BLOCK: scalar-c-ldi-effects role=effects -->
## 影响、顺序与完成

`SrcL` 的读取发生在任何内存或队列影响之前，因此即使某个源与将被压入的 `T` 槽位别名，它贡献的仍是指令执行前的值。

执行成功时进行一次 relaxed 加载并记录一个加载事件。内存字节以及任何保留状态都不改变。

压入完成后，`C.LDI` 把 `TPC` 前进 `2` 字节。被拒绝或发生故障的尝试不会退休，`TPC` 停留在同一条指令上。

设计要点：压入是处理程序的最后一步，因此加载发生故障时 `T` 队列保持原样；没有任何状态显示新值已在 `T#1` 而加载失败。

<!-- PTO-READER-BLOCK: scalar-c-ldi-constraints role=constraints -->
## 合法性、故障与重启

`16` 位编码中的固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`。`SrcL` 编码若选择一个有效性标志为清除的 `T` 或 `U` 槽位，会在同一点引发同样的故障，且不会尝试任何内存访问。

预检检查有效地址的低 `3` 位：只要不为零，就在地址翻译之前、任何权限检查之前引发 `Fault_DataAlignment`。地址对齐时，权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不写入任何队列槽位，`TPC` 停留在引发故障的指令上。恢复会重新执行整个操作：快照、地址、预检、加载与压入，不保留任何进度。

<!-- PTO-READER-BLOCK: scalar-c-ldi-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `c.ldi [5, -3], ->t`，设 GPR5 持有 `0x2000`。有符号 `simm5` 为 `-3`，乘以 `8` 得 `-24`，因此有效地址是 `0x2000` 减去 `24`，即 `0x1FE8`。
- 该指令读取 `0x1FE8` 到 `0x1FEF` 的 `8` 字节，并把整个 `64` 位模式发布为新的 `T#1`。
- GPR5 仍持有 `0x2000`，因为本形式没有基址回写；`TPC` 变为该指令地址加 `2`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.ldi [srcL, simm], ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_ldi_16_973f42d37f29 | C16 | 16 | 0x001a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_ldi_16_973f42d37f29 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_ldi_16_973f42d37f29 | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_ldi_16_973f42d37f29 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_ldi_16_973f42d37f29 | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.LDI.asl -->
```asl
readonly func InstructionContractOperation_C_LDI() => ScalarOperation
begin
    return ScalarOperation_C_LDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.LDI.asl -->
```asl
readonly func InstructionContractHandler_C_LDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_C_LDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_C_LDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_LDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_C_LDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_C_LDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_LDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_LDI()
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
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

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

- c.ldi [srcL, simm], ->t
