<!-- GENERATED FROM: asl/scalar/bru/HL.ADDTPC.asl -->
# HL.ADDTPC

**Normative ASL source:** `asl/scalar/bru/HL.ADDTPC.asl`

HL.ADDTPC - Add a signed 4 KiB page displacement to the current TPC.

## Normative identity {#PTO-INST-SCALAR-HL-ADDTPC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.addtpc imm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_addtpc_48_2e8e692eea09 | HL48 | 48 | 0x00000007000e / 0x0000007f000f | [{"field":"RegDst","operator":"not-equal","value":10}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_addtpc_48_2e8e692eea09 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_addtpc_48_2e8e692eea09 | imm32 | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_addtpc_48_2e8e692eea09 | RegDst | 5 | 0–9, 11–31 | none | 10 | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_addtpc_48_2e8e692eea09 | imm32 | 32 | 0–4294967295 | none | none | signed 32-bit 4 KiB page displacement | Encoded zero contributes a zero page displacement and produces the current instruction TPC. |

- `hl_addtpc_48_2e8e692eea09.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| imm32 | signed 32-bit 4 KiB page displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.ADDTPC.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_HL_ADDTPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.ADDTPC.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;

pure func InstructionContractUsesTPC_HL_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractImmediateWidth_HL_ADDTPC()
    => integer {32}
begin
    return 32;
end;

pure func InstructionContractImmediateIsSigned_HL_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPageShift_HL_ADDTPC()
    => integer {12}
begin
    return 12;
end;

pure func InstructionContractWritesTPC_HL_ADDTPC()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractTarget_HL_ADDTPC(
    base: Word,
    page_offset: Word)
    => Word
begin
    return base + LSL(page_offset, 12);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The imm32 field is sign-extended and scaled by 4096 bytes; encoded zero contributes a zero page displacement and produces the current instruction TPC.
- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- hl_addtpc_48_2e8e692eea09.RegDst excludes 10; the excluded encoding is reserved.

## State effects

- HL.ADDTPC writes TPC + (SignExtend(imm32) << 12), wrapping at XLEN, through the selected Reg5 destination.
- The instruction does not install a control-flow target and does not directly modify TPC.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Read the current instruction TPC before computing the wrapping XLEN result.
- After the destination effect, the scalar dispatch boundary advances TPC by six bytes.

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.addtpc imm, ->{t, u, Rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
