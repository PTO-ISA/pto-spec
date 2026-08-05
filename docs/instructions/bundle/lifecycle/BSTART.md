---
{
  "schema_version": 1,
  "id": "header.header-bstart",
  "kind": "header",
  "title": "BSTART",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Lifecycle & Control",
  "sources": {
    "davincioo": "header/BSTART.md"
  }
}
---
# BSTART

32位标准长度的BSTART指令支持全量的块类型和跳转方式，并且有三种BSTART指令提供给用户选择：

> DavinciOO v5 发布 TEPL、TLSU、CUBE 和 programmable coupled SYS。SYS 仅允许 FALL；本页其他 SYS BrType 组合属于未在 v5 激活的 inherited encoding。`.PAR/.VEC`、`BSTART.VPAR` 和 `BSTART.VSEQ` 仍只作为 Linx inherited reference。

- 第一种可以用于不同类型的块，并且支持全量跳转方式。
- 第二种仅用于标量块且跳转方式只能是DIRECT或CALL类型的，这种指令相比第一种可表达的跳转距离更远。
- 第三种仅用于标量块且跳转方式只能是COND类型的，跳转距离与第二种相同。

## 汇编语法

```asm
    BSTART<.BlockType> BrType<.label>          
    BSTART<.STD> {direct, call}, label
    BSTART<.STD> cond, label
```

其中：

- **BlockType**：该参数代表块类型，如果是标量块，则可缺省`.STD`标识。
- **BrType**：该参数代表块指令的跳转方式，根据块类型不同可选类型也不同，具体见下表。
- **label**：该参数代表跳转目标位置的标签，其相对于本指令的偏移距离除以2进行编码。

| BlockType | 支持的BrType |
|------------|-------------|
| 标量块（.STD）  | fall, direct, call, cond, ind, icall, ret |
| 系统块（.SYS）  | fall |
| 浮点块（.FP）   | fall, direct, call, cond, ind, icall, ret |
| 并行块（.PAR）  | fall  |

## 编码格式

第一种BSTART编码:

> 原 Linx 图片引用已省略；编码图用本页 bit-level 表格表达。

- **BlockType 域**

BlockType 用于指示执行该块指令的引擎类型，具体编码如下：

| BlockType | 块类型              | 汇编标识  | 解释                                                         |
|-----------|---------------------|-----------|-----------------------------------------------------------|
| 0         | Standard Block       | .STD      | 标量块，块内支持基础标量运算指令和复合操作指令               |
| 1         | System Block         | .SYS      | 系统块（也称为辅助块），块内支持基础标量运算指令和系统控制指令               |
| 2         | Floating-point Block | .FP       | 浮点块，块内支持基础标量运算指令和浮点运算指令               |
| 3         | Parallel Block       | .PAR/.VEC | Linx inherited parallel/vector block type；DavinciOO v5 superscalar intrinsic 不发布可编程 vector block body |
| 4-30      | RESERVE              | RESERVE   | 保留                                                     |

- **BrType 域**

BrType 描述了当前块的跳转类型，决定了如何从当前块跳转到下一个块。不同的跳转类型对应不同的块跳转行为。具体编码如下：

| BrType | 跳转类型          | 解释                                          |
|--------|-------------------|-----------------------------------------------|
| 0      | RESERVE            | 无效                                          |
| 1      | FALL               | 顺延(Fall Through)                            |
| 2      | DIRECT             | 直接跳转(Direct Branch)                       |
| 3      | COND               | 条件跳转(Conditional Branch)                  |
| 4      | CALL               | 直接调用(Direct Call)                         |
| 5      | IND                | 间接跳转(Indirect)                            |
| 6      | INDCALL            | 间接调用(Indirect Call)                       |
| 7      | RET                | 返回(Return)                                  |

- **PayLoad 域**

PayLoad 域用于编码块指令执行时需要的其他参数。不同的块类型或跳转类型对 PayLoad 的解释可能不同。例如，在偏移类跳转方式的块中，该字段用作编码跳转偏移距离。在顺延FALL类型的块中，该字段用作编码[主动修复块](../../arch/fixup.md)的偏移距离。其他非偏移类跳转方式的块中，该字段可以用于编码其他参数（当前版本暂时保留）。

**说明**：PayLoad 是块指令执行要求的补充参数，具体用途视块类型和跳转方式而定。

第二种BSTART编码:

> 原 Linx 图片引用已省略；编码图用本页 bit-level 表格表达。

第三种BSTART编码:

> 原 Linx 图片引用已省略；编码图用本页 bit-level 表格表达。

## 汇编示例

```asm
    BSTART.STD direct, 0x00ff
    BSTART.STD call,   0x01ef
    BSTART.SYS fall
    BSTART.FP  ret
```

