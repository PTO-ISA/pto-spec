<!-- GENERATED FROM: asl/scalar/agu/HL.LDI.PO.asl -->
# HL.LDI.PO

**Normative ASL source:** `asl/scalar/agu/HL.LDI.PO.asl`

HL.LDI.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LDI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-purpose role=purpose -->
## `HL.LDI.PO` 做什么

`HL.LDI.PO` 是一条 `48` 位的后变址加载指令，读取一个小端序 `8` 字节值并使用立即数位移。它在 `SrcL` 基址处读取八个字节，把完整的 `64` 位模式发布到 `Dst0`，把更新后的基址 `SrcL + 8 * simm17` 发布到 `Dst1`。

规范汇编形式是 `hl.ldi.po [SrcL, simm], ->Dst0, Dst1`。

设计要点：位移按 `8` 缩放，因此立即数计的是 `8` 字节元素而不是字节。可达窗口是相对基址 `-524288` 到 `524280` 字节、步长为 `8`，其中每一个位移都是访问大小的倍数。因此基于立即数的步长不需要寄存器，却仍然落在 `8` 字节对齐规则会接受的地址上。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-mechanism role=mechanism -->
## 地址与传输如何形成

立即数被符号扩展并左移 `3` 位。后变址模式下有效地址是 `SrcL` 的快照，而缩放后的位移按 `2^PTO_XLEN` 取模加到这个快照上，只是为了产生 `Dst1` 的值。

`SrcL` 从不被写入，因此无论走成功路径还是故障路径，基址寄存器都保持指令执行前的值。

编码检查与地址预检通过后，执行一次 `8` 字节小端序加载，字节原样发布到 `Dst0`，随后把更新后的基址发布到 `Dst1`。

设计要点：在 `8` 字节对齐的基址上，任何可编码位移都让 `8` 字节访问保持对齐，因此 `Fault_DataAlignment` 只可能来自基址本身。只有当基址本来就不对齐时，`Dst1` 才可能让之后的访问处于未对齐状态，因为位移永远是 `8` 的倍数。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`；队列源被读取时不会被消耗。
- `simm17` 是有符号 `17` 位立即数。它组装出的字节值等于该有符号立即数乘以 `8`。
- `Dst0` 收到加载到的模式，`Dst1` 收到更新后的基址。编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：这 `8` 个字节作为一个 `64` 位值发布，因此本宽度不存在扩展决定，记录符号性的字段也没有可见效果。本形式与字节宽度的立即数加载共用操作数字段布局；把它们区分开的是缩放因子与访问大小。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前取快照，因此指定基址的目的位置仍然为地址提供指令执行前的值。

执行成功时记录一个 relaxed 的 `8` 字节加载事件，内存与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：目的位置的写入在加载完成之后发生，因此故障会让基址寄存器与两个目的位置都保持原样。所以这条指令在缺页之后可以安全重试：重试会从同一个基址重新算出同一个地址。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 编码选中不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。该编码中不存在变换或移位字段。

预检检查有效地址的低 `3` 位——在后变址模式下就是基址——并在翻译之前、权限检查之前引发 `Fault_DataAlignment`。对齐但未通过权限或有界内存检查的地址会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会重新对立即数做符号扩展、重新缩放并重复访问。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-po-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.ldi.po [10, 3], ->11, 12`，GPR10 = `0x8000`。立即数是 `3`，乘以 `8` 得 `24`。
- 访问地址是旧基址 `0x8000`，指令把 `0x8000` 至 `0x8007` 的 `8` 字节读入 GPR11。
- GPR12 收到 `0x8000` 加 `24`，即 `0x8018`。
- GPR10 仍持有 `0x8000`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldi.po [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldi_po_48_0cc539e6798d | HL48 | 48 | 0x00003019003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldi_po_48_0cc539e6798d | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldi_po_48_0cc539e6798d | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ldi_po_48_0cc539e6798d | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldi_po_48_0cc539e6798d | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldi_po_48_0cc539e6798d | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_po_48_0cc539e6798d | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_po_48_0cc539e6798d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldi_po_48_0cc539e6798d | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LDI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LDI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDI_PO()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDI_PO()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_LDI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LDI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDI_PO()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
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

- hl.ldi.po [SrcL, simm], ->Dst0, Dst1
