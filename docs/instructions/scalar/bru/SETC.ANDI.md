# SETC.ANDI

Execute the SETC.ANDI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.ANDI.asl -->

## Assembly

```asm
setc.andi SrcL, simm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.ANDI.asl -->
```asl
readonly func InstructionContractOperation_SETC_ANDI() => ScalarOperation
begin
    return ScalarOperation_SETC_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.ANDI.asl -->
```asl
readonly func InstructionContractHandler_SETC_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
