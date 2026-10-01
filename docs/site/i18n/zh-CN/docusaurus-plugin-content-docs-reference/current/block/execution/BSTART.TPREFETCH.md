<!-- GENERATED FROM: asl/block/execution/BSTART.TPREFETCH.asl -->
# BSTART.TPREFETCH

**Normative ASL source:** `asl/block/execution/BSTART.TPREFETCH.asl`

Prefetches one typed, strided GM rectangle for each of the four PEs without a Tile destination.

## Normative identity {#PTO-INST-BLOCK-BSTART-TPREFETCH}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tprefetch-purpose role=purpose -->
## BSTART.TPREFETCH 的作用

`BSTART.TPREFETCH` 打开一个 Tile 内存指令束，其操作为 `TPREFETCH`：在全部四个 PE 上对全局内存（GM）做带类型的步长读取，不产生任何 Tile。它是一个 32 位字（匹配值 `0x00311181`，掩码 `0x07ffffff`），`DataType` 位于位 31 到 27。该形式携带固定的 TLSU 选择器 3。

成功时的架构结果仅限于加载事件及其顺序。Tile 或 Shared 的描述符、分配、载荷、已定义性或发布状态都不改变。缓存层级、放置与保留不是架构结果。

设计要点：起始命令不读取内存。[指令束启动分派](../model/dispatch/start.md)验证描述符并提交任何有效的前驱，预取在该指令束被提交时执行，例如在 `BSTOP`、下一条 `BSTART`、trace `B.HINT` 或架构进入请求处。保留的 `DataType` 编码在 `BSTART` 处引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-mechanism role=mechanism -->
## 放置与执行机制

提交时，[Tile 执行](../model/dispatch/tile-execution.md)在所有较早的专用选择器都不匹配之后到达 [TPREFETCH 处理程序](../model/dispatch/tlsu-prefetch.md)。处理程序检查类型、没有 Tile 绑定、`B.IOR` 记录、维度与数据属性，然后调用 `TPREFETCHCore`。

对四个 PE 中的每一个以及 `ValidRow x ValidCol` 中的每个元素，地址为 `base + (row * row_stride_elements + column) * element_size`。打包四位类型使用与 `TLOAD` 相同的逻辑元素字节寻址。

设计要点：`TPREFETCHCore` 在记录第一个加载事件之前探测每个 PE 的每个元素。因此任何 PE 上的转换或权限故障都不会留下任何 PE 的加载事件。契约把四个访问范围称为一次合并尝试，恢复时重新发出完整的访问范围。

设计要点：没有可携带 `PE_MASK` 的 Tile 绑定，因此参与关系隐含为 `1111`。每个 PE 根据自己的基址与步长 GPR 计算自己的访问范围，四个访问范围一起检查。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `DataType` 是预取的元素类型；接受编码 0 到 14、16 到 20 以及 24 到 28。
- `B.DIM` 的 `LB0`、`LB1` 和 `LB2` 给出 ValidCol、ValidRow 和物理 Col。省略的 `LB0` 与 `LB1` 默认为一，省略的 `LB2` 默认为解析后的 ValidCol。
- 可选的 `B.IOR` 在 `RegSrc0` 中给出每个 PE 的基址，在 `RegSrc1` 中给出行步长，均从该 PE 自己的 GPR 读取。省略时基址为零，步长为 Col。
- `B.IOT` 与 `B.IOS` 不是 `TPREFETCH` 指令束的成员。

设计要点：这里的行步长以元素计，而非字节。`TPREFETCHCore` 把 `row * row_stride_elements + column` 乘以元素大小，而 `TLOAD` 与 `TSTORE` 把 `RegSrc1` 当作字节步长。因此同一个 GPR 值对两类操作描述的是不同的访问范围。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-effects role=effects -->
## 状态效果与顺序

成功时，每个 PE 为每个有效元素记录一个带类型的加载事件，事件分解与 `TLOAD` 相同。所有访问都以指令束的 `aq` 与 `rl` 属性参与 PTO-RC，与 `TLOAD` 完全一致。

不写任何寄存器。由于没有 Tile 绑定，最后的 `FinalizeBundleTileAttempt` 不发布任何内容。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-constraints role=constraints -->
## 合法性、故障与原子性

