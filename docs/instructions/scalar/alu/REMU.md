# REMU

Execute the REMU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/REMU.asl -->

## Assembly

```asm
remu SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMU.asl -->
```asl
readonly func InstructionContractOperation_REMU() => ScalarOperation
begin
    return ScalarOperation_REMU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMU.asl -->
```asl
readonly func InstructionContractHandler_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
