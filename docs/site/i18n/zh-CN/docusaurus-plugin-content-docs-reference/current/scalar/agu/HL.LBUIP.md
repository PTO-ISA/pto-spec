<!-- GENERATED FROM: asl/scalar/agu/HL.LBUIP.asl -->
# HL.LBUIP

**Normative ASL source:** `asl/scalar/agu/HL.LBUIP.asl`

HL.LBUIP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LBUIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbuip-purpose role=purpose -->
## `HL.LBUIP` 做什么

`HL.LBUIP` 是一条 `48` 位指令，加载一对相邻字节并返回零扩展结果。它把有符号 `17` 位立即数加到 `SrcL` 基址上，读取该地址处的字节以及该地址加 `1` 处的字节，清零每个结果中第 `7` 位以上的一切，并把较低的字节发布到 `Dst0`、较高的字节发布到 `Dst1`。

规范汇编形式是 `hl.lbuip [SrcL, simm], ->Dst0, Dst1`。

设计要点：两个结果都是无符号的，因此字节对 `FF FF` 会变成 `Dst0` 中的 `255` 和 `Dst1` 中的 `255`。两个目的位置由同一条规则填充；本形式无法让一个字节按有符号发布而另一个按无符号发布。

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-mechanism role=mechanism -->
## 两个地址与传输如何形成

立即数被符号扩展，缩放因子为 `1`，按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。第二个地址是第一个地址加 `1`，因为访问大小是一个字节。

两个地址都在读取任何一个字节之前按升序被探测。处理程序在第一个故障处返回。当两次探测都成功时，它读取这两个字节，按地址顺序记录两个 relaxed 加载事件，对两个值做零扩展，并按 `Dst0` 然后 `Dst1` 的顺序发布。

设计要点：两个目的字段可以指定同一个寄存器或同一个队列。此时写入顺序决定结果：第二个字节取代第一个，因此存活下来的是较高地址处的字节。没有任何编码能颠倒这个顺序。

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`；队列源被读取时不会被消耗。
- `simm17` 是有符号 `17` 位立即数，覆盖 `-65536` 到 `65535`，缩放因子为 `1`。
- `Dst0` 收到较低的字节，`Dst1` 收到较高的字节。编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：两个结果都可以各自使用队列压入目的位置，而每次压入都会把较旧的队列条目整体挪动一个槽位。因此同时压入两个结果的成对加载会让 `T` 队列前进两次，第二次压入成为最新的条目。

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前取快照，因此基址与任一目的位置之间的别名使用指令执行前的值。

执行成功时按地址顺序记录两个 relaxed 的 `1` 字节加载事件，内存字节与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：本形式没有基址回写，因此两个目的位置是它对寄存器或队列仅有的架构影响；发生故障时连这些都不会被触及。

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检对两个地址施加 `1` 字节对齐要求，因此两者都不会引发 `Fault_DataAlignment`。权限与有界内存检查按升序作用于每个地址，第一个失败会在该原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个字节都不发布，`TPC` 停留在引发故障的指令上。恢复会从同一个 `SrcL` 重新计算两个地址与两次探测。

<!-- PTO-READER-BLOCK: scalar-hl-lbuip-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbuip [4, 6], ->9, 0`，GPR4 = `0xD000`。立即数是 `6`，因此第一个地址是 `0xD006`，第二个是 `0xD007`。
- `Dst0` 指定 GPR9，`Dst1` 是丢弃编码 `0`，因此只有第一个字节被发布。
- 若 `0xD006` 处的字节是 `FF`，GPR9 收到 `255`，第 `63`:`8` 位全为零。
- `0xD007` 处的字节仍然被读取，其加载事件仍然被记录；被丢弃的只是它的发布。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbuip [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbuip_48_ad419fc474c0 | HL48 | 48 | 0x00004019001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbuip_48_ad419fc474c0 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbuip_48_ad419fc474c0 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbuip_48_ad419fc474c0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbuip_48_ad419fc474c0 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbuip_48_ad419fc474c0 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbuip_48_ad419fc474c0 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbuip_48_ad419fc474c0 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbuip_48_ad419fc474c0 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUIP() => ScalarOperation
begin
    return ScalarOperation_HL_LBUIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LBUIP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LBUIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUIP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUIP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUIP()
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

- hl.lbuip [SrcL, simm], ->Dst0, Dst1
