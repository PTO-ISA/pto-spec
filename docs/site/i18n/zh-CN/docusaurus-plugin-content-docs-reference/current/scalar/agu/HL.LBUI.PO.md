<!-- GENERATED FROM: asl/scalar/agu/HL.LBUI.PO.asl -->
# HL.LBUI.PO

**Normative ASL source:** `asl/scalar/agu/HL.LBUI.PO.asl`

HL.LBUI.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBUI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-purpose role=purpose -->
## `HL.LBUI.PO` 做什么

`HL.LBUI.PO` 是一条 `48` 位的后变址字节加载指令，使用有符号 `17` 位立即数位移并返回零扩展结果。它在 `SrcL` 基址处读取一个字节，把该字节放在第 `7`:`0` 位并清零更高位，发布到 `Dst0`，并把更新后的基址发布到 `Dst1`。

规范汇编形式是 `hl.lbui.po [SrcL, simm], ->Dst0, Dst1`。

设计要点：这条指令在一次操作里对两个值采用相反的符号约定。位移是有符号的，因此可以在 `131072` 字节的窗口内向前向后走；而加载的字节是无符号的，所以字节 `FF` 会变成 `255`，永远不会变成 `-1`。需要该字节有符号读法的调用者必须改用同宽度的另一种形式。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-mechanism role=mechanism -->
## 地址与传输如何形成

立即数被符号扩展，并以缩放因子 `1` 使用。后变址模式下访问地址是 `SrcL` 的快照，而和 `SrcL + displacement` 按 `2^PTO_XLEN` 取模，用于发布。

`SrcL` 从不被写入。该编码中没有位移寄存器、没有变换字段，也没有移位量。

编码检查与地址预检通过后，执行一次 `1` 字节小端序加载，把字节零扩展到 `PTO_XLEN`，并按 `Dst0` 在前的顺序发布两个目的位置。

设计要点：由于位移以立即数形式施加，而不是通过寄存器移位，位移是字节粒度且从不缩放。窗口内每个字节都可达，这正是字节粒度访问所需要的；可达集合中不存在由对齐造成的空隙。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `simm17` 是有符号 `17` 位立即数，覆盖 `-65536` 到 `65535`，按 `1` 缩放。
- `Dst0` 收到零扩展后的字节，`Dst1` 收到更新后的基址；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：两个目的字段相互独立，因此常用的指针推进写法不需要额外的目的位置：只需要更新后的基址时，给 `Dst0` 编码一个丢弃即可。加载仍然发生，所以丢弃不能用来跳过访问本身会引发的故障。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-effects role=effects -->
## 影响、顺序与完成

`SrcL` 的读取先于一切内存与目的位置影响，因此别名使用的是指令执行前的基址。

执行成功时记录一个 relaxed 的 `1` 字节加载事件，内存与保留状态保持不变。发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：零扩展在发布之前施加，因此目的位置里永远不会是原始的 `8` 位；后续在同宽度上与无符号上界比较时可以直接使用已发布的值。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式不会引发 `Fault_DataAlignment`。翻译与权限检查仍可能失败，并在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会重新计算符号扩展后的立即数、求和与加载，不保留任何进度。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-po-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbui.po [12, -2], ->13, 14`，GPR12 = `0x6000`。
- 立即数是 `-2`，因此更新后的基址是 `0x6000` 减去 `2`，即 `0x5FFE`。
- 访问地址是旧基址 `0x6000`。若该处的字节为 `80`，GPR13 收到 `128`。
- GPR14 收到 `0x5FFE`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbui.po [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbui_po_48_c889b4445022 | HL48 | 48 | 0x00004019003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbui_po_48_c889b4445022 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbui_po_48_c889b4445022 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbui_po_48_c889b4445022 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbui_po_48_c889b4445022 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbui_po_48_c889b4445022 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_po_48_c889b4445022 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_po_48_c889b4445022 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbui_po_48_c889b4445022 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LBUI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBUI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBUI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUI_PO()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUI_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUI_PO()
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
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- hl.lbui.po [SrcL, simm], ->Dst0, Dst1
