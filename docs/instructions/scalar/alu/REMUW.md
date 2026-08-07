# REMUW

Execute the REMUW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/REMUW.asl -->

## Assembly

```asm
remuw SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractOperation_REMUW() => ScalarOperation
begin
    return ScalarOperation_REMUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractHandler_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsignedW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
