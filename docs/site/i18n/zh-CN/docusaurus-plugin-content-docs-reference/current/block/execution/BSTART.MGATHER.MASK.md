<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.MASK.asl -->
# BSTART.MGATHER.MASK

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.MASK.asl`

Masked gather using explicit byte displacements.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER-MASK}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-purpose role=purpose -->
## BSTART.MGATHER.MASK 的作用

`BSTART.MGATHER.MASK` 打开一个 Tile memory 指令束，其操作为 `MGATHER_MASK`：一次由 Local 谓词 Tile 逐通道决定是否装载的索引装载。对谓词元素为 `0x01` 的每个活动通道，从全局内存（GM）按基地址加上该通道的字节位移读取一个传输元素并写入目标 Tile。谓词元素为 `0x00` 的通道被跳过。

该命令是一个 32 位字，在掩码 `0x07ffffff` 下匹配 `0x00611181`，因此 `DataType` 占据第 31 至 27 位，固定的低位携带 TLSU 选择子 6。`BundleMGATHERMASKSelected` 匹配该选择子，`ExecuteBundleMGATHERMASKOperation` 运行操作 `TileOperation_MGATHER_MASK`。

设计要点：`B.IOT` 的 `PE_MASK` 与谓词 Tile 选择的是不同的东西。`PE_MASK` 选择哪些 PE 整体参与，而谓词 Tile 选择每个参与 PE 内部的各个坐标。因此谓词是一个操作数 Tile，而不是编码字段，它可以由同一程序中更早的操作产生。

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-mechanism role=mechanism -->
## 位置与机制

该 handler 先把 `PE_MASK=0000` 的指令束作为严格无操作直接返回，然后译码选择子，并校验 schema、布局与物理形状规则，以及指令束维度、索引 Tile 与谓词 Tile 之间的关系。谓词 Tile 必须是普通的 Local `U8` 载体，其有效形状等于索引 Tile 的有效形状，且每个谓词元素必须是 `0x00` 或 `0x01`；其他任何取值都会在效果之前引发 `Fault_TileLegality`。

Tile 级执行体 `MGATHER_MASK` 仅在谓词元素为 `0x01` 且 ExecutionMask 让该坐标保持活动时才计算地址并做读探测。随后它恰好装载这些通道，并为每个通道记录一个 load 事件。

设计要点：谓词为假时完全不生成地址，因此该通道不会带来任何转换、权限检查、探测、事件或数据访问故障。被跳过的通道在其目标元素中保留填充值，这正是该掩码无需单独的清零步骤即可用于稀疏模式的原因。

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 是传输元素类型，它不必与谓词 Tile 的元素类型一致。
- `B.DIM` 的 `LB0` 是 ValidCol，`LB1` 是 ValidRow（默认 1），`LB2` 是物理 Col（默认 `LB0`）。有效行数与有效列数必须等于索引 Tile 的有效形状，而谓词 Tile 必须与索引 Tile 具有相同的有效行数与有效列数。
- 一条终止 `B.IOT` 在 `source0` 中携带索引 Tile，在 `source1` 中携带谓词 Tile，并携带 `PE_MASK`、`last` 以及带 size 编码的目标。使用谓词 Tile ExecutionMask 时，目标移入第二条 `B.IOT`。
- 索引 Tile 是 `S32`、`U32`、`S64` 或 `U64`，具有指令束布局并保存字节位移。谓词 Tile 使用指令束布局。
- `B.IOR BaseGPR, zero, zero, ->zero` 是必需的，其中 `RegSrc0` 是每个 PE 的基地址 GPR，另外三个选择子编码为零。

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-effects role=effects -->
## 待处理状态与完成

每个启用通道把一个装载到的元素写入同一行同一列的目标元素。对打包四位类型，一个索引字节提供两个相邻的逻辑半字节，一个谓词元素控制整个字节对，因此目标有效列数恰好是索引有效列数的两倍。

在装载之前，整个物理目标区域已被定义：被 ExecutionMask 停用的坐标取该掩码的零值或合并值，包括被谓词跳过通道在内的其他每个元素取指令束 `PadValue`。成功时整个物理目标区域都是已定义的；失败的尝试不发布任何目标。

设计要点：填充元素与被跳过元素在发布结果中无法区分，因为两者接收相同的 `PadValue`。需要知道某个通道是否被掩蔽的程序必须保留谓词 Tile，而不能读取目标。

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-constraints role=constraints -->
## 合法性与故障边界

- `PE_MASK=0000` 是严格无操作，早于所有 schema、源、GPR、维度、分配、谓词、地址与故障检查。
- 保留的 `DataType` 编码或未知的 TLSU 选择子引发 `Fault_IllegalInstruction`。
- 非 `0x00` 或 `0x01` 的谓词元素、有效形状与索引 Tile 不同的谓词 Tile、`B.IOS` 绑定、缺少 `B.IOR`、非零的未使用 `B.IOR` 选择子、畸形绑定 schema、错误的索引类型、未定义的源，或形状、布局、维度不匹配，都会在第一次探测之前引发 `Fault_TileLegality`。
- 布局为 `ROWMAJOR`、`CUBE_M16` 或 `CUBE_M32`；`CUBE_N8` 被拒绝，并且记录条数必须与是否存在谓词 Tile ExecutionMask 相符。
- 若不存在空闲的 Local 目标，解析会引发 `Fault_TileAllocation`。地址无法访问的启用通道引发其自身的内存故障，目标会被回滚。

<!-- PTO-READER-BLOCK: block-bstart-mgather-mask-example role=example -->
## 非规范示例

该演算示例是非规范的；它说明当前 owner，而不替代它。

```asm
BSTART.MGATHER.MASK U32
B.DIM zero, 4, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 4, ->LB2
B.IOT T#1, T#2, mask=1111, last, ->T<16B>
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` 是 1 x 4 的 `S32` 索引 Tile，保存 `0`、`4`、`8` 与 `12`，`T#2` 是 1 x 4 的 `U8` 谓词 Tile，保存 `1`、`1`、`0` 与 `0`，`a0` 保存 `0x1000`。只有前两个通道被探测和装载，分别来自 `0x1000` 与 `0x1004`。后两个索引从不转成地址，因此不会引发故障，它们的目标元素保留填充值。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER.MASK DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_mask_32_5573241cd944 | L32 | 32 | 0x00611181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_mask_32_5573241cd944 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mgather_mask_32_5573241cd944 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | transfer and destination element type | Encoded zero supplies numeric zero for the transfer and destination element type. |

- `bstart_mgather_mask_32_5573241cd944.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | transfer and destination element type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.MASK.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_MASK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_mask_32_5573241cd944);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.MASK DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.MASK.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_MASK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_MASK()
    => TileOperation
begin
    return TileOperation_MGATHER_MASK;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_MASK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies DataTile or destination physical Col; omitted LB1 and LB2 default to one and LB0 respectively.
- IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed.

## Legality

- PredicateTile is an ordinary Local U8 predicate carrier with one 0x00 or 0x01 element per indexed transaction; every other value rejects before effects.
- PredicateTile valid shape equals IndexTile valid shape and its producer DataType does not constrain the transfer DataType.
- Packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and one predicate controls the complete byte pair.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each enabled indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.
- A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault and leaves the corresponding destination value(s) at PadValue.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
