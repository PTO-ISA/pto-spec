<!-- GENERATED FROM: asl/scalar/agu/HL.LHUP.asl -->
# HL.LHUP

**Normative ASL source:** `asl/scalar/agu/HL.LHUP.asl`

HL.LHUP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 2-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LHUP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lhup-purpose role=purpose -->
## HL.LHUP 的作用

`HL.LHUP` 是一条独立的 `48` 位标量 AGU 加载指令。它用 `SrcL` 基址加上先变换再移位的寄存器偏移构成地址，加载两个相邻的对齐小端序 `2` 字节值；当结果窄于该宽度时，把传输位零扩展到 `PTO_XLEN`。

第二个地址是第一个地址加 `2`，并且不发布地址基址回写，因此 `SrcL` 保持其值。

设计要点：寄存器偏移可覆盖整个 `PTO_XLEN` 取值，因此循环不变的步长可以放在 `SrcR` 中而不必进入指令流。

<!-- PTO-READER-BLOCK: scalar-hl-lhup-mechanism role=mechanism -->
## HL.LHUP 如何构成地址并完成传输

偏移由 `SrcR` 提供。`SrcRType` 先选择如何变换整个 `PTO_XLEN` 值：`0` 保持，`1` 对位 `[31:0]` 做符号扩展，`2` 对位 `[31:0]` 做零扩展。

变换后的偏移按编码 `shamt` 左移，其乘积与 `SrcL` 的值按 `2^PTO_XLEN` 取模相加。该和就是被访问的地址。

两个相邻地址先完成预检：第一次探测覆盖算出的地址，它成功之后第二次探测覆盖该地址加 `2`。随后两次 2 字节加载按地址顺序执行，并记录两个宽松加载事件。

可执行路径用 `NormalizeScalarLoadResult` 规范化两个结果：该函数把每个 `2` 字节结果零扩展，因为 `ScalarAGUSignedLoadOfForm` 对本形式返回 `FALSE`，其高位为 `0`，并按地址顺序先发布第一个、再发布第二个。

设计要点：变换在移位之前应用，因此经缩放的字偏移仍保持经缩放。若先移位，被缩放的将是另一组位，`SrcRType=1` 中位 `31` 的含义也会改变。

<!-- PTO-READER-BLOCK: scalar-hl-lhup-inputs role=inputs-outputs -->
## 编码字段及其选择的对象

- `RegDst0` 是一个 `5` 位选择子，用来选择第一个加载值。

- `RegDst1` 是一个 `5` 位选择子，用来选择第二个加载值。

- `SrcL` 是一个 `5` 位选择子，用来选择地址基址。

- `SrcR` 是一个 `5` 位选择子，用来选择寄存器偏移。

- `SrcRType` 是一个 `2` 位选择子，用来选择变换。

- `shamt` 是一个 `5` 位字段，提供在变换之后应用左移的位数。

编码 `1`..`23` 写入绝对 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 只丢弃该结果，编码 `24`..`29` 不写入任何位置。

`SrcL` 与 `SrcR` 使用完整的 `Reg5` 源域：编码 `0`..`23` 选择绝对 GPR，编码 `24`..`27` 选择 `T#1`..`T#4`，编码 `28`..`31` 选择 `U#1`..`U#4`，且不会消耗它们。选择子 `0` 读取架构零 GPR。

设计要点：只有 `SrcRType` 值 `0`、`1`、`2` 有分配，`3` 为保留，因此 `3` 会报故障，而不会选出第四种变换。地址修饰也没有取负分支。

<!-- PTO-READER-BLOCK: scalar-hl-lhup-effects role=effects -->
## 效果、快照与完成顺序

- `SrcL` 与 `SrcR` 都在内存操作之前取快照，因此与任一源别名的目的位置都无法改变所用的地址或偏移。

- 成功执行会记录两个按地址顺序排列的宽松加载事件，保持内存内容和保留状态不变，并且不回写任何基址。

- 在所有结果发布之后，`HL.LHUP` 把 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退役。

<!-- PTO-READER-BLOCK: scalar-hl-lhup-constraints role=constraints -->
## 合法性、故障与重启

故障按以下顺序产生：`SrcRType=3` 或不可用的被选中 `T` 或 `U` 源在任何效果之前产生 `Fault_IllegalInstruction`；未对齐的地址在地址转换之前产生 `Fault_DataAlignment`；权限或受限内存范围失败在转换之后于原始地址产生 `Fault_DataPage`。

对齐针对被访问的地址，而不是 `SrcR`。`shamt` 可以是 `0`，而 `SrcR` 是不受约束的 `Reg5` 值，因此当且仅当被访问的地址不是 `2` 的整数倍时，访问就是未对齐的。

设计要点：保留的 `SrcRType` 编码在合法性预检阶段就被拒绝，早于任何地址的形成，因此它不会改为产生对齐或页故障。

故障不会发出成功的内存事件，也不产生部分内存或目的位置效果，并把 `TPC` 留在故障指令处；重试会重算源快照、地址、预检、传输与发布。

<!-- PTO-READER-BLOCK: scalar-hl-lhup-example role=example -->
## 非规范阅读示例

本示例说明如何使用本页，不增加指令行为。

- 从规范汇编 `hl.lhup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1` 入手，识别基址、寄存器偏移、变换、移位和目的选择子。

- 先算出 `SrcL` 与移位后偏移之和按 `2^PTO_XLEN` 取模的结果，再检查该形式实际访问的地址的对齐。

- 然后把该形式发布的内容与下面的 ASL 契约对照检查。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lhup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lhup_48_ea24f978b27a | HL48 | 48 | 0x00005009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lhup_48_ea24f978b27a | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lhup_48_ea24f978b27a | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lhup_48_ea24f978b27a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lhup_48_ea24f978b27a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lhup_48_ea24f978b27a | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lhup_48_ea24f978b27a | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lhup_48_ea24f978b27a | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhup_48_ea24f978b27a | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhup_48_ea24f978b27a | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lhup_48_ea24f978b27a | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lhup_48_ea24f978b27a | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lhup_48_ea24f978b27a | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lhup_48_ea24f978b27a.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHUP.asl -->
```asl
readonly func InstructionContractOperation_HL_LHUP() => ScalarOperation
begin
    return ScalarOperation_HL_LHUP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHUP.asl -->
```asl
readonly func InstructionContractHandler_HL_LHUP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LHUP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LHUP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LHUP()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LHUP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LHUP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LHUP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LHUP()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 2; the instruction performs no base writeback.
- After both 2-byte probes succeed, zero-extend each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 2-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 2-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lhup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
