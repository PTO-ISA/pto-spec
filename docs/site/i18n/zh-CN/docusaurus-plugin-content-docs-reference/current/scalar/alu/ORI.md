<!-- GENERATED FROM: asl/scalar/alu/ORI.asl -->
# ORI

**Normative ASL source:** `asl/scalar/alu/ORI.asl`

ORI performs XLEN disjunction with a sign-extended signed 12-bit immediate.

## Normative identity {#PTO-INST-SCALAR-ORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ori-purpose role=purpose -->
## ORI 的作用

`ORI` 把 `SrcL` 与一个符号扩展的 `12` 位立即数做按位或，并发布完整的 `PTO_XLEN` 结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`simm12` 位于 `[20 +: 12]`。

该载体在掩码 `0x0000707f` 下匹配 `0x00003015`。由于立即数属于编码的一部分，该指令没有右源寄存器，也没有 `shamt` 字段：`ORI` 无法移位或变换其右操作数。

`simm12` 是有符号的，因此进入按位或的常量在符号扩展到 `PTO_XLEN` 后取值范围是 `-2048` 到 `2047`。

<!-- PTO-READER-BLOCK: scalar-ori-mechanism role=mechanism -->
## 结果形成方式

立即数解码器读取 `simm12`，由于其有符号性为 `signed`、宽度为 `12`，返回 `SignExtend{PTO_XLEN}(raw[11:0])`。随后分派路径在 `asl/scalar/model/dispatch/alu.asl:105-107` 处调用 `ScalarBinary(ScalarBinary_OR, left, right)`，并通过 `RegDst` 写入这个 `64` 位或运算结果。

```asm
ori SrcL, simm, ->{t, u, Rd}
```

设计要点：`12` 位立即数的符号扩展使 `ori` 可以用作负常量掩码构造器：`-1` 编码为 `0xFFF`，进入或运算时是 `0xFFFFFFFFFFFFFFFF`，因此 `ori a0, -1, ->a2` 发布全一值。

设计要点：这里没有移位阶段，因此把立即数模式放进高位的唯一办法是编码一个负值。想要置起第 `63` 位的程序使用 `simm12 = -1`，而不是移位。

<!-- PTO-READER-BLOCK: scalar-ori-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 使用 Reg5 源映射，`RegDst` 使用 Reg5 目标映射。立即数由指令译出，而不是从寄存器中选取。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，该读取永不消耗队列条目。
- `simm12`，指令切片 `[20 +: 12]`：从 `-2048` 到 `2047` 的每个值都有定义，并在按位或之前符号扩展到 `PTO_XLEN`。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，编码为零的立即数提供数值 `0`。

设计要点：`simm12` 的编码零是一个值，而不是省略标记：它提供 `0`，因此 `ori a0, 0, ->a2` 是利用或运算恒等式把 `a0` 的低 `PTO_XLEN` 位复制到 `a2` 的合法方式。

<!-- PTO-READER-BLOCK: scalar-ori-effects role=effects -->
## 效果与顺序

`SrcL` 在写目标之前取快照，因此与源同名的目标使用执行前的值。随后结果发布，`TPC` 推进 `4` 字节。

`ORI` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权或控制流状态；仅当目标是 `30` 或 `31` 时它才会移动临时队列。

设计要点：立即数没有寄存器，因此无法被重命名或入队。发布的值始终是一个快照后的 GPR 或队列槽位与编码本身的函数，这使 `ORI` 可以在不需要第二个源寄存器的情况下构造常量掩码。

<!-- PTO-READER-BLOCK: scalar-ori-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码以及全部 `4096` 个立即数取值都有定义，该形式没有约束条目。唯一固定要求是掩码 `0x0000707f` 所选出的载体位匹配 `0x00003015`，因为 `simm12` 占据全部十二个指令位 `31:20`。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`；对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `ORI` 而言这要求存在挂起的系统块终止请求；所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。每项检查都先于目标效果与 `TPC` 推进。

设计要点：立即数不可能越界。`simm12` 是完整的 `12` 位字段，每个模式都有定义，因此没有保留的立即数编码，也没有任何操作数取值会选择陷阱。

<!-- PTO-READER-BLOCK: scalar-ori-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `0x00F0` 时，`ori a0, 15, ->a2` 发布 `0x00FF`，因为 `15` 符号扩展后仍是同一个值。

当 `a0` 为 `0`、`simm12` 编码为 `-2048` 时，符号扩展后的立即数是 `0xFFFFFFFFFFFFF800`，因此 `a2` 收到该值。把 `simm12` 编码为 `-1` 则发布全一值。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ori_32_413a6cc76e9a | L32 | 32 | 0x00003015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ori_32_413a6cc76e9a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ori_32_413a6cc76e9a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ori_32_413a6cc76e9a | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ori_32_413a6cc76e9a | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| ori_32_413a6cc76e9a | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| ori_32_413a6cc76e9a | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ORI.asl -->
```asl
readonly func InstructionContractOperation_ORI()
    => ScalarOperation
begin
    return ScalarOperation_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ORI.asl -->
```asl
readonly func InstructionContractHandler_ORI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ORI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ORI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal and is sign-extended to PTO_XLEN before the disjunction.

## State effects

- Sign-extend simm12 to PTO_XLEN, compute the bitwise disjunction with the snapshotted SrcL value, and publish the complete XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- ORI raises no arithmetic exception; bitwise disjunction is defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- ori a0, -1, ->a0
- ori t#1, 2047, ->u
- ori zero, -2048, ->zero
