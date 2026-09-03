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

本页是一个架构 `ASL` owner 的稳定阅读入口。下方生成的单元仍是架构含义的完整来源。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-concepts role=concepts-state -->
## 概念与可见状态

通过生成的声明和嵌入式 requirement 区域识别该 owner 引用的概念与状态。本指南不增加状态，也不重命名现有概念。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-rules role=rules-interactions -->
## 规则与交互

沿生成单元中的依赖元数据和调用关系找到交互 owner。生成文档与证据始终只是这些源文件的投影。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-boundaries role=boundaries -->
## 架构边界

固定边界、profile hook、故障及未规定情况均以生成 owner 的原文为准。本阅读指南不会提升任何实现行为。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-example role=example-usage -->
## 非规范阅读示例

先从生成的单元标识开始，定位相关 requirement 区域，再沿引用的 owner 导航，最后查阅可执行证据。

<!-- PTO-READER-BLOCK: arch-memory-model-instruction-fetch-related role=related-owners-navigation -->
## 相关 owner

下方依赖列表和源文件链接构成相关架构 owner 的导航索引；当前含义最终都应回到命名的 `ASL` 源文件。
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

readonly impdef func TranslateInstructionAddress(address: Word) => Word
begin
    return address;
end;

readonly impdef func InstructionAccessPermitted(
    physical_address: Word,
    size_bytes: integer {2,4,6,8}) => boolean
begin
    return FALSE;
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
