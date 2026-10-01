<!-- GENERATED FROM: asl/block/execution/BSTART.TIMG2COL.asl -->
# BSTART.TIMG2COL

**Normative ASL source:** `asl/block/execution/BSTART.TIMG2COL.asl`

Begins the TLSU feature-map IMG2COL block and selects its element DataType.

## Normative identity {#PTO-INST-BLOCK-BSTART-TIMG2COL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-timg2col-purpose role=purpose -->
## BSTART.TIMG2COL 的作用

`BSTART.TIMG2COL` 打开一个 Tile 内存指令束，其操作为 IMG2COL：从全局内存（GM）读取卷积输入图像，并把它写成矩阵。矩阵的每一行是一个输出像素，每一列是一个卷积核位置与输入通道，按 32 字节的 `C0` 通道组分组。该命令是一个 32 位字（匹配值 `0x01c11181`，掩码 `0x07ffffff`），`DataType` 位于位 31 到 27。它是命令形式 94，携带固定的 TLSU 选择器 28。

结果写到两处之一：普通行主序（ND）的 Shared Tile，或 `CUBE_M16`、`CUBE_M32` 布局的 Local Tile，可直接供 CUBE 引擎使用。

设计要点：[描述符合法性](../model/dispatch/descriptor-legality.md)对形式 94 有专门的规则。只有当描述符恰为 TIMG2COL 描述符且 `DataType` 受支持时才合法。因此不受支持的编码在 `BSTART` 处引发 `Fault_IllegalInstruction`，发生在[指令束启动分派](../model/dispatch/start.md)提交任何前驱之前。

<!-- PTO-READER-BLOCK: block-bstart-timg2col-mechanism role=mechanism -->
## 位置与机制

提交时，[Tile 执行](../model/dispatch/tile-execution.md)首先测试 TIMG2COL 选择器，并调用 [TIMG2COL 执行](../model/dispatch/timg2col-execution.md)。对该操作，它跳过通用的效果资格检查、阶段 2 准备、Local 续接复用以及 ExecutionMask 捕获。处理程序先验证整个指令束，再构建矩阵。

`B.DATR` 布局选择输出。`ND2M16`（编码 22）和编码 31 选择 Local M16；`ND2M32`（编码 21）和编码 29 选择 Local M32；`NORM`（编码 0）、`DN2ND`（编码 6）或省略 `B.DATR` 选择 Shared ND。编码 6、29 和 31 通过通道主序（DN，NCHW）索引读取图像；其他布局使用通道次序（ND，NHWC）索引。每个单元的几何由 [TIMG2COL schema](../model/dispatch/timg2col-schema.md)定义。

设计要点：验证阶段不读取内存，随后 `BundleTIMG2COLPreflightGM` 在第一次加载之前探测全部 ValidRow 行的每个 GM 地址。转换或权限故障不会留下任何加载事件、分配或 Shared 代的变化。

设计要点：输入坐标落在空间填充中、或通道不小于 `Cin` 的单元，是已定义的原始零值，不访问 GM。填充永远不会引发故障，也不会记录加载事件。

