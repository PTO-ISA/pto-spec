<!-- GENERATED FROM: asl/scalar/agu/HL.LDIP.U.asl -->
# HL.LDIP.U

**Normative ASL source:** `asl/scalar/agu/HL.LDIP.U.asl`

HL.LDIP.U snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 8-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LDIP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: hl-ldip-u-purpose role=purpose -->
## `HL.LDIP.U` 的作用

`HL.LDIP.U` 是一条独立编码的 48 位加载指令，它把一个立即数位移加到 `SrcL` 基址上。它把两个相邻的 8 字节宽的值加载到两个目的。

<!-- PTO-READER-BLOCK: hl-ldip-u-mechanism role=mechanism -->
## 地址与加载机制

解码出的 `simm17` 先符号扩展再按不缩放的方式使用，因此每个编码单位代表 `1` 字节的地址。

该位移按 `2^PTO_XLEN` 取模加到快照后的 `SrcL` 值上。

两个地址在任何一次加载之前都完成预检：第二个地址是第一个地址加 `8` 字节。只有两个探测都通过后，指令才读取两个小端值，并按地址顺序记录两个 relaxed 加载事件。

这里没有基址回写：`Dst0` 与 `Dst1` 都是加载值，`Dst1` 不是地址。

被访问地址处的字节成为结果的 `7:0` 位，后续字节填充更高的位，因此该值是小端序，指令会保留完整的 `64` 位加载位模式。

**设计要点：** `HL.LDIP.U` 按不缩放方式使用，把全部 17 个编码位都作为位移，因此可以指向距基址 `-65536` 到 `65535` 字节范围内的任意字节。编码的位移不是访问大小的倍数，所以只有当基址与位移之和是访问大小的倍数时，有效地址才是对齐的。

<!-- PTO-READER-BLOCK: hl-ldip-u-inputs role=inputs-outputs -->
## 输入与目的

- `SrcL` 是地址基址，使用完整的 Reg5 源域，其中编码 `0..23` 指定绝对 GPR，`24..27` 指定 `T#1..T#4`，`28..31` 指定 `U#1..U#4`。
- 读取 `T` 或 `U` 选择器不会消费或移动它所命名的队列；队列下标 `1..4` 只被当作源值使用。
- `simm17` 覆盖从 `-65536` 到 `65535` 的全部有符号 17 位值，编码出的字节位移是该值乘以 `1`。
- `Dst0` 接收从第一个地址加载的值，`Dst1` 接收从第二个地址加载的值；两者都是加载值目的，都不是基址回写。
- 两个目的字段都使用完整的 Reg5 目的域：编码 `1..23` 写入绝对 GPR，编码 `30` 压入 U，编码 `31` 压入 T，而编码 `0` 与 `24..29` 只丢弃该结果，不抑制指令的其余部分。
- 每个显示的操数字段都是显式编码的，因此编码零是一个值，绝不表示省略。

<!-- PTO-READER-BLOCK: hl-ldip-u-effects role=effects -->
## 效果与顺序

基址寄存器在内存操作之前、任何目的写入之前读取。

成功的尝试按地址顺序记录两个 relaxed 加载事件，保持内存与保留状态不变，发布两个加载值，并把 `TPC` 前进 `6` 字节。

**设计要点：** 两个值都建立在同一份基址快照上，因此即使某个目的与 `SrcL` 命名同一寄存器，第二个地址仍是第一个地址加访问大小。这一对操作总是读取两个相邻位置。

<!-- PTO-READER-BLOCK: hl-ldip-u-constraints role=constraints -->
## 对齐、故障与重试

有效地址必须按 `8` 字节传送大小对齐。未对齐会在地址转换之前引发 `Fault_DataAlignment`；此后的转换或有界内存失败会在原始地址处引发 `Fault_DataPage`。

固定编码位不匹配、字段取保留值或选中的 `T` 或 `U` 源不可用，都会在任何指令效果之前引发 `Fault_IllegalInstruction`。

故障不会发出加载事件，也不会写入任何目的，它记录的地址就是出错的地址。恢复过程会重发整条指令：地址、源快照、每一次探测、加载以及每个目的都从头重新计算，不保留任何进度。

**设计要点：** 两次探测都在提交任何一次加载之前完成，因此这一对操作不会出现一个目的已发布、另一个仍保持指令执行前值的情况；第二次探测上的故障因此也会让第一个结果一并作废。

<!-- PTO-READER-BLOCK: hl-ldip-u-example role=example -->
## 非规范地址示例

本示例说明当前的地址与发布规则，并不替代规范加载契约。

解码出的 `simm17` 为 `8` 时对应字节位移 `8`，因此取 `SrcL=0x1000` 时两次访问分别位于 `0x1008` 与 `0x1010`。

若两个地址都对齐且有访问权限，`Dst0` 收到第一个值，`Dst1` 收到第二个值，`TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldip.u [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldip_u_48_6813f4fdce5c | HL48 | 48 | 0x00003029001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldip_u_48_6813f4fdce5c | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldip_u_48_6813f4fdce5c | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ldip_u_48_6813f4fdce5c | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldip_u_48_6813f4fdce5c | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldip_u_48_6813f4fdce5c | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldip_u_48_6813f4fdce5c | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldip_u_48_6813f4fdce5c | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldip_u_48_6813f4fdce5c | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LDIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_LDIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LDIP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LDIP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LDIP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDIP_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDIP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LDIP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LDIP_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDIP_U()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 8; the instruction performs no base writeback.
- After both 8-byte probes succeed, preserve each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 8-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 8-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ldip.u [SrcL, simm], ->Dst0, Dst1
