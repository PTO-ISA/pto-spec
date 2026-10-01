<!-- GENERATED FROM: asl/scalar/agu/SWI.asl -->
# SWI

**Normative ASL source:** `asl/scalar/agu/SWI.asl`

SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-SWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-swi-purpose role=purpose -->
## SWI 的作用

`SWI` 由 Reg5 基址加上按比例缩放的有符号位移形成地址，并把另一个 Reg5 源的低 `4` 字节以小端序存储到该地址。

设计要点：`SWI` 完全没有目标字段。它的地址更新模式为无，因此基址寄存器保留原值，该指令也不能用于推进指针；遍历需要显式的地址计算或后索引形式。

<!-- PTO-READER-BLOCK: scalar-swi-mechanism role=mechanism -->
## 地址与内存机制

地址分三步形成，每一步都发生在内存访问之前。

- `simm12` 先做符号扩展，得到 `-2048` 至 `2047` 的位移值。
- 该值左移 `2` 位，因此字节位移为 `simm12 * 4`，范围是 `-8192` 至 `8188`。
- 缩放后的位移按 `2^PTO_XLEN` 取模加到 `SrcR` 基址上。

随后预检在任何字节被写入之前检查地址：`4` 字节地址未对齐会在原地址引发 `Fault_DataAlignment`，之后的权限或受限内存失败会引发 `Fault_DataPage`。只有探测成功之后，才从最低字节开始存储这 `4` 个字节，并记录一个 relaxed 存储事件；与有效保留区间重叠的存储会使其失效。

设计要点：位移按 `4` 缩放，因此地址的低两位完全来自基址寄存器。换一个 `simm12` 无法修复未对齐的基址，`SWI` 能到达的每个地址都与 `SrcR` 具有同样的对齐。

设计要点：缩放后的位移覆盖基址下方 `8192` 字节、上方 `8188` 字节，步长为 `4`，因此可到达基址周围 `16` KiB 的窗口。由于每个缩放位移都是 `4` 的倍数，按 `4` 字节对齐的基址对任何 `simm12` 都保持访问对齐。

<!-- PTO-READER-BLOCK: scalar-swi-inputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 是 Reg5 存储数据源。
- `SrcR` 是 Reg5 地址基址。
- `simm12` 是有符号位移。
- 没有 `RegDst` 字段，因此 `SWI` 不写任何寄存器，也不写 GPR、`T` 或 `U`。

设计要点：`SrcL` 或 `SrcR` 的编码零读取架构零 GPR，因此 `swi zero, [a0, 0]` 存储四个零字节。`simm12` 的编码零是真实的零位移，绝不表示省略；页面上显示的每个字段都被显式编码。

<!-- PTO-READER-BLOCK: scalar-swi-effects role=effects -->
## 效果与顺序

两个标量源都在内存效果之前完成快照，因此数据源同时又是基址的存储会对两个角色都使用该寄存器在指令执行前的值。

成功时先提交这 `4` 个字节并更新保留状态，然后 `TPC` 前进 `4` 字节。写入范围与保存被保留地址的保留粒度重叠的成功存储会清除该保留；不重叠的存储则让它保持有效。发生故障时不写入任何字节，保留状态不变，`TPC` 停在出错指令上，因为地址探测在内存操作之前就已完成。恢复是完整的重新发射：地址形成、源快照、预检和内存操作全部重新执行，不保留任何进度。`SWI` 不改变描述符、数值状态、指令束、特权、谓词或控制流状态。

<!-- PTO-READER-BLOCK: scalar-swi-constraints role=constraints -->
## 对齐、故障与重启

`4` 字节访问就是完整的传输单位。两个 Reg5 源字段都使用完整的公共域：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不消费队列项。

各项检查按顺序执行。无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；所选 T/U 源不可用会引发 `Fault_IllegalInstruction`；随后地址探测对未对齐地址引发 `Fault_DataAlignment`，对超出允许且受限区域的地址引发 `Fault_DataPage`。

设计要点：对齐检查先于翻译和权限检查，因此落在本不可访问页面中的未对齐地址会在原地址报告 `Fault_DataAlignment`，而绝不会报告 `Fault_DataPage`。

设计要点：`simm12` 覆盖全部有符号 12 位取值，因此没有保留位移，也没有非法立即数。位移可以是其范围内 `4` 的任意倍数，包括零。

<!-- PTO-READER-BLOCK: scalar-swi-example role=example -->
## 非规范地址示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

当 `SrcR` 保存 `256`、`simm12=2` 时，位移为 `8`，访问地址为 `264`。对同样的基址取 `simm12=-2` 时地址为 `248`，两个地址的低两位都与基址相同，因此当且仅当 `256` 对齐时二者都对齐。`swi a0, [a1, 2]` 把 `a0` 的低 `4` 字节存储到 `a1 + 8`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
swi SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swi_32_147e55489c41 | L32 | 32 | 0x00002059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swi_32_147e55489c41 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swi_32_147e55489c41 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swi_32_147e55489c41 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| swi_32_147e55489c41 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| swi_32_147e55489c41 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| swi_32_147e55489c41 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SWI.asl -->
```asl
readonly func InstructionContractOperation_SWI() => ScalarOperation
begin
    return ScalarOperation_SWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SWI.asl -->
```asl
readonly func InstructionContractHandler_SWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SWI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SWI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcR base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- swi SrcL, [SrcR, simm]
