<!-- GENERATED FROM: asl/scalar/sys/SSRGET.asl -->
# SSRGET

**Normative ASL source:** `asl/scalar/sys/SSRGET.asl`

SSRGET reads the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ssrget SSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ssrget_32_959957ab6b75 | L32 | 32 | 0x0000003b / 0x000ff07f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ssrget_32_959957ab6b75 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ssrget_32_959957ab6b75 | SSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ssrget_32_959957ab6b75 | RegDst | 5 | 0–31 | none | none | Reg5 destination: discard, R1..R23, push U, or push T | Encoded zero names the architectural zero GPR. |
| ssrget_32_959957ab6b75 | SSR_ID | 12 | 0–4095 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination: discard, R1..R23, push U, or push T |
| SSR_ID | system-register identifier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractOperation_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
SSRGET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractHandler_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_SSRGET()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRGET()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.

## State effects

- Read the complete XLEN system-register value and publish it through the common Reg5 destination mapping.
- A rejected read preserves the destination and queue state except for ordinary trap entry.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- ssrget SSR_ID, ->{t, u, Rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
