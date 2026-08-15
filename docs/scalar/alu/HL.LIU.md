<!-- GENERATED FROM: asl/scalar/alu/HL.LIU.asl -->
# HL.LIU

**Normative ASL source:** `asl/scalar/alu/HL.LIU.asl`

HL.LIU zero-extends its split encoded 32-bit immediate to XLEN and publishes the result through RegDst.

## Normative identity {#PTO-INST-SCALAR-HL-LIU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.liu uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_liu_48_9dd207ce3aea | HL48 | 48 | 0x0000001d000e / 0x0000007f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_liu_48_9dd207ce3aea | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_liu_48_9dd207ce3aea | uimm32 | 32 | unsigned | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_liu_48_9dd207ce3aea | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_liu_48_9dd207ce3aea | uimm32 | 32 | 0–4294967295 | none | none | unsigned split 32-bit immediate | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| uimm32 | unsigned split 32-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LIU.asl -->
```asl
readonly func InstructionContractOperation_HL_LIU() => ScalarOperation
begin
    return ScalarOperation_HL_LIU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LIU.asl -->
```asl
readonly func InstructionContractHandler_HL_LIU() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongUnsigned;
end;

pure func InstructionContractResult_HL_LIU(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongUnsigned(encoded_immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Reassemble uimm32 from its two encoded pieces and zero-fill result bits 63:32.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- hl.liu uimm, ->{t, u, rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
