<!-- GENERATED FROM: asl/block/execution/BSTART.MSCATTER.MASK.asl -->
# BSTART.MSCATTER.MASK

**Normative ASL source:** `asl/block/execution/BSTART.MSCATTER.MASK.asl`

Masked scatter using explicit logical element indices.

## Normative identity {#PTO-INST-BLOCK-BSTART-MSCATTER-MASK}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-purpose role=purpose -->
## BSTART.MSCATTER.MASK 的作用

`BSTART.MSCATTER.MASK` 打开一个 Tile memory 指令束，其操作为 `MSCATTER_MASK`：一次由 Local 谓词 Tile 逐通道决定是否存储的索引存储。对谓词元素为 `0x01` 的每个活动通道，把数据 Tile 的一个传输元素写入全局内存（GM）中基地址加上该通道字节位移处。谓词元素为 `0x00` 的通道被跳过。

该命令是一个 32 位字，在掩码 `0x07ffffff` 下匹配 `0x00711181`，因此 `DataType` 占据第 31 至 27 位，固定的低位携带 TLSU 选择子 7。`BundleMSCATTERMASKSelected` 匹配该选择子，`ExecuteBundleMSCATTERMASKOperation` 运行操作 `TileOperation_MSCATTER_MASK`。该指令束不分配任何 Tile，也不消耗或修改任何源 Tile。

设计要点：这里的掩码总是一条独立的操作数记录，因为 scatter 没有可供第二条记录描述的目标。当存在谓词 Tile ExecutionMask 时，gather 会把第二条记录用于目标，而本指令束把第二条记录用于谓词 Tile，并且完全没有目标。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-mechanism role=mechanism -->
## 位置与机制

该 handler 先把 `PE_MASK=0000` 的指令束作为严格无操作直接返回，然后译码选择子，并校验 schema、双记录绑定形状、谓词取值、类型矩阵、布局与物理形状规则，以及数据 Tile、索引 Tile 与谓词 Tile 之间的关系。

Tile 级执行体 `MSCATTER_MASK` 仅在谓词元素为 `0x01` 时才计算地址并做写探测。随后它按 `ARBITRARY` 顺序为每个启用通道提交一次存储，并为每个通道记录一个 store 事件。

设计要点：谓词为假时既不生成地址也不探测，因此假谓词下的野索引不会引发故障也不会触碰内存。这正是掩码 scatter 可用于数据相关索引 Tile 的原因：那些从未初始化的未用条目不会被使用。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 是传输元素类型，必须等于数据 Tile 的元素类型。
- `B.DIM` 的 `LB0` 是 ValidCol，`LB1` 是 ValidRow（默认 1），`LB2` 是物理 Col。这些取值必须准确描述数据 Tile：其有效列数、有效行数与物理列数。
- 第一条 `B.IOT` 在 `source0` 中携带数据 Tile，在 `source1` 中携带索引 Tile，没有目标、没有 size 编码，也没有 `last`。
- 第二条 `B.IOT` 在 `source0` 中携带谓词 Tile 与 `last`，当存在谓词 Tile ExecutionMask 时在 `source1` 中携带该掩码。没有目标记录。
- 索引 Tile 是 `S32`、`U32`、`S64` 或 `U64`，保存字节位移并具有指令束布局。谓词 Tile 是普通的 Local `U8` 载体，具有索引 Tile 的有效形状与指令束布局。
- `B.IOR BaseGPR, zero, zero, ->zero` 是必需的：`RegSrc0` 选择每个 PE 的基地址 GPR，另外三个选择子必须编码为零。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-effects role=effects -->
## 待处理状态与完成

每个启用通道存储一个传输元素。对打包四位 `DataType`，一个索引指名一个字节，该字节接收数据列 `2 * c` 的低半字节与列 `2 * c + 1` 的高半字节，一个谓词元素控制这整个字节对。此时数据有效列数必须恰好是索引有效列数的两倍，因此不会出现不完整的字节对。

