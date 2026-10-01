<!-- GENERATED FROM: asl/arch/memory-model/instruction-fetch.asl -->
# Instruction Fetch

**Normative ASL source:** `asl/arch/memory-model/instruction-fetch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-purpose role=purpose-scope -->
## 目的与范围

本单元拥有内存模型的指令侧：把一个 `TPC` 值变成要么是带长度限定的指令字，要么是停止的理由。它定义 `PTOInstructionFetchProbe`、`DeterminePTOInstructionLength`、`TranslateInstructionAddress`、`InstructionAccessPermitted`、`ProbeInstructionAccess` 与 `FetchPTOInstruction`。

契约为 `PTO-REQ-INSTRUCTION-FETCH-001`，第 1 行元数据声明 `PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE` 为提供 `ReadPhysicalMemoryByte` 与 `PTO_MODEL_MEMORY_BYTES` 的依赖。`asl/arch/dispatch/top-level.asl` 中的 `ExecuteNextPTOInstruction` 调用这些助手函数并拥有那些 `SetFault` 调用。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-concepts role=concepts-state -->
## 探测记录、长度编码与字节读取

- `PTOInstructionFetchProbe` 恰好有两个字段：类型为 `boolean` 的 `permitted` 与类型为 `Word` 的 `physical_address`；后续读取用的是存入的地址，而不是第二次转换。
- `DeterminePTOInstructionLength(first_halfword)` 把 `first_halfword[3:1]` 为 `'111'` 且位 `0` 为 `'0'` 的情形映射到 `48`、位 `0` 为 `'1'` 的情形映射到 `64`，其余半字在位 `0` 为 `'0'` 时映射到 `16`，否则映射到 `32`。
- `TranslateInstructionAddress(address)` 原样返回 `address`，因此这里的指令取指是恒等映射。
- `InstructionAccessPermitted(physical_address, size_bytes)` 仅在 `UInt(physical_address) + size_bytes` 超过 `PTO_MODEL_MEMORY_BYTES` 时返回假；`ProbeInstructionAccess(address, size_bytes)` 把该谓词与转换后的地址放进探测记录。
- `FetchPTOInstruction(probe, length_bits)` 断言 `probe.permitted`，把 `size_bytes` 算作 `length_bits DIV 8`，并从 `Zeros{64}` 起在 `byte_index < size_bytes` 期间写入字节。
- `ReadPhysicalMemoryByte` 使用 `UInt(address) < PTO_MODEL_MEMORY_BYTES`，与这里的许可集合是同一边界。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-rules role=rules-interactions -->
## 长度编码选择了什么

被接受的四种长度是 `16`、`32`、`48` 与 `64`：位 `0` 在 `16` 与 `32` 之间做选择，`first_halfword[3:1] == '111'` 在 `48` 与 `64` 之间做选择。

`FetchPTOInstruction` 把字节 `byte_index` 放在位位置 `byte_index * 8`，因此最低地址的字节占据位 `7:0`；位于或高于 `size_bytes` 的字节保持为零，读取次数为 `2`、`4`、`6` 或 `8`。

设计要点：取指循环分配完整的 `bits(64)` 结果，但从 `Zeros{64}` 起只写入前 `size_bytes` 个字节，因此 `16` 位指令返回的字其高 48 位为零，解码者看到的是已定义的值而不是残留；长度必须单独传递，因为该字本身不携带它。

设计要点：`ProbeInstructionAccess` 存入它检查过的地址，`FetchPTOInstruction` 读取存入的地址；由于 `TranslateInstructionAddress` 是恒等函数，此处两者相等，但共用探测会把读取引向别处，因此 `ExecuteNextPTOInstruction` 会先比较 `complete_probe.physical_address` 与 `prefix_probe.physical_address`。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-boundaries role=boundaries -->
## 边界

条款把被拒绝、未映射、溢出与被截断的区间都列为 `Fault_InstructionPage` 的理由；可执行谓词只检查一个条件：`UInt(physical_address) + size_bytes > PTO_MODEL_MEMORY_BYTES`，因此 `permitted` 为假恰好对应于区间的末字节落在模型数组之外，而条款所说的被拒绝区间在这里产生不出来。

条款还说下一指令动作在任何内存访问之前拒绝奇数 `TPC`，并在读取任何剩余字节之前预检所选区间；本文件只实现后一半。奇数 `TPC` 测试是 `ExecuteNextPTOInstruction` 中的 `instruction_pc[0] == '1'`，该函数还在原始 `TPC` 处执行那些 `SetFault(Fault_InstructionPage, instruction_pc)` 调用；除 `asl/arch/dispatch/top-level.asl` 之外，没有 ASL 单元调用这些助手函数。

`TranslateInstructionAddress` 除同文件中的 `ProbeInstructionAccess` 之外没有调用者，而 `PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS` 中 `IOTTBR_ACR1`、`IOTCR_ACR1` 与 `IOMAIR_ACR1` 寄存器的目录条目称它们为 storage-only，因此没有可配置的架构转换；`InstructionAccessPermitted` 同样只被 `ProbeInstructionAccess` 调用。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-example role=example-usage -->
## 非规范性取指示例

在 `PTO_MODEL_MEMORY_BYTES` 取默认值 `4096` 时，`TPC` 为 `0x40` 会探测 `0x40` 与 `0x41` 两个字节，二者都在数组内，因此 `permitted` 为真；若它们解码为 `32` 位指令，则 `size_bytes` 为 `4`，完整探测在 `0x43` 结束。

`TPC` 为 `0xfff` 会探测字节 `0xfff` 与 `0x1000`，其和为 `4097`，因此探测不被许可：调用者在 `0xfff` 处引发 `Fault_InstructionPage`，且不读取任何字节。`TPC` 等于 `0x41` 会更早被拒绝，由分派拥有者中的奇数地址测试完成。

本示例仅作为阅读辅助：先应用上面的规则，再到规范性 ASL 拥有者中确认结果。它不增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-related role=related-owners-navigation -->
## 相关拥有者

- [地址空间](address-space.md) 拥有 `ReadPhysicalMemoryByte` 与 `PTO_MODEL_MEMORY_BYTES`。
- `PTO-ARCH-DISPATCH-TOP-LEVEL` 调用这些助手函数，并拥有故障引发、奇数地址测试与完整区间重探测。
- `PTO-ARCH-STATE-PROGRAM-COUNTER` 拥有 `ReadTPC` 与 `WriteTPC`。
- [故障精确性](fault-precision.md) 把 `Fault_InstructionPC` 与 `Fault_InstructionPage` 映射到陷阱号 `32` 与 `33`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/instruction-fetch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","surface":"arch","classification":["memory-model","instruction-fetch"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE"]}

// NDF-BEGIN: PTO-REQ-INSTRUCTION-FETCH-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A next-instruction action MUST reject an odd TPC with Fault_InstructionPC
// before memory access. It MUST preflight the first two bytes, determine a 16,
// 32, 48, or 64-bit length from the low halfword, then preflight the complete
// selected range before reading any remaining byte. Fetch is little-endian. A
// denied, unmapped, overflowing, or truncated range MUST raise
// Fault_InstructionPage at the original TPC without a decoded attempt or
// partial instruction effect.
// NDF-END: PTO-REQ-INSTRUCTION-FETCH-001

type PTOInstructionFetchProbe of record {
    permitted: boolean,
    physical_address: Word
};

pure func DeterminePTOInstructionLength(
    first_halfword: bits(16)) => integer {16,32,48,64}
begin
    if first_halfword[3:1] == '111' then
        if first_halfword[0] == '0' then return 48;
        else return 64;
        end;
    elsif first_halfword[0] == '0' then
        return 16;
    else
        return 32;
    end;
end;

readonly func TranslateInstructionAddress(
    address: Word) => Word
begin
    return address;
end;

readonly func InstructionAccessPermitted(
    physical_address: Word,
    size_bytes: integer {2,4,6,8}) => boolean
begin
    let end_address = UInt(physical_address) + size_bytes;
    if end_address > PTO_MODEL_MEMORY_BYTES then
        return FALSE;
    end;
    return TRUE;
end;

readonly func ProbeInstructionAccess(
    address: Word,
    size_bytes: integer {2,4,6,8}) => PTOInstructionFetchProbe
begin
    let physical_address = TranslateInstructionAddress(address);
    return PTOInstructionFetchProbe {
        permitted = InstructionAccessPermitted(
            physical_address,
            size_bytes),
        physical_address = physical_address
    };
end;

readonly func FetchPTOInstruction(
    probe: PTOInstructionFetchProbe,
    length_bits: integer {16,32,48,64}) => bits(64)
begin
    assert probe.permitted;
    let size_bytes = (length_bits DIV 8) as integer {2,4,6,8};
    var instruction: bits(64) = Zeros{64};
    for byte_index = 0 to 7 do
        if byte_index < size_bytes then
            let byte_address = probe.physical_address +
                NaturalToWord(byte_index);
            instruction[(byte_index * 8) +: 8] =
                ReadPhysicalMemoryByte(byte_address);
        end;
    end;
    return instruction;
end;
```
<!-- GENERATED-ASL-END: unit -->
