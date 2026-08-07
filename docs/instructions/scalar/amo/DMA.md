# DMA

Execute the DMA scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/DMA.asl -->

## Normative identity {#PTO-INST-SCALAR-DMA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
dma [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dma_32_a168aeca5fa5 | L32 | 32 | 0x0000700b / 0xfe007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dma_32_a168aeca5fa5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| dma_32_a168aeca5fa5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/DMA.asl -->
```asl
readonly func InstructionContractOperation_DMA() => ScalarOperation
begin
    return ScalarOperation_DMA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/DMA.asl -->
```asl
readonly func InstructionContractHandler_DMA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDMACopy64;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
