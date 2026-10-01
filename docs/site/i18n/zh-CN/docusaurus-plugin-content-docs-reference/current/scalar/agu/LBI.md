<!-- GENERATED FROM: asl/scalar/agu/LBI.asl -->
# LBI

**Normative ASL source:** `asl/scalar/agu/LBI.asl`

LBI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lbi-purpose role=purpose -->
## `LBI` 的作用

`LBI` 在距基址寄存器的带符号立即数位移处加载一个有符号 `1` 字节单元。它是字节读取的立即数形式：位移直接编码，因此根本不读取索引寄存器。

规范汇编是 `lbi [SrcL, simm], ->{t, u, Rd}`。

设计要点：`simm12` 以字节计数，因此本形式可以到达基址下方 `2048` 字节与上方 `2047` 字节，窗口宽 `4096` 字节，且不消耗任何寄存器来存放偏移。

<!-- PTO-READER-BLOCK: scalar-lbi-mechanism role=mechanism -->
## 地址与传输如何形成

`LBI` 把 `12` 位 `simm12` 字段符号扩展到 `PTO_XLEN`，按 `1` 字节对应一个编码单位、不加比例地加到 `SrcL` 快照上，并按模 `2^PTO_XLEN` 取和。

有效地址先通过对齐阶段（宽度 `1` 字节），再通过权限与有界内存检查。成功后读取一个小端字节并记录一个 relaxed 加载事件。

该字节被符号扩展到 `PTO_XLEN` 并通过 `RegDst` 发布；基址寄存器从不被修改。

设计要点：符号扩展在相加之前作用于该字段，因此编码值 `0x800` 表示 `-2048` 字节而不是 `2048`。负半窗与正半窗因此不对称：基址下方 `2048` 字节，上方 `2047` 字节。

<!-- PTO-READER-BLOCK: scalar-lbi-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是唯一的寄存器源。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm12` 是覆盖 `-2048`..`2047` 的带符号 `12` 位位移；编码零表示零位移，而不是省略操作数。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：`SrcL` 编码 `0` 读取架构零 `GPR`，因此零基址配非负 `simm12` 时可直接读取地址空间低端的 `2048` 字节；负位移则按模 `2^PTO_XLEN` 回绕到地址空间顶端。

<!-- PTO-READER-BLOCK: scalar-lbi-effects role=effects -->
## 效果、顺序与完成

基址快照在内存访问之前取得，因此指令后续发生的任何事情都无法改变该地址。

成功尝试记录一个 relaxed 加载事件，不写内存，不改变保留，发布符号扩展后的字节，并使 `TPC` 前进 `4` 字节。

设计要点：低于零的负位移按模 `2^PTO_XLEN` 回绕，随后由权限检查判定，因此回绕本身是静默的，由所得地址决定结果。

<!-- PTO-READER-BLOCK: scalar-lbi-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或 `SrcL` 编码指向不可用的 `T`/`U` 条目，会在读取基址之前于指令地址处引发 `Fault_IllegalInstruction`。
- 地址必须在转换之前满足 `1` 字节对齐；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录加载事件、不发布结果，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：`1` 字节访问不可能引发 `Fault_DataAlignment`，因此 `LBI` 在数据侧唯一的拒绝来自权限阶段的 `Fault_DataPage`。

<!-- PTO-READER-BLOCK: scalar-lbi-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 GPR `6` = `0x1000` 且编码 `simm12` 为 `-1` 时，有效地址是 `0xFFF`，并从该处读取一字节。
- 同一基址配 `simm12` = `2047` 时地址为 `0x17FF`，这体现了窗口正方向 `2047` 字节的边界。
- 在上述任一地址读到的字节 `0xFF` 会发布为 `0xFFFFFFFFFFFFFFFF`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lbi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lbi_32_9af2cdbeb38f | L32 | 32 | 0x00000019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lbi_32_9af2cdbeb38f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lbi_32_9af2cdbeb38f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lbi_32_9af2cdbeb38f | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lbi_32_9af2cdbeb38f | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lbi_32_9af2cdbeb38f | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lbi_32_9af2cdbeb38f | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LBI.asl -->
```asl
readonly func InstructionContractOperation_LBI() => ScalarOperation
begin
    return ScalarOperation_LBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LBI.asl -->
```asl
readonly func InstructionContractHandler_LBI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LBI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LBI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LBI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LBI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LBI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LBI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LBI()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- lbi [SrcL, simm], ->{t, u, Rd}
