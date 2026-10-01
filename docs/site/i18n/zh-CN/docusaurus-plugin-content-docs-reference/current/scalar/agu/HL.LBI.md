<!-- GENERATED FROM: asl/scalar/agu/HL.LBI.asl -->
# HL.LBI

**Normative ASL source:** `asl/scalar/agu/HL.LBI.asl`

HL.LBI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbi-purpose role=purpose -->
## `HL.LBI` 做什么

`HL.LBI` 是一条 `48` 位字节加载指令，使用有符号 `22` 位立即数位移，且不更新基址。它把立即数加到 `SrcL` 基址上，在该处读取一个字节，把字节符号扩展到 `PTO_XLEN`，并发布到唯一的 `RegDst` 字段。

规范汇编形式是 `hl.lbi [SrcL, simm], ->{t, u, Rd}`。

设计要点：本形式只有一个目的字段，因此尽管处理程序为访问计算了基址加位移的和，却没有地方发布它。该地址因此不能作为结果取得，需要连续指针的遍历必须用另一条指令去计算它。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-mechanism role=mechanism -->
## 地址与传输如何形成

位移是符号扩展后的 `22` 位立即数，缩放因子为 `1`，按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。更新模式为无，因此有效地址就是这个和，且没有任何值被回写到基址寄存器。

基址选择子只被读取；没有任何状态记录曾经形成过一个地址。

编码检查与地址预检通过后，处理程序执行一次 `1` 字节小端序加载，对第 `7` 位做符号扩展，并把结果发布到 `RegDst`。

设计要点：把立即数加宽到 `22` 位使可达窗口扩展到 `-2097152` 至 `2097151` 字节，以字节为步长。这个窗口只是立即数字段的属性，因此本形式可以访问偏移对象而不必为位移占用一个寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-inputs role=inputs-outputs -->
## 编码字段与结果

- `SrcL` 是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `simm22` 是有符号 `22` 位立即数，覆盖 `-2097152` 到 `2097151`，缩放因子为 `1`。
- `RegDst` 是 `5` 位选择子。编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃该值且不抑制访问。

设计要点：丢弃也是真实的目的编码，因此加载与其故障检查仍会发生。程序可以把本形式当作一次丢弃结果但受检查的读取，但不能用它跳过内存引用。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前取快照，因此指定基址的目的位置仍然为地址贡献指令执行前的值。

执行成功时记录一个 relaxed 的 `1` 字节加载事件。内存字节与保留状态保持不变，因为加载既不写内存也不打扰保留。

发布之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休，`TPC` 停留在引发故障的指令上。

设计要点：符号扩展在发布之前完成，因此目的位置持有的值其第 `63`:`8` 位全部是第 `7` 位的副本。对这个值做无符号比较因此并不等价于对该字节做无符号读法。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-constraints role=constraints -->
## 合法性、故障与重启

`48` 位编码中的固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 编码选中不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。该编码不携带变换或移位字段，因此在该阶段没有其他取值会被拒绝。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式不会引发 `Fault_DataAlignment`。权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不写入目的位置，`TPC` 停留在引发故障的指令上。恢复会从同一个 `SrcL` 重新计算位移与求和。

<!-- PTO-READER-BLOCK: scalar-hl-lbi-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbi [4, -8], ->7`，GPR4 = `0xA000`。立即数是 `-8`，因此有效地址是 `0xA000` 减去 `8`，即 `0x9FF8`。
- 该指令读取 `0x9FF8` 处的字节。若为 `80`，GPR7 收到 `-128`，即 `0xFFFFFFFFFFFFFF80`。
- GPR4 仍持有 `0xA000`，因为本形式只发布一个结果，也不更新基址。
- `TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbi_48_250803040cc8 | HL48 | 48 | 0x00000019000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbi_48_250803040cc8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbi_48_250803040cc8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbi_48_250803040cc8 | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbi_48_250803040cc8 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbi_48_250803040cc8 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbi_48_250803040cc8 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBI.asl -->
```asl
readonly func InstructionContractOperation_HL_LBI() => ScalarOperation
begin
    return ScalarOperation_HL_LBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBI.asl -->
```asl
readonly func InstructionContractHandler_HL_LBI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBI()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.lbi [SrcL, simm], ->{t, u, Rd}
