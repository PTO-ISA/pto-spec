<!-- GENERATED FROM: asl/scalar/agu/HL.LBU.PO.asl -->
# HL.LBU.PO

**Normative ASL source:** `asl/scalar/agu/HL.LBU.PO.asl`

HL.LBU.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBU-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-purpose role=purpose -->
## `HL.LBU.PO` 做什么

`HL.LBU.PO` 是一条 `48` 位的后变址字节加载指令，采用零扩展。它在 `SrcL` 基址处读取一个字节，把该字节放在结果的第 `7`:`0` 位并清零更高位，把该字节发布到 `Dst0`、把更新后的基址发布到 `Dst1`。

规范汇编形式是 `hl.lbu.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`。

设计要点：这条指令包含两个相互独立的扩展决定，作用于不同的值。`SrcRType` 扩展的是位移寄存器 `SrcR`，而加载的字节始终被零扩展，因为本形式是无符号加载。因此同一次执行里可以同时出现负位移与字节值 `255`：位移向后走，而结果保持非负。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-mechanism role=mechanism -->
## 位移与地址如何形成

位移是 `SrcR` 经 `SrcRType` 变换后再左移编码字段 `shamt` 位。后变址模式下访问使用 `SrcL` 的快照，而 `SrcL + offset` 按 `2^PTO_XLEN` 取模，纯粹用于发布。

`SrcL` 从不被写入，因此更新后的基址只能通过 `Dst1` 到达寄存器或队列。

编码检查与地址预检通过后，处理程序执行一次 `1` 字节小端序加载，对字节做零扩展，并发布两个结果。

设计要点：不变模式 `0` 把 `SrcR` 的完整 `PTO_XLEN` 值交给移位，而模式 `1` 与 `2` 只保留 `SrcR[31:0]`。因此建立在寄存器高半部分的位移只有在模式 `0` 下才能存活；即使 `SrcR` 本身不变，把描述符从无修饰符切换到 `.sw` 或 `.uw` 也会改变地址。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，`SrcR` 是位移来源，两者都是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `SrcRType` 为 `0` 表示不变，`1` 表示对 `SrcR[31:0]` 施加 `.sw`，`2` 表示对 `SrcR[31:0]` 施加 `.uw`；`3` 被保留。
- `shamt` 是变换之后施加的 `5` 位左移量，因此位移可以按 `1` 到 `2^31` 之间的任意 2 的幂缩放。
- `Dst0` 收到零扩展后的字节，`Dst1` 收到更新后的基址；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：由于两个目的编码相互独立，`Dst0` 可以是丢弃，而 `Dst1` 仍然写入寄存器。内存访问无论如何都会发生；被跳过的只是字节的发布。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-effects role=effects -->
## 影响、顺序与完成

两个源选择子都在任何内存或目的位置影响之前被读取，因此别名使用指令执行前的值。成功时记录一个 relaxed 的 `1` 字节加载事件，内存与保留状态保持不变。

`Dst0` 在 `Dst1` 之前发布。两次发布之后 `TPC` 前进 `6` 字节，被拒绝或发生故障的尝试不会退休。

设计要点：零扩展是发布值的一部分，而不是内存系统的属性，因此持有结果的队列或寄存器本身就已满足任何无符号比较；不需要后续的屏蔽步骤，也没有任何状态记录该值来自一个字节。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcRType` 为 `3` 会在读取任何源之前被形式约束拒绝；`SrcL` 或 `SrcR` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式不会引发 `Fault_DataAlignment`。权限与有界内存检查仍然适用，并在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会重新计算变换、移位、求和与加载。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-po-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbu.po [11, 12<<<0], ->13, 14`，`SrcRType` 选择 `.sw`，GPR11 = `0xA000`，GPR12 = `0xFFFFFFFFFFFFFFFF`。
- 变换把 `SrcR[31:0]`（即 `0xFFFFFFFF`）符号扩展为 `-1`。移位量为 `0`，因此位移是 `-1`。
- 访问地址是旧基址 `0xA000`。若该处的字节为 `FF`，GPR13 收到 `255`，更高位全为零。
- GPR14 收到 `0xA000` 减去 `1`，即 `0x9FFF`；GPR11 仍持有 `0xA000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbu.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbu_po_48_5c8a5b39e6c5 | HL48 | 48 | 0x00004009003e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbu_po_48_5c8a5b39e6c5 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbu_po_48_5c8a5b39e6c5 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lbu_po_48_5c8a5b39e6c5 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbu_po_48_5c8a5b39e6c5 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_po_48_5c8a5b39e6c5 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lbu_po_48_5c8a5b39e6c5 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lbu_po_48_5c8a5b39e6c5 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lbu_po_48_5c8a5b39e6c5.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBU.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LBU_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LBU_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBU.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LBU_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBU_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBU_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LBU_PO()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBU_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBU_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBU_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBU_PO()
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

- hl.lbu.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
