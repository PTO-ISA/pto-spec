<!-- GENERATED FROM: asl/scalar/model/dispatch/agu.asl -->
# AGU

**Normative ASL source:** `asl/scalar/model/dispatch/agu.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-AGU}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-agu-purpose role=purpose-scope -->
## 用途与范围

本单元执行每个已译码的标量加载、存储、成对访问和预取形式。`ExecuteDecodedAGUForm` 读取该形式的目录属性，由已译码字段构造基址和偏移，并调用一个动作辅助函数。

每个 AGU 形式带有以下目录属性（另有下文说明的 `prefetch_returns_address`），通过生成的函数读取：

- 动作：`ScalarAGU_Load`、`ScalarAGU_LoadPair`、`ScalarAGU_Store`、`ScalarAGU_StorePair` 或 `ScalarAGU_Prefetch`；
- 地址类别：`ScalarAGU_Register`、`ScalarAGU_Immediate`、`ScalarAGU_PCRelative` 或 `ScalarAGU_Compressed`；
- 更新模式：无、前索引或后索引；
- 以字节计的访问大小，以及加载是否有符号；
- 偏移缩放，以左移量表示。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-agu-concepts role=concepts-state -->
## 概念与可见状态

基址来自 `ScalarDecodedAGUBase`：

- PC 相对形式使用清除位 1:0 后的 TPC。
- 压缩形式使用 `SrcL`。
- 立即数偏移的单个存储和成对存储使用 `SrcR`；其数据在 HL 形式中位于 `SrcD`（和 `SrcD1`），在 32 位形式中位于 `SrcL`。
- 其他所有形式使用 `SrcL`。

偏移来自 `ScalarDecodedAGUOffset`。寄存器偏移读取 `SrcR`，应用 `SrcRType` 地址修饰符，若形式有 `shamt` 则左移 `shamt` 位，否则左移目录缩放量。立即数偏移取 `simm5`、`simm12`、`simm17`、`simm22` 或 `simm` 中第一个存在的字段，做符号扩展，并左移目录缩放量。

更新后的基址为 `base + offset`。后索引形式访问原始基址；其他所有形式访问更新后的基址。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-agu-rules role=rules-interactions -->
## 规则与交互

单个加载调用 `LoadUnsigned`，再按形式的宽度和有符号性规范化该值。如果 `_LastFault` 已设置，它不写任何内容。否则：

- 压缩加载把值压入 T；
- 无更新加载写入 `RegDst`；
- 带更新的加载先把值写入 `RegDst0`，再把更新后的基址写入 `RegDst1`。

单个存储的数据在 `SrcD` 存在时取自 `SrcD`，压缩形式取自 T#1，否则取自 `SrcL`。它调用 `Store`，成功时带更新的存储把更新后的基址写入 `RegDst`。

设计要点：每个源（包括基址、偏移寄存器和存储数据）都在内存访问之前读取，每个目标都受 `_LastFault` 保护。发生故障的访问让每个目标和基址保持不变。恢复时重新发出整条指令并重新计算地址。

成对形式从不更新基址。它们先预检第一个地址，再预检第二个地址（第一个地址加大小），然后才读写任一元素。成对加载先写 `RegDst0` 再写 `RegDst1`。成对存储读取 `SrcD` 和 `SrcD1`，然后先存储并记录第一个元素，再存储并记录第二个元素。

设计要点：先预检两个地址意味着成对访问要么完成两个元素，要么不改变任何内存和目标。报告的是第一个失败的地址。

预取形成地址并调用 `ScalarPrefetch`，后者不触及内存。目录中设置了 `prefetch_returns_address` 的形式还会把 `base + offset` 写入 `RegDst`。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-agu-boundaries role=boundaries -->
## 架构边界

保留编码不会到达本单元。目录把寄存器偏移形式的 `SrcRType` 限定为 0、1 或 2，把 `HL.PRF`、`HL.PRF.A`、`HL.PRFI.U` 和 `HL.PRFI.UA` 的 `model` 字段限定为 0、1 或 2。顶层分派在读取任何源之前拒绝其他值。

本单元不推进 TPC。对齐、边界和访问环检查属于[标量内存](../agu/memory.md)。

此处的 `NormalizeScalarLoadResult` 与标量内存中的 `NormalizeLoadedValue` 对来自 `LoadUnsigned` 的值给出相同结果；本单元的副本还会对无符号值做零扩展，而 `NormalizeLoadedValue` 原样返回无符号值。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-agu-example role=example-usage -->
## 非规范阅读示例

取位于 TPC 0x202 的 32 位字 0xFFFF22B9。其低 15 位匹配 `LW.PCR`（掩码 0x707F，匹配值 0x2039）。

| 字段 | 位 | 原始值 | 值 |
| --- | --- | --- | --- |
| `RegDst` | 11:7 | 5 | GPR 5 |
| `simm17` | 31:15 | 0x1FFFE | -2 |

- 基址为清除位 1:0 后的 0x202，即 0x200。
- 目录缩放为 2，因此偏移为 -2 x 4 = -8。
- 地址为 0x1F8，按 4 字节对齐。
- 成功时 GPR 5 接收符号扩展的字，TPC 变为 0x206。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-agu-related role=related-owners-navigation -->
## 相关所有者

- [标量寻址](../agu/addressing.md)包含直接辅助函数和 `ScalarPrefetch`。
- [标量内存](../agu/memory.md)拥有预检、字节访问和故障。
- [标量译码辅助函数](decode.md)拥有字段提取和地址修饰符。
- [标量操作数](../types/operands.md)拥有 Reg5 读取、队列压入和丢弃。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/agu.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-AGU","surface":"scalar","classification":["model","dispatch","agu"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-AGU-ADDRESSING","PTO-SCALAR-C-LDI","PTO-SCALAR-C-LWI","PTO-SCALAR-C-SDI","PTO-SCALAR-C-SWI","PTO-SCALAR-HL-LB-PCR","PTO-SCALAR-HL-LB-PO","PTO-SCALAR-HL-LB-PR","PTO-SCALAR-HL-LBI-PO","PTO-SCALAR-HL-LBI-PR","PTO-SCALAR-HL-LBI","PTO-SCALAR-HL-LBIP","PTO-SCALAR-HL-LBP","PTO-SCALAR-HL-LBU-PCR","PTO-SCALAR-HL-LBU-PO","PTO-SCALAR-HL-LBU-PR","PTO-SCALAR-HL-LBUI-PO","PTO-SCALAR-HL-LBUI-PR","PTO-SCALAR-HL-LBUI","PTO-SCALAR-HL-LBUIP","PTO-SCALAR-HL-LBUP","PTO-SCALAR-HL-LD-PCR","PTO-SCALAR-HL-LD-PO","PTO-SCALAR-HL-LD-PR","PTO-SCALAR-HL-LDI-PO","PTO-SCALAR-HL-LDI-PR","PTO-SCALAR-HL-LDI-U","PTO-SCALAR-HL-LDI-UPO","PTO-SCALAR-HL-LDI-UPR","PTO-SCALAR-HL-LDI","PTO-SCALAR-HL-LDIP-U","PTO-SCALAR-HL-LDIP","PTO-SCALAR-HL-LDP","PTO-SCALAR-HL-LH-PCR","PTO-SCALAR-HL-LH-PO","PTO-SCALAR-HL-LH-PR","PTO-SCALAR-HL-LHI-PO","PTO-SCALAR-HL-LHI-PR","PTO-SCALAR-HL-LHI-U","PTO-SCALAR-HL-LHI-UPO","PTO-SCALAR-HL-LHI-UPR","PTO-SCALAR-HL-LHI","PTO-SCALAR-HL-LHIP-U","PTO-SCALAR-HL-LHIP","PTO-SCALAR-HL-LHP","PTO-SCALAR-HL-LHU-PCR","PTO-SCALAR-HL-LHU-PO","PTO-SCALAR-HL-LHU-PR","PTO-SCALAR-HL-LHUI-PO","PTO-SCALAR-HL-LHUI-PR","PTO-SCALAR-HL-LHUI-U","PTO-SCALAR-HL-LHUI-UPO","PTO-SCALAR-HL-LHUI-UPR","PTO-SCALAR-HL-LHUI","PTO-SCALAR-HL-LHUIP-U","PTO-SCALAR-HL-LHUIP","PTO-SCALAR-HL-LHUP","PTO-SCALAR-HL-LW-PCR","PTO-SCALAR-HL-LW-PO","PTO-SCALAR-HL-LW-PR","PTO-SCALAR-HL-LWI-PO","PTO-SCALAR-HL-LWI-PR","PTO-SCALAR-HL-LWI-U","PTO-SCALAR-HL-LWI-UPO","PTO-SCALAR-HL-LWI-UPR","PTO-SCALAR-HL-LWI","PTO-SCALAR-HL-LWIP-U","PTO-SCALAR-HL-LWIP","PTO-SCALAR-HL-LWP","PTO-SCALAR-HL-LWU-PCR","PTO-SCALAR-HL-LWU-PO","PTO-SCALAR-HL-LWU-PR","PTO-SCALAR-HL-LWUI-PO","PTO-SCALAR-HL-LWUI-PR","PTO-SCALAR-HL-LWUI-U","PTO-SCALAR-HL-LWUI-UPO","PTO-SCALAR-HL-LWUI-UPR","PTO-SCALAR-HL-LWUI","PTO-SCALAR-HL-LWUIP-U","PTO-SCALAR-HL-LWUIP","PTO-SCALAR-HL-LWUP","PTO-SCALAR-HL-PRF-A","PTO-SCALAR-HL-PRF","PTO-SCALAR-HL-PRFI-U","PTO-SCALAR-HL-PRFI-UA","PTO-SCALAR-HL-SB-PCR","PTO-SCALAR-HL-SB-PO","PTO-SCALAR-HL-SB-PR","PTO-SCALAR-HL-SBI-PO","PTO-SCALAR-HL-SBI-PR","PTO-SCALAR-HL-SBI","PTO-SCALAR-HL-SBIP","PTO-SCALAR-HL-SBP","PTO-SCALAR-HL-SD-PCR","PTO-SCALAR-HL-SD-PO","PTO-SCALAR-HL-SD-PR","PTO-SCALAR-HL-SD-UPO","PTO-SCALAR-HL-SD-UPR","PTO-SCALAR-HL-SDI-PO","PTO-SCALAR-HL-SDI-PR","PTO-SCALAR-HL-SDI-U","PTO-SCALAR-HL-SDI-UPO","PTO-SCALAR-HL-SDI-UPR","PTO-SCALAR-HL-SDI","PTO-SCALAR-HL-SDIP-U","PTO-SCALAR-HL-SDIP","PTO-SCALAR-HL-SDP-U","PTO-SCALAR-HL-SDP","PTO-SCALAR-HL-SH-PCR","PTO-SCALAR-HL-SH-PO","PTO-SCALAR-HL-SH-PR","PTO-SCALAR-HL-SH-UPO","PTO-SCALAR-HL-SH-UPR","PTO-SCALAR-HL-SHI-PO","PTO-SCALAR-HL-SHI-PR","PTO-SCALAR-HL-SHI-U","PTO-SCALAR-HL-SHI-UPO","PTO-SCALAR-HL-SHI-UPR","PTO-SCALAR-HL-SHI","PTO-SCALAR-HL-SHIP-U","PTO-SCALAR-HL-SHIP","PTO-SCALAR-HL-SHP-U","PTO-SCALAR-HL-SHP","PTO-SCALAR-HL-SW-PCR","PTO-SCALAR-HL-SW-PO","PTO-SCALAR-HL-SW-PR","PTO-SCALAR-HL-SW-UPO","PTO-SCALAR-HL-SW-UPR","PTO-SCALAR-HL-SWI-PO","PTO-SCALAR-HL-SWI-PR","PTO-SCALAR-HL-SWI-U","PTO-SCALAR-HL-SWI-UPO","PTO-SCALAR-HL-SWI-UPR","PTO-SCALAR-HL-SWI","PTO-SCALAR-HL-SWIP-U","PTO-SCALAR-HL-SWIP","PTO-SCALAR-HL-SWP-U","PTO-SCALAR-HL-SWP","PTO-SCALAR-LB-PCR","PTO-SCALAR-LB","PTO-SCALAR-LBI","PTO-SCALAR-LBU-PCR","PTO-SCALAR-LBU","PTO-SCALAR-LBUI","PTO-SCALAR-LD-PCR","PTO-SCALAR-LD","PTO-SCALAR-LDI-U","PTO-SCALAR-LDI","PTO-SCALAR-LH-PCR","PTO-SCALAR-LH","PTO-SCALAR-LHI-U","PTO-SCALAR-LHI","PTO-SCALAR-LHU-PCR","PTO-SCALAR-LHU","PTO-SCALAR-LHUI-U","PTO-SCALAR-LHUI","PTO-SCALAR-LW-PCR","PTO-SCALAR-LW","PTO-SCALAR-LWI-U","PTO-SCALAR-LWI","PTO-SCALAR-LWU-PCR","PTO-SCALAR-LWU","PTO-SCALAR-LWUI-U","PTO-SCALAR-LWUI","PTO-SCALAR-PRF","PTO-SCALAR-PRFI-U","PTO-SCALAR-SB-PCR","PTO-SCALAR-SB","PTO-SCALAR-SBI","PTO-SCALAR-SD-PCR","PTO-SCALAR-SD-U","PTO-SCALAR-SD","PTO-SCALAR-SDI-U","PTO-SCALAR-SDI","PTO-SCALAR-SH-PCR","PTO-SCALAR-SH-U","PTO-SCALAR-SH","PTO-SCALAR-SHI-U","PTO-SCALAR-SHI","PTO-SCALAR-SW-PCR","PTO-SCALAR-SW-U","PTO-SCALAR-SW","PTO-SCALAR-SWI-U","PTO-SCALAR-SWI"]}
pure func ScalarDecodedAGUImmediate(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1}) => Word
begin
    if ScalarOperandPresent(form, ScalarField_simm5) then
        return ScalarDecodedWord(instruction, form, ScalarField_simm5);
    elsif ScalarOperandPresent(form, ScalarField_simm12) then
        return ScalarDecodedWord(instruction, form, ScalarField_simm12);
    elsif ScalarOperandPresent(form, ScalarField_simm17) then
        return ScalarDecodedWord(instruction, form, ScalarField_simm17);
    elsif ScalarOperandPresent(form, ScalarField_simm22) then
        return ScalarDecodedWord(instruction, form, ScalarField_simm22);
    else
        return ScalarDecodedWord(instruction, form, ScalarField_simm);
    end;
end;

readonly func ScalarDecodedAGUBase(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    action: ScalarAGUAction, address_kind: ScalarAGUAddressKind) => Word
begin
    if address_kind == ScalarAGU_PCRelative then
        var aligned_tpc = ReadTPC();
        aligned_tpc[1:0] = Zeros{2};
        return aligned_tpc;
    elsif address_kind == ScalarAGU_Compressed then
        return ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL);
    elsif (action == ScalarAGU_Store || action == ScalarAGU_StorePair) &&
          address_kind == ScalarAGU_Immediate then
        return ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR);
    else
        return ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL);
    end;
end;

readonly func ScalarDecodedAGUOffset(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    address_kind: ScalarAGUAddressKind) => Word
begin
    let scale = ScalarAGUOffsetScaleOfForm(form);
    if address_kind == ScalarAGU_Register then
        let unshifted = ApplyScalarRightModifier(
            ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
            ScalarDecodedAddressRightModifier(instruction, form), FALSE);
        let shift_amount = if ScalarOperandPresent(form, ScalarField_shamt) then
            ScalarDecodedUInt6(instruction, form, ScalarField_shamt)
            else scale;
        return LSL(unshifted, shift_amount);
    else
        return LSL(ScalarDecodedAGUImmediate(instruction, form), scale);
    end;
end;

pure func NormalizeScalarLoadResult(value: Word,
                                    size_bytes: integer {1,2,4,8},
                                    signed_load: boolean) => Word
begin
    if signed_load then
        case size_bytes of
            when 1 => return SignExtend{PTO_XLEN}(value[7:0]);
            when 2 => return SignExtend{PTO_XLEN}(value[15:0]);
            when 4 => return SignExtend{PTO_XLEN}(value[31:0]);
            when 8 => return value;
        end;
    end;
    case size_bytes of
        when 1 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 2 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 4 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when 8 => return value;
    end;
end;

func ExecuteDecodedAGULoad(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    address: Word, updated_base: Word, update_mode: AddressUpdateMode,
    size_bytes: integer {1,2,4,8})
begin
    let value = LoadUnsigned(address, size_bytes);
    if _LastFault == Fault_None then
        let normalized = NormalizeScalarLoadResult(
            value, size_bytes, ScalarAGUSignedLoadOfForm(form));
        if ScalarAGUAddressKindOfForm(form) == ScalarAGU_Compressed then
            WriteCompressedTResult(normalized);
        elsif update_mode == AddressUpdate_None then
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                normalized);
        else
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst0),
                normalized);
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst1),
                updated_base);
        end;
    end;
end;

func ExecuteDecodedAGULoadPair(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    address: Word, size_bytes: integer {1,2,4,8})
begin
    let second_address =
        address + NaturalToWord(size_bytes as integer {0..262144});
    let first_probe = ProbeDataAccess(address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(first_probe, address) then return; end;
    let second_probe = ProbeDataAccess(
        second_address, size_bytes, size_bytes, FALSE);
    if RaiseDataAccessFault(second_probe, second_address) then return; end;
    let first = LoadTranslatedUnsigned(first_probe.translated_address, size_bytes);
    let second = LoadTranslatedUnsigned(second_probe.translated_address, size_bytes);
    RecordLoadEvent(first_probe.translated_address, size_bytes, first,
        MemoryOrder_Relaxed);
    RecordLoadEvent(second_probe.translated_address, size_bytes, second,
        MemoryOrder_Relaxed);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst0),
        NormalizeScalarLoadResult(first, size_bytes,
            ScalarAGUSignedLoadOfForm(form)));
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst1),
        NormalizeScalarLoadResult(second, size_bytes,
            ScalarAGUSignedLoadOfForm(form)));
end;

readonly func ReadDecodedAGUStoreSource(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1}) => Word
begin
    if ScalarOperandPresent(form, ScalarField_SrcD) then
        return ReadDecodedScalarRegister(instruction, form, ScalarField_SrcD);
    elsif ScalarAGUAddressKindOfForm(form) == ScalarAGU_Compressed then
        return ReadScalarRegisterOperand(24);
    else
        return ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL);
    end;
end;

func ExecuteDecodedAGUStore(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    address: Word, updated_base: Word, update_mode: AddressUpdateMode,
    size_bytes: integer {1,2,4,8})
begin
    let source = ReadDecodedAGUStoreSource(instruction, form);
    Store(address, size_bytes, source);
    if _LastFault == Fault_None && update_mode != AddressUpdate_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            updated_base);
    end;
end;

func ExecuteDecodedAGUStorePair(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    address: Word, size_bytes: integer {1,2,4,8})
begin
    let second_address =
        address + NaturalToWord(size_bytes as integer {0..262144});
    let first_probe = ProbeDataAccess(address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(first_probe, address) then return; end;
    let second_probe = ProbeDataAccess(
        second_address, size_bytes, size_bytes, TRUE);
    if RaiseDataAccessFault(second_probe, second_address) then return; end;
    let first = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcD);
    let second = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcD1);
    StoreTranslated(address, first_probe.translated_address, size_bytes, first);
    RecordStoreEvent(first_probe.translated_address, size_bytes, first,
        MemoryOrder_Relaxed);
    StoreTranslated(second_address, second_probe.translated_address,
        size_bytes, second);
    RecordStoreEvent(second_probe.translated_address, size_bytes, second,
        MemoryOrder_Relaxed);
end;

func ExecuteDecodedAGUForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let action = ScalarAGUActionOfForm(form);
    let address_kind = ScalarAGUAddressKindOfForm(form);
    let update_mode = ScalarAGUUpdateModeOfForm(form);
    let size_bytes = ScalarAGUSizeOfForm(form);
    let base = ScalarDecodedAGUBase(instruction, form, action, address_kind);
    let offset = ScalarDecodedAGUOffset(instruction, form, address_kind);
    let updated_base = base + offset;
    let address = if update_mode == AddressUpdate_PostIndex then base
                  else updated_base;
    case action of
        when ScalarAGU_Load =>
            ExecuteDecodedAGULoad(instruction, form, address, updated_base,
                update_mode, size_bytes);
        when ScalarAGU_LoadPair =>
            ExecuteDecodedAGULoadPair(
                instruction, form, address, size_bytes);
        when ScalarAGU_Store =>
            ExecuteDecodedAGUStore(instruction, form, address, updated_base,
                update_mode, size_bytes);
        when ScalarAGU_StorePair =>
            ExecuteDecodedAGUStorePair(
                instruction, form, address, size_bytes);
        when ScalarAGU_Prefetch =>
            let model = DecodeScalarOperandRaw(
                instruction, form, ScalarField_model)[4:0];
            ScalarPrefetch(base, offset, size_bytes, model);
            if ScalarAGUPrefetchReturnsAddress(form) then
                WriteScalarDestination(
                    ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                    ScalarPrefetchAddress(base, offset));
            end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
