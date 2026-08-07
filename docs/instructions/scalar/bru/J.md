# J

Execute the J scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/J.asl -->

## Assembly

```asm
j label
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/J.asl -->
```asl
readonly func InstructionContractOperation_J() => ScalarOperation
begin
    return ScalarOperation_J;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/J.asl -->
```asl
readonly func InstructionContractHandler_J() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRelative;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
