# HL.SWI.U

Execute the HL.SWI.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SWI.U.asl -->

## Assembly

```asm
hl.swi.u SrcD, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI_U() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
