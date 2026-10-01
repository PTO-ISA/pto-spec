<!-- GENERATED FROM: asl/block/execution/BSTART.TEPL.asl -->
# BSTART.TEPL

**Normative ASL source:** `asl/block/execution/BSTART.TEPL.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TEPL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tepl-purpose role=purpose -->
## BSTART.TEPL 的作用

`BSTART.TEPL` 是唯一由其 `Mode` 与 `Function` 字段选择操作的 32 位编码，它选出的每个操作都在 VEC 或 SFU 引擎上运行。其 `Mode` 和 `Function` 字段组成一个七位选择器来命名操作，`DataType` 字段命名元素类型。

规范汇编从不输出 `BSTART.TEPL`。它输出带操作名的 [BSTART.VEC](BSTART.VEC.md) 或 [BSTART.SFU](BSTART.SFU.md)，两个别名都产生完全相同的位。`BSTART.TEPL` 仍作为兼容输入被接受。

<!-- PTO-READER-BLOCK: block-bstart-tepl-mechanism role=mechanism -->
## 位置与机制

[译码](../model/dispatch/decode.md)构建操作描述符：类别为 Tile 元素，`mode` 来自 `Mode`，选择器位 `4:0` 来自 `Function`，外加数据类型。Tile 译码码由位 `6:5` 的 `Mode` 与位 `4:0` 的 `Function` 组成。

随后[指令束启动分派](../model/dispatch/start.md)在提交任何前驱之前，用[描述符合法性](../model/dispatch/descriptor-legality.md)检查该描述符。译码码必须命名 TEPL 族中已分配的操作，数据类型必须是具体类型。两者都满足时，分派提交前驱、打开块并安装描述符。

操作本身稍后运行。在 `BSTOP` 或下一条 `BSTART` 时，[提交验证](../model/commit/validation.md)调用 [Tile 执行分派](../model/dispatch/tile-execution.md)，由它验证指令束并运行操作，例如对 `TADD` 运行 `ExecuteTileBinary`。

设计要点：操作身份放在一个选择器中，形状、属性与操作数来自共享的 header 命令 `B.DIM`、`B.DATR` 和 `B.IOT`。因此所有 VEC 与 SFU 操作共用同一种起始编码、同一种描述符格式和同一条提交路径。

<!-- PTO-READER-BLOCK: block-bstart-tepl-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `Mode` 位于位 `26:25`，是选择器的高位部分。
- `Function` 位于位 `24:20`，是选择器的低位部分。`TADD` 为 `Mode` 0 `Function` 0，`TEXP` 为 `Mode` 0 `Function` 18。
- `DataType` 位于位 `31:27`，是元素类型。接受编码 0 到 21 以及 24 到 28；22、23 以及 29 到 31 保留。编码零选择 `FP64`。

块 schema 的其余部分属于所选操作自己的页面。例如 `TADD` 需要 `B.DIM LB0` 和一条带两个源与一个目标的终止 `B.IOT`。

<!-- PTO-READER-BLOCK: block-bstart-tepl-effects role=effects -->
## 待处理状态与完成

前驱提交后，起始命令写入 `BPC`、块类型为 Tile 元素且转移为 `Fallthrough` 的 `BARG`，以及操作描述符。`TPC` 移到下一条指令。起始命令本身不分配 Tile、不读取源，也没有内存效果。

提交时，失败的操作使块保持有效且 header 完整，并且 Tile 执行所有者已回滚其目标。成功的操作发布其目标，块在顺序后续地址继续。

<!-- PTO-READER-BLOCK: block-bstart-tepl-constraints role=constraints -->
## 合法性与故障边界

- 保留的 `DataType` 编码不满足操作数合法性，引发 `Fault_IllegalInstruction`。
- 未分配的 `Mode:Function` 选择器不满足描述符合法性，引发 `Fault_IllegalInstruction`。

这两项检查都先于前驱提交和 `BARG` 变化，因此被拒绝的 `BSTART.TEPL` 不会触动有效前驱。

设计要点：`DTYPE_NONE`（编码 31）在该编码中保留。只有 `TMOV` 能从源推断类型，而 `TMOV` 不是 TEPL 操作，因此每个 VEC 或 SFU 块的 `BSTART.TEPL` 起始命令都命名具体类型。

操作特定的合法性，例如所选操作不支持的类型或格式错误的 `B.IOT`，在提交时检查并在那里产生故障。

<!-- PTO-READER-BLOCK: block-bstart-tepl-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.TEPL 0, 0, FP32
```

`Mode` 0、`Function` 0 选择 `TADD`，`DataType` 1 选择 `FP32`。以匹配值 `0x00019181` 为基础，在位 `31:27` 放入 `DataType` 1 得到指令字 `0x08019181`。规范反汇编把同一个字输出为 `BSTART.VEC TADD, FP32`。把 `Function` 改为 18 得到 `0x09219181`，它选择 `TEXP`，反汇编为 `BSTART.SFU TEXP, FP32`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TEPL Mode, Function, DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | L32 | 32 | 0x00019181 / 0x000fffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| bstart_tepl_32_d022db6dacb3 | Mode | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| bstart_tepl_32_d022db6dacb3 | Function | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | 0–21, 24–28 | none | 22–23, 29–31 | tile element data type selector | Encoded zero selects FP64. |
| bstart_tepl_32_d022db6dacb3 | Mode | 2 | 0–3 | none | none | execution mode selector | Encoded zero supplies numeric zero for the execution mode selector. |
| bstart_tepl_32_d022db6dacb3 | Function | 5 | 0–31 | none | none | tile operation function selector | Encoded zero supplies numeric zero for the tile operation function selector. |

- `bstart_tepl_32_d022db6dacb3.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |
| Mode | execution mode selector |
| Function | tile operation function selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TEPL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TEPL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tepl_32_d022db6dacb3);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL is the unchanged Mode:Function carrier. It retires any active predecessor, installs one Tile-element block descriptor, and accepts either the VEC or SFU operation assigned to that selector.
BSTART.TEPL remains accepted compatibility input, but canonical assembly and disassembly select BSTART.VEC or BSTART.SFU from the operation's execution engine.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TEPL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TEPL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

pure func InstructionContractAcceptsEngineAlias_BSTART_TEPL(
    engine: TileExecutionEngine) => boolean
begin
    return TileEngineHasCanonicalBundleStartAlias(engine);
end;

pure func InstructionContractAcceptsTileOperation_BSTART_TEPL(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_TEPL, operation);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No operand field is omitted; every encoded field has the value carried by the selected form.

## Legality

- Mode:Function is a seven-bit selector with Mode in bits 6:5 and Function in bits 4:0.
- Only assigned TEPL-carried operations are legal; unassigned selector holes reject before effects.
- DataType accepts 0..14, 15..21, and 24..28; 22, 23, and 29..31 are reserved.
- BSTART.TEPL is compatibility input only; canonical output uses the operation's VEC or SFU alias.

## State effects

- After successful predecessor retirement, installs the selected Tile-element descriptor and a BARG whose BlockType denotes the Tile-element block.
- The selected operation executes only when BSTOP or the next BSTART commits the completed block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Carrier field, selector, operation, engine, and descriptor legality precede predecessor retirement and BARG publication.

## Exceptions

- Reserved DataType codes, unassigned Mode:Function selectors, non-TEPL operations, or invalid descriptors raise before predecessor retirement or new BARG effects.
- An accepted selector whose operation is not assigned to VEC or SFU is illegal for this carrier.

## Examples

- BSTART.TEPL 0, 0, FP32
