<!-- GENERATED FROM: asl/tile/model/memory/stride.asl -->
# Stride

**Normative ASL source:** `asl/tile/model/memory/stride.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-STRIDE}

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
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
