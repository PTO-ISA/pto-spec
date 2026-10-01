<!-- GENERATED FROM: asl/scalar/agu/HL.LWUP.asl -->
# HL.LWUP

**Normative ASL source:** `asl/scalar/agu/HL.LWUP.asl`

HL.LWUP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LWUP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lwup-purpose role=purpose -->
## `HL.LWUP` 做什么

`HL.LWUP` 是一条独立的 `48` 位标量 AGU 指令，它通过寄存器偏移加载两个相邻的 4 字节小端序值，并把每个值零扩展到 `PTO_XLEN`。

规范汇编形式是 `hl.lwup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`。

设计要点：偏移来自 `SrcR`，基址来自 `SrcL`，因此一次遍历可以把流指针与移动索引放在两个不同的寄存器里。基址是一个地址；偏移寄存器是一个距离，可以当作计数复用。

设计要点：第二个地址不被编码。处理程序把它算作第一个地址加上传输宽度，因此成对形式总是两个相邻的 4 字节单元。想要两个相隔 8 字节的值，需要两条单独的加载。

<!-- PTO-READER-BLOCK: scalar-hl-lwup-mechanism role=mechanism -->
## 地址与传输如何形成

`SrcRType` 先变换 `SrcR` 的快照，随后 `shamt` 移位该结果，移位后的值按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。

这个和就是第一个地址，这个和加 `4` 就是第二个地址。更新模式为无，因此本形式不会回写任何基址寄存器。

两个地址都在任何内存读取开始之前被预检。只有当两个预检都报告无故障时，处理程序才读取这两个对齐的 4 字节单元、记录两个事件并发布两个结果。

设计要点：先预检整个成对范围，才使本形式成为全有或全无。第二个单元的访问故障在第一个单元被读取之前就引发，因此不可能观察到成对范围只加载了一半。

<!-- PTO-READER-BLOCK: scalar-hl-lwup-inputs role=inputs-outputs -->
## 编码字段与结果

- `SrcL` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 使用同样的 `5` 位 Reg5 域，因此偏移也可以来自队列槽位或零 GPR。
- `SrcRType` 是 `2` 位：`00` 保持整个 `SrcR` 值不变，`01` 与 `10` 分别用其低 `32` 位的有符号与无符号读法替换它，`11` 为保留值。
- `shamt` 是变换之后施加的 `5` 位无符号移位量；编码零表示不移位。
- `RegDst0` 与 `RegDst1` 是 `5` 位选择子。编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃对应的那一个结果。

设计要点：`RegDst0` 接收地址较低的那个单元，`RegDst1` 接收较高的那个，两个字段彼此独立，因此被丢弃的加载仍然发生，也仍然会引发它自己的故障。

<!-- PTO-READER-BLOCK: scalar-hl-lwup-effects role=effects -->
## 影响、顺序与完成

所有标量源都在任何内存或目的位置影响之前取快照，因此指定 `SrcL` 或 `SrcR` 的目的位置仍然为地址贡献指令执行前的值。

执行成功时按地址较低者在前记录两个 relaxed 加载事件。内存字节与保留状态保持不变，因为加载既不写内存也不打扰保留。

两个结果都发布之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：两个结果只在最后一步写入，因此一个目的位置不可能为同一条指令的第二个地址提供输入。成对操作只作用于一份指令执行前的寄存器状态，这正使 `->5, 5` 成为已定义编码。

<!-- PTO-READER-BLOCK: scalar-hl-lwup-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配、保留编码值，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。

未按 4 字节对齐的地址会在翻译或权限检查之前引发 `Fault_DataAlignment`。之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不写入目的位置，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、两个地址、两个预检与两次加载。

设计要点：`SrcRType` 原始值 `11` 在保留值检查中被拒绝，此时源尚未被读取，因此保留该编码不可能暴露一个只形成了一半的偏移。

<!-- PTO-READER-BLOCK: scalar-hl-lwup-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lwup [3, 9<<2], ->5, 6`，GPR3 = `0x1000`，GPR9 = `0x400`。
- `SrcRType` 是 `00`，因此偏移是 `0x400`；`shamt` 是 `2`，因此它变为 `0x1000`。
- 这个和是 `0x2000`，因此成对范围覆盖 `0x2000` 与 `0x2004`。
- GPR5 收到 `0x2000` 处的单元，GPR6 收到 `0x2004` 处的单元。GPR3 与 GPR9 保持原值，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lwup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwup_48_30f20380c354 | HL48 | 48 | 0x00006009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwup_48_30f20380c354 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwup_48_30f20380c354 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lwup_48_30f20380c354 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lwup_48_30f20380c354 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lwup_48_30f20380c354 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lwup_48_30f20380c354 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lwup_48_30f20380c354 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwup_48_30f20380c354 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwup_48_30f20380c354 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lwup_48_30f20380c354 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lwup_48_30f20380c354 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lwup_48_30f20380c354 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lwup_48_30f20380c354.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWUP.asl -->
```asl
readonly func InstructionContractOperation_HL_LWUP() => ScalarOperation
begin
    return ScalarOperation_HL_LWUP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWUP.asl -->
```asl
readonly func InstructionContractHandler_HL_LWUP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LWUP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LWUP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LWUP()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LWUP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LWUP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LWUP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LWUP()
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
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.lwup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
