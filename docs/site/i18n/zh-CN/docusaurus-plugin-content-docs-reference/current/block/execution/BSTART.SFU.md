<!-- GENERATED FROM: asl/block/execution/BSTART.SFU.asl -->
# BSTART.SFU

**Normative ASL source:** `asl/block/execution/BSTART.SFU.asl`

Canonical Block-start spelling for an operation assigned to the SFU execution engine.

## Normative identity {#PTO-INST-BLOCK-BSTART-SFU}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-sfu-purpose role=purpose -->
## BSTART.SFU 的作用

`BSTART.SFU` 是启动其操作在 SFU 引擎上运行的块的规范写法，例如 `TEXP`、`TDIV` 或 `TSQRT`。它是编码别名：没有自己的位。`BSTART.SFU TileOp, DataType` 把 `TileOp` 解析为其 `Mode:Function` 选择器，并以该选择器和 `DataType` 生成 [BSTART.TEPL](BSTART.TEPL.md) 指令字。

规范汇编与反汇编对每个 SFU 操作使用 `BSTART.SFU`，对每个 VEC 操作使用 [BSTART.VEC](BSTART.VEC.md)。

<!-- PTO-READER-BLOCK: block-bstart-sfu-mechanism role=mechanism -->
## 位置与机制

别名所有者把每个部分映射到 `BSTART.TEPL`：`InstructionContractMatches_BSTART_SFU` 匹配 TEPL 形式，`InstructionContractHandler_BSTART_SFU` 返回 TEPL 处理器 `CommandHandler_ExecuteBundleStart`。因此执行过程与 TEPL 路径完全相同。

1. [指令束启动分派](../model/dispatch/start.md)在提交任何前驱之前检查译码后的描述符。
2. 它提交前驱、打开 Tile 元素块并安装描述符。
3. 在 `BSTOP` 或下一条 `BSTART` 时，[Tile 执行分派](../model/dispatch/tile-execution.md)验证指令束并运行操作。

`TileTEPLAliasAcceptsOperation(TileTEPLAlias_SFU, operation)` 定义别名接受哪些名称：操作必须使用 TEPL 载体，且执行引擎必须是 SFU。

设计要点：一些 SFU 操作保留位于 VEC 选择器之间的 TEPL 选择器。`TEXP` 为 `Mode` 0 `Function` 18，`TDIV` 为 `Mode` 0 `Function` 3。引擎是操作的属性，因此写法随引擎而定，选择器位保持不变。

<!-- PTO-READER-BLOCK: block-bstart-sfu-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `TileOp` 命名一个由 TEPL 承载的 SFU 操作。它转换为 `Mode` 和 `Function`。
- `DataType` 是元素类型，编码方式与 `BSTART.TEPL` 相同。它必须是具体类型。

其余 header 命令由所选操作决定。对 `TEXP` 而言，是 `B.DIM LB0`、可选的 `LB1`、`LB2` 与 `B.DATR`，以及一条带一个 Local 源和一个新 Local 目标的终止 `B.IOT`。

<!-- PTO-READER-BLOCK: block-bstart-sfu-effects role=effects -->
## 待处理状态与完成

别名不增加任何状态。前驱提交后，起始命令安装与解析出的选择器和 `DataType` 完全对应的 TEPL 描述符，把块类型设为 Tile 元素，并把 `TPC` 移到下一条指令。

所选 SFU 操作只在块提交时运行。成功时它原子地发布目标；失败时块保持有效，其目标被回滚。起始命令没有内存效果。

<!-- PTO-READER-BLOCK: block-bstart-sfu-constraints role=constraints -->
## 合法性与故障边界

`BSTART.SFU` 只接受 `TileTEPLAliasAcceptsOperation` 对 SFU 认可的名称。未知名称、`TADD` 等 VEC 操作，或 TLSU、CUBE 操作都没有 `BSTART.SFU` 写法。

对于生成的指令字，TEPL 检查先于前驱提交：保留的 `DataType` 编码或未分配的选择器引发 `Fault_IllegalInstruction`，有效前驱保持不变。

设计要点：由于别名与 `BSTART.TEPL` 产生相同的位，任何程序都无法观察到两者的差别。它们安装相同的描述符，并以相同方式产生故障。

<!-- PTO-READER-BLOCK: block-bstart-sfu-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.SFU TEXP, FP32
```

`TEXP` 解析为 `Mode` 0 `Function` 18，`FP32` 为 `DataType` 1，因此生成的指令字为 `0x09219181`，与 `BSTART.TEPL 0, 18, FP32` 相同。完整的指令束再加上 `B.DIM` 命令和一条命名源与目标的 `B.IOT`，然后是 `BSTOP`。同一指令束的宏形式写作 `TEXP <Row=8, Col=64, FP32>, T#1, ->T<2KB>`。
<!-- SUPPLEMENTARY-END -->

## Alias contract

- **Encoding owner:** `BSTART.TEPL`
- **Canonical engine:** `SFU`

## Assembly

```asm
BSTART.SFU TileOp, DataType
```

## Encoding

This spelling reuses the exact encoding owned by `BSTART.TEPL`.

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

- **Class:** `encoding-alias`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| TileOp | assigned SFU operation mnemonic that resolves the Mode:Function selector |
| DataType | tile element data type selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.SFU.asl -->
```asl
readonly func InstructionContractMatches_BSTART_SFU(
    operation: CommandOperation) => boolean
begin
    return InstructionContractMatches_BSTART_TEPL(operation);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TileOp resolves to one assigned TEPL Mode:Function selector whose execution engine is SFU; the alias adds no encoding bits or ownership.
The resulting block uses the same descriptor, header composition, commit, and rollback rules as BSTART.TEPL.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.SFU.asl -->
```asl
readonly func InstructionContractHandler_BSTART_SFU() => CommandSemanticHandler
begin
    return InstructionContractHandler_BSTART_TEPL();
end;

pure func InstructionContractAliasEngine_BSTART_SFU() => TileExecutionEngine
begin
    return TileEngine_SFU;
end;

pure func InstructionContractAcceptsTileOperation_BSTART_SFU(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_SFU, operation);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.SFU is a canonical engine alias for BSTART.TEPL; it owns no separate encoding or default.

## Legality

- TileOp must name an assigned direct operation carried by BSTART.TEPL and assigned to SFU.
- The spelling owns no separate encoding; the resolved Mode:Function and DataType bits are exactly the BSTART.TEPL carrier bits.
- Canonical assembly and disassembly use BSTART.SFU for every SFU operation.

## State effects

- Installs exactly the BSTART.TEPL descriptor resolved from TileOp and DataType; this alias has no additional state.
- The selected SFU operation executes only when the block commits.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Alias resolution, SFU-engine match, carrier fields, and descriptor legality precede predecessor retirement and BARG publication.

## Exceptions

- An unknown TileOp, selector hole, VEC/TLSU/CUBE operation, reserved DataType, or invalid descriptor raises before predecessor retirement or new BARG effects.

## Examples

- BSTART.SFU TEXP, FP32
