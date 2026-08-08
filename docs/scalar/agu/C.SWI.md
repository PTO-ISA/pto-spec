<!-- GENERATED FROM: asl/scalar/agu/C.SWI.asl -->
# C.SWI

**Normative ASL source:** `asl/scalar/agu/C.SWI.asl`

Execute the C.SWI scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-C-SWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.swi t#1, [srcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_swi_16_ca6c111163e5 | C16 | 16 | 0x002a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_swi_16_ca6c111163e5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_swi_16_ca6c111163e5 | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.SWI.asl -->
```asl
readonly func InstructionContractOperation_C_SWI() => ScalarOperation
begin
    return ScalarOperation_C_SWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.SWI.asl -->
```asl
readonly func InstructionContractHandler_C_SWI() => ScalarSemanticHandler
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
