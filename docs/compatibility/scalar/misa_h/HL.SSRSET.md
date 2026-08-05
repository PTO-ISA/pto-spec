> DavinciOO 继承 Linx scalar ISA 原文页。Source: `docs/zh/isa/inst/misa_h/HL.SSRSET.md`
> 本页作为 ordinary GPR / `meta_gpr` 构造能力的参考；opcode/encoding 保持 Linx v0.57。

# HL.SSRSET

## 说明

写入系统寄存器(*System Status Register Set*)
将源寄存器中的值写到 **SSR-ID** 指示的系统寄存器中。

## 汇编语法

```asm
    hl.ssrset SrcL, SSR-ID
```

## 汇编符号

- **SrcL**：源寄存器，可以索引全局寄存器R0-R23和前序1-4条输出至T队列或U队列的指令结果。
- **SSR-ID**：24位系统寄存器索引ID，映射关系请见[系统寄存器](../../register/ssr/ssrintro.md)介绍章节。

## 编码格式

- 低16bit编码：

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

- 高32bit编码：

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

## 执行方式

- 转换为十进制数：[UInt()](../LibPseudoCode.md)
- 通用寄存器读写：[R\[\]](../LibPseudoCode.md)
- 系统寄存器读写：[SSR\[\]](../LibPseudoCode.md)

```c
    integer s = UInt(SrcL);
    integer datawidth = 64;

    SSR[SSR-ID] = R[s, datawidth];
```

## 汇编索引模式

```asm
hl.ssrset a1, SSR-ID     /* 单寄存器绝对索引 */
hl.ssrset t#1, SSR-ID    /* 单寄存器相对索引 */
hl.ssrset u#1, SSR-ID    /* 单寄存器相对索引 */
```

## 注意事项

1. 本指令不占块内私有寄存器槽位。

## 备注

本指令属于[增强指令扩展](../../instset/haflLongInstrs.md)，可用于任意类型的块指令块体中。
