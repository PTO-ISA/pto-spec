<!-- GENERATED FROM: asl/block/encoding/L.BSTART.STD.asl -->
# L.BSTART.STD

**Normative ASL source:** `asl/block/encoding/L.BSTART.STD.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-L-BSTART-STD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
L.BSTART.STD DIRECT, <label>
L.BSTART.STD CALL, <label>
L.BSTART.STD COND, <label>
L.BSTART.STD FALL<, fixup_label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| l_bstart_std_64_37e84068ce61 | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_std_64_37e84068ce61 | L64 | 32 | 0x00002001 / 0x00007fff | [] |
| l_bstart_std_64_463a1567da91 | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_std_64_463a1567da91 | L64 | 32 | 0x00004001 / 0x00007fff | [] |
| l_bstart_std_64_72d502fcd30d | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_std_64_72d502fcd30d | L64 | 32 | 0x00003001 / 0x00007fff | [] |
| l_bstart_std_64_899592f9c5bc | L64 | 32 | 0x0000000f / 0x0000007f | [] |
| l_bstart_std_64_899592f9c5bc | L64 | 32 | 0x00001001 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| l_bstart_std_64_37e84068ce61 | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |
| l_bstart_std_64_463a1567da91 | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |
| l_bstart_std_64_72d502fcd30d | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |
| l_bstart_std_64_899592f9c5bc | simm | 42 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/L.BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_L_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_l_bstart_std_64_37e84068ce61) ||
           (operation == CommandOperation_l_bstart_std_64_463a1567da91) ||
           (operation == CommandOperation_l_bstart_std_64_72d502fcd30d) ||
           (operation == CommandOperation_l_bstart_std_64_899592f9c5bc);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/L.BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_L_BSTART_STD() => CommandSemanticHandler
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
