> DavinciOO 继承 Linx scalar ISA 原文页。Source: `docs/zh/isa/inst/misa_g/SETRET.md`
> 本页作为 ordinary GPR / `meta_gpr` 构造能力的参考；opcode/encoding 保持 Linx v0.57。

# SETRET

## 说明

设置返回地址(*Set Return Address*)
立即数左移1位(低位置零)后与当前指令的`TPC`相加，结果写到ra寄存器中。

## 汇编语法

```
    setret uimm, ->ra
```

## 汇编符号

- **uimm**：20位无符号立即数，编码于imm20域。
- **->**：用于指示目的寄存器。
- **ra**：目的寄存器，全局寄存器ra(r10)。

## 编码格式

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

## 执行方式

- 转换为十进制数：[UInt()](../LibPseudoCode.md)
- 通用寄存器读写：[R\[\]](../LibPseudoCode.md)
- 将数据无符号扩展：[ZeroExtend()](../LibPseudoCode.md)

```c
    integer datawidth = 64;

    bits(datawidth) uimm = ZeroExtend(uimm20);
    bits(datawidth) result = tpc + (uimm << 1);
    R[10, datawidth] = result;
```

## 汇编索引模式

```asm
    setret uimm,    ->ra         /* 只能写到全局的ra寄存器 */
```

!!! note "注意！"

    1. 该指令**只能写全局的ra寄存器**。
    2. 该指令仅在**CALL**和**ICALL**跳转的块内使用。

## 备注

本指令属于[基础指令集](../../instset/baseInstrs.md)，允许使用在不同块类型块内。
