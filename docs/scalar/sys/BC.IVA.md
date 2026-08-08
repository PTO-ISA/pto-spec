<!-- GENERATED FROM: asl/scalar/sys/BC.IVA.asl -->
# BC.IVA

**Normative ASL source:** `asl/scalar/sys/BC.IVA.asl`

Execute the BC.IVA scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-BC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bc.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bc_iva_32_c166de534c98 | L32 | 32 | 0x0000402b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bc_iva_32_c166de534c98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BC.IVA.asl -->
```asl
readonly func InstructionContractOperation_BC_IVA() => ScalarOperation
begin
    return ScalarOperation_BC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BC.IVA.asl -->
```asl
readonly func InstructionContractHandler_BC_IVA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
