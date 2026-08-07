# EBREAK

Execute the EBREAK scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/EBREAK.asl -->

## Assembly

```asm
ebreak imm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractOperation_EBREAK() => ScalarOperation
begin
    return ScalarOperation_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractHandler_EBREAK() => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
