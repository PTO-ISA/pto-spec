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

`BSTART.TEPL` 是 `TEPL` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-tepl-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
BSTART.TEPL is the unchanged Mode:Function carrier. It retires any active predecessor, installs one Tile-element block descriptor, and accepts either the VEC or SFU operation assigned to that selector.
BSTART.TEPL remains accepted compatibility input, but canonical assembly and disassembly select BSTART.VEC or BSTART.SFU from the operation's execution engine.
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。

<!-- PTO-READER-BLOCK: block-bstart-tepl-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 选择元素数据类型或继承哨兵；其确切分配域仍以下方生成契约为准。
- `Mode` 提供具名选择器或属性字段；其确切分配域仍以下方生成契约为准。
- `Function` 提供具名选择器或属性字段；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-tepl-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-tepl-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-tepl-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.TEPL Mode, Function, DataType
```

假设前序 Block 退休和目标检查成功，`BSTART.TEPL Mode, Function, DataType` 会打开待处理的 `BSTART.TEPL` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TEPL Mode, Function, DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | L32 | 32 | 0x00019181 / 0x000fffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

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
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
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
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | tile element data type selector | Encoded zero selects FP64. |
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
- DataType accepts 0..14, 16..20, and 24..28; 15, 21..23, and 29..31 are reserved.
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
