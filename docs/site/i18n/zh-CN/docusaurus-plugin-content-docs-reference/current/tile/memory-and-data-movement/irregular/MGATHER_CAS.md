<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
# MGATHER_CAS

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl`

atomic compare-and-swap gather using explicit byte displacements.

## Normative identity {#PTO-INST-TILE-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-cas-purpose role=purpose -->
## MGATHER_CAS 的作用

`MGATHER_CAS` 按通道在全局内存 (GM) 中执行一次原子比较并交换，并把每个通道观察到的值写入新分配的 Local 目标 Tile。它是由 `TLSU` 执行、通过选择器编码的 Tile 操作，由 TLSU Function 8 选中，写作 `BSTART.MGATHER.CAS DataType`。块派发器 `ExecuteBundleMGATHERCASOperation` 解析指令束，然后调用函数体 `MGATHER_CAS`。

一个通道就是索引 Tile 有效区域中的一个坐标。被比较的地址是 `BaseGPR` 加上该通道索引值所解释的字节位移。`MGATHER_CAS` 没有独立操作码。

设计要点：目标携带的是观察到的旧值，而不是写入的值。比较失败的通道仍然报告 GM 当时的内容，因此软件无需再读一次就能区分成功的交换和失败。

<!-- PTO-READER-BLOCK: tile-mgather-cas-mechanism role=mechanism -->
## 双命令模式与原子机制

`ExecuteBundleMGATHERCASOperation` 调用的是自有函数体 `MGATHER_CAS`，它做两轮遍历。Function 8 不会走到共享原子体 `GMRunAtomic`：`BundleMGATHERCASSelected` 先于 `BundleGMAtomRedSelected` 认领该指令束，因此 atom/red 派发器及其 `GM_ATOM_CAS` 包装对本 Function 不会执行。

预检轮访问每个启用坐标，用 `TileMemoryByteDisplacementAddress` 构造地址。它对同一地址用 `ProbeTileMemoryAccess` 各做一次读探测与写探测，通过 `RaiseDataAccessFault` 抛出探测自身的故障，并在两次探测翻译到不同地址时引发 `Fault_DataPage`。它同时快照索引、expected 与 replacement 元素。

发布轮先初始化每个物理目标元素，然后按由 `ARBITRARY` 选择决定的顺序访问各通道。每个通道读取旧值、按元素位宽与 expected 元素比较、仅在两者相等时存储 replacement、把旧值写入自己的目标元素，并记录一个原子事件，其写入标志取决于该存储是否发生。

设计要点：两次探测必须对翻译后的地址取得一致。若不一致，请求会在预检期间引发 `Fault_DataPage`，因此它绝不可能通过一个写侧翻译从未被检查过的地址执行存储。两次探测与全部快照都在发布轮的首次读取或存储之前完成。

<!-- PTO-READER-BLOCK: tile-mgather-cas-inputs role=inputs-outputs -->
## 操作数角色与绑定

- `destination0` 是新的 Local Tile，使用指令束 `DataType`。它接收观察到的旧值。
- `address` 是基址，从当前内存代理寄存器文件中由 `B.IOR.RegSrc0` 指定的 GPR 读出。
- `source0` 是索引 Tile：`S32`、`U32`、`S64` 或 `U64` 字节位移。
- `source1` 是 expected Tile，与被寻址元素的旧值比较。
- `source2` 是 replacement Tile，在比较匹配时被存储。

`B.IOR` 是必需的，且 `RegSrc1`、`RegSrc2` 与 `RegDst` 必须编码为零。这是双命令形式：`BundleMGATHERCASBindingsLegal` 要求恰好两个 Tile 绑定，第一个携带索引 Tile 与 expected Tile、没有目标且不是 `last`，第二个携带 replacement Tile、目标与 `last`。存在谓词 Tile ExecutionMask 时，该谓词 Tile 成为第一个绑定的第一个源，于是索引 Tile 移到该绑定的第二个源，replacement Tile 移到第二个绑定的第二个源。

<!-- PTO-READER-BLOCK: tile-mgather-cas-effects role=effects -->
## GM、目标与故障效果

`B.DATR` 是可选的，且不出现在此形式的块组成中。省略它时 `_BundleDataAttributesPresent` 为假，因此 `CurrentBundlePadValue` 返回 `TilePad_Null`，`TilePadValueForDataType` 把它映射为零位。有效区域之外的每个物理目标元素都被设为该填充值，且该区域被标记为已定义。

比较匹配的通道存储 replacement。比较失败的通道不存储任何内容，但仍发布其观察到的旧值。两种情况下目标元素都接收旧值。

尝试成功时目标会被发布。预检发生故障时派发器调用 `RollBackBundleTileDestinations`，不发布任何目标，而此时函数体尚未执行任何存储。

<!-- PTO-READER-BLOCK: tile-mgather-cas-constraints role=constraints -->
## 类型、形状与故障边界

只接受 `U16`、`U32` 与 `U64` 传输 `DataType`。`GMAtomicOperationDataTypeLegal` 对 `GMAtomic_CAS` 恰好接受这三种，派发器也会独立复查同样的三种。索引 Tile 仍必须通过 `IndexedTLSUMemoryIndexDataTypeLegal`，即 `S32`、`U32`、`S64` 或 `U64`。

目标、索引、expected 与 replacement 这四个 Tile 必须都使用指令束布局，且索引、expected 与 replacement 各自的有效行数与有效列数必须与目标相同。布局为 `ROWMAJOR`、`CUBE_M16` 与 `CUBE_M32`；`IndexedTLSULayoutSupported` 拒绝 `CUBE_N8`，且每个 `B.DIM` 值必须落在 `1..65535` 内。

解码不出任何操作的选择器编码会引发 `Fault_IllegalInstruction`。Tile 绑定数量错误、缺少 `B.IOR`、启用的索引、expected 或 replacement 元素未定义，或类型、形状、布局不合法，都会引发 `Fault_TileLegality`。通道地址未对齐会引发 `Fault_DataAlignment`，读写翻译不一致会引发 `Fault_DataPage`，二者都发生在预检期间。

设计要点：atom 形式不得用作生产者。`BundleProducerEffectClassOfHandler` 把 `TileHandler_GM_ATOM_CAS` 归类为 `BundleProducerEffect_NonRollbackAuxiliary`，而当指令束带有 assemble 修饰符时 `BundleProducerEffectEligible` 会拒绝该类别，因为 atom 所做的 GM 更新不会被回滚。

<!-- PTO-READER-BLOCK: tile-mgather-cas-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取一个 1 乘 4 的 `U64` 索引 Tile，其值为 `0, 8, 0, 16`；基址 `0x2000` 放在 `a0`；expected Tile 的值为 `7, 3, 5, 9`；replacement Tile 的值为 `70, 30, 50, 90`。GM 在 `0x2000`、`0x2008` 与 `0x2010` 处分别存放 `U64` 值 `7`、`3` 与 `9`。

- 通道 `0` 与通道 `2` 都寻址 `0x2000`。通道 `0` 期望 `7` 并匹配，因此存储 `70`；通道 `2` 期望 `5`，因此永远不会匹配。无论两者谁先执行，GM 最终都是 `70`。
- 通道 `1` 寻址 `0x2008` 并与已存的 `3` 匹配，因此存储 `30`。
- 通道 `3` 寻址 `0x2010` 并与已存的 `9` 匹配，因此存储 `90`。

每个目标元素接收本通道观察到的旧值：通道 `0` 报告 `7`，通道 `1` 报告 `3`，通道 `3` 报告 `9`，而通道 `2` 在它先执行时报告 `7`，在通道 `0` 先执行时报告 `70`。

用宏形式写作 `MGATHER_CAS <Col=4, U64>, [base=a0], T#1, T#2, T#3, ->T<128B>`，其中 `T#1` 是索引 Tile，`T#2` 是 expected Tile，`T#3` 是 replacement Tile。128 字节的目标容纳 16 个 `U64` 物理元素：其中 4 个有效元素得到观察到的值，另外 12 个从默认填充值得到零位。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_CAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_CAS | TLSU |  | 8 |  | GM_ATOM_CAS |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| address | base-address |
| source0 | byte-displacement indices |
| source1 | expected |
| source2 | replacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractMatches_MGATHER_CAS(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_CAS() => TileSemanticHandler
begin
    return TileHandler_GM_ATOM_CAS;
end;
readonly func InstructionContractOperation_MGATHER_CAS() => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
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

- BSTART.MGATHER.CAS DataType; B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
