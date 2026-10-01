<!-- GENERATED FROM: asl/scalar/agu/HL.LBI.PR.asl -->
# HL.LBI.PR

**Normative ASL source:** `asl/scalar/agu/HL.LBI.PR.asl`

HL.LBI.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBI-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-purpose role=purpose -->
## `HL.LBI.PR` 做什么

`HL.LBI.PR` 是一条 `48` 位的前变址字节加载指令，使用有符号 `17` 位立即数位移。它把位移加到 `SrcL` 基址上，在该和处读取一个字节，把字节符号扩展到 `PTO_XLEN`，把字节发布到 `Dst0`，并把同一个和发布到 `Dst1`。

规范汇编形式是 `hl.lbi.pr [SrcL, simm], ->Dst0, Dst1`。

设计要点：前变址模式下这个和既是访问地址，也是发布到 `Dst1` 的值，并且只计算一次。`SrcL` 只被读取，因此任何故障都不会让基址寄存器处于半更新状态；重试会从同一个基址和同一个立即数重新算出完全相同的和。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-mechanism role=mechanism -->
## 地址与传输如何形成

位移是符号扩展后的 `17` 位立即数，缩放因子为 `1`。它按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上，该和用于访问。

`SrcL` 本身从不被本指令写入。更新后的基址只能通过 `Dst1` 到达寄存器文件、GPR 或队列。

编码检查与地址预检通过后，处理程序执行一次 `1` 字节小端序加载，对字节做符号扩展，并按 `Dst0` 在 `Dst1` 之前的顺序发布。

设计要点：立即数不做缩放，因此不是更宽访问大小倍数的立即数也能表达。对这条 `1` 字节形式来说没有对齐要求，但它意味着 `Dst1` 可能停在任何字节地址上，之后以该值作基址的更宽访问必须满足它自己的对齐规则。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，也是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `simm17` 是有符号 `17` 位立即数，覆盖 `-65536` 到 `65535`，缩放因子为 `1`。
- `Dst0` 收到符号扩展后的字节，`Dst1` 收到更新后的基址；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：这里没有位移寄存器，因此指令除 `SrcL` 外既不读取也不依赖任何寄存器。两个实例只要 `SrcL` 与立即数相同，就总会形成同一个地址，无论寄存器文件其余部分的内容是什么。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前取快照，因此 `SrcL` 与任一目的位置之间的别名使用指令执行前的值。

成功时记录一个 relaxed 的 `1` 字节加载事件，内存与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：字节在发布之前完成符号扩展，因此字节 `FF` 会以 `-1`（`64` 位全为 1）到达 `Dst0`。想要无符号读法的调用者可以改用同宽度的零扩展形式，也可以把扩展后的值屏蔽到低 `8` 位。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。该编码中不存在变换或移位字段，因此除编码固定位之外没有保留取值的拒绝路径。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式没有任何地址会引发 `Fault_DataAlignment`。权限与有界内存检查仍然适用，并在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会重新做立即数的符号扩展、求和与加载。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-pr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbi.pr [5, 16], ->6, 5`，GPR5 = `0x7002`。
- 立即数是 `16`，因此有效地址是 `0x7002` 加 `16`，即 `0x7012`。
- 若 `0x7012` 处的字节为 `7F`，GPR6 收到 `127`。
- GPR5 收到 `0x7012`，因为 `Dst1` 指定的就是基址寄存器；`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbi.pr [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbi_pr_48_b4bdbd29f859 | HL48 | 48 | 0x00000019002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbi_pr_48_b4bdbd29f859 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbi_pr_48_b4bdbd29f859 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_pr_48_b4bdbd29f859 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_pr_48_b4bdbd29f859 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbi_pr_48_b4bdbd29f859 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LBI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LBI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LBI_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBI_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBI_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBI_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBI_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBI_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBI_PR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBI_PR()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.lbi.pr [SrcL, simm], ->Dst0, Dst1
