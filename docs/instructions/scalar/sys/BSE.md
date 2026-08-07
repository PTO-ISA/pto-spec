# BSE

Execute the BSE scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/BSE.asl -->

## Assembly

```asm
bse SrcL
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractOperation_BSE() => ScalarOperation
begin
    return ScalarOperation_BSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractHandler_BSE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
