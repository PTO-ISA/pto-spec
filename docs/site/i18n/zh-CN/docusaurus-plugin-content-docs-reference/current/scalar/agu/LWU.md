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
## LWU 的作用

`LWU` 是一条独立的 `32` 位 AGU 指令；它形成寄存器偏移地址，并加载一个对齐的小端 `4` 字节值。

<!-- PTO-READER-BLOCK: scalar-lwu-mechanism role=mechanism -->
## 地址与内存机制

`LWU` 先按 `SrcRType` 转换 `SrcR`，再按编码的 `shamt` 左移，并将结果按 `2^PTO_XLEN` 取模后加到快照中的 `SrcL` 基址。

完成全部预检后，该指令执行一次小端 `4` 字节加载，并将加载的 `4` 字节值零扩展到 `PTO_XLEN`，供目的端发布。

此形式不回写基址寄存器；有效地址只供所选内存操作使用。

<!-- PTO-READER-BLOCK: scalar-lwu-inputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供基址；`SrcR` 提供寄存器偏移量；`SrcRType` 提供偏移量转换方式。其中的 Reg5 源 `SrcL`、`SrcR` 使用完整编码域：`0..23` 选择 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且读取不会消费队列项。
- `RegDst` 接收加载结果；目的端编码 `1..23` 写 GPR，`30` 压入 U，`31` 压入 T，`0` 与 `24..29` 只丢弃该结果。
- `SrcRType` 的 `0..3` 和 `shamt` 的 `0..31` 均已分配；先执行转换，再执行编码移位。

<!-- PTO-READER-BLOCK: scalar-lwu-effects role=effects -->
## 效果与顺序

所有显式和隐式标量源都在内存或目的端效果之前完成快照，因此别名观察到的是指令执行前的值。

成功执行会记录一个 relaxed 加载事件，保持内存和保留状态，发布或丢弃加载值，并将 `TPC` 前移 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-lwu-constraints role=constraints -->
## 对齐、故障与重启

每个有效地址都必须满足 `4` 字节对齐。未对齐会在地址转换前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不会记录成功的内存事件，也不会产生部分内存、目的端或回写效果；待处理回写保持不变，故障 `TPC` 保留以供完整重发。

固定比特不匹配、字段取保留值或所选 `T`/`U` 源不可用，都会在指令效果之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-lwu-example role=example -->
## 非规范地址示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

若基址为 `0x100`、偏移源为不经转换的 `2`，并采用`shamt=1`，偏移量就是 `4`，基址加偏移量为 `0x104`。内存访问使用 `0x104`。若地址对齐且权限允许，指令从该地址加载 `4` 字节。
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
