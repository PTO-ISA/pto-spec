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

`BSTART.SFU` 是使用现有 32 位 `BSTART.TEPL` 编码承载 SFU 操作时的规范拼写。它是 encoding alias，不是独立编码的 Block 起始命令。

<!-- PTO-READER-BLOCK: block-bstart-sfu-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
TileOp resolves to one assigned TEPL Mode:Function selector whose execution engine is SFU; the alias adds no encoding bits or ownership.
The resulting block uses the same descriptor, header composition, commit, and rollback rules as BSTART.TEPL.
```

alias 解析把 `TileOp` 映射到执行引擎为 SFU 的已分配 TEPL `Mode:Function`，随后使用不变的 `BSTART.TEPL` carrier 位和起始处理程序。最终描述符、header 执行、提交与回滚均沿用 TEPL 路径；该 alias 不增加状态或编码字段。

<!-- PTO-READER-BLOCK: block-bstart-sfu-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `TileOp` 提供具名选择器或属性字段；其确切分配域仍以下方生成契约为准。
- `DataType` 选择元素数据类型或继承哨兵；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-sfu-effects role=effects -->
## 待处理状态与完成

适用性、SFU 引擎匹配、carrier 字段和描述符合法性都会在前序 Block 退休前检查。退休成功后，解析得到的 TEPL 描述符进入待处理状态；只有完整 Block 提交时，选中的 SFU 操作才会执行。

<!-- PTO-READER-BLOCK: block-bstart-sfu-constraints role=constraints -->
## 合法性与故障边界

未知 `TileOp`、属于其他引擎的选择器、TEPL selector hole 或保留 `DataType`，都会在前序 Block 退休或新 `BARG` 影响之前被拒绝。前序退休失败会保留前序 Block，并且不发布 alias 描述符。

<!-- PTO-READER-BLOCK: block-bstart-sfu-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.SFU TEXP, FP32
```

`BSTART.SFU TEXP, FP32` 把 TEXP 解析为已分配的 SFU `Mode:Function`，并发出已有的 `BSTART.TEPL` carrier。前序 Block 退休成功后，这个继承的 TEPL 描述符保持待处理状态，直到完整 TEXP Block 提交。
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
| bstart_tepl_32_d022db6dacb3 | L32 | 32 | 0x00019181 / 0x000fffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

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
