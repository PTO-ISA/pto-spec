<!-- GENERATED FROM: asl/scalar/model/agu/memory.asl -->
# Memory

**Normative ASL source:** `asl/scalar/model/agu/memory.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-AGU-MEMORY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-agu-memory-purpose role=purpose-scope -->
## 用途与范围

本单元是标量加载、存储和原子操作所使用的字节级内存层，部分 Tile 和 Block 内存辅助函数也使用它。它决定一次访问能否发生，把字节组合为小端值，并在存储与加载保留状态重叠时使保留失效。

它定义四组主要辅助函数，另有用于保留检查的 `RangesOverlap` 和 `ReservationGranuleAddress`：

- 预检：`TranslateDataAddress`、`DataAccessPermitted`、`ProbeDataAccess` 和 `RaiseDataAccessFault`。
- 原始字节访问：`LoadTranslatedUnsigned`、`StoreTranslated`，以及 64 字节变体和有界变体。
- 值规范化：`NormalizeLoadedValue` 和 `NormalizeMemoryAccessValue`。
- 完整访问：`LoadWithOrder`、`LoadUnsigned`、`LoadSigned`、`StoreWithOrder` 和 `Store`。

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-concepts role=concepts-state -->
## 概念与可见状态

预检是在任何字节移动之前运行的检查。`ProbeDataAccess` 返回一个 `DataAccessProbe`，其中包含故障码和转换后的地址。

在本模型中地址转换是恒等映射：`TranslateDataAddress` 返回其输入。

值为小端序。值的第 `i` 个字节位于转换后地址加 `i` 处。

保留状态是加载保留指令留下的状态：`_ReservationValid`、`_ReservationAddress` 和 `_ReservationSize`。其粒度是包含被保留地址、按 `PTO_RESERVATION_GRANULE_BYTES`（64）字节对齐的块。

内存事件是为内存排序模型记录的一次已完成访问。加载和存储只在其字节移动之后才记录事件。

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-rules role=rules-interactions -->
## 规则与交互

`ProbeDataAccess` 按固定顺序检查：

1. 对齐。如果地址不是 `alignment_bytes` 的倍数，结果为 `Fault_DataAlignment`。
2. 地址转换，在此不会失败。
3. 权限。`DataAccessPermitted` 拒绝结束位置超过 `PTO_MODEL_MEMORY_BYTES` 的访问。当当前访问环为 2 或更高时，它还拒绝结束位置超过字节 3072 的访问。两种拒绝都是 `Fault_DataPage`。

设计要点：对齐最先检查，因此未对齐的访问即使同样会因权限失败，也报告 `Fault_DataAlignment`。权限与边界共用一个可见原因 `Fault_DataPage`。

`RaiseDataAccessFault` 用调用者传入的原始地址（而不是转换后的地址）调用 `SetFault`，并在预检失败时返回 TRUE。

`LoadWithOrder` 以等于访问大小的对齐进行预检，预检故障时返回零，否则读取字节并记录一个加载事件。`StoreWithOrder` 进行预检，故障时返回，否则写入字节并记录一个存储事件。`LoadSigned` 对 `LoadUnsigned` 的结果做符号扩展。

设计要点：每个完整访问都先预检再读写，并且只在字节移动之后记录事件。因此发生故障的访问不改变内存，也不记录事件。这与故障精确性所拥有的精确故障契约相一致。

本单元中的每个存储辅助函数，在其原始地址范围与保留粒度重叠时都会清除 `_ReservationValid`。因此对被保留的 64 字节行做普通存储也会破坏保留。

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-boundaries role=boundaries -->
## 架构边界

`PTO_MODEL_MEMORY_BYTES` 是模型配置值（默认 4096，允许 256 到 65536）。`ProbeDataAccess` 中的注释说明，物理地址上限由活动配置档拥有，托管配置档可以授权参考数组之外的地址。

访问环 2 到 15 的 3072 字节限制是 `DataAccessPermitted` 中陈述的 PTO v0 规则。

`StoreTranslated` 等原始字节辅助函数不做预检。其调用者必须先预检。例如，成对和原子辅助函数先预检每个地址，再调用原始辅助函数。

本单元不决定排序语义。它把 `MemoryOrder` 传给 `RecordLoadEvent` 和 `RecordStoreEvent`，这两者属于原子性和内存事件的所有者。

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-example role=example-usage -->
## 非规范阅读示例

假设使用默认的 4096 字节内存。

| 访问 | 访问环 | 预检结果 |
| --- | --- | --- |
| 在 0xFFE 访问 4 字节 | 0 | `Fault_DataAlignment`，因为 0xFFE 不是 4 的倍数 |
| 在 0xFFC 访问 4 字节 | 0 | 允许，因为访问结束于 4096 |
| 在 0xFFC 访问 4 字节 | 2 | `Fault_DataPage`，因为 4096 超过 3072 |
| 在 0x1000 访问 1 字节 | 0 | `Fault_DataPage`，因为访问结束于 4097 |

对于成功的 2 字节 `LoadSigned`，若依次读到字节 0x34 和 0x92，原始值为 0x9234，结果为 0xFFFFFFFFFFFF9234。

<!-- PTO-READER-BLOCK: scalar-model-agu-memory-related role=related-owners-navigation -->
## 相关所有者

- [标量寻址](addressing.md)在这些辅助函数之上构建加载、存储和成对访问。
- [AMO 语义](../amo/semantics.md)使用预检、原始访问和保留状态。
- [地址空间](../../../arch/memory-model/address-space.md)拥有 `ReadMemoryByte` 和 `WriteMemoryByte`。
- [原子性](../../../arch/memory-model/atomicity.md)拥有 `RecordLoadEvent` 和 `RecordStoreEvent`。
- [故障精确性](../../../arch/memory-model/fault-precision.md)拥有 `SetFault`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/agu/memory.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-AGU-MEMORY","surface":"scalar","classification":["model","agu","memory"],"depends_on":["PTO-SCALAR-MODEL-BRU-SEMANTICS","PTO-ARCH-MEMORY-MODEL-ORDERING"]}
// PTO-REQ-MEMORY-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-RC-001: profile-backed, little-endian memory with precise
// instruction-wide completion and PTO-RC event extraction.

pure func RangesOverlap(left_address: Word, left_size: integer,
                        right_address: Word, right_size: integer) => boolean
begin
    let left_start = UInt(left_address);
    let right_start = UInt(right_address);
    return left_start < right_start + right_size &&
           right_start < left_start + left_size;
end;

readonly func ReservationGranuleAddress() => Word
begin
    return _ReservationAddress - NaturalToWord(
        (UInt(_ReservationAddress) MOD PTO_RESERVATION_GRANULE_BYTES) as
            integer {0..262144});
end;

readonly func TranslateDataAddress(address: Word,
                                                  size_bytes: integer {1..262144},
                                                  write: boolean) => Word
begin
    return address;
end;

readonly func DataAccessPermitted(address: Word,
                                                 size_bytes: integer {1..262144},
                                                 write: boolean) => boolean
begin
    let end_address = UInt(address) + size_bytes;
    if end_address > PTO_MODEL_MEMORY_BYTES then
        return FALSE;
    end;
    // PTO v0 assigns ACR0 and ACR1 full bounded-memory access. ACR2 through
    // ACR15 use the bounded 3072-byte application region.
    if CurrentACR() >= 2 then return end_address <= 3072;
    else return TRUE;
    end;
end;

func ProbeDataAccess(address: Word,
                     size_bytes: integer {1..262144},
                     alignment_bytes: integer {1,2,4,8},
                     write: boolean) => DataAccessProbe
begin
    if UInt(address) MOD alignment_bytes != 0 then
        return DataAccessProbe {
            fault = Fault_DataAlignment,
            translated_address = address
        };
    end;
    let translated_address = TranslateDataAddress(address, size_bytes, write);
    // The active profile owns the physical address-space limit.  The
    // reference profile still applies PTO_MODEL_MEMORY_BYTES in its
    // DataAccessPermitted implementation, while a hosted profile may
    // authorize addresses outside the reference array.
    if !DataAccessPermitted(translated_address, size_bytes, write) then
        return DataAccessProbe {
            fault = Fault_DataPage,
            translated_address = translated_address
        };
    end;
    return DataAccessProbe {
        fault = Fault_None,
        translated_address = translated_address
    };
end;

func RaiseDataAccessFault(probe: DataAccessProbe, address: Word) => boolean
begin
    if probe.fault == Fault_None then return FALSE; end;
    SetFault(probe.fault, address);
    return TRUE;
end;

readonly func LoadTranslatedUnsigned(translated_address: Word,
                                     size_bytes: integer {1,2,4,8}) => Word
begin
    var result: Word = Zeros{PTO_XLEN};
    for byte_index = 0 to size_bytes - 1 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        result[(byte_index * 8) +: 8] = ReadMemoryByte(byte_address);
    end;
    return result;
end;

readonly func LoadTranslatedBytes64(translated_address: Word) => array [[64]] of Byte
begin
    var result: array [[64]] of Byte;
    for byte_index = 0 to 63 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        result[[byte_index]] = ReadMemoryByte(byte_address);
    end;
    return result;
end;

pure func Bytes64ChunkValue(value: array [[64]] of Byte,
                            chunk: integer {0..7}) => Word
begin
    var result: Word = Zeros{PTO_XLEN};
    for byte_index = 0 to 7 do
        let snapshot_index = (chunk * 8 + byte_index) as integer {0..63};
        result[(byte_index * 8) +: 8] = value[[snapshot_index]];
    end;
    return result;
end;

readonly func LoadTranslatedBytesBounded(translated_address: Word,
                                         byte_count: integer {0..63})
                                         => array [[64]] of Byte
begin
    var result: array [[64]] of Byte;
    for byte_index = 0 to 63 do
        if byte_index < byte_count then
            let byte_address = translated_address +
                NaturalToWord(byte_index as integer {0..262144});
            result[[byte_index]] = ReadMemoryByte(byte_address);
        else
            result[[byte_index]] = Zeros{8};
        end;
    end;
    return result;
end;

pure func NormalizeLoadedValue(value: Word,
                               size_bytes: integer {1,2,4,8},
                               signed_load: boolean) => Word
begin
    if !signed_load then return value; end;
    case size_bytes of
        when 1 => return SignExtend{PTO_XLEN}(value[7:0]);
        when 2 => return SignExtend{PTO_XLEN}(value[15:0]);
        when 4 => return SignExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

pure func NormalizeMemoryAccessValue(value: Word,
                                     size_bytes: integer {1,2,4,8}) => Word
begin
    case size_bytes of
        when 1 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 2 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 4 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

func StoreTranslatedBytes64(original_address: Word, translated_address: Word,
                            value: array [[64]] of Byte)
begin
    for byte_index = 0 to 63 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(byte_address, value[[byte_index]]);
    end;
    if _ReservationValid &&
       RangesOverlap(original_address, 64,
                     ReservationGranuleAddress(),
                     PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func StoreTranslatedBytesBounded(original_address: Word,
                                 translated_address: Word,
                                 byte_count: integer {0..63},
                                 value: array [[64]] of Byte)
begin
    for byte_index = 0 to 63 do
        if byte_index < byte_count then
            let byte_address = translated_address +
                NaturalToWord(byte_index as integer {0..262144});
            WriteMemoryByte(byte_address, value[[byte_index]]);
        end;
    end;
    if _ReservationValid &&
       RangesOverlap(original_address, byte_count,
                     ReservationGranuleAddress(),
                     PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func StoreTranslatedFillModelBounded(
    original_address: Word,
    translated_address: Word,
    byte_count: integer {1..262144},
    value: Byte)
begin
    for byte_index = 0 to byte_count - 1
        looplimit 262144 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(byte_address, value);
    end;
    if _ReservationValid &&
       RangesOverlap(original_address, byte_count,
                     ReservationGranuleAddress(),
                     PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func StoreTranslated(original_address: Word, translated_address: Word,
                     size_bytes: integer {1,2,4,8}, value: Word)
begin
    for byte_index = 0 to size_bytes - 1 do
        let byte_address = translated_address +
            NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(byte_address, value[(byte_index * 8) +: 8]);
    end;
    if _ReservationValid &&
       RangesOverlap(original_address, size_bytes,
                     ReservationGranuleAddress(),
                     PTO_RESERVATION_GRANULE_BYTES) then
        _ReservationValid = FALSE;
    end;
end;

func LoadWithOrder(address: Word, size_bytes: integer {1,2,4,8},
                   order: MemoryOrder) => Word
begin
    let probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(probe, address) then return Zeros{PTO_XLEN}; end;
    let value = LoadTranslatedUnsigned(probe.translated_address, size_bytes);
    RecordLoadEvent(probe.translated_address, size_bytes, value, order);
    return value;
end;

func LoadUnsigned(address: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    return LoadWithOrder(address, size_bytes, MemoryOrder_Relaxed);
end;

func LoadSigned(address: Word, size_bytes: integer {1,2,4,8}) => Word
begin
    let value = LoadUnsigned(address, size_bytes);
    return NormalizeLoadedValue(value, size_bytes, TRUE);
end;

func StoreWithOrder(address: Word, size_bytes: integer {1,2,4,8}, value: Word,
                    order: MemoryOrder)
begin
    let probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(probe, address) then return; end;
    StoreTranslated(address, probe.translated_address, size_bytes, value);
    RecordStoreEvent(probe.translated_address, size_bytes, value, order);
end;

func Store(address: Word, size_bytes: integer {1,2,4,8}, value: Word)
begin
    StoreWithOrder(address, size_bytes, value, MemoryOrder_Relaxed);
end;
```
<!-- GENERATED-ASL-END: unit -->
