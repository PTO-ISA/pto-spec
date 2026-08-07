# SETC.ORI

Execute the SETC.ORI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/SETC.ORI.asl -->

## Assembly

```asm
setc.ori SrcL, simm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.ORI.asl -->
```asl
readonly func InstructionContractOperation_SETC_ORI() => ScalarOperation
begin
    return ScalarOperation_SETC_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.ORI.asl -->
```asl
readonly func InstructionContractHandler_SETC_ORI() => ScalarSemanticHandler
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
