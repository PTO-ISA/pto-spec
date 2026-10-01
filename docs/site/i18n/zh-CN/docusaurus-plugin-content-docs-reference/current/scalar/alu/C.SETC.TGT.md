<!-- GENERATED FROM: asl/scalar/alu/C.SETC.TGT.asl -->
# C.SETC.TGT

**Normative ASL source:** `asl/scalar/alu/C.SETC.TGT.asl`

Snapshot one scalar source value into the active block BARG.BPCN.

## Normative identity {#PTO-INST-SCALAR-C-SETC-TGT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-purpose role=purpose -->
## C.SETC.TGT 的作用

`C.SETC.TGT` 把一个 Reg5 源值快照到 `BARG.BPCN`，即当前指令束的待生效目标地址；指令束退役之前，之后的间接转移会读取它。

设计要点：目标经由指令束私有的状态槽传递，而不是经由寄存器。这让条件设置指令决定是否跳转、让本指令决定跳到哪里，而两者都不必编码对方的操作数。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-mechanism role=mechanism -->
## 结果形成方式

指令先检查目标是否可写，再读取源，然后存储它。

- 指令束必须处于活动状态，其类型必须是 `Standard` 或 `Floating`，并且本指令束中不能已有更早成功的 `C.SETC.TGT`。
- 所选源的完整 `64` 位值被原样写入 `BARG.BPCN`；选择符本身不会被保留。
- 只有在该存储成功之后，用于阻止第二次出现的指令束私有标记才会置起。

设计要点：目标是快照而不是引用。之后对源寄存器的写入或对相应队列的压入都无法改变这个待生效的目标。

设计要点：该值按读取结果原样存储，不做对齐检查，也不移位。奇数在这里被接受；只有当指令束之后把它选为指令地址时才会引发 `Fault_InstructionPC`，因为奇数地址会被拒绝。

设计要点：本指令不触碰 `SETC.*` 产生的通用提交条件参数。是否跳转与跳转目标地址是两块独立的指令束状态。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是唯一编码操作数：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。
- 目标是隐式的：当前指令束的 `BARG.BPCN`。不写入任何寄存器。

设计要点：编码零读取架构零 GPR，因此 `c.setc.tgt zero` 安装目标 `0`。没有可省略的操作数，也没有丢弃形式；该指令是否被允许完全由指令束决定，而不是由某个字段决定。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-effects role=effects -->
## 效果与顺序

适用性和重复检查先于源读取，源读取又先于目标更新。在其中任何一步发生故障都不会改变 `BARG.BPCN` 和唯一性标记。

成功时，`BARG.BPCN` 和唯一性标记改变，随后 `TPC` 前进 `2` 字节。GPR、队列项、内存、保留状态、描述符、数值状态、特权、谓词和控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-constraints role=constraints -->
## 合法性与故障边界

首先检查适用性。当没有活动的 `Standard` 或 `Floating` 指令束、本指令束中已有一个成功的 `C.SETC.TGT`，或系统块关闭请求仍处于待处理状态时，会在读取源之前、写入任何状态之前于 `TPC` 处引发 `Fault_BundleControl`。

所选 `T` 或 `U` 源不可用会在 `BARG.BPCN`、唯一性标记、`TPC` 或队列状态改变之前引发 `Fault_IllegalInstruction`。若没有故障，`TPC` 前进 `2` 字节。

设计要点：同样的两个适用性条件被检查两次：一次在读取源之前，一次在目标更新内部。外层检查使重复出现无需读取源就能触发故障；内层检查让更新本身同样以该规则为条件。

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

在活动的 `Standard` 指令束内，当 `a0=4096` 时，`c.setc.tgt a0` 安装待生效目标 `4096`，并让 `TPC` 前进 `2` 字节。同一指令束中的第二次 `c.setc.tgt` 即使其源可读，也会引发 `Fault_BundleControl`。当 `a0=4097` 时指令成功并存储该奇数值；若之后发生故障，那是在该值被选为指令地址时才发生。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.setc.tgt srcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_setc_tgt_16_736be9cada01 | C16 | 16 | 0x001c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_setc_tgt_16_736be9cada01 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_setc_tgt_16_736be9cada01 | SrcL | 5 | 0–31 | none | none | common scalar source: absolute GPR, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | common scalar source: absolute GPR, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SETC.TGT.asl -->
```asl
readonly func InstructionContractOperation_C_SETC_TGT() => ScalarOperation
begin
    return ScalarOperation_C_SETC_TGT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable inside one active Standard or Floating block. The first successful occurrence owns the block target; a second occurrence is illegal.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SETC.TGT.asl -->
```asl
readonly func InstructionContractHandler_C_SETC_TGT() => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;

readonly func InstructionContractTarget_C_SETC_TGT(
    source_value: Word)
    => Word
begin
    return source_value;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- C.SETC.TGT has no omitted operand. SrcL code zero names the architectural zero GPR and snapshots numeric zero.

## Legality

- All SrcL codes 0..31 are assigned common scalar sources; relative sources are non-consuming and must be available when the instruction executes.
- C.SETC.TGT is legal only while a Standard or Floating block is active. At most one C.SETC.TGT may complete successfully in that block.
- Target alignment is not checked by C.SETC.TGT; the block commit boundary validates the final selected BARG.BPCN.

## State effects

- Read and snapshot the complete selected 64-bit source, then atomically replace active BARG.BPCN with that value.
- Set the block-private successful-C.SETC.TGT marker only after the target snapshot succeeds. Do not retain the selector and do not modify the generic commit-condition argument.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Applicability and duplicate checks precede source readiness and source read. Source readiness precedes the BARG.BPCN update.
- Later changes to the source register or queue cannot alter the pending target.

## Exceptions

- No active Standard or Floating block, or a second successful C.SETC.TGT in the active block, raises Fault_BundleControl before source readiness or any state effect.
- An unavailable relative source raises Fault_IllegalInstruction before changing BARG.BPCN, the uniqueness marker, TPC, or queue state.
- An odd snapshotted target is accepted by C.SETC.TGT and raises Fault_InstructionPC only if the later block commit selects it.

## Examples

- c.setc.tgt a0
- c.setc.tgt T#1
