<!-- GENERATED FROM: asl/scalar/agu/HL.LBUP.asl -->
# HL.LBUP

**Normative ASL source:** `asl/scalar/agu/HL.LBUP.asl`

HL.LBUP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LBUP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbup-purpose role=purpose -->
## `HL.LBUP` 做什么

`HL.LBUP` 是一条 `48` 位指令，加载一对相邻字节，位移来自寄存器并返回零扩展结果。它用 `SrcR` 与 `shamt` 构造位移，加到 `SrcL` 基址上，读取该和处的字节以及该和加 `1` 处的字节，清零每个结果中第 `7` 位以上的一切，并把较低的字节发布到 `Dst0`、较高的字节发布到 `Dst1`。

规范汇编形式是 `hl.lbup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`。

设计要点：位移寄存器通过一次变换和一次移位参与地址，但从不收回任何东西。基址与位移寄存器都不被本形式写入，因此它没有推进指针的副作用，也不能在指令内部推进一次遍历。

<!-- PTO-READER-BLOCK: scalar-hl-lbup-mechanism role=mechanism -->
## 位移与两个地址如何形成

`SrcR` 经 `SrcRType` 变换，左移编码字段 `shamt` 位，并按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。第二个地址是该和加上 `1` 字节，也就是访问大小。

两个地址按升序被探测，在两次探测都成功之前不会读取任何字节。随后处理程序读取字节，按地址顺序记录两个 relaxed 加载事件，对两个值做零扩展，并按 `Dst0` 在 `Dst1` 之前发布。

设计要点：当两个目的位置都是队列压入时，指令产生两次压入，因此让队列前进两次。较旧的条目移动两个槽位，所以指令执行前位于 `T#1` 的值在执行后位于 `T#3`。

<!-- PTO-READER-BLOCK: scalar-hl-lbup-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，`SrcR` 是位移来源，两者都是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `SrcRType` 为 `0` 表示不变，`1` 表示对 `SrcR[31:0]` 施加 `.sw`，`2` 表示对 `SrcR[31:0]` 施加 `.uw`；`3` 被保留。
- `shamt` 是变换之后施加的 `5` 位左移量，因此一个元素的位移用 `SrcR` 中的 `1` 配合相应的移位来表示。
- `Dst0` 收到较低的字节，`Dst1` 收到较高的字节；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：变换字段与单元素形式共用，因此保留值 `3` 在同一处、出于同一原因被拒绝：由形式约束拒绝，且在读取任何源或尝试任何探测之前。

<!-- PTO-READER-BLOCK: scalar-hl-lbup-effects role=effects -->
## 影响、顺序与完成

两个源选择子都在任何内存或目的位置影响之前被读取，因此别名使用指令执行前的值。

执行成功时按地址顺序记录两个 relaxed 的 `1` 字节加载事件，内存字节与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：所有内存影响都先于所有目的位置影响，因此观察到这两个事件的消费者知道两个字节都在任一结果发布之前被读取。指令内部不存在两类影响的交错。

<!-- PTO-READER-BLOCK: scalar-hl-lbup-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcRType` 为 `3` 会在读取任何源之前被形式约束拒绝；`SrcL` 或 `SrcR` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检对两个地址施加 `1` 字节对齐要求，因此本形式没有任何地址会引发 `Fault_DataAlignment`。权限与有界内存检查按升序作用于每个地址，第一个失败会在该原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个字节都不发布，`TPC` 停留在引发故障的指令上。恢复会重新计算变换、移位、两个地址与两次探测。

<!-- PTO-READER-BLOCK: scalar-hl-lbup-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbup [8, 9<<<3], ->10, 11`，`SrcRType` 选择 `.uw`，GPR8 = `0xF000`，GPR9 = `1`。
- 变换对 `SrcR[31:0]`（即 `1`）做零扩展，左移 `3` 位得到位移 `8`。
- 第一个地址是 `0xF008`，第二个是 `0xF009`。若 `0xF008` 处的字节是 `FF`、`0xF009` 处的字节是 `01`，GPR10 收到 `255`，GPR11 收到 `1`。
- GPR8 与 GPR9 保持其值，因为本形式不发布任何地址结果。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbup_48_c9598658dde4 | HL48 | 48 | 0x00004009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbup_48_c9598658dde4 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbup_48_c9598658dde4 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbup_48_c9598658dde4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbup_48_c9598658dde4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lbup_48_c9598658dde4 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lbup_48_c9598658dde4 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbup_48_c9598658dde4 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbup_48_c9598658dde4 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbup_48_c9598658dde4 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbup_48_c9598658dde4 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lbup_48_c9598658dde4 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lbup_48_c9598658dde4 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lbup_48_c9598658dde4.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUP.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUP() => ScalarOperation
begin
    return ScalarOperation_HL_LBUP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUP.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LBUP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LBUP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUP()
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
- After both 1-byte probes succeed, zero-extend each result at PTO_XLEN and publish first then second.
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

- hl.lbup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