每个维度必须在 1 到 65535 之间，ValidCol 不得超过 Col，Col 必须是非零的 2 的幂，且 `ValidRow * ValidCol` 不得超过 `PTO_MODEL_TILE_ELEMENTS`。这些失败、不支持的类型、格式错误的 `B.IOR`，或任何 `B.IOT` 或 `B.IOS`，都在第一次探测之前引发 `Fault_TileLegality`。

设计要点：省略与编码零不同。省略的 `B.DIM` 有效值为一，但显式零仍是一个值并会引发故障。由于省略的 `LB2` 等于 ValidCol，ValidCol 为 48 且没有 `LB2` 的指令束其 Col 为 48，不是 2 的幂，同样引发故障。

<!-- PTO-READER-BLOCK: block-bstart-tprefetch-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
BSTART.TPREFETCH FP16
B.DIM zero, 64, ->LB0
B.DIM zero, 4, ->LB1
B.DIM zero, 64, ->LB2
B.IOR zero, a0
BSTOP
```

每个 PE 预取 4 x 64 = 256 个 `FP16` 元素，因此在全部 1024 次探测成功之后，指令束记录 1024 个加载事件。`RegSrc0` 为 `zero`，是真实的零基址。在 `a0` 为 64 的 PE 上，元素（3, 63）位于 `(3 * 64 + 63) * 2`，即字节 510。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TPREFETCH DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tprefetch_32_d5f83e5aadf6 | L32 | 32 | 0x00311181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tprefetch_32_d5f83e5aadf6 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tprefetch_32_d5f83e5aadf6 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | prefetched element data type | Encoded zero selects FP64. |

- `bstart_tprefetch_32_d5f83e5aadf6.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | prefetched element data type |
| B.IOR.RegSrc0 | each PE's private-GPR GM base |
| B.IOR.RegSrc1 | each PE's private-GPR logical row stride in elements |
| B.DIM.LB0 | ValidCol |
| B.DIM.LB1 | ValidRow |
| B.DIM.LB2 | physical Col |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TPREFETCH.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TPREFETCH(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tprefetch_32_d5f83e5aadf6);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TPREFETCH DataType; optional B.DATR Layout; optional B.DIM LB0/ValidCol, LB1/ValidRow, LB2/Col; optional B.IOR base,row_stride; BSTOP
B.IOT and B.IOS are not members of a TPREFETCH block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TPREFETCH.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TPREFETCH() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TPREFETCH()
    => TileOperation
begin
    return TileOperation_TPREFETCH;
end;

pure func InstructionContractStartsTileBundle_BSTART_TPREFETCH()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit and B.DATR omission selects NORM layout.
- Omitted LB0 and LB1 each default to one; omitted LB2 defaults to resolved ValidCol.
- Omitted B.IOR supplies base zero and row stride equal to resolved Col independently for every PE. Explicit zero selectors read the architectural zero GPR and therefore supply actual zero values.

## Legality

- bstart_tprefetch_32_d5f83e5aadf6.DataType accepts only 0..14, 16..20, 24..28; all other encodings are reserved.
- TPREFETCH has implicit PE participation 1111 and no Local or Shared Tile binding.
- ValidCol and ValidRow are positive, Col is a nonzero power of two, and ValidCol does not exceed Col.

## State effects

- Starts a destination-free TLSU block whose successful architectural effects are limited to its defined typed memory accesses and ordering events.
- No Tile or Shared descriptor, allocation, payload, definedness, publication, or lifetime state changes.

## Memory effects and ordering

### Memory effects

- For every PE and every element in ValidRow x ValidCol, access GM at base + ((row * row_stride_elements + column) * element_size), with packed four-bit types using the same logical-element byte addressing as TLOAD.
- The operation produces the same typed-element load-event decomposition as TLOAD but allocates and writes no destination Tile. Cache level, placement, and retention are not architectural results.

### Ordering

- The four PE footprints are one combined preflighted block attempt; no request or event becomes effective until every address, translation, permission, and access check succeeds.
- All successful accesses participate in PTO-RC using the block aq/rl attributes exactly as TLOAD.

## Exceptions

- Reserved DataType, unsupported Layout, explicit zero or out-of-range dimensions, non-power-of-two Col, malformed B.IOR, any B.IOT/B.IOS, or any participating-PE memory fault rejects before the first request or memory event.
- A memory fault is precise for the complete four-PE block and recovery reissues the complete combined footprint.

## Examples

- BSTART.TPREFETCH FP16; B.DIM zero, 64, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 64, ->LB2; B.IOR zero, a0; BSTOP
