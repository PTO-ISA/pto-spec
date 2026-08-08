<!-- GENERATED FROM: asl/scalar/bru/SETC.LTU.asl -->
# SETC.LTU

**Normative ASL source:** `asl/scalar/bru/SETC.LTU.asl`

Execute the SETC.LTU scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-SETC-LTU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
setc.ltu SrcL, SrcR<{.sw, .uw}>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_ltu_32_4a1ff65ecafb | L32 | 32 | 0x00006065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_ltu_32_4a1ff65ecafb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_ltu_32_4a1ff65ecafb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_ltu_32_4a1ff65ecafb | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTU.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTU() => ScalarOperation
begin
    return ScalarOperation_SETC_LTU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTU.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
