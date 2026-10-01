<!-- GENERATED FROM: asl/scalar/agu/HL.LB.PR.asl -->
# HL.LB.PR

**Normative ASL source:** `asl/scalar/agu/HL.LB.PR.asl`

HL.LB.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LB-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-purpose role=purpose -->
## `HL.LB.PR` 做什么

`HL.LB.PR` 是一条 `48` 位的前变址字节加载指令。它用 `SrcR` 与 `shamt` 构造位移，把它加到 `SrcL` 基址上，在该和处读取一个字节，把字节符号扩展到 `PTO_XLEN`，并把加载值发布到 `Dst0`、把同一个和发布到 `Dst1`。

规范汇编形式是 `hl.lb.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`。

设计要点：访问所用的地址与发布到 `Dst1` 的值是同一个量，只计算一次。因此前变址并不意味着“在旧基址读取、发布新基址”，而是“在新基址读取并发布”。该地址发生故障时不发布任何内容，所以重新执行会从未被改动的 `SrcL` 重新算出完全相同的地址，而不会前进两次。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-mechanism role=mechanism -->
## 位移与地址如何形成

先按 `SrcRType` 变换 `SrcR`，再左移编码字段 `shamt` 位；得到的位移按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。

这个和就是有效地址。`SrcL` 本身从不被写入，因此前变址更新只能通过 `Dst1` 到达寄存器文件。

编码检查与地址预检通过后，处理程序执行一次 `1` 字节小端序加载，对第 `7` 位做符号扩展，用加载值发布 `Dst0`，再用更新后的基址发布 `Dst1`。

设计要点：由于基址只从 `SrcL` 读取、更新值送到独立的目的位置，本形式不会因故障丢失更新。访问依赖那个和，但基址寄存器本身从不前进，因此故障后重新执行会从未被改动的 `SrcL` 重新算出同一个和，而不会把指针移动两次。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，`SrcR` 是位移来源；两者都是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `SrcRType` 变换位移：`0` 不变，`1` 对 `SrcR[31:0]` 做符号扩展，`2` 对 `SrcR[31:0]` 做零扩展，`3` 被保留。
- `shamt` 是变换之后施加的 `5` 位左移量。
- `Dst0` 收到符号扩展后的字节，`Dst1` 收到更新后的基址；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 丢弃该单个结果。

设计要点：若 `Dst1` 指定 `SrcR`，位移仍然来自指令执行前的 `SrcR`，因为两个源都在任何发布之前被读取。`Dst1` 指定 `SrcL` 时同样如此，而这正是常见的指针推进写法：旧基址被读取用于求和，新基址随后取代它。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-effects role=effects -->
## 影响、顺序与完成

`SrcL` 与 `SrcR` 的读取先于一切内存与目的位置影响，因此别名看到的是指令执行前的值。

执行成功时记录一个 relaxed 的 `1` 字节加载事件，内存与保留状态保持不变。`Dst0` 在 `Dst1` 之前写入，因此共享的目的寄存器最终保存更新后的基址。

两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：加载值与更新后的基址按固定顺序发布，而不是同时发布，这使别名情形是已定义的而非未规定的。该顺序没有反向的选项。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcRType` 为 `3` 会在同一点被形式约束拒绝且不读取任何源。`SrcL` 或 `SrcR` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式不会引发 `Fault_DataAlignment`。翻译与权限检查仍可能失败，并在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个目的位置都不发布，`TPC` 停留在引发故障的指令上。恢复会用同一组快照重新计算变换、移位、求和与加载。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lb.pr [8, 9<<<4], ->10, 8`，`SrcRType` 选择零扩展变换，GPR8 = `0x9000`，GPR9 = `3`。
- 变换对 `SrcR[31:0]`（即 `3`）做零扩展，左移 `4` 位得到位移 `48`。
- 有效地址是 `0x9000` 加 `48`，即 `0x9030`。该处的字节被符号扩展进 GPR10，GPR8 收到同样的 `0x9030`，因为 `Dst1` 指定的就是基址寄存器。
- GPR9 仍持有 `3`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lb.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lb_pr_48_cf73675cad50 | HL48 | 48 | 0x00000009002e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lb_pr_48_cf73675cad50 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lb_pr_48_cf73675cad50 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lb_pr_48_cf73675cad50 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lb_pr_48_cf73675cad50 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lb_pr_48_cf73675cad50 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lb_pr_48_cf73675cad50 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lb_pr_48_cf73675cad50 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_pr_48_cf73675cad50 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_pr_48_cf73675cad50 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lb_pr_48_cf73675cad50 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lb_pr_48_cf73675cad50 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lb_pr_48_cf73675cad50 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lb_pr_48_cf73675cad50.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LB.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LB_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LB_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LB.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LB_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LB_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LB_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LB_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LB_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LB_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LB_PR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LB_PR()
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
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
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

- hl.lb.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
