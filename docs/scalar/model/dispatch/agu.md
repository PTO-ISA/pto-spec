<!-- GENERATED FROM: asl/scalar/model/dispatch/agu.asl -->
# AGU

**Normative ASL source:** `asl/scalar/model/dispatch/agu.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-AGU}

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
            ScalarDecodedRightModifier(instruction, form), FALSE);
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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
