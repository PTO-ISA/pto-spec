<!-- GENERATED FROM: asl/arch/memory-model/address-space.asl -->
# Address Space

**Normative ASL source:** `asl/arch/memory-model/address-space.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-address-space-purpose role=purpose-scope -->
## 用途与范围

本单元提供可执行内存模型使用的有界字节地址访问层。它判断一个 `Word` 地址是否位于已配置模型内，并为有效地址提供字节读取与写入。

<!-- PTO-READER-BLOCK: arch-address-space-concepts role=concepts-state -->
## 地址与存储概念

- `IsModelAddress` 将 `UInt(address)` 与 `PTO_MODEL_MEMORY_BYTES` 比较。
- `ReadMemoryByte` 返回转换后的模型索引在 `_Memory` 中保存的 `Byte`。
- `WriteMemoryByte` 更新同一个按字节寻址的 `_Memory` 状态。

<!-- PTO-READER-BLOCK: arch-address-space-rules role=rules-interactions -->
## 访问顺序

两个访问器都会先断言 `IsModelAddress(address)`，再把地址转换为 `ModelAddress`。因此调用方必须先建立模型范围有效性，随后才能观察或修改一个字节。

<!-- PTO-READER-BLOCK: arch-address-space-boundaries role=boundaries -->
## 模型边界

已配置的 `_Memory` 数组是可执行验证存储。它的大小限制当前模型实例；本页并不声称每个 PTO 实现都把该字节数作为其架构地址空间。

<!-- PTO-READER-BLOCK: arch-address-space-example role=example-usage -->
## 非规范访问示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-address-space-related role=related-owners-navigation -->
## 相关所有者

- `PTO-ARCH-STATE-DEFINEDNESS` 提供本单元使用的状态基础。
- 内存事件和指令访问所有者在这些字节辅助函数之上构建更高层行为。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/address-space.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE","surface":"arch","classification":["memory-model","address-space"],"depends_on":["PTO-ARCH-STATE-DEFINEDNESS"]}

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-MEMORY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// PTO memory operations MUST reach physical byte storage only through
// ReadPhysicalMemoryByte and WritePhysicalMemoryByte. A functional-model
// binding MAY replace the reference array with host storage, but MUST preserve
// the ASL-owned translation, permission, preflight, ordering, and precise-fault
// behavior. The reference array bound MUST NOT constrain a host address space.
// NDF-END: PTO-REQ-FUNCTIONAL-MEMORY-001

readonly impdef func ReadPhysicalMemoryByte(address: Word) => Byte
begin
    return Zeros{8};
end;

impdef func WritePhysicalMemoryByte(address: Word, value: Byte)
begin
    assert FALSE;
end;

readonly func ReadMemoryByte(address: Word) => Byte
begin
    return ReadPhysicalMemoryByte(address);
end;

func WriteMemoryByte(address: Word, value: Byte)
begin
    WritePhysicalMemoryByte(address, value);
end;
```
<!-- GENERATED-ASL-END: unit -->
