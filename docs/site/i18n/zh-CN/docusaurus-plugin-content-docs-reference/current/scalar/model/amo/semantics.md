<!-- GENERATED FROM: asl/scalar/model/amo/semantics.asl -->
# Semantics

**Normative ASL source:** `asl/scalar/model/amo/semantics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-AMO-SEMANTICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-purpose role=purpose-scope -->
## 用途与范围

本单元定义标量原子内存操作：加载保留与条件存储（LR/SC）、原子读-改-写（RMW）、比较并交换（CAS），以及 64 字节 `DMA` 复制。RMW、CAS 和 `DMA` 在读写内存之前先预检其地址。LR 和 SC 遵循下文的保留规则。

[AMO 分派](../dispatch/amo.md)读取已译码操作数并调用这些辅助函数。它只在未引发故障时把返回值写入目标。

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-concepts role=concepts-state -->
## 概念与可见状态

保留状态由 `_ReservationValid`、`_ReservationAddress` 和 `_ReservationSize` 组成。成功的 LR 设置这三项。保留粒度是包含 `_ReservationAddress` 的 64 字节行。

`AtomicAddress` 把地址和 `far` 提示映射为平坦地址。在本模型中它原样返回地址，因此 `far` 没有效果。

`AtomicValueSized` 按访问宽度计算新的内存值：

- `SWAP` 写入操作数。
- `ADD`、`AND`、`OR` 和 `XOR` 作用于零扩展的宽度值，并截断结果。
- `SMIN` 和 `SMAX` 比较符号扩展的宽度值；`UMIN` 和 `UMAX` 比较零扩展的宽度值。

`NormalizeAtomicReturn` 为目标整理旧值。它对 1 字节和 2 字节值做零扩展，对 4 字节值做符号扩展，8 字节值原样返回。

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-rules role=rules-interactions -->
## 规则与交互

`LoadReserved` 执行一次有序加载。如果加载发生故障，它不改动保留状态，因此较早的保留得以保留。

`StoreConditional` 首先比较粒度。如果保留有效且 SC 地址落在同一 64 字节行内，它清除保留、预检存储，成功时存储该值、记录一个存储事件并返回 0。未命中时它清除保留并返回 1，不做预检。

设计要点：保留未命中不做预检。无法成功的 SC 从不报告对齐故障或页故障，即使地址非法；它只是返回 1。命中的 SC 在预检之前清除保留，因此发生故障的 SC 也会失去保留。恢复后重新发出时，除非软件执行新的 LR，否则返回 1。

`AtomicReadModifyWrite` 和 `CompareAndSwap` 先按读预检地址，再按写预检。两次预检都必须通过，且两个转换后地址必须相等；否则操作引发 `Fault_DataPage`。只有此后它们才读取旧值并写入新值。两者都返回原始旧值。

`CompareAndSwap` 把旧值与按宽度规范化的期望值比较。匹配时存储期望写入值。两种结果都会记录原子事件，并带有成功标志。

设计要点：两次预检和转换后地址检查都在读取之前完成。除非读和写都能完成，否则不会读取旧值，也不会写入任何字节，因此发生故障的 RMW 或 CAS 让内存保持不变。

`ExecuteScalarDMACopy64` 以 1 字节对齐按读预检 64 字节源、按写预检 64 字节目标。它对全部 64 个源字节做快照，记录八个 8 字节加载事件，写入全部 64 个字节，并记录八个存储事件。

设计要点：快照发生在第一次目标写入之前，因此源与目标范围重叠时行为类似 `memmove`。任一预检故障都会让内存保持不变。

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-boundaries role=boundaries -->
## 架构边界

`PTO_RESERVATION_GRANULE_BYTES` 为 64。在保留有效时，SC 是否成功只取决于所在行；SC 的宽度和确切字节地址不必与 LR 相同。

[标量内存](../agu/memory.md)中的普通存储在所存范围与保留的 64 字节粒度重叠时，也会清除保留。`FENCE.D` 和 `FENCE.I` 无条件清除保留。

`CompareAndSwap` 通过 `StoreTranslated` 存储期望写入值操作数，只写入 `size_bytes` 个字节。原子事件记录按宽度规范化后的期望写入值。

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-example role=example-usage -->
## 非规范阅读示例

程序先在 0x104 执行 `LR.W`，然后在 0x138 执行 `SC.D`。

- `LoadReserved` 成功，并记录保留地址 0x104、大小 4。
- 保留粒度为 0x100，因为 0x104 向下取整到 64 的倍数。
- SC 的粒度也是 0x100，因此 SC 命中。
- 保留被清除，0x138 处的 8 字节预检通过，值被存储，SC 返回 0。

之后在 0x138 再执行一次 `SC.D` 会未命中，返回 1，且不做预检。

<!-- PTO-READER-BLOCK: scalar-model-amo-semantics-related role=related-owners-navigation -->
## 相关所有者

- [AMO 分派](../dispatch/amo.md)把 AMO 形式、宽度和排序位映射到这些辅助函数。
- [标量内存](../agu/memory.md)拥有预检、原始访问以及存储造成的保留失效。
- [原子性](../../../arch/memory-model/atomicity.md)拥有内存事件记录。
- [SYS 语义](../sys/semantics.md)拥有清除保留的栅栏。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/amo/semantics.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-AMO-SEMANTICS","surface":"scalar","classification":["model","amo","semantics"],"depends_on":["PTO-SCALAR-MODEL-AGU-ADDRESSING","PTO-ARCH-MEMORY-MODEL-ATOMICITY"]}
// PTO-REQ-SCALAR-AMO-001, PTO-REQ-MEMORY-RC-001: LR/SC, CAS, and atomic
// read-modify-write operations represented as indivisible PTO-RC memory events.

readonly func AtomicAddress(address: Word,
                                            far: boolean) => Word
begin
    return address;
end;

pure func NormalizeAtomicReturn(value: Word,
                                size_bytes: integer {1,2,4,8}) => Word
begin
    case size_bytes of
        when 1 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 2 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 4 => return SignExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

// DMA copies one 64-byte command payload. Both ranges are translated and
// permission-checked before any byte is read or written. Source bytes are
// snapshotted before the destination commit, so overlapping ranges have
// memmove semantics and any fault leaves memory unchanged.
func ExecuteScalarDMACopy64(source_address: Word, destination_address: Word)
begin
    let source_probe = ProbeDataAccess(source_address, 64, 1, FALSE);
    if RaiseDataAccessFault(source_probe, source_address) then
        return;
    end;

    let destination_probe = ProbeDataAccess(destination_address, 64, 1, TRUE);
    if RaiseDataAccessFault(destination_probe, destination_address) then
        return;
    end;

    let snapshot = LoadTranslatedBytes64(source_probe.translated_address);
    var event_values: array [[8]] of Word;
    for chunk = 0 to 7 do
        let offset = (chunk * 8) as integer {0..262144};
        let translated_source = source_probe.translated_address +
            NaturalToWord(offset);
        let snapshot_value = Bytes64ChunkValue(snapshot, chunk);
        event_values[[chunk]] = snapshot_value;
        RecordLoadEvent(
            translated_source,
            8,
            snapshot_value,
            MemoryOrder_Relaxed);
    end;

    StoreTranslatedBytes64(
        destination_address,
        destination_probe.translated_address,
        snapshot);

    for chunk = 0 to 7 do
        let offset = (chunk * 8) as integer {0..262144};
        let translated_destination = destination_probe.translated_address +
            NaturalToWord(offset);
        RecordStoreEvent(
            translated_destination,
            8,
            event_values[[chunk]],
            MemoryOrder_Relaxed);
    end;
end;

func LoadReserved(address: Word, size_bytes: integer {1,2,4,8},
                  order: MemoryOrder) => Word
begin
    let result = LoadWithOrder(address, size_bytes, order);
    // A fault has no LR reservation effect. In particular, it preserves an
    // older reservation rather than replacing or clearing it.
    if _LastFault == Fault_None then
        _ReservationValid = TRUE;
        _ReservationAddress = address;
        _ReservationSize = size_bytes;
    end;
    return result;
end;

func StoreConditional(address: Word, size_bytes: integer {1,2,4,8},
                      value: Word, order: MemoryOrder) => Word
begin
    let reservation_granule = ReservationGranuleAddress();
    let requested_granule = address - NaturalToWord(
        (UInt(address) MOD PTO_RESERVATION_GRANULE_BYTES) as
            integer {0..262144});
    // PTO's local exclusive monitor is cache-line based: SC width and exact
    // byte address do not narrow the reservation once the 64-byte line matches.
    let succeeds = _ReservationValid && reservation_granule == requested_granule;
    if succeeds then
        // Every SC attempt clears the local monitor, including a successful
        // reservation check followed by an access fault.
        _ReservationValid = FALSE;
        let probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
        if RaiseDataAccessFault(probe, address) then return Zeros{PTO_XLEN}; end;
        StoreTranslated(address, probe.translated_address, size_bytes, value);
        RecordStoreEvent(probe.translated_address, size_bytes, value, order);
        return Zeros{PTO_XLEN};
    else
        // A reservation miss is deliberately probe-free, even when address is
        // misaligned or outside the active access domain.
        _ReservationValid = FALSE;
        return Zeros{PTO_XLEN} + 1;
    end;
end;

pure func AtomicValue(op: AtomicOperation, old_value: Word, operand: Word) => Word
begin
    case op of
        when Atomic_SWAP => return operand;
        when Atomic_ADD  => return old_value + operand;
        when Atomic_AND  => return old_value AND operand;
        when Atomic_OR   => return old_value OR operand;
        when Atomic_XOR  => return old_value XOR operand;
        when Atomic_SMIN =>
            if SInt(old_value) < SInt(operand) then return old_value; else return operand; end;
        when Atomic_SMAX =>
            if SInt(old_value) > SInt(operand) then return old_value; else return operand; end;
        when Atomic_UMIN =>
            if UInt(old_value) < UInt(operand) then return old_value; else return operand; end;
        when Atomic_UMAX =>
            if UInt(old_value) > UInt(operand) then return old_value; else return operand; end;
    end;
end;

pure func NormalizeAtomicUnsigned(value: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    case size_bytes of
        when 1 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 2 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 4 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

pure func NormalizeAtomicSigned(value: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    case size_bytes of
        when 1 => return SignExtend{PTO_XLEN}(value[7:0]);
        when 2 => return SignExtend{PTO_XLEN}(value[15:0]);
        when 4 => return SignExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

pure func AtomicValueSized(op: AtomicOperation, old_value: Word, operand: Word,
                           size_bytes: integer {1,2,4,8}) => Word
begin
    let old_unsigned = NormalizeAtomicUnsigned(old_value, size_bytes);
    let operand_unsigned = NormalizeAtomicUnsigned(operand, size_bytes);
    let old_signed = NormalizeAtomicSigned(old_value, size_bytes);
    let operand_signed = NormalizeAtomicSigned(operand, size_bytes);
    case op of
        when Atomic_SMIN =>
            if SInt(old_signed) < SInt(operand_signed) then return old_unsigned;
            else return operand_unsigned; end;
        when Atomic_SMAX =>
            if SInt(old_signed) > SInt(operand_signed) then return old_unsigned;
            else return operand_unsigned; end;
        otherwise => return NormalizeAtomicUnsigned(AtomicValue(op, old_unsigned, operand_unsigned), size_bytes);
    end;
end;

func AtomicReadModifyWrite(address: Word, size_bytes: integer {1,2,4,8},
                           op: AtomicOperation, operand: Word,
                           order: MemoryOrder) => Word
begin
    let read_probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(read_probe, address) then return Zeros{PTO_XLEN}; end;
    let write_probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(write_probe, address) then return Zeros{PTO_XLEN}; end;
    if read_probe.translated_address != write_probe.translated_address then
        SetFault(Fault_DataPage, address);
        return Zeros{PTO_XLEN};
    end;
    let old_value = LoadTranslatedUnsigned(
        read_probe.translated_address, size_bytes);
    let new_value = AtomicValueSized(op, old_value, operand, size_bytes);
    StoreTranslated(address, write_probe.translated_address, size_bytes,
        new_value);
    RecordAtomicEvent(write_probe.translated_address, size_bytes, old_value,
        new_value, order, TRUE);
    return old_value;
end;

func CompareAndSwap(address: Word, size_bytes: integer {1,2,4,8},
                    expected: Word, desired: Word, order: MemoryOrder) => Word
begin
    let read_probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(read_probe, address) then return Zeros{PTO_XLEN}; end;
    let write_probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(write_probe, address) then return Zeros{PTO_XLEN}; end;
    if read_probe.translated_address != write_probe.translated_address then
        SetFault(Fault_DataPage, address);
        return Zeros{PTO_XLEN};
    end;
    let old_value = LoadTranslatedUnsigned(
        read_probe.translated_address, size_bytes);
    let succeeds = old_value == NormalizeAtomicUnsigned(expected, size_bytes);
    if succeeds then
        StoreTranslated(address, write_probe.translated_address,
            size_bytes, desired);
    end;
    RecordAtomicEvent(write_probe.translated_address, size_bytes, old_value,
        NormalizeAtomicUnsigned(desired, size_bytes), order, succeeds);
    return old_value;
end;
```
<!-- GENERATED-ASL-END: unit -->
