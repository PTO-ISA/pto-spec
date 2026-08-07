# SRL

Execute the SRL scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SRL.asl -->

## Assembly

```asm
srl SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractOperation_SRL() => ScalarOperation
begin
    return ScalarOperation_SRL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractHandler_SRL() => ScalarSemanticHandler
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
