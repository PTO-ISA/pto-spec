<!-- GENERATED FROM: asl/scalar/model/agu/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/scalar/model/agu/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-AGU-ADDRESSING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-purpose role=purpose-scope -->
## 用途与范围

本单元定义直接的标量加载、存储、成对访问和预取辅助函数。每个辅助函数接收已解析的寄存器索引和一个偏移，形成地址，并通过[标量内存](memory.md)中的辅助函数执行一次内存事务。

本单元包含四类辅助函数：

- `EffectiveAddress`，按更新模式选出被访问的地址。
- `ExecuteScalarLoad` 和 `ExecuteScalarStore`，访问一个元素，并可回写更新后的基址。
- `ExecuteScalarLoadPair` 和 `ExecuteScalarStorePair`，访问两个相邻元素。
- `ScalarPrefetchAddress` 和 `ScalarPrefetch`，形成预取地址而不触及内存。

没有任何 ASL 代码调用 `EffectiveAddress` 或四个加载、存储和成对辅助函数；`ScalarHandler_*` 处理函数名只用于标注目录形式。[AGU 分派](../dispatch/agu.md)中的译码路径用已译码字段重复相同规则，并调用本单元的 `ScalarPrefetch` 和 `ScalarPrefetchAddress`。

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-concepts role=concepts-state -->
## 概念与可见状态

地址更新模式是 `AddressUpdate_None`、`AddressUpdate_PreIndex` 或 `AddressUpdate_PostIndex` 之一。更新后的基址总是 `base + offset`。前索引和无更新访问以更新后的基址为地址。后索引访问使用原始基址。

所有地址运算都使用 64 位 `Word` 值，因此按 2^64 取模回绕。

加载辅助函数把加载值规范化为 64 位。有符号加载从访问宽度符号扩展；无符号加载零扩展。

这些辅助函数通过 `ReadGPR` 读取 GPR，通过 `WriteGPR` 写入 GPR。它们会触及内存、内存事件、保留状态和 `_LastFault`。它们不推进 TPC；通过 `SetFault` 引发的故障还会记录故障地址和陷阱上下文，并把 TPC 重定向到陷阱向量。

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-rules role=rules-interactions -->
## 规则与交互

`ExecuteScalarLoad` 读取基址，执行 `LoadSigned` 或 `LoadUnsigned`，然后检查 `_LastFault`。只有在未引发故障时，它才写入目标寄存器，并在前索引或后索引时写入更新后的基址。目标寄存器先于基址写入。

`ExecuteScalarStore` 读取基址和数据寄存器，调用 `Store`，并且仅当 `_LastFault` 仍为 `Fault_None` 时才回写更新后的基址。

设计要点：在单元素辅助函数中，每次目标写入和基址写入都受 `_LastFault == Fault_None` 保护。因此发生故障的访问会让目标 GPR 和基址 GPR 保持不变。恢复时可以从原始源重新发出完整指令，因为没有发布任何部分的基址更新。

成对辅助函数从不回写基址。它们把第二个地址计算为第一个地址加上访问大小。随后按此顺序用 `ProbeDataAccess` 预检第一个地址和第二个地址，然后才移动任何数据。第一个失败的预检在其自身的原始地址上引发故障，辅助函数随即返回。

设计要点：两次预检都在第一次加载或存储之前完成。因此成对存储不会先写入第一个元素、再在第二个元素上发生故障。成功时，成对加载读取两个值，先低元素后高元素记录两个宽松加载事件，并先写低位目标、再写高位目标。成对存储在任一存储之前读取两个源寄存器，然后先存储并记录低元素，再存储并记录高元素。

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-boundaries role=boundaries -->
## 架构边界

`ScalarPrefetch` 形成 `base + offset` 并将其丢弃。它不执行地址转换、不做权限检查、不访问内存，也不记录事件，因此预取不会引发数据故障。该辅助函数不使用其 `model` 参数。编码的 `model` 值是否合法由分派之前该形式的目录约束决定。

对齐、有界内存限制和访问环限制由[标量内存](memory.md)中的 `ProbeDataAccess` 负责，而不是本单元。

直接辅助函数接收绝对 GPR 索引。它们不处理 T/U 队列选择子、压缩形式、PC 相对基址或偏移缩放；这些属于译码分派。

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-example role=example-usage -->
## 非规范阅读示例

考虑调用 `ExecuteScalarLoad`：目标 GPR 5，基址 GPR 6 持有 0x100，偏移 8，大小 4，无符号，模式 `AddressUpdate_PostIndex`。

- `EffectiveAddress` 返回原始基址 0x100，因为模式是后索引。
- `LoadUnsigned` 预检 0x100。它按 4 字节对齐，因此不引发对齐故障。
- 如果访问被允许，GPR 5 接收零扩展的 32 位值，随后 GPR 6 接收 0x108。
- 如果预检失败，则设置 `_LastFault`，GPR 5 和 GPR 6 都不改变。

若使用 `AddressUpdate_PreIndex`，同一调用会访问 0x108，并同样把 0x108 写入 GPR 6。

