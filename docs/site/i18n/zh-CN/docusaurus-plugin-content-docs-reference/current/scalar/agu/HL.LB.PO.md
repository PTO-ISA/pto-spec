<!-- GENERATED FROM: asl/scalar/agu/HL.LB.PO.asl -->
# HL.LB.PO

**Normative ASL source:** `asl/scalar/agu/HL.LB.PO.asl`

HL.LB.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LB-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lb-po-purpose role=purpose -->
## `HL.LB.PO` 做什么

`HL.LB.PO` 是一条 `48` 位的后变址字节加载指令。它在 `SrcL` 基址处读取一个字节，把该字节符号扩展到 `PTO_XLEN`，并发布两个相互独立的结果：加载值送到 `Dst0`，更新后的基址 `SrcL + offset` 送到 `Dst1`。

规范汇编形式是 `hl.lb.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`。位移由第二个寄存器 `SrcR` 构造：可以选择扩展其低 `32` 位，再做一次左移。

设计要点：后变址在旧基址读取，并在之后发布新基址。基址寄存器只被读取，因此 `SrcL` 本身从不改变；把 `SrcL` 指定为 `Dst1` 时，更新值只在加载完成之后才写入该处。

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-mechanism role=mechanism -->
## 位移与地址如何形成

位移分两步构造：先按 `SrcRType` 变换 `SrcR`，再把变换后的值左移编码字段 `shamt` 位。`SrcL + offset` 按 `2^PTO_XLEN` 取模。

后变址寻址的有效地址是 `SrcL` 的快照，而 `Dst1` 收到 `SrcL + offset`。本指令从不写入基址选择子 `SrcL`。

编码检查与地址预检通过后，执行一次 `1` 字节小端序加载，对第 `7` 位做符号扩展，然后完成两次发布。

设计要点：变换先于移位运行，因此 `SrcRType` 把 `SrcR` 截到 `32` 位，移位再对截断后的值做缩放。在 `.sw` 与 `.uw` 下，第 `31` 位以上的位永远无法影响地址；而非零的变换值移位后仍非零，因为 `32` 位值最多左移 `31` 位不可能离开 `64` 位字。

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是地址基址，`SrcR` 是位移来源；两者都是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。队列选择子被读取时不会被消耗。
- `SrcRType` 选择变换：`0` 不变，`1` 对 `SrcR[31:0]` 做符号扩展，`2` 对 `SrcR[31:0]` 做零扩展；第四个编码被保留。
- `shamt` 是变换之后施加的 `5` 位左移量。
- `Dst0` 收到符号扩展后的字节，`Dst1` 收到更新后的基址。编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 丢弃该单个结果。

设计要点：两个目的位置分别编码，因此只为推进指针的加载可以对 `Dst0` 使用丢弃编码，同时仍在 `Dst1` 收到更新后的基址。丢弃 `Dst0` 去掉的是发布，而不是内存访问。

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-effects role=effects -->
## 影响、顺序与完成

`SrcL` 与 `SrcR` 都在任何内存或目的位置影响之前被读取，因此源与目的之间的任何别名都使用指令执行前的值。

成功时记录一个 relaxed 的 `1` 字节加载事件，内存与保留状态保持不变。`Dst0` 先发布，`Dst1` 后发布。

两次发布之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：由于更新后的基址在加载值之后写入，若程序让 `Dst0` 与 `Dst1` 指定同一个寄存器，该寄存器最终保存的是更新后的基址，加载到的字节会丢失。没有任何编码能产生相反的顺序。

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcRType` 为 `3` 会在读取任何源之前被形式约束拒绝，因此被保留的变换无法影响地址或探测。`SrcL` 或 `SrcR` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式不会引发 `Fault_DataAlignment`。权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会从快照重新计算变换、移位、地址与加载。

<!-- PTO-READER-BLOCK: scalar-hl-lb-po-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lb.po [1, 2<<<3], ->3, 4`，`SrcRType` 选择符号扩展变换，GPR1 = `0x8000`，GPR2 = `0xFFFFFFFFFFFFFFFE`。
- 变换取 `SrcR[31:0]`，即 `0xFFFFFFFE`，把它符号扩展为 `-2`。左移 `3` 位得到位移 `-16`。
- 访问地址是旧基址 `0x8000`。该处的字节被符号扩展进 GPR3，GPR4 收到 `0x8000` 减去 `16`，即 `0x7FF0`。
- GPR1 仍持有 `0x8000`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lb.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lb_po_48_5c7f5c82b186 | HL48 | 48 | 0x00000009003e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lb_po_48_5c7f5c82b186 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lb_po_48_5c7f5c82b186 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lb_po_48_5c7f5c82b186 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lb_po_48_5c7f5c82b186 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lb_po_48_5c7f5c82b186 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lb_po_48_5c7f5c82b186 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lb_po_48_5c7f5c82b186 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_po_48_5c7f5c82b186 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_po_48_5c7f5c82b186 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lb_po_48_5c7f5c82b186 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lb_po_48_5c7f5c82b186 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lb_po_48_5c7f5c82b186 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lb_po_48_5c7f5c82b186.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LB.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LB_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LB_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LB.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LB_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LB_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LB_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LB_PO()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LB_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LB_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LB_PO()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LB_PO()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.lb.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
