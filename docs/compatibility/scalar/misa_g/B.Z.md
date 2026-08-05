> DavinciOO 继承 Linx scalar ISA 原文页。Source: `docs/zh/isa/inst/misa_g/B.Z.md`
> 本页作为 ordinary GPR / `meta_gpr` 构造能力的参考；opcode/encoding 保持 Linx v0.56。

# B.Z

## 说明

全零时跳转(*Branch if all Zeros*)
如果[P寄存器](../../register/common/pred.md)的**所有位都为0时**，跳转到当前`TPC`加上左移一位的立即数偏移指示的目标地址处；否则，顺序执行。

## 汇编语法

```
    b.z label
```

## 汇编符号

- **label**：表示条件跳转目标位置的程序标签。它相对于本指令TPC的偏移距离除以2后编码在simm22字段。

## 编码格式

> 原 Linx 图片引用已省略；如需查看图形 bitfield，请打开本页 Source 路径对应的 Linx 原文。

## 执行方式

- 转换为十进制数：[UInt()](../LibPseudoCode.md)
- 通用寄存器读写：[R\[\]](../LibPseudoCode.md)
- 对数据符号扩展：[SignExtend()](../LibPseudoCode.md)

```c
    bits(64) mask = P[63:0];
    bits(64) simm = SignExtend(simm22);
    bits(64) offset = simm << 1;

    if mask == 0 then
        TPC += offset;
    else
        TPC += 4;
```

## 注意事项

本指令不占块内私有寄存器槽位。

## 备注

本指令属于[基础指令集](../../instset/baseInstrs.md)，可用于向量Tile块、并行Tile块和访存Tile块的块体中。