该指令束不发布任何 Tile，并保持两个源 Tile 不变。成功时每个启用通道写入 GM 一次并记录一个 store 事件；除重复地址之间的实现定义顺序外，内存序不变。

设计要点：由于被跳过的通道什么都不写，该 GM 元素保持它原有的值。与掩码 gather 不同（其被跳过的通道表现为填充后的目标元素），掩码 scatter 不留下被跳过通道的任何痕迹，因此程序若日后需要知道自己存储了哪些元素，就必须保留谓词 Tile。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-constraints role=constraints -->
## 合法性与故障边界

- `PE_MASK=0000` 是严格无操作，早于所有 schema、源、GPR、维度、地址、谓词与内存检查。
- 保留的 `DataType` 编码或未知的 TLSU 选择子引发 `Fault_IllegalInstruction`。
- 非 `0x00` 或 `0x01` 的谓词元素、有效形状与索引 Tile 不同的谓词 Tile、`B.IOS` 绑定、缺少 `B.IOR`、非零的未使用 `B.IOR` 选择子、不是上述两条记录的绑定形状、未定义的源，或类型、形状、布局、维度不匹配，都会在第一次探测之前引发 `Fault_TileLegality`。
- 布局为 `ROWMAJOR`、`CUBE_M16` 或 `CUBE_M32`；`CUBE_N8` 被拒绝。对 `ROWMAJOR`，物理列数必须是非零的 2 的幂，且不得小于有效列数。
- 无法写入的启用通道引发其自身的内存故障。没有需要回滚的目标，因此这种故障让指令束保持活动且不发布任何东西。

<!-- PTO-READER-BLOCK: block-bstart-mscatter-mask-example role=example -->
## 非规范示例

该演算示例是非规范的；它说明当前 owner，而不替代它。

```asm
BSTART.MSCATTER.MASK U32
B.DIM zero, 4, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 4, ->LB2
B.IOT T#2, T#1, mask=1111
B.IOT T#3, mask=1111, last
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#2` 是 1 x 4 的 `U32` 数据 Tile，保存 `7`、`8`、`9` 与 `10`，`T#1` 是 1 x 4 的 `S32` 索引 Tile，保存 `0`、`4`、`8` 与 `12`，`T#3` 是 1 x 4 的 `U8` 谓词 Tile，保存 `1`、`1`、`0` 与 `0`，`a0` 保存 `0x1000`。只有前两个通道存储，分别在 `0x1000` 写入 `7`、在 `0x1004` 写入 `8`。索引 `8` 与 `12` 从不转成地址，它们指名的内存保持原有内容。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MSCATTER.MASK DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_mask_32_2a33eed646f7 | L32 | 32 | 0x00711181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mscatter_mask_32_2a33eed646f7 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_mscatter_mask_32_2a33eed646f7 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | memory transfer element type selector | Encoded zero supplies numeric zero for the memory transfer element type selector. |

- `bstart_mscatter_mask_32_2a33eed646f7.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | memory transfer element type selector |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MSCATTER.MASK.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MSCATTER_MASK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_mask_32_2a33eed646f7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MASK DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK
B.IOT MaskTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MSCATTER.MASK.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MSCATTER_MASK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER_MASK()
    => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies DataTile or destination physical Col; omitted LB1 and LB2 default to one and LB0 respectively.
- IndexTile entries are S32, U32, S64, or U64 logical element indices; each index is scaled by the transfer element width and is not decomposed.

## Legality

- PredicateTile is an ordinary Local U8 predicate carrier with one 0x00 or 0x01 element per indexed transaction; every other value rejects before effects.
- PredicateTile valid shape equals IndexTile valid shape and its producer DataType does not constrain the transfer DataType.
- Packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and one predicate controls the complete byte pair.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 7 with encoded DataType.
- No Tile is allocated and no source is consumed by the start instruction.

## Memory effects and ordering

### Memory effects

- Each enabled indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the logical element index scaled by the transfer element width.
- A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
