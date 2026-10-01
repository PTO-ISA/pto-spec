<!-- GENERATED FROM: asl/scalar/alu/LUI.asl -->
# LUI

**Normative ASL source:** `asl/scalar/alu/LUI.asl`

LUI sign-extends its encoded 20-bit immediate to XLEN, shifts it left by 12 bits, and publishes the result through RegDst.

## Normative identity {#PTO-INST-SCALAR-LUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lui-purpose role=purpose -->
## LUI 的作用

`LUI` 是一条 32 位编码的标量 ALU 指令，它物化 `SignExtend(imm20) << 12` 并通过一个 Reg5 目标发布 XLEN 值。它不读取任何标量寄存器。

发布值总是 `4096` 的倍数，其绝对值不超过 `2^31`，因此该指令物化的是位于一个字高 `20` 位上的有符号立即数。

<!-- PTO-READER-BLOCK: scalar-lui-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_LUI`，它返回 `MaterializeLUI(encoded_immediate)`。该辅助函数是 `LSL(SignExtend{PTO_XLEN}(immediate), 12)`：先对 `20` 位字段做符号扩展，然后左移。分派路径从 `ScalarOperation_LUI` 以 `ScalarDecodedBits20(instruction, form, ScalarField_imm20)` 调用它。

```asm
lui simm, ->{t, u, Rd}
```

设计要点：移位发生在符号扩展之后，因此负字段会把字的高位填满，而不是留下零。`imm20 = 0x80000` 物化出 `0xFFFFFFFF80000000`，而不是 `0x0000000080000000`。

<!-- PTO-READER-BLOCK: scalar-lui-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[7 +: 5]`，接收 XLEN 结果，或丢弃它。
- `imm20`，指令切片 `[12 +: 20]`，提供有符号的高位立即数。

没有 `SrcL` 或 `SrcR` 字段。目标使用通用映射：编码 `1..23` 写绝对 GPR，编码 `30` 推入 `U`，编码 `31` 推入 `T`，编码 `0` 与编码 `24..29` 丢弃。

设计要点：没有源字段，`LUI` 就没有可快照的读取，也没有需要检查的临时源可用性。唯一能影响结果的操作数是立即数，唯一被写入的状态是目标。

<!-- PTO-READER-BLOCK: scalar-lui-effects role=effects -->
## 效果与顺序

结果仅由编码立即数算出，随后通过 `RegDst` 发布。它没有更早的体系结构状态需要观察，因此顺序问题归结为这一次目标写入。

目标效果之后 `TPC` 前进 `4` 字节。`LUI` 不访问内存，也不改变数值状态、保留、描述符、Tile、指令束、特权与控制流状态；唯一可能的队列变化是由 `RegDst` 选择的那一次 `T` 或 `U` 推送。

<!-- PTO-READER-BLOCK: scalar-lui-constraints role=constraints -->
## 合法性与故障边界

两个编码字段都完全有定义：全部 `32` 个 `RegDst` 编码都被接受，`imm20` 的全部 `2^20` 个取值都合法。只有低位操作码字段是固定的，因此一旦形式译码成功，操作数合法性检查就没有可拒绝的对象。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则唯一可达的故障是与形式不匹配的编码在进入指令束主体之前于 `PC` 触发的 `Fault_IllegalInstruction`。不存在临时源不可用的故障，因为没有 Reg5 源。

设计要点：立即数是 `20` 位，因此 `SignExtend(imm20)` 的绝对值不超过 `2^19`，左移 `12` 位后不超过 `2^31`。所以对每个 `imm20` 取值，移位都停留在 XLEN 之内，从寄存器顶端移出的位是冗余符号位，每个 `imm20` 取值都物化出 `-2147483648` 到 `2147479552` 范围内一个不同的 `4096` 的倍数。

<!-- PTO-READER-BLOCK: scalar-lui-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `imm20 = 1` 时 `SignExtend(1)` 为 `1`，移位产生 `4096`，因此 `RegDst` 收到 `4096`。取 `imm20 = 0x80000` 时该字段为负，`SignExtend` 产生 `0xFFFFFFFFFFF80000`，发布值是 `0xFFFFFFFF80000000`。最大的正字段 `imm20 = 0x7FFFF` 发布 `0x7FFFF000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lui simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lui_32_982113b541d6 | L32 | 32 | 0x00000017 / 0x0000007f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lui_32_982113b541d6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lui_32_982113b541d6 | imm20 | 20 | encoding-defined | [{"instruction_lsb":12,"value_lsb":0,"width":20}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lui_32_982113b541d6 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| lui_32_982113b541d6 | imm20 | 20 | 0–1048575 | none | none | signed upper 20-bit immediate | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| imm20 | signed upper 20-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/LUI.asl -->
```asl
readonly func InstructionContractOperation_LUI() => ScalarOperation
begin
    return ScalarOperation_LUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/LUI.asl -->
```asl
readonly func InstructionContractHandler_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLUI;
end;

pure func InstructionContractResult_LUI(
    encoded_immediate: bits(20))
    => Word
begin
    return MaterializeLUI(encoded_immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Sign-extend imm20 to XLEN, shift left by 12, and discard overflow beyond XLEN.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- lui simm, ->{t, u, rd}
