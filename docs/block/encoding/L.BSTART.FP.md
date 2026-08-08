<!-- GENERATED FROM: asl/block/encoding/L.BSTART.FP.asl -->
# L.BSTART.FP

**Normative ASL source:** `asl/block/encoding/L.BSTART.FP.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-L-BSTART-FP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
L.BSTART.FP COND, <label>
L.BSTART.FP DIRECT, <label>
L.BSTART.FP CALL, <label>
L.BSTART.FP FALL<, fixup_label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| l_bstart_fp_64_098e57019d7b | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_fp_64_098e57019d7b | L64 | 32 | 0x00003081 / 0x00007fff | [] |
| l_bstart_fp_64_0cac9941f7d4 | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_fp_64_0cac9941f7d4 | L64 | 32 | 0x00002081 / 0x00007fff | [] |
| l_bstart_fp_64_2067ad6667ed | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_fp_64_2067ad6667ed | L64 | 32 | 0x00004081 / 0x00007fff | [] |
| l_bstart_fp_64_8115c042ef26 | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_fp_64_8115c042ef26 | L64 | 32 | 0x00001081 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| l_bstart_fp_64_098e57019d7b | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |
| l_bstart_fp_64_0cac9941f7d4 | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |
| l_bstart_fp_64_2067ad6667ed | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |
| l_bstart_fp_64_8115c042ef26 | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/L.BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_L_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_l_bstart_fp_64_098e57019d7b) ||
           (operation == CommandOperation_l_bstart_fp_64_0cac9941f7d4) ||
           (operation == CommandOperation_l_bstart_fp_64_2067ad6667ed) ||
           (operation == CommandOperation_l_bstart_fp_64_8115c042ef26);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/L.BSTART.FP.asl -->
```asl
readonly func InstructionContractHandler_L_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.`
- **Semantic handler:** `ExecuteBundleStart`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
