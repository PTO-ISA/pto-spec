<!-- GENERATED FROM: asl/scalar/agu/HL.SB.PCR.asl -->
# HL.SB.PCR

**Normative ASL source:** `asl/scalar/agu/HL.SB.PCR.asl`

HL.SB.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SB-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-purpose role=purpose -->
## `HL.SB.PCR` 做什么

`HL.SB.PCR` 是一条独立的 `48` 位标量 AGU 指令，它把 `SrcL` 的低字节存储到 PC 相对位移处的一个 1 字节小端序单元。

规范汇编形式是 `hl.sb.pcr SrcL, [<symbol>]`。

设计要点：基址不是寄存器，而是该指令自身的对齐地址，这正是汇编写成 `[<symbol>]` 的原因。存储目标因此在链接时固定，运行期无法通过修改指针寄存器来改变它。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-mechanism role=mechanism -->
## 地址与传输如何形成

基址是指令地址清掉第 `1`: `0` 位，因此位移是从一个 4 字节对齐的指令地址量起，而不是从 `TPC` 的任意比特模式量起。

位移是符号扩展后的 `29` 位立即数左移 `2` 位，因此该编码字段以 4 字节单元计数，覆盖 `-268435456`..`268435455` 个单元，即 `-1073741824`..`1073741820` 字节。它按 `2^PTO_XLEN` 取模加到对齐基址上。

地址在存储之前被预检。成功时执行一次 1 字节小端序存储，并记录一个 relaxed 存储事件。

设计要点：清掉 `TPC[1:0]` 会把基址量化到 `4` 字节边界，而位移按 `4` 缩放，因此本形式能产生的每个地址都是 `4` 的倍数。基址仍然随指令移动，因此同一符号在不同位置的两处编码需要不同的编码位移。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-inputs role=inputs-outputs -->
## 编码字段与效果

- `SrcL` 是 `5` 位 Reg5 选择子，提供存储数据。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `simm` 是有符号 `29` 位位移，以 4 字节单元计，在编码中由三段承载，即第 `36`..`47` 位、第 `23`..`27` 位与第 `4`..`15` 位。
- 本形式没有 `RegDst` 字段，因此没有寄存器收到结果，也不发布更新后的基址。

设计要点：数据源是 `SrcL`，与其他 AGU 形式用作地址基址的字段同名。这里它是被存储的值，因为地址来自指令自身的位置而不是来自寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存影响之前被读取，因此被存储的值是该源的指令执行前的值，即使之后的指令会覆盖它。

执行成功恰好改变一个内存字节，即 `SrcL` 的低 `8` 位，按小端序排列。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

内存操作完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：保留是在存储这一动作内被清除的，而不是由后续步骤完成，因此在本指令之后立即读取保留状态的程序不可能看到过期的占用声明。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。

每个地址都是 1 字节单元的整数倍，因此预检不可能为本形式引发 `Fault_DataAlignment`。权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、基址、位移与预检。

设计要点：1 字节传输本身就是完整单元，因此本形式的对齐规则由构造满足。剩下唯一与地址相关的故障就是权限与有界内存检查。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pcr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 设该指令位于 `0x3002`，因此对齐基址是 `0x3000`，且 GPR5 = `0xABCD`。
- 取位移为 `-2` 个单元，即 `-8`，因此有效地址是 `0x2FF8`。
- 预检成功，字节 `0xCD` 被写入 `0x2FF8`；GPR5 的其他字节不属于本次传输。
- 没有寄存器改变，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sb.pcr SrcL, [<symbol>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sb_pcr_48_d0ba4b6e0f54 | HL48 | 48 | 0x00000069000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sb_pcr_48_d0ba4b6e0f54 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sb_pcr_48_d0ba4b6e0f54 | simm | 29 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":23,"value_lsb":12,"width":5},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sb_pcr_48_d0ba4b6e0f54 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sb_pcr_48_d0ba4b6e0f54 | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SB.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_SB_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_SB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SB.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_SB_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SB_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SB_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_SB_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SB_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SB_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SB_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SB_PCR()
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
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sb.pcr SrcL, [<symbol>]
