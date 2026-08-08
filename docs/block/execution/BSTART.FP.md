<!-- GENERATED FROM: asl/block/execution/BSTART.FP.asl -->
# BSTART.FP

**Normative ASL source:** `asl/block/execution/BSTART.FP.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-FP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.FP RET
BSTART.FP ICALL
BSTART.FP COND, <label>
BSTART.FP IND
BSTART.FP DIRECT, <label>
BSTART.FP CALL, <label>
BSTART.FP FALL<, fixup_label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_fp_32_0c671a644214 | L32 | 32 | 0x00007101 / 0xffffffff | [] |
| bstart_fp_32_24db3966d6ba | L32 | 32 | 0x00006101 / 0xffffffff | [] |
| bstart_fp_32_58ad7954fb49 | L32 | 32 | 0x00003101 / 0x00007fff | [] |
| bstart_fp_32_7978795a29a1 | L32 | 32 | 0x00005101 / 0xffffffff | [] |
| bstart_fp_32_d00a708a81f0 | L32 | 32 | 0x00002101 / 0x00007fff | [] |
| bstart_fp_32_dd7bc8dd694c | L32 | 32 | 0x00004101 / 0x00007fff | [] |
| bstart_fp_32_face4f238d84 | L32 | 32 | 0x00001101 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_fp_32_58ad7954fb49 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_d00a708a81f0 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_dd7bc8dd694c | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_face4f238d84 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_fp_32_0c671a644214) ||
           (operation == CommandOperation_bstart_fp_32_24db3966d6ba) ||
           (operation == CommandOperation_bstart_fp_32_58ad7954fb49) ||
           (operation == CommandOperation_bstart_fp_32_7978795a29a1) ||
           (operation == CommandOperation_bstart_fp_32_d00a708a81f0) ||
           (operation == CommandOperation_bstart_fp_32_dd7bc8dd694c) ||
           (operation == CommandOperation_bstart_fp_32_face4f238d84);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractHandler_BSTART_FP() => CommandSemanticHandler
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
