# ADDTPC

Execute the ADDTPC scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/ADDTPC.asl -->

## Assembly

```asm
addtpc simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/ADDTPC.asl -->
```asl
readonly func InstructionContractOperation_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_ADDTPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/ADDTPC.asl -->
```asl
readonly func InstructionContractHandler_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
