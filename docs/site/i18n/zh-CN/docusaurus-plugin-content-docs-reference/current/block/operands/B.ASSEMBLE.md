<!-- GENERATED FROM: asl/block/operands/B.ASSEMBLE.asl -->
# B.ASSEMBLE

**Normative ASL source:** `asl/block/operands/B.ASSEMBLE.asl`

Decodes one writer-range assemble modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.

## Normative identity {#PTO-INST-BLOCK-B-ASSEMBLE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-assemble-purpose role=purpose -->
## B.ASSEMBLE 的作用

`B.ASSEMBLE` 是一条 32 位头部命令，把紧邻其前的绑定命令的目标变为多块构建中的一个写入者。绑定命令是 `B.IOT` 或 `B.IOS`。这种构建称为世代：一个父 Tile 由多个块或多个 PE 按范围写入，并在 LAST 时发布一次。

与 `B.SUBVIEW` 一样，该命令是范围修饰符。它附着于绑定命令并记录字段；执行时不分配任何内容。参见[范围修饰符](../model/operands/range-modifiers.md)、[Local 世代](../model/operands/local-generation.md)与 [Shared 世代](../model/operands/shared-generation.md)。

<!-- PTO-READER-BLOCK: block-b-assemble-mechanism role=mechanism -->
## 阶段与机制

`INIT` 与 `LAST` 选择四个阶段之一：

- INIT（`INIT = 1`，`LAST = 0`）开始一个世代。绑定命令的目标 `SizeCode` 成为父容量，并分配父 Tile。
- MIDDLE（`INIT = 0`，`LAST = 0`）向打开的世代添加一个写入者。
- LAST（`INIT = 0`，`LAST = 1`）添加最后一个写入者并关闭世代。
- INIT_LAST（`INIT = 1`，`LAST = 1`）在一个块中开始并关闭世代。

续写阶段（MIDDLE 或 LAST）在两类存储上以不同方式指定父 Tile。对 Local Tile，绑定命令没有目标，绑定命令的最后一个源槽位成为父引用，而不是数据源。对 Shared Tile，`SizeCode = 0` 的最后一条 `B.IOS` 被复用为打开世代的目标。

设计要点：Local 父 Tile 通过 `T#1` 这类普通相对选择器指定。INIT 把父 Tile 发布到普通相对队列中，不存在私有的组装命名空间。因此续写阶段查找父 Tile 的方式与任何源查找 Tile 的方式相同。

<!-- PTO-READER-BLOCK: block-b-assemble-inputs role=inputs-outputs -->
## 字段与编码值

- `INIT`（位 31）为 1 时选择 INIT 或 INIT_LAST，为 0 时选择 MIDDLE 或 LAST。
- `uimm11`（位 30:20）是无符号加数，零扩展。零是真实的零。
- `RegSrc`（位 19:15）指定绝对 GPR 0 至 23。编码零指零 GPR。
- `LAST`（位 11）标记最后一个写入者。
- `WriterSizeCode`（位 10:7）是本写入者范围的大小：Local 范围组为 1 至 10，Shared 范围组为 1 至 12，从 128 B 起。原始编码 13 至 15 保留。

写入者偏移为 `GPR[RegSrc] + uimm11`（模 2^XLEN），以父 Tile 的 128 字节 CELL 计数。处理程序把原始字段与该偏移存入目标的范围记录。

设计要点：在每个阶段，`WriterSizeCode` 都是当前写入者的大小，而不是父 Tile 的大小。父容量来自 INIT 绑定命令的 `SizeCode`，因此一个父 Tile 可以由多个较小的写入者填充，它们的范围必须位于父 Tile 之内，并且在共享 PE 上不得重叠。

<!-- PTO-READER-BLOCK: block-b-assemble-effects role=effects -->
## 记录的状态与发布

被接受的 `B.ASSEMBLE` 只改变绑定命令的范围记录；对于 Local 续写阶段，它还把最后一个源移入父引用。它不读取 Tile 载荷。

操作成功后，写入者的 CELL 被标记为已覆盖。在 LAST 时世代关闭。只有当每个参与 PE 都满足条件时，世代才被标记为已发布，这要求每个必需 CELL 对该 PE 既已覆盖也已就绪。

设计要点：零参与的绑定命令（`PEMode = 000`）会打开零模式范围组。在该组中，每条原始字段合法的 `B.ASSEMBLE` 只经过范围组已打开的检查，不读取 GPR，也不记录任何内容。

<!-- PTO-READER-BLOCK: block-b-assemble-constraints role=constraints -->
## 合法性与故障边界

