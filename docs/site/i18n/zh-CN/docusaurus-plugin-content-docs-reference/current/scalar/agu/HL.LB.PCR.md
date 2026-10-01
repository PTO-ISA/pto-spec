<!-- GENERATED FROM: asl/scalar/agu/HL.LB.PCR.asl -->
# HL.LB.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LB.PCR.asl`

HL.LB.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LB-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-purpose role=purpose -->
## `HL.LB.PCR` 做什么

`HL.LB.PCR` 是一条 `48` 位的 PC 相对字节加载指令。它用当前程序计数器而不是寄存器来计算地址，读取一个字节，把它符号扩展到 `PTO_XLEN`，再通过唯一的 `RegDst` 字段发布结果。

规范汇编形式是 `hl.lb.pcr [<symbol>], ->{t, u, Rd}`。汇编里写的是符号，而编码里携带的是一个有符号 `29` 位位移，指令把它按 `4` 缩放。

设计要点：本形式完全没有源寄存器字段。指令中没有任何部分依赖 GPR、`T` 或 `U` 的值，因此访问之前既没有源快照要取，也没有队列可用性要检查。唯一被读取的架构状态就是程序计数器。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-mechanism role=mechanism -->
## 地址与传输如何形成

基址是当前 `TPC` 把第 `1`:`0` 位清零后的值，位移是有符号 `29` 位字段左移 `2` 位的结果。两者按 `2^PTO_XLEN` 取模相加。

访问直接使用该地址；本形式没有基址回写，因为它没有第二个目的位置，也没有更新模式。

编码检查与地址预检通过后，处理程序执行一次 `1` 字节小端序加载，对字节的第 `7` 位做符号扩展，并把扩展后的值发布到 `RegDst`。

设计要点：清掉 `TPC[1:0]` 使基址 `4` 字节对齐，位移又按 `4` 缩放，因此本形式能到达的每个地址都是 `4` 字节对齐的。`1` 字节访问不要求对齐，所以没有任何可达地址会被对齐规则拒绝；不过该规则仍会被求值，因为预检总是在翻译之前运行。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-inputs role=inputs-outputs -->
## 编码字段与字节去向

- `RegDst` 是 `5` 位选择子。编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 与 `24`..`29` 丢弃加载值且不抑制指令的其余部分。
- 有符号 `29` 位位移是字位移：它组装出的字节取值从 `-1073741824` 到 `1073741820`，步长为 `4`。
- 基址是隐式的：即当前 `TPC` 向下对齐到 `4` 字节边界后的值。

设计要点：`RegDst` 编码 `0` 是显式丢弃，不是省略。加载、其预检与事件仍然发生，只是发布步骤被跳过。因此程序可以把本形式当作一次不需要结果但会被检查的内存探测。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-effects role=effects -->
## 影响、顺序与完成

执行成功时进行一次 relaxed 的 `1` 字节加载并记录一个加载事件。内存字节以及任何保留状态都不改变。

发布只在内存操作报告无故障之后才写入目的位置，因此发生故障的加载不会改动目的选择子。

发布之后，`HL.LB.PCR` 把 `TPC` 前进 `6` 字节。地址是用指令执行前的 `TPC` 形成的，因此这次前进不会移动被读取的位置。

设计要点：目的选择子不是源，但如果它正好指向后续指令要读取的队列，压入在成功时只会发生一次且是无条件的；值在压入之前已完成符号扩展，因此队列里不会出现原始的 `8` 位。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-constraints role=constraints -->
## 合法性、故障与重启

`48` 位编码中的固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`。这里没有基址寄存器选择子需要检查，因此不存在源侧的 `T`/`U` 不可用拒绝路径。

预检按访问本身的对齐要求检查地址。对 `1` 字节传输而言任何地址都满足该要求，因此本形式不会引发 `Fault_DataAlignment`。随后地址被翻译并接受权限检查，权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不写入目的位置，`TPC` 停留在引发故障的指令上。恢复会从头重新计算对齐后的基址、缩放后的位移、预检与加载。

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lb.pcr [<symbol>], ->5`，在 `TPC` = `0x1002` 处执行，编码位移等于 `7`。清掉低 `2` 位得到基址 `0x1000`，位移组装为 `28`。
- 有效地址是 `0x1000` 加 `28`，即 `0x101C`。
- 该指令读取 `0x101C` 处的单个字节，并把第 `7` 位符号扩展到 GPR5。
- `TPC` 变为 `0x1002` 加 `6`，即 `0x1008`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lb.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lb_pcr_48_c0ba9a54c8e0 | HL48 | 48 | 0x00000039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lb_pcr_48_c0ba9a54c8e0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lb_pcr_48_c0ba9a54c8e0 | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lb_pcr_48_c0ba9a54c8e0 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_pcr_48_c0ba9a54c8e0 | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LB.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LB_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LB.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LB_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LB_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LB_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LB_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LB_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LB_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LB_PCR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LB_PCR()
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
- After a successful 1-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- hl.lb.pcr [<symbol>], ->{t, u, Rd}
