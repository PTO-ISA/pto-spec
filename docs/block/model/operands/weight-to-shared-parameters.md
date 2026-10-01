<!-- GENERATED FROM: asl/block/model/operands/weight-to-shared-parameters.asl -->
# Weight To Shared Parameters

**Normative ASL source:** `asl/block/model/operands/weight-to-shared-parameters.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-WEIGHT-PARAMETERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the parameter carrier of weight-mode `TLOAD`. Weight mode loads a convolution weight tensor from Global Memory (GM) into a Shared Tile. Its geometry travels in three general-purpose registers (GPRs) named by one `B.IOR` record. This unit defines how those GPR values are unpacked, which bits must be zero, how values are compared across PEs, and the metadata word used by a cooperative build.

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-concepts role=concepts-state -->
## Concepts and visible state

The unit declares one record and no state variables. `BundleWeightTLOADParameters` holds `cin`, `cout`, `kernel_h`, `kernel_w`, `n_start`, and `k_start`.

The single `B.IOR` record names three sources and a zero destination:

| Source | Content |
| --- | --- |
| `GMBase` | the GM byte address of the weight tensor |
| `ShapeGPR` | `cin` 15:0, `cout` 31:16, `kernel_h` 39:32, `kernel_w` 47:40; bits 48..63 must be zero |
| `StartGPR` | `n_start` 31:0, `k_start` 63:32 |

`BundleWeightTLOADParametersFromWords` performs this unpacking. `n_start` selects the first output-channel row and `k_start` the first K column of the requested window.

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-rules role=rules-interactions -->
## Rules and interactions

`BundleWeightTLOADShapeReservedBitsLegal` is TRUE only when `ShapeGPR` bits 48..63 are zero.

`BundleWeightTLOADParticipantValuesEqual(mask)` reads `GMBase`, `ShapeGPR`, and `StartGPR` from every PE selected by the Shared destination mask. It is TRUE only when at least one PE is selected and all selected PEs hold identical values.

The weight execution unit applies these checks in `BundleWeightTLOADStateLegal`, in this order: the data type and `B.DATR` field checks, exactly one physical Shared binding and no Tile bindings, a valid first scalar binding with three sources and a zero destination and no second binding, then the check that the mask includes the current PE together with the participant-equality check, then the dimensions, then the reserved-bit check, then nonzero `cin`, `cout`, `kernel_h`, and `kernel_w`, and then shape legality, all before the GM preflight.

Design point: participant values must be equal. A cooperative load splits N rows across PEs, and each PE computes its slice from its own GPR copy. Equal values guarantee that the slices come from one tensor and one window. A mismatch rejects before GM access.

Design point: reserved `ShapeGPR` bits must be zero instead of being ignored. `BundleWeightTLOADStateLegal` checks them before it unpacks the fields, so a nonzero value rejects the operation before GM preflight and no field is ever read from bits 48..63.

`BundleWeightTLOADGenerationMetadata` packs source layout, data type, `valid_col`, a 16-bit `valid_row`, `total_col`, and the parent size code into one word. The execution unit passes it with the three source words to the Shared-generation checks, so all cooperative writers must agree on it.

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-boundaries role=boundaries -->
## Architectural boundaries

`BundleWeightTLOADStateLegal` returns TRUE early for a zero mask, and the build then returns without effects. In practice a recorded Shared binding never has a zero mask: the command handler treats a zero-mask `B.IOS` as a strict no-op that records no binding, and `BundleSharedMaskCanAppend` also rejects a zero mask, so the equality check runs with a nonzero mask. The state check also rejects a mask that does not include the current PE.

This unit does not define the K order, the index formulas, or row splitting. The GM and execution units own those.

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

For `cin` 64, `cout` 128, and a 3 by 3 kernel, `ShapeGPR` is `0x0000_0303_0080_0040`. Bits 48..63 are zero, so the reserved check passes. To start at output channel 32 and K column 0, `StartGPR` is `0x0000_0000_0000_0020`. With mask `1111`, all four PEs must hold these same two words and the same `GMBase`.

<!-- PTO-READER-BLOCK: block-model-operands-weight-to-shared-parameters-related role=related-owners-navigation -->
## Related owners

- [Weight schema](../dispatch/weight-to-shared-schema.md) selects weight mode and checks the shape.
- [Weight execution](../dispatch/weight-to-shared-execution.md) applies these checks and builds the Tile.
- [Weight GM access](../memory/weight-to-shared-gm.md) maps cells to GM indices.
- [B.IOR](../../operands/B.IOR.md) is the command page.
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
