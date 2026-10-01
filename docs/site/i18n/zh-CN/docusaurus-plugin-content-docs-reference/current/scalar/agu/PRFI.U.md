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
## `PRFI.U` 做什么

`PRFI.U` 从 `SrcL` 加一个不做缩放的立即数形成字节地址，并为其发出非绑定的预取提示。其规范汇编是 `prfi.u [SrcL, simm]`，且不暴露任何目的端。

设计要点：提示不需要对齐检查，这正是非缩放立即数在这里有用的原因。`PRFI.U` 可以指向基址周围 `-2048`..`2047` 之间的任意字节，包括 `4` 字节加载会以 `Fault_DataAlignment` 拒绝的那些地址。

<!-- PTO-READER-BLOCK: scalar-prfi-u-mechanism role=mechanism -->
## `PRFI.U` 如何形成地址并发出提示

`simm12` 从其 `12` 位符号扩展到 `PTO_XLEN`，并与 `SrcL` 基址按 `2^PTO_XLEN` 取模相加。该和被交给提示，随后被丢弃。

编码保留了不命名任何目的端的 `RegDst` 字段，其他字段也不发布结果。因此 `SrcL` 保持其值，且不写入任何队列槽位。

设计要点：该操作留下的唯一架构痕迹就是 `TPC` 前移。形成的地址不保存在任何地方，因此对同一地址连续发出的两次提示与一次提示无法区分。

<!-- PTO-READER-BLOCK: scalar-prfi-u-inputs role=inputs-outputs -->
## 编码字段与提示消费的内容

- `SrcL` 是 `5` 位 Reg5 源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm12` 是有符号 `12` 位字段，因此全部 `4096` 个编码都是取值，编码为零提供零位移，并不表示省略。
- `RegDst` 作为被忽略的别名保留：编码 `0`..`31` 全部合法，它们都不写寄存器、不压入队列槽位，规范汇编也不暴露目的端。

设计要点：提示仍然读取 `SrcL`，因为地址由它形成，也正是这次读取使不可用的 `T`/`U` 源成为拒绝理由。读取之后不会有任何内容被发布。

<!-- PTO-READER-BLOCK: scalar-prfi-u-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在提示之前被读取，因此即使后续指令覆盖该寄存器，地址仍使用执行前的值。

成功执行不改变内存字节、保留项、队列项或寄存器。随后 `TPC` 前移 `4` 字节，即本编码的长度。

设计要点：由于没有内存事件也没有顺序边，本形式无法改变其他代理观察到的东西。它唯一可见的效果是该指令退休、`TPC` 移到下一条指令。

<!-- PTO-READER-BLOCK: scalar-prfi-u-constraints role=constraints -->
## 合法性、故障与重启

当固定比特不匹配，或所选 `T`/`U` 源槽位因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

合法的 `PRFI.U` 不执行对齐、翻译、权限或有界内存测试，因此对合法编码而言 `Fault_DataAlignment` 与 `Fault_DataPage` 都不可达。

拒绝发生在地址形成之前，因此被拒绝的尝试没有部分效果，`TPC` 停在故障指令上；重发会重复同样的编码检查。

设计要点：没有可重启的数据故障路径，因此本形式唯一可能需要的重启是编码或源可用性拒绝，软件通过修改指令而非修正地址来解决。

<!-- PTO-READER-BLOCK: scalar-prfi-u-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `prfi.u [3, 2]`，设 GPR3 = `0x1000`。
- `simm12=2` 符号扩展为 `2`，因此提示地址是 `0x1002`。
- `0x1002` 不满足 `4` 字节对齐，但提示不执行对齐检查，因此不会被拒绝。
- 该地址被丢弃：寄存器、队列槽位与内存字节都不变，`TPC` 前移 `4` 字节。
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
