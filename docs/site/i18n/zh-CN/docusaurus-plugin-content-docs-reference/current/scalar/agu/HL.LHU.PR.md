<!-- GENERATED FROM: asl/scalar/agu/HL.LHU.PR.asl -->
# HL.LHU.PR

**Normative ASL source:** `asl/scalar/agu/HL.LHU.PR.asl`

HL.LHU.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LHU-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lhu-pr-purpose role=purpose -->
## `HL.LHU.PR` 的作用

`HL.LHU.PR` 是一条独立编码的 48 位加载指令。它的基址来自 `SrcL`，偏移来自 `SrcR`，并在使用前先经变换和移位；它把一个 2 字节宽的值加载到一个目的。

<!-- PTO-READER-BLOCK: scalar-hl-lhu-pr-mechanism role=mechanism -->
## 地址与加载机制

`SrcR` 先被读取，再按 `SrcRType` 变换，然后按编码的 `shamt` 左移，结果就是偏移；`shamt` 为零时该偏移是按字节粒度的。

该偏移按 `2^PTO_XLEN` 取模加到快照后的 `SrcL` 值上。

该 `2` 字节地址依次通过对齐检查与转换和权限检查之后，指令执行一次小端 `2` 字节加载，并记录一个 relaxed 加载事件。

前索引模式访问更新后的基址，并通过 `Dst1` 发布同一个值。

被访问地址处的字节成为结果的 `7:0` 位，后续字节填充更高的位，因此该值是小端序，指令会把加载值零扩展到 `PTO_XLEN`，即保留低 `16` 位并把每个更高位设为零。

**设计要点：** `HL.LHU.PR` 的偏移来自寄存器，因此地址在运行时可变而编码固定不变。`SrcRType` 只改写 `SrcR` 的 `31:0` 位，因此同一条形式可服务于全宽、有符号 `32` 位或无符号 `32` 位偏移；而 `shamt=0` 是普通的按字节偏移，不是保留编码。

<!-- PTO-READER-BLOCK: scalar-hl-lhu-pr-inputs role=inputs-outputs -->
## 输入与目的

- `SrcL` 是地址基址，`SrcR` 是寄存器偏移；两者都使用完整的 Reg5 源域，其中编码 `0..23` 指定绝对 GPR，`24..27` 指定 `T#1..T#4`，`28..31` 指定 `U#1..U#4`。
- 读取 `T` 或 `U` 选择器不会消费或移动它所命名的队列；队列下标 `1..4` 只被当作源值使用。
- `SrcRType` 选择变换方式：编码 `0` 保持 `SrcR` 不变，编码 `1` 对 `SrcR[31:0]` 符号扩展，编码 `2` 对 `SrcR[31:0]` 零扩展。
- `shamt` 的 `0..31` 全部已定义，它是在修饰符之后施加的逻辑左移；编码零表示不移动。
- `Dst0` 接收加载值，`Dst1` 接收更新后的基址，因此 `Dst1` 收到的是地址而不是加载数据。
- 两个目的字段都使用完整的 Reg5 目的域：编码 `1..23` 写入绝对 GPR，编码 `30` 压入 U，编码 `31` 压入 T，而编码 `0` 与 `24..29` 只丢弃该结果，不抑制指令的其余部分。
- 每个显示的操数字段都是显式编码的，因此编码零是一个值，绝不表示省略。

<!-- PTO-READER-BLOCK: scalar-hl-lhu-pr-effects role=effects -->
## 效果与顺序

基址和偏移寄存器都在内存操作之前、任何目的写入之前读取。

成功的尝试记录一个 relaxed 加载事件，保持内存与保留状态不变，发布加载值，并把 `TPC` 前进 `6` 字节。

**设计要点：** `SrcR` 在目的写入之前完成变换，因此当目的与 `SrcR` 命名同一寄存器时，被变换的是指令执行前的值，而不是即将发布的值。一次访问使用的偏移在指令开始时就已经固定。

<!-- PTO-READER-BLOCK: scalar-hl-lhu-pr-constraints role=constraints -->
## 对齐、故障与重试

`SrcRType=3` 是保留值，会在读取任何源之前、任何架构效果之前引发 `Fault_IllegalInstruction`。

有效地址必须按 `2` 字节传送大小对齐。未对齐会在地址转换之前引发 `Fault_DataAlignment`；此后的转换或有界内存失败会在原始地址处引发 `Fault_DataPage`。

固定编码位不匹配、字段取保留值或选中的 `T` 或 `U` 源不可用，都会在任何指令效果之前引发 `Fault_IllegalInstruction`。

故障不会发出加载事件，也不会写入任何目的，它记录的地址就是出错的地址。恢复过程会重发整条指令：地址、源快照、每一次探测、加载以及每个目的都从头重新计算，不保留任何进度。

**设计要点：** 保留的 `SrcRType` 值在该形式解码时、读取偏移寄存器之前就被拒绝，因此即使编码的 `SrcR` 是合法选择器，非法编码也不会通过队列读取变得架构可见。

<!-- PTO-READER-BLOCK: scalar-hl-lhu-pr-example role=example -->
## 非规范地址示例

本示例说明当前的地址与发布规则，并不替代规范加载契约。

取 `SrcL=0x2000`、`SrcR=0x4`、`SrcRType=2`、`shamt=1` 时，`SrcR` 小于 `2^31`，零扩展不改变它，左移使其翻倍为 `0x8`，原始基址 `0x2000` 加该偏移得到 `0x2008`。

若该地址对齐且有访问权限，`Dst0` 收到加载值，`Dst1` 收到更新后的基址 `0x2008`，`TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lhu.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lhu_pr_48_f874b126e29c | HL48 | 48 | 0x00005009002e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lhu_pr_48_f874b126e29c | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lhu_pr_48_f874b126e29c | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lhu_pr_48_f874b126e29c | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lhu_pr_48_f874b126e29c | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lhu_pr_48_f874b126e29c | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lhu_pr_48_f874b126e29c | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lhu_pr_48_f874b126e29c | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhu_pr_48_f874b126e29c | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhu_pr_48_f874b126e29c | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lhu_pr_48_f874b126e29c | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lhu_pr_48_f874b126e29c | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lhu_pr_48_f874b126e29c | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lhu_pr_48_f874b126e29c.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHU.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LHU_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LHU_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHU.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LHU_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LHU_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LHU_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LHU_PR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LHU_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LHU_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LHU_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LHU_PR()
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
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lhu.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
