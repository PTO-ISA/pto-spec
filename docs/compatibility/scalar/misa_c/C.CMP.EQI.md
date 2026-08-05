> DavinciOO 继承 Linx scalar ISA 原文页。Source: `docs/zh/isa/inst/misa_c/C.CMP.EQI.md`
> 本页作为 ordinary GPR / `meta_gpr` 构造能力的参考；opcode/encoding 保持 Linx v0.57。

# C.CMP.EQI

## 说明

立即数相等比较(*Compare with Immediate if Equal*)
比较前序输出至T队列的指令结果和有符号扩展立即数，如果相等则将**1**写到T寄存器中，否则写入**0**。

本指令的标准形式请见[CMP.EQI](../misa_g/CMP.EQI.md)。

## 汇编语法

```
    c.cmp.eqi t#1, simm, ->t
```

## 汇编符号

- **t#1**：源寄存器，索引前序第一条输出至T队列的指令结果。
- **simm**：5位有符号立即数。
- **->**：用于指示目的寄存器。
- **t**：目的寄存器，代表块内的T寄存器队列。

## 编码格式

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

## 执行方式

- 转换为十进制数：[UInt()](../LibPseudoCode.md)
- 通用寄存器读写：[R\[\]](../LibPseudoCode.md)
- 对数据符号扩展：[SignExtend()](../LibPseudoCode.md)

```c
    integer d = UInt(RegDst);
    integer s = UInt(SrcL);
    integer datawidth = 64;

    bits(datawidth) operand = TR1[63:0];
    bits(datawidth) simm = SignExtend(simm5);

    bits(datawidth) result = (operand == simm ? 1 : 0);
    T[id] = result;
```

## 汇编索引模式

```asm
    c.cmp.eqi t#1, simm,  ->t        /* 单寄存器绝对索引 */
```

## 备注

本指令属于[压缩指令扩展](../../instset/compressInstrs.md)，仅在使能了压缩扩展的处理器中支持使用。
