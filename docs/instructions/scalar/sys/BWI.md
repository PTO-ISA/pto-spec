# BWI

Execute the BWI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/BWI.asl -->

## Assembly

```asm
bwi SrcL
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BWI.asl -->
```asl
readonly func InstructionContractOperation_BWI() => ScalarOperation
begin
    return ScalarOperation_BWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BWI.asl -->
```asl
readonly func InstructionContractHandler_BWI() => ScalarSemanticHandler
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
