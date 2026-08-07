# ADDI

Execute the ADDI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/ADDI.asl -->

## Assembly

```asm
addi SrcL, uimm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADDI.asl -->
```asl
readonly func InstructionContractOperation_ADDI() => ScalarOperation
begin
    return ScalarOperation_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADDI.asl -->
```asl
readonly func InstructionContractHandler_ADDI() => ScalarSemanticHandler
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
