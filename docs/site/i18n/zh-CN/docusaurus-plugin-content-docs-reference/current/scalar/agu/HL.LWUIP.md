<!-- GENERATED FROM: asl/scalar/agu/HL.LWUIP.asl -->
# HL.LWUIP

**Normative ASL source:** `asl/scalar/agu/HL.LWUIP.asl`

HL.LWUIP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LWUIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lwuip-purpose role=purpose -->
## `HL.LWUIP` 做什么

`HL.LWUIP` 是一条独立的 `48` 位标量 AGU 指令，它通过立即数位移加载两个相邻的 4 字节小端序值，并把每个值零扩展到 `PTO_XLEN`。

规范汇编形式是 `hl.lwuip [SrcL, simm], ->Dst0, Dst1`。

设计要点：第二个地址不被编码。处理程序把它算作第一个地址加上传输宽度，因此成对形式只能是两个同宽度的相邻单元。想要两个相隔八字节的值，程序必须发两条单独的加载，而不能用一条成对形式。

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-mechanism role=mechanism -->
## 地址与传输如何形成

位移是符号扩展后的 `simm17` 左移 `2` 位，因此该编码字段以 4 字节单元计数，覆盖 `-65536` 到 `65535` 个单元，即 `-262144` 到 `262140` 字节。它按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。

这个和就是第一个地址；第二个地址是这个和加 `4`。更新模式为无，因此本形式不会把任何字节回写到基址寄存器。

两个地址都在任何内存读取开始之前被预检。只有当两个预检都成功之后，处理程序才读取这两个对齐单元、记录事件并发布这两个结果。

设计要点：先预检整个成对范围，才使本形式成为全有或全无。第二个单元的访问故障在第一个单元被读取之前就被引发，因此不可能观察到成对范围只加载了一半。

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-inputs role=inputs-outputs -->
## 编码字段与结果

- `SrcL` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `simm17` 是有符号 `17` 位位移，分两段编码承载，即第 `36`..`47` 位与第 `6`..`10` 位，缩放因子为 `4`。
- `RegDst0` 与 `RegDst1` 是 `5` 位选择子。编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃对应的那一个结果。

设计要点：`RegDst0` 是第一个、地址较低的那个单元，`RegDst1` 是第二个。两个字段彼此独立，因此可以丢弃第一个值而保留第二个，而被丢弃的加载仍然发生，也仍然会引发它的故障。

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-effects role=effects -->
## 影响、顺序与完成

所有标量源都在任何内存或目的位置影响之前取快照，因此指定 `SrcL` 的目的位置仍然为地址贡献指令执行前的基址。

执行成功时按先第一、后第二的顺序记录两个 relaxed 加载事件。内存字节与保留状态保持不变，因为加载既不写内存也不打扰保留。

两个结果都发布之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：两个结果只在最后一步发布，因此在此之前任何位置发生故障，两个目的位置都仍持有指令执行前的值。

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`；这些检查在源被读取之前运行。

未按 `4` 字节对齐的地址会在翻译或权限检查之前引发 `Fault_DataAlignment`。之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不写入目的位置，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、两个地址、两个预检与两次加载。

<!-- PTO-READER-BLOCK: scalar-hl-lwuip-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lwuip [5, -2], ->8, 9`，GPR5 = `0x2000`。立即数是 `-2`，因此字节位移是 `-8`，第一个地址是 `0x1FF8`。
- 第二个地址是 `0x1FF8` 加 `4`，即 `0x1FFC`。两者都按 `4` 字节对齐，因此两个预检都通过。
- 第一个单元送到 GPR8，第二个送到 GPR9；每个结果都零扩展到 `PTO_XLEN`。
- GPR5 仍持有 `0x2000`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lwuip [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwuip_48_2a5d6d8f3b70 | HL48 | 48 | 0x00006019001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwuip_48_2a5d6d8f3b70 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwuip_48_2a5d6d8f3b70 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lwuip_48_2a5d6d8f3b70 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lwuip_48_2a5d6d8f3b70 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lwuip_48_2a5d6d8f3b70 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwuip_48_2a5d6d8f3b70 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwuip_48_2a5d6d8f3b70 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lwuip_48_2a5d6d8f3b70 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWUIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LWUIP() => ScalarOperation
begin
    return ScalarOperation_HL_LWUIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWUIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LWUIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LWUIP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LWUIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LWUIP()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LWUIP()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LWUIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LWUIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LWUIP()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 4; the instruction performs no base writeback.
- After both 4-byte probes succeed, zero-extend each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 4-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 4-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lwuip [SrcL, simm], ->Dst0, Dst1
