# SETRET

Execute the SETRET scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETRET.asl -->

## Assembly

```asm
setret uimm, ->Ra
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETRET.asl -->
```asl
readonly func InstructionContractOperation_SETRET() => ScalarOperation
begin
    return ScalarOperation_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETRET.asl -->
```asl
readonly func InstructionContractHandler_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
