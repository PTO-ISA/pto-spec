<!-- GENERATED FROM: asl/scalar/agu/LW.PCR.asl -->
# LW.PCR

**Normative ASL source:** `asl/scalar/agu/LW.PCR.asl`

LW.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LW-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lw-pcr-purpose role=purpose -->
## `LW.PCR` 的作用

`LW.PCR` 从相对于指令的地址加载一个有符号 `4` 字节小端字，并把加载到的 `32` 位符号扩展到完整目的宽度。

规范汇编是 `lw.pcr [symbol], ->{t, u, Rd}`。

设计要点：位移比例等于访问宽度，因此该字段以 `4` 字节字计数，并且每个合法的指令地址都会产生 `4` 字节对齐的目标。

<!-- PTO-READER-BLOCK: scalar-lw-pcr-mechanism role=mechanism -->
## 地址与传输如何形成

基址是清掉第 `1:0` 位后的 `TPC`。`simm17` 被符号扩展、乘以 `4`，并按模 `2^PTO_XLEN` 加到该基址上。

预检依次检查 `4` 字节对齐、转换、权限与有界内存。成功后小端读取 `4` 字节并记录一个 relaxed 加载事件。

该字被符号扩展到 `PTO_XLEN` 并通过 `RegDst` 发布；随后 `TPC` 前进 `4` 字节。

设计要点：同一个比例承担两项职责：它让 `simm17` 以 `4` 字节字计数，并与清位后的基址一起保证和是 `4` 的倍数。

<!-- PTO-READER-BLOCK: scalar-lw-pcr-inputs role=inputs-outputs -->
## 编码字段与角色

- `TPC` 是隐式基址，仍持有正在执行的指令地址。
- `simm17` 为带符号数，覆盖 `-65536`..`65535` 个与指令同宽的单位，因此字节位移覆盖 `-262144`..`262140`。
- `RegDst` 是本编码中唯一的选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：目的端编码 `24`..`29` 会丢弃加载到的字，而加载及其事件仍然发生，因此内存效果不取决于目的端字段。

<!-- PTO-READER-BLOCK: scalar-lw-pcr-effects role=effects -->
## 效果、顺序与完成

基址在内存操作之前从 `TPC` 读取，因此位移相对于本指令，而绝不相对于已前进的程序计数器。

成功时记录一个 relaxed 加载事件，不改变任何内存字节，保留保持不变，发布符号扩展后的字，并使 `TPC` 前进 `4` 字节。

设计要点：加载到的 `32` 位被符号扩展，因此最高位被置起的字会发布为负的 `64` 位值。

<!-- PTO-READER-BLOCK: scalar-lw-pcr-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配会在任何内存或目的端效果之前于指令地址处引发 `Fault_IllegalInstruction`。
- 地址必须是 `4` 的倍数才会考虑转换；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布结果，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：`LW.PCR` 不可能引发 `Fault_DataAlignment`，因此合法性之后唯一的数据侧失败是 `Fault_DataPage`。

<!-- PTO-READER-BLOCK: scalar-lw-pcr-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `TPC` = `0x100`、`simm17` = `-2` 时，字节位移是 `-8`，地址是 `0xF8`。
- `0xF8` 处的字节 `00 00 00 80` 是字 `0x80000000`，发布为 `0xFFFFFFFF80000000`。
- 当 `simm17` = `1` 时地址是 `0x104`，它仍是 `4` 的倍数，因此对任何编码位移该访问都合法。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lw.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lw_pcr_32_d135a1aa4ffb | L32 | 32 | 0x00002039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lw_pcr_32_d135a1aa4ffb | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lw_pcr_32_d135a1aa4ffb | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lw_pcr_32_d135a1aa4ffb | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lw_pcr_32_d135a1aa4ffb | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LW.PCR.asl -->
```asl
readonly func InstructionContractOperation_LW_PCR() => ScalarOperation
begin
    return ScalarOperation_LW_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LW.PCR.asl -->
```asl
readonly func InstructionContractHandler_LW_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LW_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LW_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LW_PCR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LW_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LW_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LW_PCR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LW_PCR()
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
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 4-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lw.pcr [symbol], ->{t, u, Rd}