- `RegSrc` 编码为 24 至 31、原始 `WriterSizeCode` 为 13 至 15，或固定位非零时，在读取任何 GPR 之前引发 `Fault_IllegalInstruction`。
- 附着于参与的 Local 范围组的 `WriterSizeCode` 11 或 12 引发 `Fault_TileLegality`。
- 没有打开的范围组、INIT 所在绑定命令没有未使用的目标角色、续写阶段所在绑定命令带有目标，或参与范围组中写入者大小编码为 0 时，引发 `Fault_BundleControl`。
- 在阶段 2 准备期间，范围超出父 Tile、范围在共享 PE 上与较早写入者重叠、写入者掩码不是世代掩码的子集，或父引用未指向打开的世代时，在操作效果之前引发故障。
- 有多个参与 PE 且没有 `B.ASSEMBLE` 的 Shared 目标引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-b-assemble-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.IOT T#2, mask=1111, <last>, ->T<4KB>
B.ASSEMBLE 1, 0, zero, 0, 5
```

该块开始一个 Local 世代。绑定命令的 `SizeCode` 6 产生 4 KiB 父 Tile，即 32 个 CELL。修饰符是 INIT 而非 LAST，偏移为 0 + 0 = 0，写入者大小编码为 5，即 2 KiB 或 16 个 CELL，编码为 `0x800012d3`。提交后，CELL 0 至 15 已覆盖，父 Tile 成为新的 `T#1`。之后的块 `B.IOT T#2, T#1, mask=1111, <last>` 接 `B.ASSEMBLE 0, 1, zero, 16, 5`（编码 `0x01001ad3`）以 `T#1` 作为父引用，从其源 `T#2` 写入 CELL 16 至 31，并关闭世代。若第二个块的偏移为 8，将与 CELL 8 至 15 重叠并引发故障。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.ASSEMBLE INIT, LAST, RegSrc, uimm11, WriterSizeCode
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_assemble_32_122000000002 | L32 | 32 | 0x00001053 / 0x0000707f | [{"field":"INIT","operator":"one-of","values":[0,1]},{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"WriterSizeCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_assemble_32_122000000002 | INIT | 1 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":1}] |
| b_assemble_32_122000000002 | uimm11 | 11 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":11}] |
| b_assemble_32_122000000002 | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_assemble_32_122000000002 | LAST | 1 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":1}] |
| b_assemble_32_122000000002 | WriterSizeCode | 4 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_assemble_32_122000000002 | INIT | 1 | 0–1 | none | none | selects INIT versus MIDDLE/LAST form | Zero selects MIDDLE/LAST rather than INIT/INIT_LAST. |
| b_assemble_32_122000000002 | uimm11 | 11 | 0–2047 | none | none | unsigned XLEN addend | Zero is a real zero displacement. |
| b_assemble_32_122000000002 | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR selector | Zero names the architectural zero GPR. |
| b_assemble_32_122000000002 | LAST | 1 | 0–1 | none | none | marks the final assembler carrier | One closes the modifier sequence at the semantic assembler. |
| b_assemble_32_122000000002 | WriterSizeCode | 4 | 0–12 | none | 13–15 | current writer extent code | Zero is reserved for discarded groups; participating writers require a nonzero extent. |

- `b_assemble_32_122000000002.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_assemble_32_122000000002.WriterSizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| INIT | selects INIT versus MIDDLE/LAST form |
| LAST | marks the final assembler carrier |
| RegSrc | absolute GPR selector |
| uimm11 | unsigned XLEN addend |
| WriterSizeCode | current writer extent code |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.ASSEMBLE.asl -->
```asl
readonly func InstructionContractMatches_B_ASSEMBLE(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_b_assemble_32_122000000002;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Immediately follows B.IOT or B.IOS and is contiguous with the associated modifier group.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.ASSEMBLE.asl -->
```asl
pure func InstructionContractWriterSizeCodeIsRawLegal_B_ASSEMBLE(code: integer {0..15}) => boolean
begin
    return code <= 12;
end;

readonly func InstructionContractHandler_B_ASSEMBLE() => CommandSemanticHandler
begin
    return CommandHandler_ApplyBundleAssemble;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- uimm11 is unsigned and zero-extended. RegSrc zero names the architectural zero GPR. INIT=0 encodes MIDDLE/LAST; INIT=1 encodes INIT/INIT_LAST.

## Legality

- RegSrc accepts only absolute GPR selectors 0..23.
- WriterSizeCode raw values 0..12 are decoded; raw values 13..15 are reserved and raise Fault_IllegalInstruction; INIT/size combinations select INIT, MIDDLE, LAST, or INIT_LAST and contradictory combinations are BundleControl.
- Local WriterSizeCode values 1..10 and Shared WriterSizeCode values 1..12 are accepted in every phase; Local continuation identity is carried by the final source-form binder slot, while Shared continuation reuses the final B.IOS SizeCode=0 destination and selects the exact OPEN Sx generation.
- The modifier is legal only in the contiguous immediately preceding binder group and follows source roles.

## State effects

- Store raw INIT/LAST/RegSrc/uimm11/WriterSizeCode and the derived XLEN offset in the destination carrier of the open binder group.
- PEMode=000 on the binder opens a discarded syntactic group; every raw-legal contiguous modifier advances TPC without reads, state, role, or fault effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode fixed/reserved fields and raw ranges before any GPR read; compute GPR[RegSrc]+ZeroExtend(uimm11) modulo 2^XLEN after group legality.

## Exceptions

- Reserved funct3/opcode and RegSrc24..31 raise Fault_IllegalInstruction before GPR reads, carrier updates, or TPC advance; raw WriterSizeCode 13..15 is reserved and raises Fault_IllegalInstruction.
- Participating INIT, MIDDLE, and LAST writers require a legal nonzero WriterSizeCode; raw reserved codes raise Fault_IllegalInstruction.
- Missing, reversed, duplicate, intervening, or role-incompatible groups raise Fault_BundleControl.

## Examples

- B.IOT T0, mask=1111, ->T1<1>; B.ASSEMBLE 1, 1, a0, 0, 10
