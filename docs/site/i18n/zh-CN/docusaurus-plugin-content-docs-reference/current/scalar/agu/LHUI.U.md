<!-- GENERATED FROM: asl/scalar/agu/LHUI.U.asl -->
# LHUI.U

**Normative ASL source:** `asl/scalar/agu/LHUI.U.asl`

LHUI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LHUI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lhui-u-purpose role=purpose -->
## `LHUI.U` 的作用

`LHUI.U` 在距基址寄存器的、不带比例的立即数位移处加载一个无符号 `2` 字节半字。每个编码单位对应一字节地址，结果做零扩展。

规范汇编是 `lhui.u [SrcL, simm], ->{t, u, Rd}`。

设计要点：`.u` 形式是 `LHUI` 的按字节细分版本：同一个 `12` 位字段现在表示 `-2048`..`2047` 字节，而不是 `-4096`..`4094`。

<!-- PTO-READER-BLOCK: scalar-lhui-u-mechanism role=mechanism -->
## 地址与传输如何形成

符号扩展后的 `simm12` 不经移位地与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。

预检依次检查 `2` 字节对齐、转换、权限与有界内存。成功后小端读取 `2` 字节，记录一个 relaxed 加载事件，并发布零扩展后的半字。

基址寄存器只被读取而从不被写入；只有 `RegDst` 发生变化。

设计要点：不带比例的位移可以是奇数，因此本形式可以从奇数基址到达奇数字节偏移处的半字。决定对齐的是和，而不是仅基址。

<!-- PTO-READER-BLOCK: scalar-lhui-u-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm12` 为带符号数，覆盖 `-2048`..`2047`，且不加比例使用。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：基址是唯一被读取的寄存器；任何 Reg5 源编码都被接受，用作基址的队列条目被读取而不被消费。

<!-- PTO-READER-BLOCK: scalar-lhui-u-effects role=effects -->
## 效果、顺序与完成

基址快照在内存操作之前取得，因此之后对同一寄存器的写入无法改变这次访问。

成功时记录一个 relaxed 加载事件，不改变任何内存字节，保留保持不变，发布零扩展后的半字，并使 `TPC` 前进 `4` 字节。

设计要点：结果恰好落在 `0`..`65535`，因为零扩展清除了第 `15` 位以上的所有位。

<!-- PTO-READER-BLOCK: scalar-lhui-u-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或 `SrcL` 选择子指向不可用的 `T`/`U` 条目，会在形成地址之前引发 `Fault_IllegalInstruction`。
- 奇数之和会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件，不向 `RegDst` 发布结果，并让 `TPC` 停留在引发故障的指令上，使尝试可以重发。
- 设计要点：奇数位移配奇数基址仍然合法，而奇数之和则不然；这一区别会在转换之前被报告为 `Fault_DataAlignment`。

<!-- PTO-READER-BLOCK: scalar-lhui-u-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x1001`、`simm12` = `1` 时，地址是 `0x1002`，该访问合法。
- 同一基址配 `simm12` = `0` 时地址是 `0x1001`，引发 `Fault_DataAlignment`。
- 合法尝试读到的半字做零扩展，因此以 `0`..`65535` 进入 `RegDst`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lhui.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhui_u_32_748b15cd2ced | L32 | 32 | 0x00005029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhui_u_32_748b15cd2ced | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhui_u_32_748b15cd2ced | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lhui_u_32_748b15cd2ced | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lhui_u_32_748b15cd2ced | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lhui_u_32_748b15cd2ced | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lhui_u_32_748b15cd2ced | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHUI.U.asl -->
```asl
readonly func InstructionContractOperation_LHUI_U() => ScalarOperation
begin
    return ScalarOperation_LHUI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHUI.U.asl -->
```asl
readonly func InstructionContractHandler_LHUI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHUI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHUI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LHUI_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHUI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LHUI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHUI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHUI_U()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- lhui.u [SrcL, simm], ->{t, u, Rd}
