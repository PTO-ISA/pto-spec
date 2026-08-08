<!-- GENERATED FROM: asl/tile/memory/regular/TLOAD.asl -->
# TLOAD

**Normative ASL source:** `asl/tile/memory/regular/TLOAD.asl`

Execute the TLOAD Tile operation contract.

## Normative identity {#PTO-INST-TILE-TLOAD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TLOAD <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TLOAD | TLSU |  | 0 |  | TLOAD |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory/regular/TLOAD.asl -->
```asl
readonly func InstructionContractOperation_TLOAD() => TileOperation
begin
    return TileOperation_TLOAD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
# Local form
BSTART.TLSU TLOAD
B.DATR/B.DIM
B.IOT
B.IOR
BSTOP
# Shared form
BSTART.TLSU TLOAD
B.DATR/B.DIM
B.IOS
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory/regular/TLOAD.asl -->
```asl
pure func InstructionContractDestinationShapeLegal_TLOAD(
    size_code: integer {1..7}, columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    return TileDescriptorShapeLegal(TileSizeCodeBytes(size_code), columns,
        valid_rows, valid_columns, data_type);
end;

readonly func InstructionContractHandler_TLOAD() => TileSemanticHandler
begin
    return TileHandler_TLOAD;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->
Both Local (`B.IOT`) and Shared (`B.IOS`) destination forms use LB0 as valid
columns, LB1 as valid rows, and LB2 as physical Col. The embedded shape helper
checks the same per-PE TSize/Col/dtype derivation for both forms before memory
probing. An explicit B.IOR supplies base and row stride; omission uses base zero
and LB2 as the dense row stride, while an encoded zero stride remains zero.
<!-- SUPPLEMENTARY-END -->
