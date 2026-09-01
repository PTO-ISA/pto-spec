<!-- GENERATED FROM: asl/tile/model/execution/predicate-carriers.asl -->
# Predicate Carriers

**Normative ASL source:** `asl/tile/model/execution/predicate-carriers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/predicate-carriers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","surface":"tile","classification":["model","execution","predicate-carriers"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-STATE-ALLOCATION","PTO-TILE-MODEL-SHAPE-CUBE-CELL"]}
// PTO-REQ-TEPL-PREDICATE-CARRIER-001: CUBE predicate carrier layouts.

pure func TileCubePredicateGPRBit(
    low: Word, high: Word, layout: TileLayout,
    row: integer {0..65535}, column: integer {0..65535}) => boolean
begin
    let rows = TileCubePredicateRowBits(layout);
    assert row < rows && column * rows < 128;
    let packed_index = (row + column * rows) as integer {0..127};
    if packed_index < 64 then return low[packed_index] == '1'; end;
    return high[packed_index - 64] == '1';
end;

readonly func TileOperandsLegal_ExecuteTileCompareCUBEScalarGPR(
    source: TileIndex, scalar: Word) => boolean
begin
    let tile = _Tiles[[source]];
    if !TileCubeNumericSourceLegal(source) ||
       !TileCubePredicateGPRDataTypeSupported(tile.data_type) ||
       !TileCubePredicateGPRShapeLegal(source) then
        return FALSE;
    end;
    return TileNumericEncodingValid(
        tile.data_type, TileRawElementValue(scalar, tile.data_type));
end;

func TileCompareCUBEScalarToGPR(source: TileIndex, scalar: Word,
                                comparison: TileComparison,
                                high: boolean) => Word
begin
    assert TileOperandsLegal_ExecuteTileCompareCUBEScalarGPR(source, scalar);
    let tile = _Tiles[[source]];
    let normalized_scalar = TileRawElementValue(scalar, tile.data_type);
    let rows = TileCubePredicateRowBits(tile.layout);
    let fields = TileCubePredicateFieldCount(tile.data_type, tile.layout);
    let base = TileCubePredicateColumnBase(tile.data_type, tile.layout, high);
    var result = TilePredicateGPRPaddingValue();
    var flags = Zeros{5};
    for field = 0 to fields - 1 looplimit 8 do
        let column = base + field;
        if column < tile.valid_columns then
            for row = 0 to rows - 1 looplimit 32 do
                if row < tile.valid_rows then
                    let element = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let (predicate, element_flags) = TileCompareElement(
                        comparison, tile.data_type,
                        TileReadLogicalElement(tile, element),
                        normalized_scalar);
                    flags = flags OR element_flags;
                    result[row + field * rows] = if predicate then '1' else '0';
                end;
            end;
        end;
    end;
    RecordNumericStatusFlags(flags);
    return result;
end;

func ExecuteTileSelectCUBEGPR(destination: TileIndex, mask_low: Word,
                              mask_high: Word, source_true: TileIndex,
                              source_false: TileIndex)
begin
    let true_tile = _Tiles[[source_true]];
    var result = _Tiles[[destination]];
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let selected = TileCubePredicateGPRBit(
                mask_low, mask_high, true_tile.layout,
                row as integer {0..65535}, column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element,
                if selected then TileReadLogicalElement(true_tile, element)
                else TileReadLogicalElement(_Tiles[[source_false]], element));
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;

func ExecuteTileSelectScalarCUBEGPR(destination: TileIndex, mask_low: Word,
                                    mask_high: Word, source_true: TileIndex,
                                    scalar_false: Word)
begin
    let true_tile = _Tiles[[source_true]];
    let normalized_scalar = TileRawElementValue(scalar_false,
        true_tile.data_type);
    var result = _Tiles[[destination]];
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let selected = TileCubePredicateGPRBit(
                mask_low, mask_high, true_tile.layout,
                row as integer {0..65535}, column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element,
                if selected then TileReadLogicalElement(true_tile, element)
                else normalized_scalar);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;


pure func TileTGPR2TEncodingLegal(mask: integer, match: integer) => boolean
begin
    return mask == 0x000fffff && match == 0x07e19181;
end;

pure func TileTGPR2TRModeLegal(raw_rmode: bits(3)) => boolean
begin
    return raw_rmode[2] == '0';
end;

pure func TileTGPR2TByteOffset(raw_rmode: bits(3)) => integer {0..3}
begin
    assert TileTGPR2TRModeLegal(raw_rmode);
    return UInt(raw_rmode[1:0]) as integer {0..3};
end;

readonly func TileTGPR2TEffectivePadValue() => TilePadValue
begin
    return if _BundleDataAttributesPresent then CurrentBundlePadValue()
        else TilePad_Zero;
end;

readonly func TileTGPR2TPadLegal() => boolean
begin
    let pad = TileTGPR2TEffectivePadValue();
    return pad == TilePad_Zero || pad == TilePad_Max;
end;

pure func TileTGPR2TPredicateBit(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    plane: integer {0..15}, row: integer {0..31}) => bit
begin
    // M32 packs two 32-bit predicate planes per complete 64-bit GPR.
    assert row < 32;
    let word = plane DIVRM 2;
    let half = plane MOD 2;
    let within = half * 32 + row;
    if word == 0 then return gpr0[within]; end;
    if word == 1 then return gpr1[within]; end;
    if word == 2 then return gpr2[within]; end;
    return gpr3[within];
end;

pure func TileTGPR2TPredicateBitM16(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    plane: integer {0..15}, row: integer {0..15}) => bit
begin
    // M16 packs four 16-bit predicate planes per complete 64-bit GPR.
    let word = plane DIVRM 4;
    let quarter = plane MOD 4;
    let within = quarter * 16 + row;
    if word == 0 then return gpr0[within]; end;
    if word == 1 then return gpr1[within]; end;
    if word == 2 then return gpr2[within]; end;
    return gpr3[within];
end;

pure func TileTGPR2TPackedRowByte(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    row: integer {0..31}) => bits(8)
begin
    var result = Zeros{8};
    for bit_index = 0 to 7 looplimit 8 do
        result[bit_index] = TileTGPR2TPredicateBit(
            gpr0, gpr1, gpr2, gpr3, bit_index as integer {0..15}, row);
    end;
    return result;
end;

pure func TileTGPR2TPackedRowHalf(
    gpr0: Word, gpr1: Word, gpr2: Word, gpr3: Word,
    row: integer {0..15}, high: boolean) => bits(8)
begin
    var result = Zeros{8};
    let plane_base = if high then 8 else 0;
    for bit_index = 0 to 7 looplimit 8 do
        let plane = (plane_base + bit_index) as integer {0..15};
        result[bit_index] = TileTGPR2TPredicateBitM16(
            gpr0, gpr1, gpr2, gpr3, plane, row);
    end;
    return result;
end;

readonly func TileOperandsLegal_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex) => boolean
begin
    if source0 >= PTO_ABSOLUTE_GPR_COUNT ||
       source1 >= PTO_ABSOLUTE_GPR_COUNT ||
       source2 >= PTO_ABSOLUTE_GPR_COUNT ||
       source3 >= PTO_ABSOLUTE_GPR_COUNT ||
       !TileCubeDescriptorLegal(_Tiles[[destination]]) ||
       _Tiles[[destination]].storage_kind != TileStorage_Numeric ||
       _Tiles[[destination]].data_type != TileDataType_U8 ||
       !TileLayoutIsCube(_Tiles[[destination]].layout) ||
       !TileTGPR2TRModeLegal(_BundleDataAttributes.rounding_mode) ||
       !TileTGPR2TPadLegal() then
        return FALSE;
    end;
    let tile = _Tiles[[destination]];
    return (tile.layout == TileLayout_CUBE_M32 &&
            tile.valid_rows == 32 && tile.valid_columns == 4) ||
           (tile.layout == TileLayout_CUBE_M16 &&
            tile.valid_rows == 16 && tile.valid_columns == 8);
end;

func TGPR2T(destination: TileIndex, source0: TileIndex, source1: TileIndex,
            source2: TileIndex, source3: TileIndex)
begin
    assert TileOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
    let gpr0 = ReadGPR(source0 as GPRIndex);
    let gpr1 = ReadGPR(source1 as GPRIndex);
    let gpr2 = ReadGPR(source2 as GPRIndex);
    let gpr3 = ReadGPR(source3 as GPRIndex);
    let selected_pad = TileTGPR2TEffectivePadValue();
    var result = TileWithPadding(_Tiles[[destination]], selected_pad);
    let pad = TilePadValueForDataType(selected_pad,
        result.data_type);
    for row = 0 to result.valid_rows - 1 looplimit 32 do
        for column = 0 to result.valid_columns - 1 looplimit 8 do
            let index = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            result.payload[[index]] = pad;
        end;
    end;
    let offset = TileTGPR2TByteOffset(
        _BundleDataAttributes.rounding_mode);
    if result.layout == TileLayout_CUBE_M32 then
        for row = 0 to 31 looplimit 32 do
            let index = TileLogicalLinearIndex(result,
                row as integer {0..65535}, offset);
            var value = Zeros{PTO_XLEN};
            value[7:0] = TileTGPR2TPackedRowByte(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..31});
            result.payload[[index]] = value;
        end;
    else
        for row = 0 to 15 looplimit 16 do
            let pair_start = (offset * 2) as integer {0..6};
            let low = TileLogicalLinearIndex(result,
                row as integer {0..65535}, pair_start);
            let high = TileLogicalLinearIndex(result,
                row as integer {0..65535}, pair_start + 1);
            var low_value = Zeros{PTO_XLEN};
            low_value[7:0] = TileTGPR2TPackedRowHalf(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..15}, FALSE);
            result.payload[[low]] = low_value;
            var high_value = Zeros{PTO_XLEN};
            high_value[7:0] = TileTGPR2TPackedRowHalf(
                gpr0, gpr1, gpr2, gpr3, row as integer {0..15}, TRUE);
            result.payload[[high]] = high_value;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
