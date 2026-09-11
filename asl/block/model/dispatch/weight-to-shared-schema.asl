// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","surface":"block","classification":["model","dispatch","weight-to-shared-schema"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-WEIGHT-PARAMETERS","PTO-BLOCK-B-DATR","PTO-BLOCK-B-DIM","PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
// PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001 owns the specialized carrier
// selection and the NK physical descriptor shape.  The generic TLOAD carrier
// remains the fallback whenever this explicit B.DATR layout is absent.
type BundleWeightTLOADShape of record {
    valid_col: integer {1..65535},
    valid_row: integer {1..65535},
    total_col: integer {1..65535},
    data_type: TileDataType,
    cin: integer {1..65535},
    cout: integer {1..65535},
    kernel_h: integer {1..255},
    kernel_w: integer {1..255},
    n_start: integer {0..4294967295},
    k_start: integer {0..4294967295}
};

readonly func BundleWeightTLOADSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           BundleOperationDecodeCode(_BundleOperation) == Zeros{12} &&
           _BundleDataAttributesPresent &&
           TileDataLayoutIsWeightTLOAD(TileDataLayoutOfCode(
               _BundleDataAttributes.data_layout));
end;

pure func BundleWeightTLOADDataTypeSupported(data_type: TileDataType)
    => boolean
begin
    case data_type of
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32,
             TileDataType_FP16, TileDataType_BF16, TileDataType_HiF8,
             TileDataType_E4M3, TileDataType_E5M2, TileDataType_E8M0,
             TileDataType_S32, TileDataType_S16, TileDataType_S8,
             TileDataType_U32, TileDataType_U16, TileDataType_U8 =>
            return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func BundleWeightTLOADC0Elements(data_type: TileDataType) => integer
begin
    return (32 DIVRM TileElementBytes(data_type)) as integer {4,8,16,32};
end;

pure func BundleWeightTLOADC1(cin: integer {1..65535},
                              data_type: TileDataType) => integer
begin
    let c0 = BundleWeightTLOADC0Elements(data_type);
    return ((cin + (c0 - 1)) DIVRM c0) as integer {1..16384};
end;

pure func BundleWeightTLOADKFull(cin: integer {1..65535},
                                 kernel_h: integer {1..255},
                                 kernel_w: integer {1..255},
                                 data_type: TileDataType) => integer
begin
    let c0 = BundleWeightTLOADC0Elements(data_type);
    let c1 = BundleWeightTLOADC1(cin, data_type);
    return (kernel_h * kernel_w * c1 * c0) as integer {1..18446744073709551615};
end;

pure func BundleWeightTLOADShapeLegal(shape: BundleWeightTLOADShape) => boolean
begin
    let c0 = BundleWeightTLOADC0Elements(shape.data_type);
    let k_full = BundleWeightTLOADKFull(shape.cin, shape.kernel_h,
        shape.kernel_w, shape.data_type);
    return BundleWeightTLOADDataTypeSupported(shape.data_type) &&
           shape.valid_col <= shape.total_col &&
           shape.n_start + shape.valid_row <= shape.cout &&
           shape.k_start + shape.valid_col <= k_full &&
           (shape.k_start MOD c0) == 0 &&
           (shape.valid_col MOD c0) == 0 &&
           IsNonzeroPowerOfTwo(shape.total_col);
end;

readonly func BundleWeightTLOADPEBit() => bits(4)
begin
    var result = Zeros{4};
    result[PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent)] = '1';
    return result;
end;

pure func BundleWeightTLOADSelectedPECount(mask: bits(4)) => integer {1..4}
begin
    return PEMaskPopulation(mask) as integer {1..4};
end;

readonly func BundleWeightTLOADCurrentPERank(mask: bits(4)) => integer {0..3}
begin
    var rank: integer {0..3} = 0;
    let current = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    for pe = 0 to 3 looplimit 4 do
        if pe < (_CurrentMemoryAgent as integer {0..3}) &&
           mask[PTOPEMaskBitOfPEIdentity(pe as MemoryAgentId)] == '1' then
            rank = (rank + 1) as integer {0..3};
        end;
    end;
    assert mask[current] == '1';
    return rank;
end;

pure func BundleWeightTLOADRowsForRank(valid_row: integer {1..65535},
                                       mask: bits(4), rank: integer {0..3})
                                       => integer {0..65535}
begin
    let count = BundleWeightTLOADSelectedPECount(mask);
    let base = (valid_row DIVRM count) as integer {0..65535};
    let remainder = (valid_row MOD count) as integer {0..3};
    return (base + (if rank < remainder then 1 else 0))
        as integer {0..65535};
end;

pure func BundleWeightTLOADRowStartForRank(
    n_start: integer {0..4294967295}, valid_row: integer {1..65535},
    mask: bits(4), rank: integer {0..3}) => integer
begin
    var result: integer = n_start;
    for previous = 0 to 2 looplimit 3 do
        if previous < rank then
            result = result + BundleWeightTLOADRowsForRank(
                valid_row, mask, previous);
        end;
    end;
    return result;
end;

pure func BundleWeightTLOADFirstPE(mask: bits(4)) => integer {0..3}
begin
    for pe = 0 to 3 looplimit 4 do
        if mask[PTOPEMaskBitOfPEIdentity(pe as MemoryAgentId)] == '1' then
            return pe as integer {0..3};
        end;
    end;
    return 0;
end;

pure func BundleWeightTLOADLastPE(mask: bits(4)) => integer {0..3}
begin
    var result: integer {0..3} = 0;
    for pe = 0 to 3 looplimit 4 do
        if mask[PTOPEMaskBitOfPEIdentity(pe as MemoryAgentId)] == '1' then
            result = pe as integer {0..3};
        end;
    end;
    return result;
end;
