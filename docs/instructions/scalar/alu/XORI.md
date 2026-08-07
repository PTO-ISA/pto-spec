# XORI

Execute the XORI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/XORI.asl -->

## Assembly

```asm
xori SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XORI.asl -->
```asl
readonly func InstructionContractOperation_XORI() => ScalarOperation
begin
    return ScalarOperation_XORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XORI.asl -->
```asl
readonly func InstructionContractHandler_XORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
