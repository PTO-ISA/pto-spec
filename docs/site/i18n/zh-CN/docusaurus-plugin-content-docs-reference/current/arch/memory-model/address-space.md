<!-- GENERATED FROM: asl/arch/memory-model/address-space.asl -->
# Address Space

**Normative ASL source:** `asl/arch/memory-model/address-space.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-address-space-purpose role=purpose-scope -->
## 目的与范围

本单元是内存模型的字节存储底层。它声明 PTO 内存操作通过 `ReadPhysicalMemoryByte` 与 `WritePhysicalMemoryByte` 到达物理字节，并提供两个便捷包装 `ReadMemoryByte` 与 `WriteMemoryByte`。下面的可执行主体不包含转换表、不包含权限检查、也不包含故障路径：它只是围绕一个字节数组的五个小助手函数。

所需条款是 `PTO-REQ-PHYSICAL-MEMORY-BINDING-001`。第 1 行的单元元数据声明 `PTO-ARCH-STATE-DEFINEDNESS` 为其依赖，但可执行主体从未提及已定义性；请把该依赖当作它本来的单元图边，而不是对代码的描述。

<!-- PTO-READER-BLOCK: arch-address-space-concepts role=concepts-state -->
## 字节、地址与唯一的状态对象

- `IsModelAddress` 返回 `UInt(address) < PTO_MODEL_MEMORY_BYTES`，因此合法性就是与一个配置值做一次无符号比较。
- `ReadPhysicalMemoryByte` 断言 `IsModelAddress(address)`，用 `let index = UInt(address) as ModelAddress` 转换，并返回 `_Memory[[index]]`。
- `WritePhysicalMemoryByte` 执行同样的断言与转换，然后把 `Byte` 实参存入 `_Memory[[index]]`。
- `ReadMemoryByte` 与 `WriteMemoryByte` 是无条件的一行转发，转发到那对物理函数。
- 唯一被触及的状态是 `_Memory`，一个由 `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT` 拥有的 `array [[PTO_MODEL_MEMORY_BYTES]] of Byte`。
- `PTO_MODEL_MEMORY_BYTES` 是声明在 `asl/arch/features/tile-allocation.asl` 中的 `config`，取值范围 `256..65536`、默认值 `4096`。

<!-- PTO-READER-BLOCK: arch-address-space-rules role=rules-interactions -->
## 访问顺序与调用者必须建立的前提

两个物理访问函数都断言 `IsModelAddress(address)`，然后转换到 `ModelAddress` 范围 `0..PTO_MODEL_MEMORY_BYTES-1`。两个逻辑访问函数自身不做任何检查；它们继承被调用者的断言。

设计要点：范围检查是一条 `assert`，在 ASL 中它是模型完整性条件，而不是架构故障。若调用者以 `UInt(address) >= PTO_MODEL_MEMORY_BYTES` 到达这些助手函数，则模型运行失败，而不会产生一个已定义的故障。可观察的后果是：本单元永远不能成为某个故障码的拥有者；诸如标量数据路径这样的调用者会先运行自己的探测，把拒绝转换成 `Fault_DataPage` 之后再调用这里。

设计要点：转换 `UInt(address) as ModelAddress` 发生在断言之后，因此索引已知在范围内，数组访问是全定义的。由于物理助手函数接受普通的 `Word` 字节地址并且只读取一个 `Byte`，非对齐与单字节粒度的访问不需要任何特例：`0x7c0` 与 `0x7c1` 只是不同的索引。

<!-- PTO-READER-BLOCK: arch-address-space-boundaries role=boundaries -->
## 边界

该条款规定固定的参考数组边界 MUST NOT 约束每一个实现，而这正是 `PTO_MODEL_MEMORY_BYTES` 在此处的地位：它约束一个可执行模型实例。本页不声称任何实现暴露 `4096` 个架构字节。

该条款归为一组的若干能力并不在这个主体里。转换不在这里（标量路径有 `TranslateDataAddress`，指令取指有 `TranslateInstructionAddress`）。权限不在这里（`DataAccessPermitted` 与 `InstructionAccessPermitted` 位于别处）。顺序、预检与提交也不在这里。本单元只提供那些拥有者所调用的字节底层。

确实有两个调用者绕过包装直接到达物理函数对：标量数据路径使用 `ReadMemoryByte` 与 `WriteMemoryByte`，例如在 `asl/scalar/model/agu/memory.asl` 中；`asl/arch/memory-model/instruction-fetch.asl` 中的 `FetchPTOInstruction` 使用 `ReadPhysicalMemoryByte`。本文件之外的 ASL 单元没有调用 `WritePhysicalMemoryByte`；实际被走到的路径是 `WriteMemoryByte`。它们全都在探测已经拒绝越界地址之后运行，因此这里的断言是兜底，而不是主要检查。

<!-- PTO-READER-BLOCK: arch-address-space-example role=example-usage -->
## 非规范性阅读示例

在 `PTO_MODEL_MEMORY_BYTES` 取默认值 `4096` 时，`IsModelAddress(0x7c0)` 为真，`IsModelAddress(0x1000)` 为假。`0x7c0` 是 `1984`，`0x1000` 是 `4096`，因此该助手函数接受的最后一个地址是 `0xfff`。

因此，从 `0x7c0` 开始的六字节值通过 `WriteMemoryByte(0x7c0, ...)` 到 `WriteMemoryByte(0x7c5, ...)` 逐个字节写入，再用六个对应的 `ReadMemoryByte` 调用读回。每次调用都是独立的：不存在多字节内建操作，也不会隐式清零两次调用之间的字节，而且 `IsModelAddress` 只校验传给它的那一个字节地址，从不校验多字节范围。

本示例仅作为阅读辅助：先应用上面的规则，再到规范性 ASL 拥有者中确认结果。它不增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-address-space-related role=related-owners-navigation -->
## 相关拥有者

- `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT` 声明 `_Memory` 数组以及列出它的 `PTO-STATE-ARCH-MEMORY` 状态记录。
- [指令取指](instruction-fetch.md) 直接调用 `ReadPhysicalMemoryByte`，并补上本单元没有的探测。
- [全局内存访问](global-memory-access.md) 与 [原子性](atomicity.md) 描述建立在这些字节之上的请求级行为。
- `PTO-ARCH-FEATURES-TILE-ALLOCATION` 声明 `IsModelAddress` 所用的 `PTO_MODEL_MEMORY_BYTES` 边界。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/address-space.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE","surface":"arch","classification":["memory-model","address-space"],"depends_on":["PTO-ARCH-STATE-DEFINEDNESS"]}

// NDF-BEGIN: PTO-REQ-PHYSICAL-MEMORY-BINDING-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// PTO memory operations MUST reach physical byte storage through
// ReadPhysicalMemoryByte and WritePhysicalMemoryByte. An implementation MAY
// bind those primitives to external storage, but MUST preserve ASL-owned
// translation, permission, ordering, preflight, precise-fault, and commit
// behavior. Fixed reference-array bounds MUST NOT constrain every
// implementation.
// NDF-END: PTO-REQ-PHYSICAL-MEMORY-BINDING-001

readonly func ReadPhysicalMemoryByte(address: Word) => Byte
begin
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    return _Memory[[index]];
end;

func WritePhysicalMemoryByte(address: Word, value: Byte)
begin
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    _Memory[[index]] = value;
end;

readonly func IsModelAddress(address: Word) => boolean
begin
    return UInt(address) < PTO_MODEL_MEMORY_BYTES;
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
