<!-- GENERATED FROM: asl/block/execution/BSTART.MGATHER.CAS.asl -->
# BSTART.MGATHER.CAS

**Normative ASL source:** `asl/block/execution/BSTART.MGATHER.CAS.asl`

atomic compare-and-swap gather using explicit byte displacements.

## Normative identity {#PTO-INST-BLOCK-BSTART-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-purpose role=purpose -->
## BSTART.MGATHER.CAS 的作用

`BSTART.MGATHER.CAS` 打开一个 Tile memory 指令束，其操作为 `MGATHER_CAS`：逐通道的原子比较并交换。对每个活动通道，它读取基地址加上该通道字节位移处的全局内存（GM）元素，将其与该通道的期望值比较，并且仅当两者匹配时才存入该通道的替换值。无论结果如何，观察到的旧值都会写入目标 Tile。

该命令是一个 32 位字，在掩码 `0x07ffffff` 下匹配 `0x00811181`，因此 `DataType` 占据第 31 至 27 位，固定的低位携带 TLSU 选择子 8。`BundleMGATHERCASSelected` 在 atom 与 reduction 选择子之前匹配该选择子，`ExecuteBundleMGATHERCASOperation` 运行操作 `TileOperation_MGATHER_CAS`。

设计要点：其他 gather 形式把所有操作数放在一条绑定中，而比较并交换需要两条。因此本指令束有两条 `B.IOT` 记录：第一条携带索引与期望 Tile，没有目标；第二条携带替换 Tile、目标以及 `last`。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-mechanism role=mechanism -->
## 位置与机制

该 handler 先把 `PE_MASK=0000` 的指令束作为严格无操作直接返回，然后译码选择子，并校验 schema、双记录绑定形状、类型矩阵、布局与物理形状规则，以及索引、期望、替换 Tile 与目标之间的形状关系。

Tile 级执行体 `MGATHER_CAS` 随后为每个活动通道做读探测与写探测，并要求同一地址的两次转换结果一致。只有全部探测成功之后，它才按 `ARBITRARY` 顺序访问各通道，执行比较、存储，把旧值发布到目标，并记录一个原子事件。

设计要点：比较使用元素位宽的原始旧值，因此对 `U16`、`U32` 与 `U64` 而言，交换是全位宽的位比较，没有数值转换。比较失败的通道不存储任何东西，并记录一个报告未写入的事件，因此内存内容可以从事件流重建。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 必须是 `U16`、`U32` 或 `U64`；其他所有类型（包括每一种打包四位类型）都被拒绝。
- `B.DIM` 的 `LB0` 是 ValidCol，`LB1` 是 ValidRow（默认 1），`LB2` 是物理 Col。索引、期望、替换 Tile 与目标都必须具有该有效形状与指令束布局。
- 第一条 `B.IOT` 在 `source0` 中携带索引 Tile，在 `source1` 中携带期望 Tile，没有目标、没有 size 编码，也没有 `last`。
- 第二条 `B.IOT` 在 `source0` 中携带替换 Tile，携带带 size 编码的目标与 `last`。使用谓词 Tile ExecutionMask 时，目标记录还在 `source1` 中携带该掩码。
- 索引 Tile 是 `S32`、`U32`、`S64` 或 `U64` 并保存字节位移，`B.IOR BaseGPR, zero, zero, ->zero` 是必需的，规则与普通 gather 相同。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-effects role=effects -->
## 待处理状态与完成

每个活动通道把观察到的旧值发布到同一行同一列的目标元素，无论比较是否成功。整个物理目标区域在这些结果之前就已初始化：被 ExecutionMask 停用的坐标取该掩码的零值或合并值，活动通道之外的其他每个元素取指令束 `PadValue`。成功时整个物理目标区域都是已定义的。

匹配的通道原子地替换一个 GM 元素并记录一个原子事件；不匹配的通道记录一个报告未写入的事件。若任一探测发生故障，分派器调用 `RollBackBundleTileDestinations`，因此不发布目标，本次尝试也没有修改任何 GM 元素。

设计要点：在两种结果下都发布旧值，正是该操作可用于锁原语的原因。指令束提交之后，目标元素仍等于其期望值的通道表示它未能获取，无需再次读取 GM 就能得知这一点。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-constraints role=constraints -->
## 合法性与故障边界

- `PE_MASK=0000` 是严格无操作，早于所有 schema、源、GPR、维度、分配与内存检查。
- 保留的 `DataType` 编码或未知的 TLSU 选择子引发 `Fault_IllegalInstruction`；`U16`、`U32` 与 `U64` 之外的类型引发 `Fault_TileLegality`。
- 绑定条数不是两条、第一条记录带目标或带 `last`、第二条记录没有目标、缺少 `B.IOR`、非零的未使用 `B.IOR` 选择子、未定义的源，或形状、布局不匹配，都会在第一次探测之前引发 `Fault_TileLegality`。
- 布局为 `ROWMAJOR`、`CUBE_M16` 或 `CUBE_M32`；`CUBE_N8` 被拒绝。读探测、写探测，或两次转换不一致，会引发相应的内存故障，其中不一致的情况为 `Fault_DataPage`。
- 若不存在空闲的 Local 目标，解析会引发 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: block-bstart-mgather-cas-example role=example -->
## 非规范示例

该演算示例是非规范的；它说明当前 owner，而不替代它。

```asm
BSTART.MGATHER.CAS U32
B.DIM zero, 2, ->LB0
B.DIM zero, 1, ->LB1
B.DIM zero, 2, ->LB2
B.IOT T#1, T#2, mask=1111
B.IOT T#3, mask=1111, last, ->T<8B>
B.IOR a0, zero, zero, ->zero
BSTOP
```

`T#1` 保存字节位移 `0` 与 `4`，`T#2` 保存期望值 `10` 与 `99`，`T#3` 保存替换值 `20` 与 `0`，`a0` 保存 `0x1000`。假设 GM 在 `0x1000` 处保存 `10`，在 `0x1004` 处保存 `5`。通道 0 匹配，因此存入 `20`；通道 1 与 `99` 不匹配，因此 `0x1004` 保留 `5`。目标接收观察到的值 `10` 与 `5`，两个元素都已定义，共 8 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.MGATHER.CAS DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_mgather_cas_32_fd8c8a3b720a | L32 | 32 | 0x00811181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_mgather_cas_32_fd8c8a3b720a | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_mgather_cas_32_fd8c8a3b720a | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | transfer, comparison, replacement, and destination element type | Encoded zero supplies numeric zero for the transfer, comparison, replacement, and destination element type. |

- `bstart_mgather_cas_32_fd8c8a3b720a.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | transfer, comparison, replacement, and destination element type |
| B.IOR.RegSrc0 | per-PE private-GPR GM base address |
| B.IOR.RegSrc1 | per-PE private-GPR zero selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_CAS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_cas_32_fd8c8a3b720a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.DATR PadValue, Layout (optional)
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_CAS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_CAS()
    => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_CAS()
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

- Only U16, U32, and U64 transfer DataTypes are accepted; packed four-bit and every other existing unsupported atomic DataType remain illegal.
- Index, Expected, Replacement, and destination have equal logical valid shape and layout class.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- The complete physical destination region is initialized to PadValue before active valid results are published.
- On success the full physical destination region is defined; a failing attempt publishes no destination.

## Memory effects and ordering

### Memory effects

- Each valid coordinate performs one atomic compare-and-swap at BaseGPR plus the sign- or zero-extended byte displacement.
- All read/write probes complete before the first atomic effect; observed old values publish in the destination and non-valid physical elements contain PadValue.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
