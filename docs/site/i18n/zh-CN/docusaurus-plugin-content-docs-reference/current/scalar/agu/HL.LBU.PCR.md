<!-- GENERATED FROM: asl/scalar/agu/HL.LBU.PCR.asl -->
# HL.LBU.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LBU.PCR.asl`

HL.LBU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-purpose role=purpose -->
## `HL.LBU.PCR` 做什么

`HL.LBU.PCR` 是一条 `48` 位的 PC 相对字节加载指令，采用零扩展。它用当前程序计数器形成地址，读取一个字节，把该字节放在 `PTO_XLEN` 结果的第 `7`:`0` 位、高位全部清零，再通过 `RegDst` 发布结果。

规范汇编形式是 `hl.lbu.pcr [<symbol>], ->{t, u, Rd}`。

设计要点：由本形式发布的字节 `FF` 会变成 `255`，因为结果的第 `63`:`8` 位被清零。因此发布的值永远不会为负，也不可能有符号位从内存进入字的高半部分。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-mechanism role=mechanism -->
## 地址与传输如何形成

基址是当前 `TPC` 把第 `1`:`0` 位清零后的值。位移是有符号 `29` 位字段左移 `2` 位的结果，两者之和按 `2^PTO_XLEN` 取模。

本形式没有基址寄存器，也没有回写，因此除通过发布的目的位置之外，指令不改变任何通用寄存器。

编码检查与地址预检通过后，处理程序执行一次 `1` 字节小端序加载，并把该字节零扩展到完整字宽后再发布到 `RegDst`。

设计要点：由于基址是 `4` 字节对齐的且位移按 `4` 缩放，编码位移 `0` 指向的是包含该指令自身的那一个 `4` 字节对齐块。那是一个已定义的地址，而不是缺失的操作数：`29` 位字段在编码中总是存在。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-inputs role=inputs-outputs -->
## 编码字段与字节去向

- `RegDst` 是 `5` 位选择子：编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 只丢弃该值而不做别的。
- 有符号 `29` 位位移按 `4` 缩放，因此它组装出的字节范围是 `-1073741824` 到 `1073741820`，步长为 `4`。
- 基址是隐式的，等于对齐后的 `TPC`。

设计要点：通过 `RegDst` 压入 `T` 或 `U` 队列会产生一个新的最新条目，并把较旧的条目整体挪动一个槽位，所以 `hl.lbu.pcr [...] ->t` 并不等价于写一个 GPR：它还会改变 `T#2`、`T#3` 与 `T#4`。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-effects role=effects -->
## 影响、顺序与完成

执行成功时记录一个 relaxed 加载事件，内存与保留状态保持不变。只有当加载报告无故障时才写入目的位置。

发布之后，`TPC` 前进 `6` 字节，度量起点是基址所依据的那条指令地址。

设计要点：零扩展在发布之前完成，因此队列槽位或 GPR 收到的正好是一个高半部分已定义的值；消费者不必自己去屏蔽第 `63`:`8` 位。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-constraints role=constraints -->
## 合法性、故障与重启

`48` 位编码中的固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`。本形式不编码任何源选择子，因此没有 `T` 或 `U` 可用性检查能拒绝它。

预检按访问本身的对齐要求检查地址。`1` 字节传输被任何地址满足，因此本形式没有任何可达地址会引发 `Fault_DataAlignment`。随后地址被翻译并接受权限检查；权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不写入目的位置，`TPC` 停留在引发故障的指令上。恢复会重新推导对齐后的基址与缩放后的位移，并重复整个操作。

<!-- PTO-READER-BLOCK: scalar-hl-lbu-pcr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbu.pcr [<symbol>], ->t`，在 `TPC` = `0x1040` 处执行，编码位移为 `3`。截断后的基址是 `0x1040`，组装出的位移是 `12`。
- 有效地址是 `0x1040` 加 `12`，即 `0x104C`，指令读取该处的字节。
- 若该字节为 `FF`，压入成为新 `T#1` 的值是 `255`，第 `63`:`8` 位全为零。
- `TPC` 变为 `0x1040` 加 `6`，即 `0x1046`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbu.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbu_pcr_48_504b34c0ec9d | HL48 | 48 | 0x00004039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbu_pcr_48_504b34c0ec9d | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbu_pcr_48_504b34c0ec9d | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbu_pcr_48_504b34c0ec9d | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbu_pcr_48_504b34c0ec9d | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBU.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LBU_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LBU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBU.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LBU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LBU_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LBU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBU_PCR()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- hl.lbu.pcr [<symbol>], ->{t, u, Rd}
