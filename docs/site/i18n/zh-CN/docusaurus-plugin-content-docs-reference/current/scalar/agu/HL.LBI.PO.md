<!-- GENERATED FROM: asl/scalar/agu/HL.LBI.PO.asl -->
# HL.LBI.PO

**Normative ASL source:** `asl/scalar/agu/HL.LBI.PO.asl`

HL.LBI.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-purpose role=purpose -->
## `HL.LBI.PO` 做什么

`HL.LBI.PO` 是一条 `48` 位的后变址字节加载指令，使用有符号 `17` 位立即数位移。它在 `SrcL` 基址处读取一个字节，把该字节符号扩展到 `PTO_XLEN`，把字节发布到 `Dst0`，把更新后的基址 `SrcL + simm17` 发布到 `Dst1`。

规范汇编形式是 `hl.lbi.po [SrcL, simm], ->Dst0, Dst1`。

设计要点：位移编码在指令里，而不是从寄存器读取。因此本形式只有一个源选择子 `SrcL`，没有 `SrcR`，也没有移位量，于是不存在可能被保留的变换字段，也不存在第二个源会因不可用而拒绝指令。整个位移范围都可以使用，且不必为此占用一个寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-mechanism role=mechanism -->
## 地址与传输如何形成

位移是符号扩展后的 `17` 位立即数，不做缩放。后变址模式下访问使用 `SrcL` 的快照，而 `SrcL + displacement` 按 `2^PTO_XLEN` 取模，仅用于发布。

`SrcL` 从不被写入，因此更新后的基址只作为送到 `Dst1` 的值存在。

编码检查与地址预检通过后，处理程序执行一次 `1` 字节小端序加载，对第 `7` 位做符号扩展，并按 `Dst0` 然后 `Dst1` 的顺序发布。

设计要点：缩放因子是 `1`，因此从 `-65536` 到 `65535` 的每个字节位移都可达；又因为 `1` 字节访问没有对齐要求，这个窗口内没有任何取值会被预检拒绝。立即数的字节粒度与访问的字节粒度完全一致。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`；读取队列条目不会消耗它。
- `simm17` 是有符号 `17` 位立即数，覆盖 `-65536` 到 `65535`；缩放因子为 `1`。
- `Dst0` 收到符号扩展后的字节，`Dst1` 收到更新后的基址。编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：两个目的位置是各自独立的字段，因此只用于推进指针的加载可以丢弃 `Dst0`。访问仍会发生，加载事件仍会被记录；丢弃抑制的是字节的发布，而不是内存引用。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前被读取，因此指定 `SrcL` 的目的位置仍然为地址贡献指令执行前的基址。

执行成功时记录一个 relaxed 的 `1` 字节加载事件，内存字节与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：`Dst0` 在 `Dst1` 之前发布，因此用一个寄存器承载两个结果时它最终保存的是更新后的基址。加载到的字节并没有从内存中丢失，只是没有留在该寄存器里。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-constraints role=constraints -->
## 合法性、故障与重启

`48` 位编码中的固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 编码选中不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。本形式不编码变换也不编码移位，因此在该阶段没有其他东西会被拒绝。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式不会引发 `Fault_DataAlignment`。翻译与权限检查仍可能失败，并在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会从快照重新计算位移、求和与加载。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-po-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbi.po [2, -1], ->3, 4`，GPR2 = `0x7000`。立即数是 `-1`，因此更新后的基址是 `0x7000` 减去 `1`，即 `0x6FFF`。
- 访问地址是旧基址 `0x7000`，而不是更新后的基址，因为模式是后变址。
- 若 `0x7000` 处的字节为 `80`，GPR3 收到 `-128`，即 `0xFFFFFFFFFFFFFF80`。
- GPR4 收到 `0x6FFF`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbi.po [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbi_po_48_afbc00c48aba | HL48 | 48 | 0x00000019003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbi_po_48_afbc00c48aba | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbi_po_48_afbc00c48aba | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbi_po_48_afbc00c48aba | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbi_po_48_afbc00c48aba | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbi_po_48_afbc00c48aba | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_po_48_afbc00c48aba | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_po_48_afbc00c48aba | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbi_po_48_afbc00c48aba | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LBI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LBI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LBI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBI_PO()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBI_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBI_PO()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBI_PO()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- After a successful 1-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.lbi.po [SrcL, simm], ->Dst0, Dst1