<!-- PTO-READER-BLOCK: scalar-model-agu-addressing-related role=related-owners-navigation -->
## 相关所有者

- [标量内存](memory.md)拥有预检、字节访问、规范化和保留失效。
- [AGU 分派](../dispatch/agu.md)拥有译码地址形成、缩放和队列操作数。
- [故障精确性](../../../arch/memory-model/fault-precision.md)拥有精确故障与重启契约。
- [内存事件](../../../arch/memory-model/memory-events.md)拥有所记录的加载和存储事件。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/agu/addressing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-AGU-ADDRESSING","surface":"scalar","classification":["model","agu","addressing"],"depends_on":["PTO-SCALAR-MODEL-AGU-MEMORY"]}
// PTO-REQ-SCALAR-ADDRESS-001, PTO-REQ-MEMORY-COMPLETION-001: scalar addressing,
// pair preflight, and fault-suppressed register writeback.

pure func EffectiveAddress(base: Word, offset: Word, mode: AddressUpdateMode) => Word
begin
    if mode == AddressUpdate_PostIndex then return base;
    else return base + offset;
    end;
end;

func ExecuteScalarLoad(destination: GPRIndex, base_register: GPRIndex,
                       offset: Word, size_bytes: integer {1,2,4,8},
                       signed_load: boolean, mode: AddressUpdateMode)
begin
    let base = ReadGPR(base_register);
    let address = EffectiveAddress(base, offset, mode);
    let value = if signed_load then LoadSigned(address, size_bytes)
                else LoadUnsigned(address, size_bytes);
    if _LastFault == Fault_None then
        WriteGPR(destination, value);
        if mode == AddressUpdate_PreIndex || mode == AddressUpdate_PostIndex then
            WriteGPR(base_register, base + offset);
        end;
    end;
end;

func ExecuteScalarStore(source: GPRIndex, base_register: GPRIndex,
                        offset: Word, size_bytes: integer {1,2,4,8},
                        mode: AddressUpdateMode)
begin
    let base = ReadGPR(base_register);
    let address = EffectiveAddress(base, offset, mode);
    Store(address, size_bytes, ReadGPR(source));
    if _LastFault == Fault_None &&
       (mode == AddressUpdate_PreIndex || mode == AddressUpdate_PostIndex) then
        WriteGPR(base_register, base + offset);
    end;
end;

func ExecuteScalarLoadPair(destination_low: GPRIndex, destination_high: GPRIndex,
                           base_register: GPRIndex, offset: Word,
                           size_bytes: integer {1,2,4,8}, signed_load: boolean)
begin
    let base = ReadGPR(base_register);
    let address = base + offset;
    let second_address = address + NaturalToWord(size_bytes as integer {0..262144});
    let low_probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(low_probe, address) then return; end;
    let high_probe = ProbeDataAccess(
        second_address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(high_probe, second_address) then return; end;
    let low_raw = LoadTranslatedUnsigned(low_probe.translated_address, size_bytes);
    let high_raw = LoadTranslatedUnsigned(high_probe.translated_address, size_bytes);
    let low = NormalizeLoadedValue(low_raw, size_bytes, signed_load);
    let high = NormalizeLoadedValue(high_raw, size_bytes, signed_load);
    RecordLoadEvent(low_probe.translated_address, size_bytes,
        low_raw, MemoryOrder_Relaxed);
    RecordLoadEvent(high_probe.translated_address, size_bytes,
        high_raw, MemoryOrder_Relaxed);
    WriteGPR(destination_low, low);
    WriteGPR(destination_high, high);
end;

func ExecuteScalarStorePair(source_low: GPRIndex, source_high: GPRIndex,
                            base_register: GPRIndex, offset: Word,
                            size_bytes: integer {1,2,4,8})
begin
    let base = ReadGPR(base_register);
    let address = base + offset;
    let second_address = address + NaturalToWord(size_bytes as integer {0..262144});
    let low_probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(low_probe, address) then return; end;
    let high_probe = ProbeDataAccess(
        second_address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(high_probe, second_address) then return; end;
    let low = ReadGPR(source_low);
    let high = ReadGPR(source_high);
    StoreTranslated(address, low_probe.translated_address, size_bytes, low);
    RecordStoreEvent(low_probe.translated_address, size_bytes, low,
        MemoryOrder_Relaxed);
    StoreTranslated(second_address, high_probe.translated_address,
        size_bytes, high);
    RecordStoreEvent(high_probe.translated_address, size_bytes, high,
        MemoryOrder_Relaxed);
end;

pure func ScalarPrefetchAddress(base: Word, offset: Word) => Word
begin
    return base + offset;
end;

func ScalarPrefetch(base: Word, offset: Word, size_bytes: integer {1,2,4,8},
                    model: bits(5))
begin
    // Decode admits only the assigned L1/L2/L3 model values before sources are
    // read. Address formation is explicit, but no translation, permission
    // check, event, or memory effect is architecturally observed.
    - = ScalarPrefetchAddress(base, offset);
end;
```
<!-- GENERATED-ASL-END: unit -->