<!-- PTO-READER-BLOCK: block-bstart-timg2col-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 是元素类型：`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`HiF8`、`E4M3`、`E5M2`、`E8M0`、`S32`、`S16`、`S8`、`U32`、`U16` 或 `U8`。
- 显式的 `B.DATR` 必须使用 `DTYPE_NONE`、Zero 填充（编码 0），且比较、舍入、饱和与规范化控制均为零；只有它的布局起作用。
- `B.DIM` 的 `LB0`、`LB1` 和 `LB2` 给出 ValidCol、ValidRow（1 到 128，Local M16 最多 64）和 TotalCol。
- 两条相邻的仅源 `B.IOR` 记录：第一条为 `GMBase, zero, zero`，第二条为 `ParamGPR0, ParamGPR1, ParamGPR2`。[TIMG2COL 参数](../model/operands/timg2col-parameters.md)定义了打包方式。
- Shared ND 输出恰好使用一条 `B.IOS`，没有 `B.IOT`。Local 输出恰好使用一条 `PE_MASK` 为 `1111` 的目标 `B.IOT`，没有 `B.IOS`。

设计要点：每个参与 PE 必须持有相同的 `GMBase` 与参数字。每个 PE 根据同一几何计算不同的行份额，因此该检查使所有份额属于同一个矩阵；不一致时在任何 GM 访问之前拒绝。

<!-- PTO-READER-BLOCK: block-bstart-timg2col-effects role=effects -->
## 结果与发布

ValidRow 分给四个 PE，先填满 PE 0。Local M16 每个 PE 16 行，Local M32 每个 PE 32 行；Shared ND 在 ValidRow 不超过 64 时每个 PE 16 行，否则 32 行。行数为零的 Local PE 不分配也不读取，但仍是参与者。

Shared ND 的掩码必须是单个 PE 或 `1111`，并且必须包含当前 PE。单个 PE 不得使用 `B.ASSEMBLE`，并直接发布 Tile。使用 `1111` 时 `B.ASSEMBLE` 是必需的：PE 0 携带 INIT，PE 3 携带 LAST，PE 1 与 PE 2 两者都不携带。其寄存器与立即数必须为零，因为处理程序根据行起点以 32 字节为单位推导每个写者的偏移。父对象只在无空隙的 LAST 写者到达时发布。

只写入逻辑矩形及其已定义性；物理存储尾部既不写入，也不标记为已定义。Local CUBE 结果等于 Shared ND 结果再经过普通的 ND 到 CUBE 转换。

<!-- PTO-READER-BLOCK: block-bstart-timg2col-constraints role=constraints -->
## 合法性与故障边界

裁剪必须按 `C0` 对齐：ValidCol、TotalCol 与 ColStart 是 `C0` 的倍数，ValidCol 不超过 TotalCol，`RowStart + ValidRow` 不超过 `Hout * Wout`，`ColStart + ValidCol` 不超过 `KValid`。非零的参数扩展位、零尺寸以及错误的绑定数量同样会被拒绝。

没有记录故障的失败检查变为 `Fault_TileLegality`；内存故障保持其自身类型。任何失败时，`BundleTIMG2COLAbortFailedAttempt` 中止 Shared 代或回滚 Local 目标，因此之前的 Shared 代保持不变。

设计要点：如 NDF 条款 `PTO-BSTART-TIMG2COL-CONTRACT-001` 所述，重复、转置、双源以及隐藏的描述符状态都不属于这一逐指令束接口。操作的每个输入都在指令束自己的命令与 GPR 中可见。

<!-- PTO-READER-BLOCK: block-bstart-timg2col-example role=example -->
## 非规范示例

以下示例勾勒一个协作式 Shared 结果；符号值代表事先准备好的 GPR 或维度。

```asm
BSTART.TIMG2COL FP16
B.DIM zero, 64, ->LB0
B.DIM zero, 64, ->LB1
B.DIM zero, 64, ->LB2
B.IOR a0, zero, zero
B.IOR a1, a2, a3
B.IOS mask=1111, ->S0<7>
B.ASSEMBLE 1, 0, zero, 0, 5
BSTOP
```

这是 PE 0 的指令束。PE 1 与 PE 2 绑定 `B.IOS S0, mask=1111` 并使用 `B.ASSEMBLE 0, 0, zero, 0, 5`，PE 3 使用 `B.ASSEMBLE 0, 1, zero, 0, 5`。对 `FP16`，`C0` 为 16。ValidRow 64 使每个 PE 得到 16 行，每个写者覆盖 16 * 64 / 16 = 64 个 32 字节单位，偏移分别为 0、64、128 和 192。`SizeCode` 7 为 8192 字节，即 256 个单位，因此 PE 3 的 LAST 范围恰好结束于 256，父对象随之发布。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TIMG2COL DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_timg2col_32_7a0f8d6c3e21 | L32 | 32 | 0x01c11181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[1,2,3,4,5,6,7,8,13,17,18,19,25,26,27]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_timg2col_32_7a0f8d6c3e21 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_timg2col_32_7a0f8d6c3e21 | DataType | 5 | 1–8, 13, 17–19, 25–27 | none | 0, 9–12, 14–16, 20–24, 28–31 | element DataType selector | Encoded zero selects FP64 and is inapplicable to TIMG2COL; explicit B.DATR DTYPE_NONE inherits the BSTART type. |

- `bstart_timg2col_32_7a0f8d6c3e21.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | element DataType selector |
| B.DATR.Layout | dense GM source view and output destination path |
| B.DIM.LB0/LB1/LB2 | ValidCol, ValidRow, TotalCol |
| B.IOR | GMBase and packed parameter GPRs |
| B.IOS/B.IOT | Shared ND or Local CUBE destination |
| B.ASSEMBLE | Shared cooperative row-range coverage |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TIMG2COL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TIMG2COL(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_timg2col_32_7a0f8d6c3e21;
end;

// The standalone TLSU carrier is Function 28 with mask 0x07ffffff and match
// 0x01c11181; DataType occupies instruction bits [31:27].
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TIMG2COL DataType; optional B.DATR; exactly one write-once binding for each of LB0/LB1/LB2; exactly two immediately contiguous source-only B.IOR records; Shared singleton uses one B.IOS; Shared multi-PE uses one B.IOS with PE_MASK=1111 followed by B.ASSEMBLE; Local direct output uses one B.IOT with PE_MASK=1111; BSTOP or the next BSTART completes the block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TIMG2COL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TIMG2COL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

pure func InstructionContractTIMG2COLLayoutLegal(layout: bits(5)) => boolean
begin
    return layout == Zeros{5} + 0 ||
           layout == Zeros{5} + 6 ||
           layout == Zeros{5} + 21 ||
           layout == Zeros{5} + 22 ||
           layout == Zeros{5} + 29 ||
           layout == Zeros{5} + 31;
end;

pure func InstructionContractTIMG2COLIsLocalCube(layout: bits(5)) => boolean
begin
    return layout == Zeros{5} + 21 || layout == Zeros{5} + 22 ||
           layout == Zeros{5} + 29 || layout == Zeros{5} + 31;
end;

pure func InstructionContractTIMG2COLIsM32(layout: bits(5)) => boolean
begin
    return layout == Zeros{5} + 21 || layout == Zeros{5} + 29;
end;

pure func InstructionContractTIMG2COLDATRLegal(
    layout: bits(5), data_type: bits(5), pad: bits(2), cmode: bits(3),
    rmode: bits(3), sat: boolean, canonicalize: boolean) => boolean
begin
    return InstructionContractTIMG2COLLayoutLegal(layout) &&
           data_type == DTYPE_NONE && pad == Zeros{2} &&
           cmode == Zeros{3} && rmode == Zeros{3} && !sat && !canonicalize;
end;

pure func InstructionContractTIMG2COLCoreMaskLegal(mask: bits(4)) => boolean
begin
    return mask == '1111';
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.DATR is equivalent to NORM/ND2ND with DTYPE_NONE, Zero pad, and zero controls. Explicit B.DATR must use DTYPE_NONE and zero controls.

## Legality

- TLSU Function=28 with mask 0x07ffffff and match 0x01c11181.
- The operation accepts only FP32, TF32, HF32, FP16, BF16, HiF8, E4M3, E5M2, E8M0, S32, S16, S8, U32, U16, and U8.
- B.DATR accepts exactly NORM/ND2ND, DN2ND, ND2M16, ND2M32, DN2M16, and DN2M32; Shared uses ND output and Local uses explicit CUBE M16/M32.
- LB0, LB1, LB2 bind ValidCol, ValidRow, TotalCol exactly once each.
- Exactly two contiguous source-only B.IOR records bind GMBase and ParamGPR0..2; no source or destination binding is accepted for GM.
- The four-PE mask is 1111 for cooperative forms; zero-row PEs remain collective participants but perform no allocation or memory effect.

## State effects

- Writes the expanded-and-cropped logical rectangle with defined zeros for spatial OOB and Cin padding.
- Direct Local CUBE materialization is equivalent to Shared ND followed by existing ND2CUBE for every valid element and definedness result.

## Memory effects and ordering

### Memory effects

- Dense NCHW/DN and NHWC/ND source indices are computed with wide unsigned arithmetic; spatial OOB and Cin padding lanes produce defined raw zero without a GM access.
- Physical storage tails are not written or marked defined.

### Ordering

- All schema, dimensions, crop, distribution, address, capacity, translation, permission, readiness, allocation, alias, and PE consistency checks precede source reads, destination payload, definedness, or publication.
- Shared output publishes a complete generation atomically; failure preserves the previous generation.

## Exceptions

- Reserved or unsupported DataType, malformed B.IOR sequence, wrong layout direction, invalid dimensions/crop/capacity, unsupported destination binding, address overflow, translation/permission, readiness, allocation, or PE consistency raises the applicable fault before GM access or visible target effects.

## Examples

- BSTART.TIMG2COL FP16; B.DIM LB0, ValidCol; B.DIM LB1, ValidRow; B.DIM LB2, TotalCol; B.IOR GMBase, zero, zero; B.IOR ParamGPR0, ParamGPR1, ParamGPR2; B.IOS PE_MASK, ->S0<SizeCode>; B.ASSEMBLE 1, 1, zero, 0, ParentSizeCode; BSTOP
