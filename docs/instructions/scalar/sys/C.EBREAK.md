# C.EBREAK

Execute the C.EBREAK scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/C.EBREAK.asl -->

## Assembly

```asm
c.break imm
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/C.EBREAK.asl -->
```asl
readonly func InstructionContractOperation_C_EBREAK() => ScalarOperation
begin
    return ScalarOperation_C_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/C.EBREAK.asl -->
```asl
readonly func InstructionContractHandler_C_EBREAK() => ScalarSemanticHandler
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
