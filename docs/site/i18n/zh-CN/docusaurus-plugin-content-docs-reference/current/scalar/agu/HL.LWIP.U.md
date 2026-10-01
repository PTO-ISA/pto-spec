<!-- GENERATED FROM: asl/scalar/agu/HL.LWIP.U.asl -->
# HL.LWIP.U

**Normative ASL source:** `asl/scalar/agu/HL.LWIP.U.asl`

HL.LWIP.U snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LWIP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lwip-u-purpose role=purpose -->
## HL.LWIP.U 的作用

`HL.LWIP.U` 是一条独立的 `48` 位标量 AGU 加载指令。它用 `SrcL` 基址和经过缩放的立即数位移构成地址，加载两个相邻的对齐小端序 `4` 字节值；当结果窄于该宽度时，把传输位符号扩展到 `PTO_XLEN`。

它不执行地址基址回写，因此除内存之外，它改变的架构状态只有下面的目的选择子。

设计要点：该形式不对立即数移位，因此编码字段本身就是字节数；当且仅当被访问的地址不是 `4` 字节传输单元的整数倍时，本次访问未对齐。

<!-- PTO-READER-BLOCK: scalar-hl-lwip-u-mechanism role=mechanism -->
## HL.LWIP.U 如何构成地址并完成传输

位移由 `simm17` 提供。它从其 `17` 位符号扩展到 `PTO_XLEN`，所得结果与 `SrcL` 的值按 `2^PTO_XLEN` 取模相加。该和就是被访问的地址。`SrcL` 只读一次，因此整个地址都来自一个指令前的值。

两个相邻地址先完成预检：第一次探测覆盖算出的地址，它成功之后第二次探测覆盖该地址加 `4`。随后两次 4 字节加载按地址顺序执行，并记录两个宽松加载事件。

可执行路径用 `NormalizeScalarLoadResult` 规范化两个结果：该函数把每个 `4` 字节结果符号扩展，因为 `ScalarAGUSignedLoadOfForm` 对本形式返回 `TRUE`，因此加载数据的第 31 位会被复制到所有更高位，并按地址顺序先发布第一个、再发布第二个。不发布基址回写，因此 `SrcL` 保持其值。

设计要点：对位移做符号扩展，使一个编码就能访问基址两侧。代价是范围不对称：最大正字节位移为 `65535`，最负字节位移为 `-65536`。

<!-- PTO-READER-BLOCK: scalar-hl-lwip-u-inputs role=inputs-outputs -->
## 编码字段及其选择的对象

- `RegDst0` 是一个 `5` 位选择子，用来选择第一个加载值。

- `RegDst1` 是一个 `5` 位选择子，用来选择第二个加载值。

- `SrcL` 是一个 `5` 位选择子，用来选择地址基址。

- `simm17` 是一个 `17` 位有符号立即数；其字节位移就是该值本身。

编码 `1`..`23` 写入绝对 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 只丢弃该结果，编码 `24`..`29` 不写入任何位置。

`SrcL` 使用完整的 `Reg5` 源域：编码 `0`..`23` 选择绝对 GPR，编码 `24`..`27` 选择 `T#1`..`T#4`，编码 `28`..`31` 选择 `U#1`..`U#4`，且不会消耗它们。选择子 `0` 读取架构零 GPR。

设计要点：目的选择子为 `0` 时是丢弃结果，而不是取消整条指令，因此加载、其内存事件和`TPC` 前进都仍然发生。

<!-- PTO-READER-BLOCK: scalar-hl-lwip-u-effects role=effects -->
## 效果、快照与完成顺序

源在内存操作之前取快照，因此即使某个目的位置就是 `SrcL`，写入也只在两次加载都完成之后落地。

- 成功执行会记录两个按地址顺序排列的宽松加载事件，保持内存内容和保留状态不变，并且不回写任何基址。

- 在所有结果发布之后，`HL.LWIP.U` 把 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退役。

<!-- PTO-READER-BLOCK: scalar-hl-lwip-u-constraints role=constraints -->
## 合法性、故障与重启

故障按以下顺序产生：不可用的被选中 `T` 或 `U` 源在任何效果之前产生 `Fault_IllegalInstruction`；未对齐的地址在地址转换之前产生 `Fault_DataAlignment`；权限或受限内存范围失败在转换之后于原始地址产生 `Fault_DataPage`。

每个编码字段都有分配，因此没有需要拒绝的保留字段值；固定位不匹配会产生 `Fault_IllegalInstruction`。

被访问的地址就是不受约束的 `Reg5` 基址，因此对齐取决于该基址，而不是编码。

设计要点：对齐检查在地址转换之前进行，因此未对齐的访问不会改动转换状态后再报故障；`Fault_DataPage` 之后报告的是原始地址。

故障不会发出成功的内存事件，也不产生部分内存或目的位置效果，并把 `TPC` 留在故障指令处；重试会重算地址、预检、传输与发布。

<!-- PTO-READER-BLOCK: scalar-hl-lwip-u-example role=example -->
## 非规范阅读示例

本示例说明如何使用本页，不增加指令行为。

- 从规范汇编 `hl.lwip.u [SrcL, simm], ->Dst0, Dst1` 入手，识别基址选择子、立即数位移和目的选择子们。

- 在使用该形式做远距离访问之前，结合不经移位的编码读出 `17` 个编码位所能达到的字节位移。

- 然后把对齐规则、效果列表和下面的 ASL 契约与打算访问的地址对照检查。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lwip.u [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwip_u_48_c9aca369eab2 | HL48 | 48 | 0x00002029001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwip_u_48_c9aca369eab2 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwip_u_48_c9aca369eab2 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lwip_u_48_c9aca369eab2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lwip_u_48_c9aca369eab2 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lwip_u_48_c9aca369eab2 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwip_u_48_c9aca369eab2 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwip_u_48_c9aca369eab2 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lwip_u_48_c9aca369eab2 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LWIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_LWIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LWIP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LWIP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LWIP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LWIP_U()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LWIP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LWIP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LWIP_U()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LWIP_U()
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
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 4; the instruction performs no base writeback.
- After both 4-byte probes succeed, sign-extend each result at PTO_XLEN and publish first then second.
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

- hl.lwip.u [SrcL, simm], ->Dst0, Dst1
