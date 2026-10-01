<!-- GENERATED FROM: asl/scalar/agu/HL.LBIP.asl -->
# HL.LBIP

**Normative ASL source:** `asl/scalar/agu/HL.LBIP.asl`

HL.LBIP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LBIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbip-purpose role=purpose -->
## `HL.LBIP` 做什么

`HL.LBIP` 是一条 `48` 位指令，加载一对相邻字节。它把有符号 `17` 位立即数加到 `SrcL` 基址上，读取该地址处以及该地址加 `1` 处的字节，把两者分别符号扩展到 `PTO_XLEN`，并把较低的字节发布到 `Dst0`、较高的字节发布到 `Dst1`。

规范汇编形式是 `hl.lbip [SrcL, simm], ->Dst0, Dst1`。

设计要点：这一对字节属于同一条指令、同一个故障边界。两个地址的探测都在读取任何一个字节之前完成，因此第二个地址发生故障时第一个字节不会被读取，也不会为它记录加载事件。不存在“一对中一个字节已被观察到、另一个没有”的状态。

<!-- PTO-READER-BLOCK: scalar-hl-lbip-mechanism role=mechanism -->
## 两个地址与传输如何形成

立即数被符号扩展，缩放因子为 `1`，按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。第二个地址是第一个地址加上访问大小，即 `1` 字节，因此这一对总是覆盖两个连续字节。

探测按地址升序进行，处理程序在第一个发生故障的探测处返回。只有当两个探测都成功时，才读取这两个字节，按地址顺序记录两个 relaxed 加载事件，并按 `Dst0` 在前、`Dst1` 在后的顺序发布结果。

设计要点：成对的步长是访问大小，而不是固定的偏移，因此更宽元素的一对之间会相隔该宽度。对这条 `1` 字节形式来说两个元素是相邻的，这正是它能在一条指令里读取一个两字节字段、而不需要第二种编码的原因。

<!-- PTO-READER-BLOCK: scalar-hl-lbip-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `simm17` 是有符号 `17` 位立即数，覆盖 `-65536` 到 `65535`，按 `1` 缩放；它定位这一对的第一个地址。
- `Dst0` 收到第一个地址处的字节，`Dst1` 收到第二个地址处的字节。编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该单个结果。

设计要点：两个目的位置相互独立，丢弃只抑制那一个字节的发布。指令仍然会探测并读取两个地址，因此被丢弃的结果并不会减少一半的内存工作。

<!-- PTO-READER-BLOCK: scalar-hl-lbip-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前被读取，因此指定基址的目的位置仍然为两个地址贡献指令执行前的值。

成功时按地址顺序记录两个 relaxed 的 `1` 字节加载事件，内存字节与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：两个事件都在任一目的位置写入之前记录，因此事件流的观察者会先看到完整的一对内存影响，然后才看到这条指令的寄存器影响。

<!-- PTO-READER-BLOCK: scalar-hl-lbip-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检对每个地址施加 `1` 字节对齐要求，两者都满足，因此本形式不会引发 `Fault_DataAlignment`。权限与有界内存检查仍可能失败：按升序测试时第一个失败的地址会在该原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个字节都不发布，`TPC` 停留在引发故障的指令上。恢复会从快照重新导出两个地址并重复两次探测。

<!-- PTO-READER-BLOCK: scalar-hl-lbip-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbip [4, 6], ->9, 10`，GPR4 = `0xD000`。立即数是 `6`，因此第一个地址是 `0xD006`，第二个是 `0xD007`。
- 该指令先探测 `0xD006`，再探测 `0xD007`。只有当两次探测都成功时，它才读取这两个字节。
- 若 `0xD006` 处的字节是 `7F`、`0xD007` 处的字节是 `80`，GPR9 收到 `127`，GPR10 收到 `-128`。
- GPR4 仍持有 `0xD000`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbip [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbip_48_70a5767aff16 | HL48 | 48 | 0x00000019001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbip_48_70a5767aff16 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbip_48_70a5767aff16 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbip_48_70a5767aff16 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbip_48_70a5767aff16 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbip_48_70a5767aff16 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbip_48_70a5767aff16 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbip_48_70a5767aff16 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbip_48_70a5767aff16 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LBIP() => ScalarOperation
begin
    return ScalarOperation_HL_LBIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LBIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LBIP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LBIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBIP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBIP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBIP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBIP()
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

- hl.lbip [SrcL, simm], ->Dst0, Dst1
