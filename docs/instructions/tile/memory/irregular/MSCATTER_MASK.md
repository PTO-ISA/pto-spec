# MSCATTER_MASK

Execute the MSCATTER_MASK Tile operation contract.

<!-- ASL-SOURCE: asl/tile/memory/irregular/MSCATTER_MASK.asl -->

## Assembly

```asm
MSCATTER_MASK <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER_MASK() => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.MSCATTER.MASK DataType
B.IOT
B.IOR base_address
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_MASK() => TileSemanticHandler
begin
    return TileHandler_MSCATTER_MASK;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
