# C.SETC.TGT

Execute the C.SETC.TGT scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/C.SETC.TGT.asl -->

## Assembly

```asm
c.setc.tgt srcL
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SETC.TGT.asl -->
```asl
readonly func InstructionContractOperation_C_SETC_TGT() => ScalarOperation
begin
    return ScalarOperation_C_SETC_TGT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SETC.TGT.asl -->
```asl
readonly func InstructionContractHandler_C_SETC_TGT() => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
