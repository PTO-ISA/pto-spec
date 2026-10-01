<!-- GENERATED FROM: asl/scalar/agu/HL.LBU.PR.asl -->
# HL.LBU.PR

**Normative ASL source:** `asl/scalar/agu/HL.LBU.PR.asl`

HL.LBU.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBU-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-purpose role=purpose -->
## `HL.LBU.PR` 做什么

`HL.LBU.PR` 是一条 `48` 位的前变址字节加载指令，采用零扩展。它用 `SrcR` 与 `shamt` 构造位移，加到 `SrcL` 上，在该和处读取一个字节，对字节做零扩展，并把字节发布到 `Dst0`、把该和发布到 `Dst1`。

规范汇编形式是 `hl.lbu.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`。

设计要点：和是按 `2^PTO_XLEN` 取模形成的，因此越过地址空间顶端的位移会回绕到低地址，而不是被拒绝。回绕本身不引发任何故障；回绕后的地址随后接受与其他地址相同的预检，因此回绕到允许区域之外会表现为 `Fault_DataPage`，而不是一种单独的溢出故障。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-mechanism role=mechanism -->
## 位移与地址如何形成

`SrcR` 经 `SrcRType` 变换，左移编码字段 `shamt` 位，再加到 `SrcL` 的快照上。这个和既是访问地址，也是发布到 `Dst1` 的值。

`SrcL` 只被读取；无论成功路径还是故障路径，基址寄存器都保持其值。

编码检查与地址预检通过后，执行一次 `1` 字节小端序加载，把字节零扩展到字宽，并按 `Dst0` 然后 `Dst1` 的顺序发布两个目的位置。

设计要点：移位量是 `5` 位字段，因此位移最多跨越 `2^31` 倍。配合只保留 `SrcR[31:0]` 的 `.uw` 变换，该路径能产生的最大正位移是 `0x7FFFFFFF80000000`，在 `shamt` 为 `31` 且 `SrcR[31:0]` 等于 `0xFFFFFFFF` 时取得。更大的步长只能通过改变基址来构造。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，`SrcR` 是位移来源，两者都是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `SrcRType` 为 `0` 表示不变，`1` 表示 `.sw`，`2` 表示对 `SrcR[31:0]` 施加 `.uw`；`3` 被保留。
- `shamt` 是变换之后施加的 `5` 位左移量。
- `Dst0` 收到零扩展后的字节，`Dst1` 收到更新后的基址；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：位移不可能来自立即数；本形式总是从寄存器取值。因此编译期常量步长需要一个寄存器来保存它，而且该寄存器必须在整个循环中保持有效，因为编码的是移位量而不是位移本身。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-effects role=effects -->
## 影响、顺序与完成

两个源都在任何内存或目的位置影响之前取快照，因此 `SrcR`、`SrcL` 与目的位置之间的别名使用指令执行前的值。

成功时记录一个 relaxed 的 `1` 字节加载事件，内存与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：由于 `Dst1` 在 `Dst0` 之后写入，用一个寄存器承载两个结果时它最终保存的是更新后的基址。这是写入顺序带来的已定义结果，而不是冲突，因此指针推进可以与一个已知会被取代的加载值组合使用。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcRType` 为 `3` 会在读取任何源之前被形式约束拒绝；`SrcL` 或 `SrcR` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式没有任何地址会引发 `Fault_DataAlignment`。翻译与权限检查仍可能失败，并在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会从快照重建变换、移位、求和与加载，不保留任何进度。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbu.pr [15, 16<<<31], ->17, 15`，`SrcRType` 选择 `.uw`，GPR15 = `0x1000`，GPR16 = `1`。
- 变换对 `SrcR[31:0]`（即 `1`）做零扩展，左移 `31` 位得到位移 `0x80000000`，即 `2147483648`。
- 有效地址是 `0x1000` 加 `0x80000000`，即 `0x80001000`。该处的字节被零扩展进 GPR17，GPR15 收到 `0x80001000`，因为 `Dst1` 指定的就是基址寄存器。
- GPR16 仍持有 `1`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbu.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbu_pr_48_bf9a0ea4b0db | HL48 | 48 | 0x00004009002e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbu_pr_48_bf9a0ea4b0db | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbu_pr_48_bf9a0ea4b0db | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lbu_pr_48_bf9a0ea4b0db | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbu_pr_48_bf9a0ea4b0db | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_pr_48_bf9a0ea4b0db | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lbu_pr_48_bf9a0ea4b0db | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lbu_pr_48_bf9a0ea4b0db | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lbu_pr_48_bf9a0ea4b0db.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBU.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LBU_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LBU_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBU.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LBU_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBU_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBU_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LBU_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBU_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBU_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBU_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBU_PR()
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

- hl.lbu.pr [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
