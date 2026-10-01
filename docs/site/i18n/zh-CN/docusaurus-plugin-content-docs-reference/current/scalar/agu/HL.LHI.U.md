<!-- GENERATED FROM: asl/scalar/agu/HL.LHI.U.asl -->
# HL.LHI.U

**Normative ASL source:** `asl/scalar/agu/HL.LHI.U.asl`

HL.LHI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LHI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lhi-u-purpose role=purpose -->
## `HL.LHI.U` 的作用

`HL.LHI.U` 是一条独立编码的 48 位加载指令，它把一个立即数位移加到 `SrcL` 基址上。它把一个 2 字节宽的值加载到一个目的。

<!-- PTO-READER-BLOCK: scalar-hl-lhi-u-mechanism role=mechanism -->
## 地址与加载机制

解码出的 `simm22` 先符号扩展再按不缩放的方式使用，因此每个编码单位代表 `1` 字节的地址。

该位移按 `2^PTO_XLEN` 取模加到快照后的 `SrcL` 值上。

该 `2` 字节地址依次通过对齐检查与转换和权限检查之后，指令执行一次小端 `2` 字节加载，并记录一个 relaxed 加载事件。

不发生索引更新：`SrcL` 只为形成地址读取一次，之后保持不变。

被访问地址处的字节成为结果的 `7:0` 位，后续字节填充更高的位，因此该值是小端序，指令会把加载值符号扩展到 `PTO_XLEN`，即保留低 `16` 位并把第 `15` 位复制到每个更高位。

**设计要点：** `HL.LHI.U` 按不缩放方式使用，把全部 22 个编码位都作为位移，因此可以指向距基址 `-2097152` 到 `2097151` 字节范围内的任意字节。编码的位移不是访问大小的倍数，所以只有当基址与位移之和是访问大小的倍数时，有效地址才是对齐的。

<!-- PTO-READER-BLOCK: scalar-hl-lhi-u-inputs role=inputs-outputs -->
## 输入与目的

- `SrcL` 是地址基址，使用完整的 Reg5 源域，其中编码 `0..23` 指定绝对 GPR，`24..27` 指定 `T#1..T#4`，`28..31` 指定 `U#1..U#4`。
- 读取 `T` 或 `U` 选择器不会消费或移动它所命名的队列；队列下标 `1..4` 只被当作源值使用。
- `simm22` 覆盖从 `-2097152` 到 `2097151` 的全部有符号 22 位值，编码出的字节位移是该值乘以 `1`。
- `RegDst` 是唯一目的字段：编码 `1..23` 写入绝对 GPR，编码 `30` 压入 U，编码 `31` 压入 T，而编码 `0` 与 `24..29` 只丢弃加载值。
- 每个显示的操数字段都是显式编码的，因此编码零是一个值，绝不表示省略。

<!-- PTO-READER-BLOCK: scalar-hl-lhi-u-effects role=effects -->
## 效果与顺序

基址寄存器在内存操作之前、任何目的写入之前读取。

成功的尝试记录一个 relaxed 加载事件，保持内存与保留状态不变，发布加载值，并把 `TPC` 前进 `6` 字节。

**设计要点：** 基址在目的写入之前快照，因此在 `SrcL` 与 `RegDst` 上命名同一寄存器时，加载使用的是指令执行前的值，之后该寄存器被覆盖。同一个寄存器因此可以既作指针又作结果。

<!-- PTO-READER-BLOCK: scalar-hl-lhi-u-constraints role=constraints -->
## 对齐、故障与重试

有效地址必须按 `2` 字节传送大小对齐。未对齐会在地址转换之前引发 `Fault_DataAlignment`；此后的转换或有界内存失败会在原始地址处引发 `Fault_DataPage`。

固定编码位不匹配、字段取保留值或选中的 `T` 或 `U` 源不可用，都会在任何指令效果之前引发 `Fault_IllegalInstruction`。

故障不会发出加载事件，也不会写入任何目的，它记录的地址就是出错的地址。恢复过程会重发整条指令：地址、源快照、每一次探测、加载以及每个目的都从头重新计算，不保留任何进度。

**设计要点：** 对齐检查在地址转换之前执行，因此既未对齐又超出允许区域的访问报告 `Fault_DataAlignment`，而不是 `Fault_DataPage`。故障把出错地址保存为陷阱参数并把 `TPC` 重定向到陷阱入口，这正是处理程序能够在不保留任何进度的前提下重发该指令的原因。

<!-- PTO-READER-BLOCK: scalar-hl-lhi-u-example role=example -->
## 非规范地址示例

本示例说明当前的地址与发布规则，并不替代规范加载契约。

取 `SrcL=0x100`、解码出的 `simm22` 为 `2` 时，字节位移是 `2`，因此被访问地址是 `0x102`。

若该地址对齐且有访问权限，从该处开始的 `2` 字节会被发布，`TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lhi.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lhi_u_48_4d4b89e63c98 | HL48 | 48 | 0x00001029000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lhi_u_48_4d4b89e63c98 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lhi_u_48_4d4b89e63c98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lhi_u_48_4d4b89e63c98 | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lhi_u_48_4d4b89e63c98 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhi_u_48_4d4b89e63c98 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lhi_u_48_4d4b89e63c98 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LHI_U() => ScalarOperation
begin
    return ScalarOperation_HL_LHI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LHI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LHI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LHI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LHI_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LHI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LHI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LHI_U()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LHI_U()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 2-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lhi.u [SrcL, simm], ->{t, u, Rd}
