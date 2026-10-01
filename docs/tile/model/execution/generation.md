<!-- GENERATED FROM: asl/tile/model/execution/generation.asl -->
# Generation

**Normative ASL source:** `asl/tile/model/execution/generation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-GENERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-generation-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the Tile operations that create values without reading a source Tile. `TCI` writes an integer index sequence into a one-row RowMajor Tile. `TCICube` writes a two-dimensional index pattern into a CUBE_M16 or CUBE_M32 Tile. `TTRI` writes a triangular mask of typed ones and zeros.

It also owns the type sets for these operations: `TileTCIDataTypeSupported` accepts S32, S16, U32, and U16, and `TileTTRIDataTypeSupported` adds FP32 and FP16.

<!-- PTO-READER-BLOCK: tile-model-execution-generation-concepts role=concepts-state -->
## Concepts and visible state

The only state these helpers change is the destination `TileInfo`: its payload, its per-element definedness, `defined_valid_elements`, and `contents_defined`. Each helper builds the result in a local copy and assigns `_Tiles` once at the end.

A start value arrives in a scalar register. `TileRawElementValue` keeps only the low bits that fit the element width, and each generated value is normalized the same way. Integer sequences therefore wrap modulo the element width.

`TTRI` compares each column `c` with `r + diagonal`, where `r` is the row. Lower orientation selects `c <= r + diagonal`; upper orientation selects `c >= r + diagonal`. Selected elements receive the typed one from `TileTTRIOneEncoding`, for example `0x3f800000` for FP32; other valid elements receive zero.

<!-- PTO-READER-BLOCK: tile-model-execution-generation-rules role=rules-interactions -->
## Rules and interactions

`TCI` asserts `valid_rows == 1` and writes column `k` as `start + k`, or `start - k` when descending.

`TCICube` takes a packed Step2D word. Bits 63 to 32 give the row step and bits 31 to 0 give the column step, and each step must be -1, 0, or 1. Element (row, column) receives `start + row x row_step + column x column_step`, normalized to the element width.

`TCICube` is the only helper here that consults the ExecutionMask. An active coordinate receives the generated value. An inactive coordinate receives `BundleExecutionMaskDestinationValue`: zero under ZERO, or the old value of the merge base under MERGE.

All three helpers call `TileWithValidRegionDefined` and then `TileWithPadding` with `TilePad_Null`. They do not use the bundle PadValue.

Design point: generation always pads with Null. The TCI and TTRI B.DATR contracts require the pad field to be zero, so these instructions carry no PadValue. Null writes a zero carrier outside the valid region but leaves those elements undefined, so a later definedness check does not treat them as generated data.

Design point: the arithmetic is raw carrier arithmetic followed by truncation. A U16 ascending sequence that passes 65535 continues at 0 instead of faulting or saturating.

<!-- PTO-READER-BLOCK: tile-model-execution-generation-boundaries role=boundaries -->
## Architectural boundaries

Bundle dispatch in [Tile execution](../../../block/model/dispatch/tile-execution.md) selects `TCICube` when the operation is TCI and the current bundle layout is CUBE_M16 or CUBE_M32. It checks `TileOperandsLegal_TCICube` first and raises `Fault_TileLegality` without calling the helper if that check fails. Other TCI forms reach `TCI` through the generated instruction handler.

`TTRI` does not call `BundleExecutionMaskActiveAt`. The [ExecutionMask source schema](../legality/execution-mask-source-schema.md) states that TTRI is RowMajor-only and has no applicable ExecutionMask form, so a mask carrier on TTRI must be rejected before effects. The executable list `TileOperationExecutionMaskEligible` nevertheless still names TTRI.

`TCI` and `TTRI` assert their preconditions. The legality predicates that turn a bad request into a fault are evaluated before these helpers run: `TileOperandsLegal_TCICube` is defined in this unit and called by bundle dispatch, and `TileOperandsLegal_TCI` and `TileOperandsLegal_TTRI` are defined in [operand schema legality](../legality/operand-schema.md).

<!-- PTO-READER-BLOCK: tile-model-execution-generation-example role=example-usage -->
## Non-normative reading example

A U16 `TCI` destination has one row and 4 valid columns. The start register holds `0x1fffe` and the direction is ascending.

1. `TileRawElementValue` keeps the low 16 bits, so the start is 65534.
2. Columns 0 to 3 receive 65534, 65535, 0, and 1. The third value is 65536 truncated to 16 bits.
3. The 4 valid elements become defined. Physical elements outside the valid region hold zero but stay undefined because the padding is Null.

A FP32 `TTRI` destination with 3 valid rows, 4 valid columns, lower orientation, and diagonal 0 holds these values, with 1 meaning `0x3f800000`:

```text
row 0: 1 0 0 0
row 1: 1 1 0 0
row 2: 1 1 1 0
```

<!-- PTO-READER-BLOCK: tile-model-execution-generation-related role=related-owners-navigation -->
## Related owners

- [TCI](../../irregular-and-complex/initialization/TCI.md) and [TTRI](../../irregular-and-complex/initialization/TTRI.md) own the instruction contracts.
- [Irregular and complex dispatch](../dispatch/irregular-and-complex.md) names the instruction class that contains TCI and TTRI; it has no executable ASL.
- [ExecutionMask state](execution-mask-state.md) defines `BundleExecutionMaskActiveAt` and the inactive-value rule.
- [Element definedness](../definedness/elements.md) defines `TileWithValidRegionDefined` and `TileWithPadding`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/generation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-GENERATION","surface":"tile","classification":["model","execution","generation"],"depends_on":["PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"]}
// PTO-REQ-TEPL-GENERATE-001: generated sequences, masks, and padding.

pure func TileTCIDataTypeSupported(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16;
end;

pure func TileTTRIDataTypeSupported(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16;
end;

pure func TileTTRIOneEncoding(data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} + 0x3f800000;
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} + 0x3c00;
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x3f80;
        otherwise =>
            return Zeros{PTO_XLEN} + 1;
    end;
end;

func TCI(destination: TileIndex, start: Word, descending: boolean)
begin
    var result = _Tiles[[destination]];
    assert result.allocated;
    assert result.valid_rows == 1;
    assert TileTCIDataTypeSupported(result.data_type);
    let normalized_start = TileRawElementValue(
        start,
        result.data_type);
    for column = 0 to result.valid_columns - 1 looplimit 65536 do
        let element = TileLogicalLinearIndex(
            result,
            0,
            column as integer {0..65535});
        let offset = NaturalToWord(column as integer {0..65535});
        let value = if descending then
            normalized_start - offset
        else
            normalized_start + offset;
        result = TileInfoWithLogicalElement(result, element,
            TileRawElementValue(
            value,
            result.data_type));
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

readonly func TileOperandsLegal_TCICube(destination: TileIndex, start: Word, step2d: Word) => boolean
begin
    let tile = _Tiles[[destination]];
    let row_step = SInt(step2d[63:32]); let column_step = SInt(step2d[31:0]);
    return TileCubeDescriptorLegal(tile) && TileTCIDataTypeSupported(tile.data_type) &&
           tile.storage_kind == TileStorage_Numeric &&
           (tile.layout == TileLayout_CUBE_M16 || tile.layout == TileLayout_CUBE_M32) &&
           tile.valid_rows >= 1 && tile.valid_columns >= 1 &&
           (row_step == -1 || row_step == 0 || row_step == 1) &&
           (column_step == -1 || column_step == 0 || column_step == 1);
end;
func TCICube(destination: TileIndex, start: Word, step2d: Word)
begin
    var result = _Tiles[[destination]];
    assert result.allocated;
    assert (result.layout == TileLayout_CUBE_M16 ||
            result.layout == TileLayout_CUBE_M32);
    assert result.valid_rows >= 1 && result.valid_columns >= 1;
    assert TileTCIDataTypeSupported(result.data_type);
    let row_step = SInt(step2d[63:32]);
    let column_step = SInt(step2d[31:0]);
    assert (row_step == -1 || row_step == 0 || row_step == 1) &&
           (column_step == -1 || column_step == 0 || column_step == 1);
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let row_offset = if row_step == -1 then
                    Zeros{PTO_XLEN} - NaturalToWord(
                        row as integer {0..65535})
                else if row_step == 1 then
                    NaturalToWord(row as integer {0..65535})
                else
                    Zeros{PTO_XLEN};
                let column_offset = if column_step == -1 then
                    Zeros{PTO_XLEN} - NaturalToWord(
                        column as integer {0..65535})
                else if column_step == 1 then
                    NaturalToWord(column as integer {0..65535})
                else
                    Zeros{PTO_XLEN};
                result = TileInfoWithLogicalElement(result, element,
                    TileRawElementValue(
                        start + row_offset + column_offset,
                        result.data_type));
            else
                result = TileInfoWithLogicalElement(result, element,
                    BundleExecutionMaskDestinationValue(
                        result.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN}));
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TTRI(destination: TileIndex, upper: boolean,
          diagonal: integer {-65535..65535})
begin
    var result = _Tiles[[destination]];
    assert result.allocated;
    assert result.valid_rows >= 1;
    assert result.valid_columns >= 1;
    assert TileTTRIDataTypeSupported(result.data_type);
    let one = TileTTRIOneEncoding(result.data_type);
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let boundary: integer = row + diagonal;
            let selected = if upper then
                column >= boundary
            else
                column <= boundary;
            let element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element,
                if selected then
                one
            else
                Zeros{PTO_XLEN});
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