## Bit-level Encoding

### `BSTART.CUBE` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `DataType` | 5 | `` |
| `[26:25]` | `0` | 2 | `0` |
| `[24:20]` | `Function` | 5 | `` |
| `[19:15]` | `6` | 5 | `6` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `3` | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.FIXP` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `DataType` | 5 | `` |
| `[26:25]` | `0` | 2 | `0` |
| `[24:20]` | `Function` | 5 | `` |
| `[19:15]` | `7` | 5 | `7` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `3` | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.FP_CALL` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | `` |
| `[14:12]` | `Func` | 3 | `4` |
| `[11:7]` | `2` | 5 | `2` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.FP_COND` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | `` |
| `[14:12]` | `Func` | 3 | `3` |
| `[11:7]` | `2` | 5 | `2` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.FP_DIRECT` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | `` |
| `[14:12]` | `Func` | 3 | `2` |
| `[11:7]` | `2` | 5 | `2` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.FP_FALL` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | `` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `2` | 5 | `2` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.FP_ICALL` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `reserve` | 17 | `` |
| `[14:12]` | `Func` | 3 | `6` |
| `[11:7]` | `2` | 5 | `2` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.FP__IND` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `reserve` | 17 | `` |
| `[14:12]` | `Func` | 3 | `5` |
| `[11:7]` | `2` | 5 | `2` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.FP__RET` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `reserve` | 17 | `` |
| `[14:12]` | `Func` | 3 | `7` |
| `[11:7]` | `2` | 5 | `2` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.MPAR` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `0` | 5 | `0` |
| `[26:25]` | `Mode` | 2 | `` |
| `[24:20]` | `0` | 5 | `0` |
| `[19:15]` | `0` | 5 | `0` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `3` | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.MSEQ` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `0` | 5 | `0` |
| `[26:25]` | `Mode` | 2 | `` |
| `[24:20]` | `0` | 5 | `0` |
| `[19:15]` | `1` | 5 | `1` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `3` | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.STD_CALL` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | `` |
| `[14:12]` | `Func` | 3 | `4` |
| `[11:7]` | `0` | 5 | `0` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.STD_COND` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | `` |
| `[14:12]` | `Func` | 3 | `3` |
| `[11:7]` | `0` | 5 | `0` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.STD_DIRECT` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | `` |
| `[14:12]` | `Func` | 3 | `2` |
| `[11:7]` | `0` | 5 | `0` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.STD_FALL` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | `` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `0` | 5 | `0` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.STD_ICALL` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `reserve` | 17 | `` |
| `[14:12]` | `Func` | 3 | `6` |
| `[11:7]` | `0` | 5 | `0` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.STD_IND` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `reserve` | 17 | `` |
| `[14:12]` | `Func` | 3 | `5` |
| `[11:7]` | `0` | 5 | `0` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.STD_RET` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `reserve` | 17 | `` |
| `[14:12]` | `Func` | 3 | `7` |
| `[11:7]` | `0` | 5 | `0` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.SYS` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | `` |
| `[14:12]` | `BrType` | 3 | `1` |
| `[11:7]` | `BlockType` | 5 | `1` |
| `[6:4]` | `Opcode` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.TEPL` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `DataType` | 5 | `` |
| `[26:25]` | `Mode` | 2 | `` |
| `[24:20]` | `Function` | 5 | `` |
| `[19:15]` | `3` | 5 | `3` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `3` | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.TLSU` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `DataType` | 5 | `` |
| `[26:25]` | `0` | 2 | `0` |
| `[24:20]` | `Function` | 5 | `` |
| `[19:15]` | `2` | 5 | `2` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `3` | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

> `BSTART.VPAR/VSEQ` 编码仅作为 Linx inherited reference 保留；DavinciOO v5 superscalar intrinsic 不使用这些 block start 定义 vector block body。

### `BSTART.VPAR` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `0` | 5 | `0` |
| `[26:25]` | `Mode` | 2 | `` |
| `[24:20]` | `0` | 5 | `0` |
| `[19:15]` | `4` | 5 | `4` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `3` | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART.VSEQ` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `0` | 5 | `0` |
| `[26:25]` | `Mode` | 2 | `` |
| `[24:20]` | `0` | 5 | `0` |
| `[19:15]` | `5` | 5 | `5` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | `3` | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `PayLoad` | 17 | `` |
| `[14:12]` | `BrType!=0` | 3 | `` |
| `[11:7]` | `BlockType` | 5 | `` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART_1` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:7]` | `simm25` | 25 | `` |
| `[6:4]` | `Opc1` | 3 | `1` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

### `BSTART_2` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:7]` | `simm25` | 25 | `` |
| `[6:4]` | `Opc1` | 3 | `2` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |
