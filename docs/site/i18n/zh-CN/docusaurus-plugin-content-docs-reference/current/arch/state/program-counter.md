<!-- GENERATED FROM: asl/arch/state/program-counter.asl -->
# Program Counter

**Normative ASL source:** `asl/arch/state/program-counter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-PROGRAM-COUNTER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-program-counter-purpose-scope role=purpose-scope -->
## 用途与范围

本单元定义普通程序计数器、陷阱程序计数器和指令束程序计数器视图的读写辅助函数。

<!-- PTO-READER-BLOCK: arch-program-counter-concepts-state role=concepts-state -->
## 计数器视图

`ReadPC` 和 `ReadTPC` 都返回 `_PC`。`ReadBPC` 返回独立的 `_BPC` 状态。

`WritePC` 和 `WriteTPC` 都替换 `_PC`，而 `WriteBPC` 替换 `_BPC`。

<!-- PTO-READER-BLOCK: arch-program-counter-rules-interactions role=rules-interactions -->
## 共享 PC 存储

PC 和 TPC 是同一个已存 `Word` 的两个访问名称；在本模型中它们不是独立计数器。BPC 与该共享存储相互独立。

<!-- PTO-READER-BLOCK: arch-program-counter-boundaries role=boundaries -->
## 架构边界

这些辅助函数只定义存储访问。它们本身不定义指令顺序、对齐检查、陷阱进入、指令束完成或恢复资格。

<!-- PTO-READER-BLOCK: arch-program-counter-example-usage role=example-usage -->
## 非规范视图示例

`WriteTPC` 存入一个对齐地址后，`ReadPC` 会观测到相同值，因为二者都使用 `_PC`。随后调用 `WriteBPC` 只改变 `ReadBPC` 返回的值。

<!-- PTO-READER-BLOCK: arch-program-counter-related-owners role=related-owners-navigation -->
## 相关所有者

- [标量寄存器](../programming-model/scalar-registers.md)是声明的依赖项。
- [陷阱上下文](trap-context.md)快照并恢复 TPC 和 BPC。
- [执行上下文](../programming-model/execution-context.md)拥有更广泛的程序控制状态。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/program-counter.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-PROGRAM-COUNTER","surface":"arch","classification":["state","program-counter"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
readonly func ReadPC() => Word
begin
    return _PC;
end;

readonly func ReadTPC() => Word
begin
    return _PC;
end;

readonly func ReadBPC() => Word
begin
    return _BPC;
end;

func WritePC(value: Word)
begin
    _PC = value;
end;

func WriteTPC(value: Word)
begin
    _PC = value;
end;

func WriteBPC(value: Word)
begin
    _BPC = value;
end;
```
<!-- GENERATED-ASL-END: unit -->
