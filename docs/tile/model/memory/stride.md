<!-- GENERATED FROM: asl/tile/model/memory/stride.asl -->
# Stride

**Normative ASL source:** `asl/tile/model/memory/stride.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-STRIDE}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/stride.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-STRIDE","surface":"tile","classification":["model","memory","stride"],"depends_on":["PTO-TILE-MODEL-MEMORY-ADDRESSING"]}
readonly func TileMemoryStridedIndex(row: integer {0..65535},
                                     column: integer {0..65535},
                                     row_stride_elements: Word) => Word
begin
    return MultiplyWord(NaturalToWord(row as integer {0..262144}),
                        row_stride_elements) +
           NaturalToWord(column as integer {0..262144});
end;

pure func TileDenseRowStrideBytes(columns: integer {0..65535},
                                  data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        let packed_bytes = ((columns + 1) DIVRM 2) as integer {0..32768};
        return NaturalToWord(packed_bytes as integer {0..262144});
    else
        return MultiplyWord(
            NaturalToWord(columns as integer {0..262144}),
            NaturalToWord(TileElementBytes(data_type) as
                integer {0..262144}));
    end;
end;

readonly func TileMemoryStridedByteAddress(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_bytes: Word,
    data_type: TileDataType) => Word
begin
    let row_base = base_address + MultiplyWord(
        NaturalToWord(row as integer {0..262144}), row_stride_bytes);
    if TileDataTypeIsFourBit(data_type) then
        return row_base + NaturalToWord(
            (column DIVRM 2) as integer {0..262144});
    else
        return row_base + MultiplyWord(
            NaturalToWord(column as integer {0..262144}),
            NaturalToWord(TileElementBytes(data_type) as
                integer {0..262144}));
    end;
end;

pure func TileMemoryStridedByteHighNibble(
    column: integer {0..65535}, data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && column MOD 2 == 1;
end;
```
<!-- GENERATED-ASL-END: unit -->
