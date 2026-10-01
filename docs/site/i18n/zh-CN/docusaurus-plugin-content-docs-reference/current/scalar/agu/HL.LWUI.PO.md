<!-- GENERATED FROM: asl/scalar/agu/HL.LWUI.PO.asl -->
# HL.LWUI.PO

**Normative ASL source:** `asl/scalar/agu/HL.LWUI.PO.asl`

HL.LWUI.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LWUI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lwui-po-purpose role=purpose -->
## HL.LWUI.PO 的作用

`HL.LWUI.PO` 是一条独立的 `48` 位标量 AGU 加载指令。它用 `SrcL` 基址和经过缩放的立即数位移构成地址，加载一个对齐的小端序 `4` 字节值；当结果窄于该宽度时，把传输位零扩展到 `PTO_XLEN`。

它是后置基址更新的加载：本次访问使用原始基址，下面的第二个目的选择子发布更新后的基址。

设计要点：`SrcL` 是不受约束的 `Reg5` 值，而位移总是 `4` 的整数倍，因此当且仅当被访问的地址不是 `4` 字节传输单元的整数倍时，本次访问未对齐。

<!-- PTO-READER-BLOCK: scalar-hl-lwui-po-mechanism role=mechanism -->
## HL.LWUI.PO 如何构成地址并完成传输

位移由 `simm17` 提供。它从其 `17` 位符号扩展到 `PTO_XLEN`，再左移 `2` 位，即乘以 `4`，所得结果与 `SrcL` 的值按 `2^PTO_XLEN` 取模相加。被访问的地址是原始基址，该和作为新基址发布。`SrcL` 只读一次，因此整个地址都来自一个指令前的值。

预检之后，执行一次对齐的小端序 `4` 字节加载，并记录一个宽松加载事件。可执行路径用 `NormalizeScalarLoadResult` 规范化结果：该函数把 `4` 字节结果零扩展，因为 `ScalarAGUSignedLoadOfForm` 对本形式返回 `FALSE`，其高位为 `0`。

设计要点：对位移做符号扩展，使一个编码就能访问基址两侧，而 `2` 位左移让每个编码步长都是 `4` 字节。代价是范围不对称：最大正字节位移为 `262140`，最负字节位移为 `-262144`。

<!-- PTO-READER-BLOCK: scalar-hl-lwui-po-inputs role=inputs-outputs -->
## 编码字段及其选择的对象

- `RegDst0` 是一个 `5` 位选择子，用来选择加载值。

- `RegDst1` 是一个 `5` 位选择子，用来选择更新后的基址。

- `SrcL` 是一个 `5` 位选择子，用来选择地址基址。

- `simm17` 是一个 `17` 位有符号立即数；其字节位移是该值左移 `2` 位，因此是 `4` 的整数倍。

编码 `1`..`23` 写入绝对 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 只丢弃该结果，编码 `24`..`29` 不写入任何位置。

`SrcL` 使用完整的 `Reg5` 源域：编码 `0`..`23` 选择绝对 GPR，编码 `24`..`27` 选择 `T#1`..`T#4`，编码 `28`..`31` 选择 `U#1`..`U#4`，且不会消耗它们。选择子 `0` 读取架构零 GPR。

设计要点：目的选择子为 `0` 时是丢弃结果，而不是取消整条指令，因此加载、其内存事件和`TPC` 前进都仍然发生。

<!-- PTO-READER-BLOCK: scalar-hl-lwui-po-effects role=effects -->
## 效果、快照与完成顺序

源在内存操作之前取快照，因此即使某个目的位置就是 `SrcL`，写入也只在该次加载完成之后落地。

- 成功执行会记录一个宽松加载事件，保持内存内容和保留状态不变，并且只在内存操作完成之后才把更新后的基址发布到 `RegDst1`。

- 在所有结果发布之后，`HL.LWUI.PO` 把 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退役。

<!-- PTO-READER-BLOCK: scalar-hl-lwui-po-constraints role=constraints -->
## 合法性、故障与重启

故障按以下顺序产生：不可用的被选中 `T` 或 `U` 源在任何效果之前产生 `Fault_IllegalInstruction`；未对齐的地址在地址转换之前产生 `Fault_DataAlignment`；权限或受限内存范围失败在转换之后于原始地址产生 `Fault_DataPage`。

每个编码字段都有分配，因此没有需要拒绝的保留字段值；固定位不匹配会产生 `Fault_IllegalInstruction`。

被访问的地址就是不受约束的 `Reg5` 基址本身（这是后置形式），因此对齐取决于该基址，而不是编码。

设计要点：对齐检查在地址转换之前进行，因此未对齐的访问不会改动转换状态后再报故障；`Fault_DataPage` 之后报告的是原始地址。

故障不会发出成功的内存事件，也不产生部分内存或目的位置效果，并把 `TPC` 留在故障指令处；重试会重算地址、预检、传输与发布。

<!-- PTO-READER-BLOCK: scalar-hl-lwui-po-example role=example -->
## 非规范阅读示例

本示例说明如何使用本页，不增加指令行为。

- 从规范汇编 `hl.lwui.po [SrcL, simm], ->Dst0, Dst1` 入手，识别基址选择子、立即数位移和目的选择子们。

- 在使用该形式做远距离访问之前，结合`2` 位左移读出 `17` 个编码位所能达到的字节位移。

- 然后把对齐规则、效果列表和下面的 ASL 契约与打算访问的地址对照检查。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lwui.po [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwui_po_48_09a75b628dc4 | HL48 | 48 | 0x00006019003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwui_po_48_09a75b628dc4 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwui_po_48_09a75b628dc4 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lwui_po_48_09a75b628dc4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lwui_po_48_09a75b628dc4 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lwui_po_48_09a75b628dc4 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwui_po_48_09a75b628dc4 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwui_po_48_09a75b628dc4 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lwui_po_48_09a75b628dc4 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWUI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LWUI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LWUI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWUI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LWUI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LWUI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LWUI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LWUI_PO()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LWUI_PO()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LWUI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LWUI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LWUI_PO()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- After a successful 4-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.lwui.po [SrcL, simm], ->Dst0, Dst1
