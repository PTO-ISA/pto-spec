<!-- GENERATED FROM: asl/scalar/agu/PRFI.U.asl -->
# PRFI.U

**Normative ASL source:** `asl/scalar/agu/PRFI.U.asl`

PRFI.U snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.

## Normative identity {#PTO-INST-SCALAR-PRFI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-prfi-u-purpose role=purpose -->
## PRFI.U 的作用

`PRFI.U` 是一条独立的 `32` 位 AGU 指令；它形成有符号立即数地址，并发出一条不产生目的端效果的非约束性预取提示。

<!-- PTO-READER-BLOCK: scalar-prfi-u-mechanism role=mechanism -->
## 地址与内存机制

`PRFI.U` 将完整 `-2048..2047` 取值域中的 `simm12` 符号扩展，随后不再缩放，并将位移按 `2^PTO_XLEN` 取模后加到快照中的 `SrcL` 基址。

形成的地址只是一条非约束性、粒度为一字节的预取提示；合法执行不产生架构地址转换、内存访问、内存事件、保留更新、排序边或缓存放置保证。

任何编码目的端都不会发布提示地址，该指令也不更新基址寄存器。

<!-- PTO-READER-BLOCK: scalar-prfi-u-inputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供基址；`simm12` 提供有符号位移。其中的 Reg5 源 `SrcL` 使用完整编码域：`0..23` 选择 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且读取不会消费队列项。
- `RegDst` 是忽略别名；所有 `RegDst` 编码都是已分配且不写入的别名。
- `simm12` 分配从 `-2048` 到 `2047` 的全部有符号值；编码零表示零位移，而不是省略该操作数。

<!-- PTO-READER-BLOCK: scalar-prfi-u-effects role=effects -->
## 效果与顺序

所有显式和隐式标量源都在内存或目的端效果之前完成快照，因此别名观察到的是指令执行前的值。

合法提示不产生内存事件、保留变化或目的端写入，并将 `TPC` 前移 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-prfi-u-constraints role=constraints -->
## 对齐、故障与重启

合法预取不执行数据对齐、地址转换、权限或有界内存检查，因此不会引发数据访问故障。

保留的预取模型会在读取源和任何可选地址发布之前拒绝。

固定比特不匹配、字段取保留值或所选 `T`/`U` 源不可用，都会在指令效果之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-prfi-u-example role=example -->
## 非规范地址示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

若基址为 `0x100`、有符号立即数为 `2`，形成的提示地址就是 `0x102`；该地址只作为非约束性提示发出，不产生架构内存或目的端效果。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
prfi.u [SrcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| prfi_u_32_167b42882547 | L32 | 32 | 0x00007029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| prfi_u_32_167b42882547 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| prfi_u_32_167b42882547 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| prfi_u_32_167b42882547 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| prfi_u_32_167b42882547 | RegDst | 5 | 0–31 | none | none | ignored encoded alias field | Encoded zero is the canonical ignored alias value and names no destination. |
| prfi_u_32_167b42882547 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| prfi_u_32_167b42882547 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | ignored encoded alias field |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/PRFI.U.asl -->
```asl
readonly func InstructionContractOperation_PRFI_U() => ScalarOperation
begin
    return ScalarOperation_PRFI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/PRFI.U.asl -->
```asl
readonly func InstructionContractHandler_PRFI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_PRFI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_PRFI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_PRFI_U()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_PRFI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_PRFI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_PRFI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_PRFI_U()
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
- Every encoded RegDst value is an assigned non-writing alias. Canonical assembly uses zero and does not expose a destination.
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- Discard the formed address after issuing the non-binding hint; no encoded field publishes a result.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- For a legal model, form the hint, publish the optional address result, and then advance TPC by 4 bytes.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication.

## Examples

- prfi.u [SrcL, simm]
