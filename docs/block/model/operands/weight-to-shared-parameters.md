<!-- GENERATED FROM: asl/block/model/operands/weight-to-shared-parameters.asl -->
# Weight To Shared Parameters

**Normative ASL source:** `asl/block/model/operands/weight-to-shared-parameters.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-WEIGHT-PARAMETERS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/weight-to-shared-parameters.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-WEIGHT-PARAMETERS","surface":"block","classification":["model","operands","weight-to-shared-parameters"],"depends_on":["PTO-BLOCK-B-IOR","PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}
// NDF-BEGIN: PTO-BSTART-TLOAD-WEIGHT-SOURCE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Weight-mode TLOAD has exactly one three-source B.IOR record: GMBase,
// ShapeGPR, StartGPR, with a zero destination selector. ShapeGPR packs Cin,
// Cout, KernelH, and KernelW in bits 0..47 and requires bits 48..63 zero;
// StartGPR packs NStart in bits 0..31 and KStart in bits 32..63. Every
// participating PE must resolve equal values for all three sources.
// NDF-END: PTO-BSTART-TLOAD-WEIGHT-SOURCE-001
// PTO-BSTART-TLOAD-WEIGHT-SOURCE-001 owns the one-record B.IOR carrier and
// packed ShapeGPR/StartGPR fields.
type BundleWeightTLOADParameters of record {
    cin: integer {0..65535},
    cout: integer {0..65535},
    kernel_h: integer {0..255},
    kernel_w: integer {0..255},
    n_start: integer {0..4294967295},
    k_start: integer {0..4294967295}
};

pure func BundleWeightTLOADParametersFromWords(
    shape_word: Word, start_word: Word) => BundleWeightTLOADParameters
begin
    return BundleWeightTLOADParameters {
        cin = UInt(shape_word[15:0]),
        cout = UInt(shape_word[31:16]),
        kernel_h = UInt(shape_word[39:32]),
        kernel_w = UInt(shape_word[47:40]),
        n_start = UInt(start_word[31:0]),
        k_start = UInt(start_word[63:32])
    };
end;

pure func BundleWeightTLOADShapeReservedBitsLegal(shape_word: Word) => boolean
begin
    return shape_word[63:48] == Zeros{16};
end;

readonly func BundleWeightTLOADParticipantValuesEqual(mask: bits(4)) => boolean
begin
    var reference_valid = FALSE;
    var reference_gm_base: Word = Zeros{PTO_XLEN};
    var reference_shape: Word = Zeros{PTO_XLEN};
    var reference_start: Word = Zeros{PTO_XLEN};
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        if mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let gm_base = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[0]].source0);
            let shape_word = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[0]].source1);
            let start_word = ReadPEAbsoluteGPROperand(
                agent, _BundleScalarBindings[[0]].source2);
            if !reference_valid then
                reference_valid = TRUE;
                reference_gm_base = gm_base;
                reference_shape = shape_word;
                reference_start = start_word;
            elsif gm_base != reference_gm_base ||
                  shape_word != reference_shape ||
                  start_word != reference_start then
                return FALSE;
            end;
        end;
    end;
    return reference_valid;
end;

pure func BundleWeightTLOADGenerationMetadata(
    source_layout: bits(5), data_type: bits(5), valid_col: bits(16),
    valid_row: bits(16), total_col: bits(16), size_code: bits(4)) => Word
begin
    var metadata = Zeros{PTO_XLEN};
    metadata[4:0] = source_layout;
    metadata[9:5] = data_type;
    metadata[25:10] = valid_col;
    metadata[41:26] = valid_row;
    metadata[57:42] = total_col;
    metadata[61:58] = size_code;
    return metadata;
end;
```
<!-- GENERATED-ASL-END: unit -->
