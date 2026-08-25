<!-- GENERATED FROM: asl/arch/system-registers/context.asl -->
# Context

**Normative ASL source:** `asl/arch/system-registers/context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-context-purpose-scope role=purpose-scope -->
## 用途与范围

本单元定义环编号与低位上下文寄存器索引如何选中扩展系统寄存器文件中的条目，并定义该条目的 PTOv0 读写辅助函数。

<!-- PTO-READER-BLOCK: arch-system-context-concepts-state role=concepts-state -->
## 上下文寄存器索引

`ContextRegisterIndex` 和 `PTOv0ContextRegisterIndex` 都计算 `ring * 4096 + low_index`。低位索引限制在 `0` 到 `4095`。

结果类型是 `SystemRegisterFileIndex`，所以每个 ACR 都得到一个连续的 `4096` 条目窗口。

<!-- PTO-READER-BLOCK: arch-system-context-rules-interactions role=rules-interactions -->
## PTOv0 读取与写入

`PTOv0ReadContextRegister` 返回计算所得 PTOv0 索引处的 `_ExtendedSystemRegisters`。`PTOv0WriteContextRegister` 用给定 `Word` 替换同一条目。

<!-- PTO-READER-BLOCK: arch-system-context-boundaries role=boundaries -->
## 架构边界

两个索引辅助函数当前使用相同算术。

保留 PTOv0 具名辅助函数，可以让读者清楚看到版本专用的访问路径，而不在本页给各个低位索引赋予语义。

本单元不定义访问许可、特定寄存器的副作用或复位值。

<!-- PTO-READER-BLOCK: arch-system-context-example-usage role=example-usage -->
## 非规范地址示例

对于 ACR2 和低位索引 `0x0f08`，选中的扩展寄存器索引是 `2 * 4096 + 0x0f08`。通过 PTOv0 辅助函数进行读写时，访问的是同一个元素。

<!-- PTO-READER-BLOCK: arch-system-context-related-owners role=related-owners-navigation -->
## 相关所有者

- [访问控制](access-control.md)定义 ACR 状态，并且是直接依赖项。
- [中断寄存器](interrupt.md)为低位索引 `0x0f07`、`0x0f08` 和 `0x0f09` 赋予含义。
- [定时器寄存器](timer.md)使用低位索引 `0x0f21` 存储比较值。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-CONTEXT","surface":"arch","classification":["system-registers","context"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL"]}
pure func ContextRegisterIndex(ring: AccessControlRing,
                               low_index: integer {0..4095})
    => SystemRegisterFileIndex
begin
    return ((ring * 4096) + low_index) as SystemRegisterFileIndex;
end;

pure func PTOv0ContextRegisterIndex(ring: AccessControlRing,
                                    low_index: integer {0..4095})
                                    => SystemRegisterFileIndex
begin
    return ((ring * 4096) + low_index) as SystemRegisterFileIndex;
end;

readonly func PTOv0ReadContextRegister(ring: AccessControlRing,
                                       low_index: integer {0..4095}) => Word
begin
    return _ExtendedSystemRegisters[[
        PTOv0ContextRegisterIndex(ring, low_index)]];
end;

func PTOv0WriteContextRegister(ring: AccessControlRing,
                               low_index: integer {0..4095}, value: Word)
begin
    _ExtendedSystemRegisters[[PTOv0ContextRegisterIndex(ring, low_index)]] =
        value;
end;
```
<!-- GENERATED-ASL-END: unit -->
