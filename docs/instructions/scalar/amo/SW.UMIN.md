# SW.UMIN

Execute the SW.UMIN scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SW.UMIN.asl -->

## Normative identity {#PTO-INST-SCALAR-SW-UMIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sw.umin<.{rl, f, rlf}> [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_umin_32_3ce114819cfc | L32 | 32 | 0x7000300b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_umin_32_3ce114819cfc | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_umin_32_3ce114819cfc | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_umin_32_3ce114819cfc | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sw_umin_32_3ce114819cfc | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.UMIN.asl -->
```asl
readonly func InstructionContractOperation_SW_UMIN() => ScalarOperation
begin
    return ScalarOperation_SW_UMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.UMIN.asl -->
```asl
readonly func InstructionContractHandler_SW_UMIN() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
