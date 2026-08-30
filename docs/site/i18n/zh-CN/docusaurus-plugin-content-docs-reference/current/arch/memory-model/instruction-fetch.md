<!-- GENERATED FROM: asl/arch/memory-model/instruction-fetch.asl -->
# Instruction Fetch

**Normative ASL source:** `asl/arch/memory-model/instruction-fetch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-instruction-fetch-purpose role=purpose-scope -->
## 用途与范围

本单元将功能取指与指令执行分离。它定义地址翻译与权限钩子、探测快照，以及对一条已获准的 16/32/48/64 位指令进行小端组装的行为。

<!-- PTO-READER-BLOCK: arch-instruction-fetch-concepts role=concepts-state -->
## 探测模型

`TranslateInstructionAddress` 将架构字节地址映射到配置档物理地址。`InstructionAccessPermitted` 判断完整请求大小是否可读。`ProbeInstructionAccess` 同时快照两者，使后续取指使用已批准的翻译基址。

<!-- PTO-READER-BLOCK: arch-instruction-fetch-rules role=rules-interactions -->
## 取指顺序

功能步骤所有者先探测两个字节以取得低半字和长度，再在读取剩余字节前探测完整所选范围。`FetchPTOInstruction` 将字节零放入位 `[7:0]`，并把所选指令长度以上的位清零。

<!-- PTO-READER-BLOCK: arch-instruction-fetch-boundaries role=boundaries -->
## 访问边界

被拒绝、未映射、溢出或截断的范围在解码前于原始 TPC 产生 `Fault_InstructionPage`。取指辅助函数要求已许可的探测结果，本身不定义缓存、MMU 结构、设备或可执行文件权限。

<!-- PTO-READER-BLOCK: arch-instruction-fetch-example role=example-usage -->
## 非规范字节示例

若翻译地址处获准的字节为 `95 04 e0 05`，32 位取指得到原始值 `0x05e00495`。这只说明字节放置；标量解码器拥有该值的含义。

<!-- PTO-READER-BLOCK: arch-instruction-fetch-related role=related-owners-navigation -->
## 相关所有者

- [功能步骤](../dispatch/functional-step.md)安排前缀与完整范围探测。
- [地址空间](address-space.md)拥有参考配置档的物理字节存储。
- [精确故障](fault-precision.md)拥有精确故障发布。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/instruction-fetch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","surface":"arch","classification":["memory-model","instruction-fetch"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE"]}

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-FETCH-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A functional step MUST reject an odd TPC with Fault_InstructionPC before
// memory access. It MUST preflight the first two bytes, determine a 16, 32, 48,
// or 64-bit length from the low halfword, then preflight the complete selected
// range before reading any remaining byte. Fetch is little-endian. A denied,
// unmapped, overflowing, or truncated range MUST raise Fault_InstructionPage
// at the original TPC without a decoded attempt or partial instruction effect.
// NDF-END: PTO-REQ-FUNCTIONAL-FETCH-001

readonly impdef func TranslateInstructionAddress(
    address: Word) => Word
begin
    return address;
end;

readonly impdef func InstructionAccessPermitted(
    address: Word,
    size_bytes: integer {2,4,6,8}) => boolean
begin
    return FALSE;
end;

readonly func ProbeInstructionAccess(
    address: Word,
    size_bytes: integer {2,4,6,8}) => PTOInstructionAccessProbe
begin
    let translated_address = TranslateInstructionAddress(address);
    return PTOInstructionAccessProbe {
        permitted = InstructionAccessPermitted(
            translated_address, size_bytes),
        translated_address = translated_address
    };
end;

readonly func FetchPTOInstruction(
    probe: PTOInstructionAccessProbe,
    length_bits: integer {16,32,48,64}) => bits(64)
begin
    assert probe.permitted;
    let size_bytes = (length_bits DIV 8) as integer {2,4,6,8};
    var instruction: bits(64) = Zeros{64};
    for byte_index = 0 to 7 do
        if byte_index < size_bytes then
            let byte_address = probe.translated_address +
                NaturalToWord(byte_index);
            instruction[(byte_index * 8) +: 8] =
                ReadPhysicalMemoryByte(byte_address);
        end;
    end;
    return instruction;
end;
```
<!-- GENERATED-ASL-END: unit -->
