---
{
  "schema_version": 1,
  "id": "header.header-b.datr",
  "kind": "header",
  "title": "B.DATR",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Dimensions & Attributes",
  "sources": {
    "davincioo": "header/B.DATR.md"
  }
}
---
# B.DATR

## 说明

**B.DATR (Block Data Attribute)** 用于描述 block 的数据属性。如果一个 block 不需要本指令定义的任何非默认属性，可以省略 `B.DATR`，并按默认属性执行。

DavinciOO v5 superscalar profile 中，`B.DATR` 继续承载 dtype 扩展、`PadValue`、round、sat、compare 等数据属性；它不承载 shape、valid-region 或 `PE_MASK`。Block shape / dimension 由 `B.DIM` 表达，participant selection 由 `B.IOT.PE_MASK` 表达。

省略 `B.DATR` 等价于使用当前 profile 的默认 data attribute：

| Attribute | Default when `B.DATR` is omitted |
| --- | --- |
| `Layout` | `NORM`；其他编码保留 |
| `DataType` | 使用 `BSTART.*` 中的主 `DataType`，不额外指定 destination / convert type |
| `PadValue` | `Zero` |
| `CMode` | compare op 使用的比较模式；对 `TCMP/TCMPS` 等 compare opcode 是必需语义字段 |
| `RMode` | `NONE` |
| `Sat` | disabled |
| `ByteId` | `Byte0` / opcode 默认 |

因此，像 `TADD` 这类普通 elementwise op 如果只需要默认 zero padding，且不需要 dtype convert、round、sat 或 compare attribute，可以不发 `B.DATR`。需要 `PadValue.Max/Min/Null` 或任何其他非默认属性时，必须显式发出 `B.DATR`。

注意：`B.DATR` 是否可省略由具体 opcode contract 决定。某些指令把它作为核心语义，例如 `TCVT`、`TCMP/TCMPS` 和 CUBE matrix family。所有 active matrix opcode 都必须发出 `B.DATR`，即使 AType、BType 和 DType 相同。

## 汇编语法

```asm
B.DATR {DataType, PadValue, ByteId, CMode, RMode, Sat}
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `Layout` | 当前 active profile 仅定义 `NORM`；其他编码保留 |
| `DataType` | dtype convert / destination type 等数据类型属性 |
| `PadValue` | output Tile valid-region 外的填充值策略 |
| `ByteId` | histogram/stat 类 op 使用的目标字节 |
| `CMode` | compare op 使用的比较模式 |
| `RMode` | convert op 使用的舍入模式 |
| `Sat` | 饱和运算标志 |

## Bit-level Encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:29]` | `CMode` | 3 |  |
| `[28:27]` | `PadValue` | 2 |  |
| `[26]` | `S` | 1 |  |
| `[25]` | `C` | 1 |  |
| `[24:20]` | `DataType` | 5 |  |
| `[19:18]` | `0` | 2 | `0` |
| `[17:15]` | `RMode` | 3 |  |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `Layout` | 5 |  |
| `[6:4]` | `Opc1` | 3 | `2` |
| `[3:1]` | `Opcode` | 3 | `1` |
| `[0]` | `W` | 1 | `1` |

## 字段编码

### `C`

| `C` | 含义 |
| --- | --- |
| `0` | 不执行 canonicalize |
| `1` | 执行 canonicalize |

### Matrix/CUBE Profile

12 个 active Matrix operation 统一使用 B.DATR 表达 BType、RMode 与 Sat；DType 由 B.FPATR.PreQuantMode 及 PostProcessConfig 推导。TGEMV 不再使用旧 fused-D B.DATR subprofile。

### `DataType`

| 编码 | DataType | 编码 | DataType | 编码 | DataType | 编码 | DataType |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0` | `FP64` | `8` | `e5m2` | `16` | `S64` | `24` | `U64` |
| `1` | `FP32` | `9` | `e3m2` | `17` | `S32` | `25` | `U32` |
| `2` | `TF32` | `10` | `e2m3` | `18` | `S16` | `26` | `U16` |
| `3` | `HF32` | `11` | `e2m1x2` | `19` | `S8` | `27` | `U8` |
| `4` | `FP16` | `12` | `e1m2x2` | `20` | `S4x2` | `28` | `U4x2` |
| `5` | `BF16` | `13` | `e8m0` | `21` | reserved | `29` | reserved |
| `6` | `HiF8` | `14` | `HiF4x2` | `22` | reserved | `30` | reserved |
| `7` | `e4m3` | `15` | reserved | `23` | reserved | `31` | invalid |

### `Layout`

`Layout` bitfield 保留在编码中以兼容 Linx-style header 格式。DavinciOO v5 superscalar profile 只有 `NORM` 合法；其他编码保留，软件不得生成。

| 编码 | Format | 说明 |
| --- | --- | --- |
| `0` | `NORM` | 不转换 |
| `1..31` | reserved | 当前 profile 保留 |

### `PadValue`

| `PadValue` | 填充值 | 说明 |
| --- | --- | --- |
| `0` | `Zero` | 零值 |
| `1` | `Max` | 对应数据格式最大值 |
| `2` | `Min` | 对应数据格式最小值 |
| `3` | `Null` | 不主动填充，保留随机值 |

### `CMode`

| `CMode` | 比较方式 |
| --- | --- |
| `0` | `EQ` |
| `1` | `NE` |
| `2` | `LT` |
| `3` | `GT` |
| `4` | `LE` |
| `5` | `GE` |
| `6..7` | reserved |

### `RMode`

Matrix RMode 是 PostProcessConfig 的一部分，并与 B.FPATR 一致。canonical None 必须为 NONE；需要 convert/quant 时使用对应合法 rounding mode。

### `S`

Matrix Sat 位由 PostProcessConfig 静态确定。canonical None 必须为 0；启用 saturating convert/quant 时按目标 dtype/profile 编码。

### `ByteId`

| `ByteId` | 含义 |
| --- | --- |
| `0` | `Byte0` |
| `1` | `Byte1` |
| `2` | `Byte2` |
| `3` | `Byte3` |
