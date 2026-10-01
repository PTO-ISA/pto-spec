<!-- GENERATED FROM: asl/scalar/agu/LB.PCR.asl -->
# LB.PCR

**Normative ASL source:** `asl/scalar/agu/LB.PCR.asl`

LB.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LB-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lb-pcr-purpose role=purpose -->
## `LB.PCR` 的作用

`LB.PCR` 从相对于指令自身对齐地址的地址加载一个有符号 `1` 字节单元。它既不读取基址寄存器，也不读取索引寄存器。

规范汇编是 `lb.pcr [symbol], ->{t, u, Rd}`。

设计要点：唯一的寻址输入是 `simm17`，因此无论指令放在指令流的哪个位置，同一编码都取到同一个相对字节。

<!-- PTO-READER-BLOCK: scalar-lb-pcr-mechanism role=mechanism -->
## 地址与传输如何形成

基址是清掉第 `1:0` 位后的 `TPC`，即本指令的 `4` 字节对齐地址。符号扩展后的 `simm17` 乘以 `4`，并按模 `2^PTO_XLEN` 加到该基址上。

预检依次检查 `1` 字节对齐、转换、权限与有界内存。成功后小端读取 `1` 字节并记录一个 relaxed 加载事件。

该字节被符号扩展到 `PTO_XLEN` 并通过 `RegDst` 发布；本编码没有其他状态效果。

设计要点：`4` 的位移比例就是指令长度，因此 `simm17` 以指令计数并覆盖 `-262144`..`262140` 字节。基址与位移都是 `4` 的倍数，因此和也是。

<!-- PTO-READER-BLOCK: scalar-lb-pcr-inputs role=inputs-outputs -->
## 编码字段与角色

- `TPC` 是隐式基址，持有正在执行的指令地址；相加之前先清掉第 `1:0` 位。
- `simm17` 为带符号数，覆盖 `-65536`..`65535` 个 `4` 字节单位，即 `-262144`..`262140` 字节。
- `RegDst` 是本编码中唯一的选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：由于没有需要取快照的基址寄存器，也没有 `SrcRType` 或 `shamt` 字段，本形式唯一可能产生的合法性失败是固定位模式不匹配。

<!-- PTO-READER-BLOCK: scalar-lb-pcr-effects role=effects -->
## 效果、顺序与完成

基址在内存操作之前从 `TPC` 读取，因此位移相对于本指令，而不是相对于已前进的程序计数器。

成功时记录一个 relaxed 加载事件，不改变任何内存字节，保留保持不变，发布符号扩展后的字节，并使 `TPC` 前进 `4` 字节。

设计要点：加载的字节被符号扩展，因此内存中的字节 `0xFF` 会发布为 `0xFFFFFFFFFFFFFFFF`。

<!-- PTO-READER-BLOCK: scalar-lb-pcr-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配会在任何内存或目的端效果之前于指令地址处引发 `Fault_IllegalInstruction`。
- 地址必须在考虑转换之前满足 `1` 字节对齐；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布结果，并让 `TPC` 停留在引发故障的指令上，使尝试可以原样重发。
- 设计要点：由于基址的第 `1:0` 位被清除且位移是 `4` 的倍数，有效地址始终是 `4` 的倍数；对 `1` 字节访问而言 `Fault_DataAlignment` 不可达。

<!-- PTO-READER-BLOCK: scalar-lb-pcr-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `TPC` = `0x108`、`simm17` = `-2` 时，字节位移是 `-8`，地址是 `0x100`。
- `0x100` 处的字节 `0xFF` 发布为 `0xFFFFFFFFFFFFFFFF`，因为该加载是带符号的。
- 由于基址向下对齐到 `4` 字节边界，`TPC` 为 `0x106` 时会使用同一个 `0x104` 基址。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lb.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lb_pcr_32_3fa2540b22d0 | L32 | 32 | 0x00000039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lb_pcr_32_3fa2540b22d0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lb_pcr_32_3fa2540b22d0 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lb_pcr_32_3fa2540b22d0 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lb_pcr_32_3fa2540b22d0 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LB.PCR.asl -->
```asl
readonly func InstructionContractOperation_LB_PCR() => ScalarOperation
begin
    return ScalarOperation_LB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LB.PCR.asl -->
```asl
readonly func InstructionContractHandler_LB_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LB_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LB_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LB_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LB_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LB_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LB_PCR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LB_PCR()
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
- After a successful 1-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- lb.pcr [symbol], ->{t, u, Rd}
