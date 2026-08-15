<!-- GENERATED FROM: asl/scalar/sys/ACRC.asl -->
# ACRC

**Normative ASL source:** `asl/scalar/sys/ACRC.asl`

ACRC requests context close and marks the final scalar position of the active SYS block.

## Normative identity {#PTO-INST-SCALAR-ACRC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
acrc rst_type
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| acrc_32_a9c0e33f9904 | L32 | 32 | 0x0000302b / 0xff0fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| acrc_32_a9c0e33f9904 | RST_Type | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| acrc_32_a9c0e33f9904 | RST_Type | 4 | 0–15 | none | none | return-stack record type | Encoded zero selects value zero of the return-stack record type. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RST_Type | return-stack record type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractOperation_ACRC()
    => ScalarOperation
begin
    return ScalarOperation_ACRC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
ACRC executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractHandler_ACRC()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureCloseRequest;
end;

pure func InstructionContractRequiresSystemBlock_ACRC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRequestWidth_ACRC()
    => integer {4}
begin
    return 4;
end;

pure func InstructionContractIsTerminalScalar_ACRC()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- All four-bit request values are encoded; manager routing and current-ACR permission determine instruction-local acceptance.

## State effects

- A permitted request publishes the service-request trap, request type, and architecture-request epoch.
- After recovery, only BSTOP or a following BSTART may commit the block; another instruction raises Illegal Block Exception before effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Preflight request routing before setting the terminal marker or entering the service-request trap.
- On permission success, set the SYS terminal marker before trap entry so recovery preserves the final-position rule.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- acrc rst_type

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
