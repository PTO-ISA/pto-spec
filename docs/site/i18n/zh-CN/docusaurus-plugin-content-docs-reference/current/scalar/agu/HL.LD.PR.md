<!-- GENERATED FROM: asl/scalar/agu/HL.LD.PR.asl -->
# HL.LD.PR

**Normative ASL source:** `asl/scalar/agu/HL.LD.PR.asl`

HL.LD.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LD-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-purpose role=purpose -->
## `HL.LD.PR` 做什么

`HL.LD.PR` 是一条 `48` 位的前变址加载指令，读取一个小端序 `8` 字节值。它用 `SrcR` 与 `shamt` 构造位移，加到 `SrcL` 基址上，在该和处读取八个字节，把 `64` 位模式发布到 `Dst0`，并把同一个和发布到 `Dst1`。

规范汇编形式是 `hl.ld.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`。

设计要点：有效地址包含位移，因此决定访问是否合法的是这个和的对齐。`8` 字节对齐的基址配上 `8` 的倍数步长会让每次访问都保持对齐；步长为 `4` 则会产生交替模式，其中一半的迭代会在翻译之前引发 `Fault_DataAlignment`。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-mechanism role=mechanism -->
## 位移与地址如何形成

`SrcR` 经 `SrcRType` 变换后左移编码字段 `shamt` 位。和 `SrcL + offset` 按 `2^PTO_XLEN` 取模，既作为访问地址，也作为 `Dst1` 的值。

`SrcL` 从不被写入，因此被发布的基址变更只能通过 `Dst1` 到达寄存器文件。

编码检查与地址预检通过后，处理程序执行一次 `8` 字节小端序加载，把字节原样发布到 `Dst0`，随后把更新后的基址发布到 `Dst1`。

设计要点：对齐的基址寄存器可以被位移修好，因为预检检查的是那个和。基址 `0x5004` 配位移 `4` 产生 `8` 字节对齐的地址 `0x5008` 并被接受；同一个基址配位移 `2` 产生 `0x5006`，则引发对齐故障。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，`SrcR` 是位移来源，两者都是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `SrcRType` 为 `0` 表示不变，`1` 表示对 `SrcR[31:0]` 施加 `.sw`，`2` 表示对 `SrcR[31:0]` 施加 `.uw`；`3` 被保留。
- `shamt` 是变换之后施加的 `5` 位左移量。当不变的 `SrcR` 为 `1` 时，`shamt` 取 `3` 得到步长 `8`，对任何 `8` 字节对齐的基址都能保持 `8` 字节对齐。
- `Dst0` 收到加载到的模式，`Dst1` 收到更新后的基址；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：`Dst1` 是普通目的位置，因此更新后的基址可以被压入 `T` 或 `U` 队列，而不写入寄存器。该压入会像任何其他队列压入目的位置一样，把较旧的队列条目整体挪动。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-effects role=effects -->
## 影响、顺序与完成

两个源都在任何内存或目的位置影响之前被读取，因此 `SrcR`、`SrcL` 与两个目的位置之间的别名看到的是指令执行前的值。`Dst0` 在 `Dst1` 之前发布。

成功时记录一个 relaxed 的 `8` 字节加载事件，内存字节与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节，被拒绝或发生故障的尝试不会退休。

设计要点：当两个目的位置指定同一个寄存器时，写入顺序很关键：加载到的字节会在同一条指令内被更新后的基址取代。因此这条指令无法用一个寄存器同时取得两个结果。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcRType` 为 `3` 会在读取任何源之前被形式约束拒绝；`SrcL` 或 `SrcR` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检检查有效地址的低 `3` 位——在这里就是那个和——并在翻译之前、权限检查之前引发 `Fault_DataAlignment`。之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个目的位置都不发布，`TPC` 停留在引发故障的指令上。恢复会重新计算变换、移位、求和与加载；由于 `SrcL` 从未被改动，重试从同一个基址开始。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.ld.pr [9, 10<<<2], ->11, 9`，`SrcRType` 选择不变变换，GPR9 = `0x5004`，GPR10 = `1`。
- 位移是 `1` 左移 `2` 位，即 `4`。有效地址是 `0x5004` 加 `4`，即 `0x5008`，它是 `8` 字节对齐的。
- GPR11 收到 `0x5008` 至 `0x500F` 的 `8` 字节，GPR9 收到 `0x5008`，因为 `Dst1` 指定的就是基址寄存器。
- 若移位量为 `1`，地址将是 `0x5006`，指令会在翻译之前引发 `Fault_DataAlignment`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ld.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ld_pr_48_7ec4111b123b | HL48 | 48 | 0x00003009002e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ld_pr_48_7ec4111b123b | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ld_pr_48_7ec4111b123b | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ld_pr_48_7ec4111b123b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ld_pr_48_7ec4111b123b | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ld_pr_48_7ec4111b123b | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_ld_pr_48_7ec4111b123b | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ld_pr_48_7ec4111b123b | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_pr_48_7ec4111b123b | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_pr_48_7ec4111b123b | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ld_pr_48_7ec4111b123b | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_ld_pr_48_7ec4111b123b | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_ld_pr_48_7ec4111b123b | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_ld_pr_48_7ec4111b123b.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LD.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LD_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LD_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LD.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LD_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LD_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LD_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LD_PR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LD_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LD_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LD_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LD_PR()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
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

- hl.ld.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
