<!-- GENERATED FROM: asl/scalar/agu/HL.LBP.asl -->
# HL.LBP

**Normative ASL source:** `asl/scalar/agu/HL.LBP.asl`

HL.LBP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LBP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbp-purpose role=purpose -->
## `HL.LBP` 做什么

`HL.LBP` 是一条 `48` 位指令，加载一对相邻字节，位移来自寄存器。它用 `SrcR` 与 `shamt` 构造位移，加到 `SrcL` 基址上，读取该和处以及该和加 `1` 处的字节，对两者做符号扩展，并把较低的字节发布到 `Dst0`、较高的字节发布到 `Dst1`。

规范汇编形式是 `hl.lbp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`。

设计要点：本形式有两个目的位置，却不更新基址，这与单元素的寄存器位移加载不同。位移寄存器被读取，基址寄存器被读取，两者都不被写入；这一对加载到的字节就是仅有的结果。若程序还希望推进基址，必须另外处理。

<!-- PTO-READER-BLOCK: scalar-hl-lbp-mechanism role=mechanism -->
## 位移与两个地址如何形成

`SrcR` 经 `SrcRType` 变换后再左移编码字段 `shamt` 位。变换并移位后的值按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上，而这一对的第二个地址是该和加上访问大小，即 `1` 字节。

两个地址都在读取任何一个字节之前按升序被探测；处理程序在第一个故障处返回。两次探测都成功时，读取这两个字节，按地址顺序记录两个 relaxed 加载事件，并按 `Dst0` 在前的顺序发布结果。

设计要点：这里同样先做变换再移位，因此 `.sw` 与 `.uw` 把 `SrcR` 截到 `32` 位，只有不变模式才传完整的 `PTO_XLEN` 值。由于这一对的两个地址只相差一个字节，移位量决定的是与上一对之间的距离，而不是对内元素之间的距离。

<!-- PTO-READER-BLOCK: scalar-hl-lbp-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，`SrcR` 是位移来源，两者都是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `SrcRType` 为 `0` 表示不变，`1` 表示对 `SrcR[31:0]` 施加 `.sw`，`2` 表示对 `SrcR[31:0]` 施加 `.uw`；`3` 被保留。
- `shamt` 是变换之后施加的 `5` 位左移量。
- `Dst0` 收到较低的字节，`Dst1` 收到较高的字节；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：由于没有更新基址的目的位置，两个目的字段都可以用于加载到的数据。只需要其中一个字节的调用者可以丢弃另一个，而不会丢失任何地址信息，因为本形式根本不发布地址信息。

<!-- PTO-READER-BLOCK: scalar-hl-lbp-effects role=effects -->
## 影响、顺序与完成

两个源都在任何内存或目的位置影响之前取快照，因此 `SrcR`、`SrcL` 与目的位置之间的别名使用指令执行前的值。

成功时按地址顺序记录两个 relaxed 的 `1` 字节加载事件，内存与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：若两个目的位置指定同一个寄存器，由于 `Dst1` 最后写入，存活下来的是较高的字节。若两者指定同一个队列，则发生两次压入，较高的字节成为最新的条目。

<!-- PTO-READER-BLOCK: scalar-hl-lbp-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`。`SrcRType` 取值 `3` 会在同一点、且在读取任何源之前被形式约束拒绝，因此被保留的变换不可能影响任一个地址或任一次探测。`SrcL` 或 `SrcR` 指向不可用的 `T` 或 `U` 槽位也会在执行之前引发该故障。

预检对两个地址施加 `1` 字节对齐要求，因此两者都不会引发 `Fault_DataAlignment`。第一个失败地址上的权限或有界内存失败会在该原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个字节都不发布，`TPC` 停留在引发故障的指令上。恢复会重新计算变换、移位、两个地址与两次探测。

<!-- PTO-READER-BLOCK: scalar-hl-lbp-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbp [2, 3<<<1], ->4, 5`，`SrcRType` 选择 `.sw`，GPR2 = `0xE000`，GPR3 = `0xFFFFFFFFFFFFFFFE`。
- 变换把 `SrcR[31:0]`（即 `0xFFFFFFFE`）符号扩展为 `-2`。左移 `1` 位得到位移 `-4`。
- 第一个地址是 `0xE000` 减去 `4`，即 `0xDFFC`，第二个是 `0xDFFD`。
- 若 `0xDFFC` 处的字节是 `01`、`0xDFFD` 处的字节是 `80`，GPR4 收到 `1`，GPR5 收到 `-128`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbp_48_9d1fd0b3105b | HL48 | 48 | 0x00000009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbp_48_9d1fd0b3105b | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbp_48_9d1fd0b3105b | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbp_48_9d1fd0b3105b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbp_48_9d1fd0b3105b | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lbp_48_9d1fd0b3105b | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lbp_48_9d1fd0b3105b | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbp_48_9d1fd0b3105b | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbp_48_9d1fd0b3105b | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbp_48_9d1fd0b3105b | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbp_48_9d1fd0b3105b | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lbp_48_9d1fd0b3105b | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lbp_48_9d1fd0b3105b | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lbp_48_9d1fd0b3105b.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBP.asl -->
```asl
readonly func InstructionContractOperation_HL_LBP() => ScalarOperation
begin
    return ScalarOperation_HL_LBP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBP.asl -->
```asl
readonly func InstructionContractHandler_HL_LBP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LBP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LBP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LBP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBP()
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
- The pair addresses are address and address plus 1; the instruction performs no base writeback.
- After both 1-byte probes succeed, sign-extend each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 1-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 1-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lbp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
