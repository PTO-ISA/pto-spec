<!-- GENERATED FROM: asl/scalar/agu/LBU.PCR.asl -->
# LBU.PCR

**Normative ASL source:** `asl/scalar/agu/LBU.PCR.asl`

LBU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LBU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lbu-pcr-purpose role=purpose -->
## `LBU.PCR` 的作用

`LBU.PCR` 从相对于指令的地址加载一个无符号 `1` 字节单元，并把该字节发布为 `0`..`255` 范围内的值。

规范汇编是 `lbu.pcr [symbol], ->{t, u, Rd}`。

设计要点：`LBU.PCR` 是 `LB.PCR` 的无符号孪生形式。两者共用寻址字段，因此总是访问同一地址，只在所加载字节的扩展方式上不同。

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-mechanism role=mechanism -->
## 地址与传输如何形成

清掉第 `1:0` 位后的 `TPC` 提供基址。符号扩展后的 `simm17` 乘以 `4`，并按模 `2^PTO_XLEN` 与之相加。

预检依次检查 `1` 字节对齐、转换、权限与有界内存。成功后小端读取 `1` 字节并记录一个 relaxed 加载事件。

该字节被零扩展到 `PTO_XLEN` 并通过 `RegDst` 发布；不存在需要回写的基址寄存器。

设计要点：清位后的基址与按 `4` 缩放的位移都是 `4` 的倍数，因此和是 `4` 的倍数，`1` 字节访问对任何编码都满足对齐。

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-inputs role=inputs-outputs -->
## 编码字段与角色

- `TPC` 是隐式基址。清除第 `1:0` 位使参考点成为 `4` 字节边界。
- `simm17` 为带符号数，覆盖 `-65536`..`65535` 个 `4` 字节单位，即 `-262144`..`262140` 字节。
- `RegDst` 是本编码中唯一的选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：目的端编码 `30` 与 `31` 把该字节压入 `U` 或 `T` 队列，因此常量字节可以直接加载到队列条目中。

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-effects role=effects -->
## 效果、顺序与完成

基址在内存操作之前读取，因此这次访问只由指令自身的位置决定，而不受其他因素影响。

成功时记录一个 relaxed 加载事件，内存与保留保持不变，发布零扩展后的字节，并使 `TPC` 前进 `4` 字节。

设计要点：结果恰好落在 `0`..`255`，因为零扩展清除了第 `7` 位以上的所有位。

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配会在任何指令效果之前引发 `Fault_IllegalInstruction`。
- 地址必须在考虑转换之前满足 `1` 字节对齐；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布字节，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：`Fault_DataAlignment` 不可达，因此合法性阶段之后唯一剩下的数据侧拒绝是来自权限检查的 `Fault_DataPage`。

<!-- PTO-READER-BLOCK: scalar-lbu-pcr-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `TPC` = `0x2000`、`simm17` = `1` 时，字节位移是 `4`，地址是 `0x2004`。
- 该地址处的字节 `0xFF` 发布为 `0xFF`，而同一访问经 `LB.PCR` 会发布 `0xFFFFFFFFFFFFFFFF`。
- 当 `simm17` = `-1` 时地址是 `0x1FFC`，它仍是 `4` 的倍数，因此负位移不会引起任何对齐失败。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lbu.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lbu_pcr_32_5b571b0c8dc2 | L32 | 32 | 0x00004039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lbu_pcr_32_5b571b0c8dc2 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lbu_pcr_32_5b571b0c8dc2 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lbu_pcr_32_5b571b0c8dc2 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lbu_pcr_32_5b571b0c8dc2 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LBU.PCR.asl -->
```asl
readonly func InstructionContractOperation_LBU_PCR() => ScalarOperation
begin
    return ScalarOperation_LBU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LBU.PCR.asl -->
```asl
readonly func InstructionContractHandler_LBU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LBU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LBU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LBU_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LBU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LBU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LBU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LBU_PCR()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

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

- lbu.pcr [symbol], ->{t, u, Rd}
