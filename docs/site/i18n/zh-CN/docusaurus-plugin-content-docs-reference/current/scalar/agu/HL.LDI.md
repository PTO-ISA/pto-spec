<!-- GENERATED FROM: asl/scalar/agu/HL.LDI.asl -->
# HL.LDI

**Normative ASL source:** `asl/scalar/agu/HL.LDI.asl`

HL.LDI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldi-purpose role=purpose -->
## HL.LDI 的作用

`HL.LDI` 是一条独立编码的 48 位加载指令。它形成带缩放的有符号立即数地址，并把一个对齐的小端 8 字节值传送到 Reg5 目的位置。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-mechanism role=mechanism -->
## 地址与加载机制

指令先对 `simm22` 符号扩展并乘以 `8`，再把缩放后的位移与已经快照的 `SrcL` 基址按 `2^PTO_XLEN` 取模相加。

完整访问预检成功后，`HL.LDI` 执行一次小端 8 字节加载，并保留完整的 64 位加载位模式用于目的发布。

该形式不更新基址寄存器，也不会用地址替代加载数据作为返回结果。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-inputs role=inputs-outputs -->
## 输入与目的位置

- `SrcL` 接受完整 Reg5 源域，包括不消费的 `T#1..T#4` 和 `U#1..U#4` 选择器。
- `simm22` 覆盖 `-2097152` 至 `2097151` 的全部 22 位有符号值；编码零表示零位移。
- `RegDst` 的 `1..23` 写入 GPR，`30` 压入 U，`31` 压入 T，`0` 和 `24..29` 只丢弃加载结果。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-effects role=effects -->
## 效果与顺序

所有标量源都会在内存或目的效果之前完成快照，因此别名读取的是指令执行前的值。

成功的执行会发出一个 relaxed 排序的加载事件，保持内存和保留状态不变，发布或丢弃加载值，并让 `TPC` 前进 `6` 字节。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-constraints role=constraints -->
## 对齐、故障与重试

有效地址必须按 8 字节传送大小对齐。未对齐会在地址转换前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址处引发 `Fault_DataPage`。

故障不会发出成功内存事件，不产生部分目的或内存效果，保留待处理写回，并保留发生故障时的 `TPC` 以便完整重试。

固定编码位不匹配、保留字段值或选中的 T/U 源尚不可用，会在指令效果之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-example role=example -->
## 非规范地址示例

下面的示例只帮助理解当前地址规则，并不替代规范加载契约。

当基址为 `0x100`、`simm22=2` 时，缩放后的位移是 `16`，因此 `HL.LDI` 访问 `0x110`。若该地址对齐且有访问权限，指令会加载从该处开始的八个字节，并让 `TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldi_48_088e69e45b37 | HL48 | 48 | 0x00003019000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldi_48_088e69e45b37 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldi_48_088e69e45b37 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldi_48_088e69e45b37 | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldi_48_088e69e45b37 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_48_088e69e45b37 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldi_48_088e69e45b37 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI() => ScalarOperation
begin
    return ScalarOperation_HL_LDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_LDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDI()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.ldi [SrcL, simm], ->{t, u, Rd}
