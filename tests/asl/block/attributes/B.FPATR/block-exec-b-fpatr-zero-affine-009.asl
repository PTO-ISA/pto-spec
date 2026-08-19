// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-ZERO-AFFINE-009","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR","PTO-MATRIX-POSTPROCESS-BITEXACT-001"],"kind":"execution","summary":"B.FPATR floating signed zero participates in the complete affine pipeline","pass_condition":"positive and negative FP32 zero publish the assigned positive negative or zero S8 offset","related_sources":["asl/arch/profile/matrix-postprocess.asl"]}
func main() => integer
begin
    let scale_one = FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000);
    let control = DefaultNumericExecutionControl();

    let positive_offset = MatrixQuantParameter(
        scale_one, Zeros{PTO_XLEN} + 5, 9);
    let (positive_zero_positive_offset, positive_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN}, '011000', Zeros{3}, Zeros{4},
            TileDataType_S8, positive_offset,
            Zeros{PTO_XLEN}, control);
    assert positive_zero_positive_offset == Zeros{PTO_XLEN} + 5;
    assert positive_flags == Zeros{5};

    let (negative_zero_positive_offset, negative_positive_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0x80000000,
            '011000', Zeros{3}, Zeros{4}, TileDataType_S8,
            positive_offset, Zeros{PTO_XLEN}, control);
    assert negative_zero_positive_offset == Zeros{PTO_XLEN} + 5;
    assert negative_positive_flags == Zeros{5};

    let negative_offset = MatrixQuantParameter(
        scale_one, Zeros{PTO_XLEN} + 0x1fb, 9);
    let (positive_zero_negative_offset, negative_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN}, '011000', Zeros{3}, Zeros{4},
            TileDataType_S8, negative_offset,
            Zeros{PTO_XLEN}, control);
    assert positive_zero_negative_offset ==
        Zeros{PTO_XLEN} + 0xfffffffffffffffb;
    assert negative_flags == Zeros{5};

    let zero_offset = MatrixQuantParameter(
        scale_one, Zeros{PTO_XLEN}, 9);
    let (negative_zero_zero_offset, zero_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0x80000000,
            '011000', Zeros{3}, Zeros{4}, TileDataType_S8,
            zero_offset, Zeros{PTO_XLEN}, control);
    assert negative_zero_zero_offset == Zeros{PTO_XLEN};
    assert zero_flags == Zeros{5};
    return 0;
end;
