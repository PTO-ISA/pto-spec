<!-- GENERATED FROM: asl/arch/overview/encoding-ownership.asl -->
# Encoding Ownership

**Normative ASL source:** `asl/arch/overview/encoding-ownership.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/overview/encoding-ownership.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP","surface":"arch","classification":["overview","encoding-ownership"],"depends_on":["PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION"],"catalog_projection":{"catalog":"linx-vector-reservations","isa":"PTO Instruction Set Architecture","schema_version":1,"reservations":[{"encoding":[{"index":0,"mask":"0xf9ffffff","match":"0x00021181","width_bits":32}],"fields":[{"name":"Mode","pieces":[{"instruction_lsb":25,"part_index":0,"value_lsb":0,"width":2}],"width":2}],"length_bits":32,"mnemonic":"BSTART.VPAR","owner":"Linx ISA two-level vector extension","status":"reserved-in-pto"},{"encoding":[{"index":0,"mask":"0xf9ffffff","match":"0x00029181","width_bits":32}],"fields":[{"name":"Mode","pieces":[{"instruction_lsb":25,"part_index":0,"value_lsb":0,"width":2}],"width":2}],"length_bits":32,"mnemonic":"BSTART.VSEQ","owner":"Linx ISA two-level vector extension","status":"reserved-in-pto"},{"encoding":[{"index":0,"mask":"0x0000ffff","match":"0x000088c0","width_bits":16}],"fields":[],"length_bits":16,"mnemonic":"C.BSTART.VPAR","owner":"Linx ISA two-level vector extension","status":"reserved-in-pto"},{"encoding":[{"index":0,"mask":"0x0000ffff","match":"0x0000c8c0","width_bits":16}],"fields":[],"length_bits":16,"mnemonic":"C.BSTART.VSEQ","owner":"Linx ISA two-level vector extension","status":"reserved-in-pto"},{"encoding":[{"index":0,"mask":"0x0000007f","match":"0x0000007f","width_bits":32},{"index":1,"mask":"0x00000000","match":"0x00000000","width_bits":32}],"fields":[],"length_bits":64,"mnemonic":"V.*","owner":"Linx ISA two-level vector extension","status":"reserved-in-pto"}]}}

// NDF-BEGIN: PTO-ARCH-ENCODING-OWNERSHIP-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// PTO and Linx MUST assign identical encodings and semantics to every common
// scalar, block, and Tile instruction. Linx-only vector encodings MUST remain
// reserved to Linx and MUST NOT be assigned by a future PTO instruction.
// Permanently deleted instruction names are assembler errors, not reservations;
// their former slots MAY be assigned by an active common instruction.
// NDF-END: PTO-ARCH-ENCODING-OWNERSHIP-001

pure func LinxVectorRoot64Reserved(first_word: bits(32)) => boolean
begin
    return (first_word AND (Zeros{32} + 0x7f)) == Zeros{32} + 0x7f;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
