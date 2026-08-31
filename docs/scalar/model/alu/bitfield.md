<!-- GENERATED FROM: asl/scalar/model/alu/bitfield.asl -->
# Bitfield

**Normative ASL source:** `asl/scalar/model/alu/bitfield.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-ALU-BITFIELD}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/alu/bitfield.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-ALU-BITFIELD","surface":"scalar","classification":["model","alu","bitfield"],"depends_on":["PTO-SCALAR-MODEL-TYPES-OPERANDS"]}

pure func InsertBitfield(base: Word, source: Word,
                         first: integer {0..63}, last: integer {0..63}) => Word
begin
    let width: integer = (((last - first) + 64) MOD 64) + 1;
    var result = base;
    for bit_index = 0 to width - 1 do
        let destination = ((first + bit_index) MOD 64) as integer {0..63};
        result[destination] = source[bit_index];
    end;
    return result;
end;

pure func InsertByteField(base: Word, source: Word,
                          byte_offset: integer {0..63},
                          byte_count: integer {1..64}) => Word
begin
    assert byte_offset <= 7;
    assert byte_count <= 8;
    let first = (byte_offset * 8) as integer {0..63};
    let last = ((((byte_offset + byte_count) * 8) - 1) MOD 64)
        as integer {0..63};
    return InsertBitfield(base, source, first, last);
end;
```
<!-- GENERATED-ASL-END: unit -->
