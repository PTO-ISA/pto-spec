// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-STRIDE","surface":"tile","classification":["model","memory","stride"],"depends_on":["PTO-TILE-MODEL-MEMORY-ADDRESSING"]}
readonly func TileMemoryStridedIndex(row: integer {0..65535},
                                     column: integer {0..65535},
                                     row_stride_elements: Word) => Word
begin
    return MultiplyWord(NaturalToWord(row as integer {0..262144}),
                        row_stride_elements) +
           NaturalToWord(column as integer {0..262144});
end;

