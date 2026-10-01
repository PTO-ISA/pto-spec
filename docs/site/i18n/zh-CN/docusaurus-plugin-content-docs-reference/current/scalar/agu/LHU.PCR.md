<!-- GENERATED FROM: asl/scalar/agu/LHU.PCR.asl -->
# LHU.PCR

**Normative ASL source:** `asl/scalar/agu/LHU.PCR.asl`

LHU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LHU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lhu-pcr-purpose role=purpose -->
## `LHU.PCR` 的作用

`LHU.PCR` 从相对于指令自身对齐地址的地址加载一个无符号 `2` 字节半字，并发布零扩展后的值。

规范汇编是 `lhu.pcr [symbol], ->{t, u, Rd}`。

设计要点：既不读取基址也不读取索引寄存器，因此整个地址只取决于 `TPC` 与 `simm17`；该编码没有软件可能忘记初始化的字段。

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-mechanism role=mechanism -->
## 地址与传输如何形成

清掉第 `1:0` 位后的 `TPC` 提供基址，符号扩展并乘以 `4` 的 `simm17` 提供位移。加法按模 `2^PTO_XLEN` 进行。

预检依次检查 `2` 字节对齐、转换、权限与有界内存。成功后小端读取 `2` 字节并记录一个 relaxed 加载事件。

该半字被零扩展到 `PTO_XLEN` 并通过 `RegDst` 发布；随后 `TPC` 前进 `4` 字节。

设计要点：基址与位移都是 `4` 的倍数，因此有效地址是 `4` 的倍数，`2` 字节对齐规则由构造保证满足。

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-inputs role=inputs-outputs -->
## 编码字段与角色

- `TPC` 是隐式基址。第 `1:0` 位被清除，因此即使指令流更紧凑，参考点也是 `4` 字节边界。
- `simm17` 为带符号数，覆盖 `-65536`..`65535` 个 `4` 字节单位，即 `-262144`..`262140` 字节。
- `RegDst` 是本编码中唯一的选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：`RegDst` 接受任何 `5` 位编码，包括队列压入 `30` 与 `31`，因此无符号半字可以直接进入队列。

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-effects role=effects -->
## 效果、顺序与完成

基址是前进之前的 `TPC`，因此地址由指令位置决定，而不是由程序写入的任何内容决定。

成功时记录一个 relaxed 加载事件，内存与保留保持不变，发布零扩展后的半字，并使 `TPC` 前进 `4` 字节。

设计要点：结果落在 `0`..`65535`，因此加载不会置起第 `15` 位以上的任何位，该值可以直接作为无符号计数比较。

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配会在任何指令效果之前引发 `Fault_IllegalInstruction`；不存在可能违反合法性的寄存器操作数。
- 会产生奇数地址的位移会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布结果，并让 `TPC` 停留在引发故障的指令上，使尝试可以重发。
- 设计要点：`4` 字节的位移比例使对齐阶段不可达，因此 `Fault_DataPage` 是 `LHU.PCR` 能报告的唯一数据侧失败。

<!-- PTO-READER-BLOCK: scalar-lhu-pcr-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `TPC` = `0x2000`、`simm17` = `2` 时，字节位移是 `8`，地址是 `0x2008`。
- `0x2008` 处的字节 `00 80` 是半字 `0x8000`，发布为 `0x8000`。
- 若 `TPC` 为 `0x2002`，基址仍会是 `0x2000`，因为相加之前已清除第 `1:0` 位。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lhu.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhu_pcr_32_9f4a1c04f258 | L32 | 32 | 0x00005039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhu_pcr_32_9f4a1c04f258 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhu_pcr_32_9f4a1c04f258 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lhu_pcr_32_9f4a1c04f258 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lhu_pcr_32_9f4a1c04f258 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHU.PCR.asl -->
```asl
readonly func InstructionContractOperation_LHU_PCR() => ScalarOperation
begin
    return ScalarOperation_LHU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHU.PCR.asl -->
```asl
readonly func InstructionContractHandler_LHU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LHU_PCR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LHU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHU_PCR()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

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

- lhu.pcr [symbol], ->{t, u, Rd}
