<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.asl -->
# BSTART.MGATHER

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.asl`

gather using explicit logical element indices.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-purpose role=purpose -->
## BSTART.MGATHER 的作用

`BSTART.MGATHER` 打开一个 Tile memory 指令束，其操作为 `MGATHER`：一次索引装载。每个活动通道从全局内存（GM）中按基地址加上该通道的字节位移读取一个传输元素，并把它写入一个新的 Local 目标 Tile。该指令束返回目标，且不写入内存。

该命令是一个 32 位字，在掩码 `0x07ffffff` 下匹配 `0x00411181`，因此 `DataType` 占据第 31 至 27 位，固定的低位携带 TLSU 选择子 4。`BundleMGATHERSelected` 匹配该选择子，`ExecuteBundleMGATHEROperation` 运行该操作，其译码身份为 `TileOperation_MGATHER`。

设计要点：索引是字节位移，从不按元素大小缩放。需要按元素步进地址的程序自行缩放索引，因此同一个索引 Tile 无需改动即可服务多种传输类型。

<!-- PTO-READER-BLOCK: block-bstart-mgather-mechanism role=mechanism -->
## 位置与机制

`ExecuteBundleMGATHEROperation` 先把 `PE_MASK=0000` 的指令束作为严格无操作直接返回，然后译码 TLSU 选择子并校验 schema：没有 Shared 绑定、恰好一个 Local 绑定、有效的 `B.IOR`、完整的绑定、合法的 GPR 取值、合法的 tile 掩码以及合法的维度。随后它检查传输数据类型、索引数据类型、维度与索引 Tile 之间的形状关系、布局的物理形状规则，以及每个参与 Tile 的指令束布局。

Tile 级执行体 `MGATHER` 为每个活动通道地址做读探测。只有全部探测成功之后，它才定义整个物理目标并装载活动通道，每个通道记录一个 load 事件。

设计要点：所有探测都在第一次装载之前、目标填充之前运行。因此被禁用或发生故障的地址会让该次尝试停止而不产生部分目标：分派器调用 `RollBackBundleTileDestinations`，该指令束不发布任何东西。

<!-- PTO-READER-BLOCK: block-bstart-mgather-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 是传输元素类型；它也固定每次装载的位宽。
- `B.DIM` 的 `LB0` 是 ValidCol，`LB1` 是 ValidRow（默认 1），`LB2` 是物理 Col（默认 `LB0`）。有效行数与有效列数必须等于索引 Tile 自身的有效形状。
- 一条终止 `B.IOT` 在 `source0` 中携带索引 Tile，并携带 `PE_MASK`、`last` 以及带 size 编码的目标。若改用谓词 Tile ExecutionMask，则目标移入第二条 `B.IOT`，此时第一条记录只携带索引 Tile，没有目标也没有 `last`。
- 索引 Tile 是 `S32`、`U32`、`S64` 或 `U64`，使用指令束布局，并保存字节位移。
- `B.IOR BaseGPR, zero, zero, ->zero` 是必需的：`RegSrc0` 选择每个 PE 的基地址 GPR，`RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零，而 `RegSrc0` 为 `zero` 时提供基地址零。

<!-- PTO-READER-BLOCK: block-bstart-mgather-effects role=effects -->
## 待处理状态与完成

对每个活动通道，同一行同一列的目标元素接收装载到的元素。对打包四位类型，一个索引字节提供两个相邻的逻辑半字节，因此目标有效列数恰好是索引有效列数的两倍，不会出现不完整的半字节对。

在装载之前，整个物理目标区域已被定义：被 ExecutionMask 停用的坐标取该掩码的零值或合并值，活动通道之外的其他每个元素取指令束 `PadValue`。成功时整个物理目标区域都是已定义的；失败的尝试不发布任何目标。

设计要点：由于目标是新分配而不是既有 Tile，填充规则正是让有效区域之外的结果确定的原因。读取整个物理 Tile 的调用方即使在没有任何通道写入的位置也看不到未定义的位。

<!-- PTO-READER-BLOCK: block-bstart-mgather-constraints role=constraints -->
## 合法性与故障边界

- `PE_MASK=0000` 是严格无操作，早于所有 schema、源、GPR、维度、分配与内存检查。
- 保留的 `DataType` 编码或未知的 TLSU 选择子引发 `Fault_IllegalInstruction`。
- `B.IOS` 绑定、缺少 `B.IOR`、非零的未使用 `B.IOR` 选择子、畸形绑定 schema、非 `S32`、`U32`、`S64` 或 `U64` 的索引类型、未定义的源，或形状、布局、维度不匹配，都会在第一次探测之前引发 `Fault_TileLegality`。
- 布局为 `ROWMAJOR`、`CUBE_M16` 或 `CUBE_M32`；`CUBE_N8` 被拒绝。对 `ROWMAJOR`，物理列数必须是非零的 2 的幂，且不得小于有效列数。
- 若不存在空闲的 Local 目标，解析会引发 `Fault_TileAllocation`。内存故障保留其自身种类，而 gather 不修改任何内存。

<!-- PTO-READER-BLOCK: block-bstart-mgather-example role=example -->
## 非规范示例

该演算示例是非规范的；它说明当前 owner，而不替代它。

```asm
BSTART.MGATHER U32
B.DIM zero, 4, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 4, ->LB2
B.IOT T#1, mask=1111, last, ->T<16B>
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` 是 1 x 4 的 `S32` 索引 Tile，保存字节位移 `0`、`4`、`8` 与 `12`，`a0` 保存 `0x1000`。四个活动通道分别从 `0x1000`、`0x1004`、`0x1008` 与 `0x100C` 装载。目标是 16 字节的 1 x 4 `U32` Tile，因此四个元素都接收装载值，填充规则没有可见效果。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_32_c9defbf18276 | L32 | 32 | 0x00411181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_32_c9defbf18276 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mgather_32_c9defbf18276 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | tile element data type selector | Encoded zero supplies numeric zero for the tile element data type selector. |

- `bstart_mgather_32_c9defbf18276.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_32_c9defbf18276);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER()
    => TileOperation
begin
    return TileOperation_MGATHER;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER()
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

- Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the logical element index scaled by the transfer element width.
- All valid addresses are preflighted before the first architectural effect.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
