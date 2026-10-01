<!-- GENERATED FROM: asl/scalar/agu/HL.LH.PCR.asl -->
# HL.LH.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LH.PCR.asl`

HL.LH.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LH-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: hl-lh-pcr-purpose role=purpose -->
## `HL.LH.PCR` 的作用

`HL.LH.PCR` 是一条独立编码的 48 位加载指令，其地址相对于当前指令位置而不是某个寄存器。它把一个 2 字节宽的值加载到一个目的。

<!-- PTO-READER-BLOCK: hl-lh-pcr-mechanism role=mechanism -->
## 地址与加载机制

基址是当前指令位置把 `1:0` 位清零后的值，因此即使指令从某个字的第二个半字开始，基址也按 `4` 字节对齐。

解码出的 `simm` 先符号扩展再乘以 `4`，然后按 `2^PTO_XLEN` 取模加到该基址上。

该 `2` 字节地址依次通过对齐检查与转换和权限检查之后，指令执行一次小端 `2` 字节加载，并记录一个 relaxed 加载事件。

不发生索引更新：该形式不写任何基址寄存器，也不为它的地址读取任何寄存器。

被访问地址处的字节成为结果的 `7:0` 位，后续字节填充更高的位，因此该值是小端序，指令会把加载值符号扩展到 `PTO_XLEN`，即保留低 `16` 位并把第 `15` 位复制到每个更高位。

**设计要点：** 在加上位移之前把指令位置的 `1:0` 位清零，使基址不取决于指令从哪个半字开始；因此把该指令放到不同的半字偏移处仍然到达同一目标。

<!-- PTO-READER-BLOCK: hl-lh-pcr-inputs role=inputs-outputs -->
## 输入与目的

- 地址基址是隐含的：`1:0` 位清零后的当前指令位置。该形式不编码基址寄存器，因此它的地址不读取任何标量寄存器。
- `simm` 覆盖从 `-268435456` 到 `268435455` 的全部有符号 29 位值，它的每个单位让地址移动 `4` 字节。
- `RegDst` 是唯一目的字段：编码 `1..23` 写入绝对 GPR，编码 `30` 压入 U，编码 `31` 压入 T，而编码 `0` 与 `24..29` 只丢弃加载值。
- 每个显示的操数字段都是显式编码的，因此编码零是一个值，绝不表示省略。

<!-- PTO-READER-BLOCK: hl-lh-pcr-effects role=effects -->
## 效果与顺序

当前指令位置在该次尝试开始时只读取一次，位移施加在该快照上；因此即使位置随后前进，引发故障的地址与被访问的地址仍是同一个地址。

成功的尝试记录一个 relaxed 加载事件，保持内存与保留状态不变，发布加载值，并把 `TPC` 前进 `6` 字节。

**设计要点：** 位置在该次尝试开始时被快照，因为同一次尝试随后会把 `TPC` 前进 `6` 字节。若在那次前进之后才形成地址，重发就会算出不同的目标。

<!-- PTO-READER-BLOCK: hl-lh-pcr-constraints role=constraints -->
## 对齐、故障与重试

有效地址必须按 `2` 字节传送大小对齐。未对齐会在地址转换之前引发 `Fault_DataAlignment`；此后的转换或有界内存失败会在原始地址处引发 `Fault_DataPage`。

固定编码位不匹配、字段取保留值或选中的 `T` 或 `U` 源不可用，都会在任何指令效果之前引发 `Fault_IllegalInstruction`。

故障不会发出加载事件，也不会写入任何目的，它记录的地址就是出错的地址。恢复过程会重发整条指令：地址、源快照、每一次探测、加载以及每个目的都从头重新计算，不保留任何进度。

**设计要点：** 对齐检查在地址转换之前执行，因此既未对齐又超出允许区域的访问报告 `Fault_DataAlignment`，而不是 `Fault_DataPage`。故障把出错地址保存为陷阱参数并把 `TPC` 重定向到陷阱入口，这正是处理程序能够在不保留任何进度的前提下重发该指令的原因。

<!-- PTO-READER-BLOCK: hl-lh-pcr-example role=example -->
## 非规范地址示例

本示例说明当前的地址与发布规则，并不替代规范加载契约。

若指令位置是 `0x1002`，清零 `1:0` 位得到基址 `0x1000`；若解码位移是 `3`，缩放后的值为 `12`，因此被访问地址是 `0x100c`。

若该地址对齐且有访问权限，结果会被发布，`TPC` 从 `0x1002` 前进 `6` 字节到 `0x1008`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lh.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lh_pcr_48_37df3cfe0d6e | HL48 | 48 | 0x00001039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lh_pcr_48_37df3cfe0d6e | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lh_pcr_48_37df3cfe0d6e | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lh_pcr_48_37df3cfe0d6e | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lh_pcr_48_37df3cfe0d6e | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LH.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LH_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LH.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LH_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LH_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LH_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LH_PCR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LH_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LH_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LH_PCR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LH_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
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

- hl.lh.pcr [<symbol>], ->{t, u, Rd}
